
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 34 01 00 00       	call   800165 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003e:	eb 43                	jmp    800083 <cat+0x50>
		if ((r = write(1, buf, n)) != n)
  800040:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800044:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80004b:	00 
  80004c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800053:	e8 bf 13 00 00       	call   801417 <write>
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 27                	je     800083 <cat+0x50>
			panic("write error copying %s: %e", s, r);
  80005c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800060:	8b 45 0c             	mov    0xc(%ebp),%eax
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 20 28 80 	movl   $0x802820,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 3b 28 80 00 	movl   $0x80283b,(%esp)
  80007e:	e8 43 01 00 00       	call   8001c6 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800083:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008a:	00 
  80008b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800092:	00 
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 9f 12 00 00       	call   80133a <read>
  80009b:	89 c3                	mov    %eax,%ebx
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f 9f                	jg     800040 <cat+0xd>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	79 27                	jns    8000cc <cat+0x99>
		panic("error reading %s: %e", s, n);
  8000a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 3b 28 80 00 	movl   $0x80283b,(%esp)
  8000c7:	e8 fa 00 00 00       	call   8001c6 <_panic>
}
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 5b 	movl   $0x80285b,0x803000
  8000e6:	28 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	74 07                	je     8000f6 <umain+0x23>
  8000ef:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f4:	eb 62                	jmp    800158 <umain+0x85>
		cat(0, "<stdin>");
  8000f6:	c7 44 24 04 5f 28 80 	movl   $0x80285f,0x4(%esp)
  8000fd:	00 
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 29 ff ff ff       	call   800033 <cat>
  80010a:	eb 51                	jmp    80015d <umain+0x8a>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80010c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800113:	00 
  800114:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800117:	89 04 24             	mov    %eax,(%esp)
  80011a:	e8 f4 16 00 00       	call   801813 <open>
  80011f:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	79 19                	jns    80013e <umain+0x6b>
				printf("can't open %s: %e\n", argv[i], f);
  800125:	89 44 24 08          	mov    %eax,0x8(%esp)
  800129:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800137:	e8 87 18 00 00       	call   8019c3 <printf>
  80013c:	eb 17                	jmp    800155 <umain+0x82>
			else {
				cat(f, argv[i]);
  80013e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e6 fe ff ff       	call   800033 <cat>
				close(f);
  80014d:	89 34 24             	mov    %esi,(%esp)
  800150:	e8 82 10 00 00       	call   8011d7 <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800155:	83 c3 01             	add    $0x1,%ebx
  800158:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80015b:	7c af                	jl     80010c <umain+0x39>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015d:	83 c4 1c             	add    $0x1c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800170:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800173:	e8 4d 0b 00 00       	call   800cc5 <sys_getenvid>
  800178:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 db                	test   %ebx,%ebx
  80018c:	7e 07                	jle    800195 <libmain+0x30>
		binaryname = argv[0];
  80018e:	8b 06                	mov    (%esi),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	89 74 24 04          	mov    %esi,0x4(%esp)
  800199:	89 1c 24             	mov    %ebx,(%esp)
  80019c:	e8 32 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 07 00 00 00       	call   8001ad <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b3:	e8 52 10 00 00       	call   80120a <close_all>
	sys_env_destroy(0);
  8001b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bf:	e8 af 0a 00 00       	call   800c73 <sys_env_destroy>
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001d7:	e8 e9 0a 00 00       	call   800cc5 <sys_getenvid>
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  8001f9:	e8 c1 00 00 00       	call   8002bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800202:	8b 45 10             	mov    0x10(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 51 00 00 00       	call   80025e <vcprintf>
	cprintf("\n");
  80020d:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800214:	e8 a6 00 00 00       	call   8002bf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800219:	cc                   	int3   
  80021a:	eb fd                	jmp    800219 <_panic+0x53>

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 14             	sub    $0x14,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800226:	8b 13                	mov    (%ebx),%edx
  800228:	8d 42 01             	lea    0x1(%edx),%eax
  80022b:	89 03                	mov    %eax,(%ebx)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800234:	3d ff 00 00 00       	cmp    $0xff,%eax
  800239:	75 19                	jne    800254 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800242:	00 
  800243:	8d 43 08             	lea    0x8(%ebx),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 e8 09 00 00       	call   800c36 <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800254:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800258:	83 c4 14             	add    $0x14,%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800267:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026e:	00 00 00 
	b.cnt = 0;
  800271:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800278:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 44 24 08          	mov    %eax,0x8(%esp)
  800289:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800293:	c7 04 24 1c 02 80 00 	movl   $0x80021c,(%esp)
  80029a:	e8 af 01 00 00       	call   80044e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	e8 7f 09 00 00       	call   800c36 <sys_cputs>

	return b.cnt;
}
  8002b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 87 ff ff ff       	call   80025e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    
  8002d9:	66 90                	xchg   %ax,%ax
  8002db:	66 90                	xchg   %ax,%ax
  8002dd:	66 90                	xchg   %ax,%ax
  8002df:	90                   	nop

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 c3                	mov    %eax,%ebx
  8002f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80030d:	39 d9                	cmp    %ebx,%ecx
  80030f:	72 05                	jb     800316 <printnum+0x36>
  800311:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800314:	77 69                	ja     80037f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800316:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031d:	83 ee 01             	sub    $0x1,%esi
  800320:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80032c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800330:	89 c3                	mov    %eax,%ebx
  800332:	89 d6                	mov    %edx,%esi
  800334:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800337:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80033a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80033e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 3c 22 00 00       	call   802590 <__udivdi3>
  800354:	89 d9                	mov    %ebx,%ecx
  800356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 fa                	mov    %edi,%edx
  800367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036a:	e8 71 ff ff ff       	call   8002e0 <printnum>
  80036f:	eb 1b                	jmp    80038c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	8b 45 18             	mov    0x18(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff d3                	call   *%ebx
  80037d:	eb 03                	jmp    800382 <printnum+0xa2>
  80037f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800382:	83 ee 01             	sub    $0x1,%esi
  800385:	85 f6                	test   %esi,%esi
  800387:	7f e8                	jg     800371 <printnum+0x91>
  800389:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800397:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 0c 23 00 00       	call   8026c0 <__umoddi3>
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	0f be 80 a7 28 80 00 	movsbl 0x8028a7(%eax),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c5:	ff d0                	call   *%eax
}
  8003c7:	83 c4 3c             	add    $0x3c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d2:	83 fa 01             	cmp    $0x1,%edx
  8003d5:	7e 0e                	jle    8003e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	8b 52 04             	mov    0x4(%edx),%edx
  8003e3:	eb 22                	jmp    800407 <getuint+0x38>
	else if (lflag)
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 10                	je     8003f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	eb 0e                	jmp    800407 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800413:	8b 10                	mov    (%eax),%edx
  800415:	3b 50 04             	cmp    0x4(%eax),%edx
  800418:	73 0a                	jae    800424 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	88 02                	mov    %al,(%edx)
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80042c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	8b 45 10             	mov    0x10(%ebp),%eax
  800436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 02 00 00 00       	call   80044e <vprintfmt>
	va_end(ap);
}
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
  800454:	83 ec 3c             	sub    $0x3c,%esp
  800457:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80045a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80045d:	eb 14                	jmp    800473 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 b3 03 00 00    	je     80081a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800467:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	89 f3                	mov    %esi,%ebx
  800473:	8d 73 01             	lea    0x1(%ebx),%esi
  800476:	0f b6 03             	movzbl (%ebx),%eax
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e1                	jne    80045f <vprintfmt+0x11>
  80047e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800482:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800489:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800490:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
  80049c:	eb 1d                	jmp    8004bb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a4:	eb 15                	jmp    8004bb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ac:	eb 0d                	jmp    8004bb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004be:	0f b6 0e             	movzbl (%esi),%ecx
  8004c1:	0f b6 c1             	movzbl %cl,%eax
  8004c4:	83 e9 23             	sub    $0x23,%ecx
  8004c7:	80 f9 55             	cmp    $0x55,%cl
  8004ca:	0f 87 2a 03 00 00    	ja     8007fa <vprintfmt+0x3ac>
  8004d0:	0f b6 c9             	movzbl %cl,%ecx
  8004d3:	ff 24 8d e0 29 80 00 	jmp    *0x8029e0(,%ecx,4)
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ee:	83 fb 09             	cmp    $0x9,%ebx
  8004f1:	77 36                	ja     800529 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f6:	eb e9                	jmp    8004e1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800501:	8b 00                	mov    (%eax),%eax
  800503:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800508:	eb 22                	jmp    80052c <vprintfmt+0xde>
  80050a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	0f 49 c1             	cmovns %ecx,%eax
  800517:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
  80051c:	eb 9d                	jmp    8004bb <vprintfmt+0x6d>
  80051e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800520:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800527:	eb 92                	jmp    8004bb <vprintfmt+0x6d>
  800529:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80052c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800530:	79 89                	jns    8004bb <vprintfmt+0x6d>
  800532:	e9 77 ff ff ff       	jmp    8004ae <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053c:	e9 7a ff ff ff       	jmp    8004bb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
			break;
  800556:	e9 18 ff ff ff       	jmp    800473 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	8b 00                	mov    (%eax),%eax
  800566:	99                   	cltd   
  800567:	31 d0                	xor    %edx,%eax
  800569:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056b:	83 f8 0f             	cmp    $0xf,%eax
  80056e:	7f 0b                	jg     80057b <vprintfmt+0x12d>
  800570:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	75 20                	jne    80059b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80057b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057f:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800586:	00 
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 90 fe ff ff       	call   800426 <printfmt>
  800596:	e9 d8 fe ff ff       	jmp    800473 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80059b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059f:	c7 44 24 08 75 2c 80 	movl   $0x802c75,0x8(%esp)
  8005a6:	00 
  8005a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 70 fe ff ff       	call   800426 <printfmt>
  8005b6:	e9 b8 fe ff ff       	jmp    800473 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005cf:	85 f6                	test   %esi,%esi
  8005d1:	b8 b8 28 80 00       	mov    $0x8028b8,%eax
  8005d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005dd:	0f 84 97 00 00 00    	je     80067a <vprintfmt+0x22c>
  8005e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005e7:	0f 8e 9b 00 00 00    	jle    800688 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	e8 cf 02 00 00       	call   8008c8 <strnlen>
  8005f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fc:	29 c2                	sub    %eax,%edx
  8005fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800601:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800605:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800608:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060b:	8b 75 08             	mov    0x8(%ebp),%esi
  80060e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800611:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	eb 0f                	jmp    800624 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800621:	83 eb 01             	sub    $0x1,%ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f ed                	jg     800615 <vprintfmt+0x1c7>
  800628:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062e:	85 d2                	test   %edx,%edx
  800630:	b8 00 00 00 00       	mov    $0x0,%eax
  800635:	0f 49 c2             	cmovns %edx,%eax
  800638:	29 c2                	sub    %eax,%edx
  80063a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063d:	89 d7                	mov    %edx,%edi
  80063f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800642:	eb 50                	jmp    800694 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800644:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800648:	74 1e                	je     800668 <vprintfmt+0x21a>
  80064a:	0f be d2             	movsbl %dl,%edx
  80064d:	83 ea 20             	sub    $0x20,%edx
  800650:	83 fa 5e             	cmp    $0x5e,%edx
  800653:	76 13                	jbe    800668 <vprintfmt+0x21a>
					putch('?', putdat);
  800655:	8b 45 0c             	mov    0xc(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800668:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	83 ef 01             	sub    $0x1,%edi
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x246>
  80067a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800680:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800683:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800686:	eb 0c                	jmp    800694 <vprintfmt+0x246>
  800688:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80068e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800694:	83 c6 01             	add    $0x1,%esi
  800697:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80069b:	0f be c2             	movsbl %dl,%eax
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 27                	je     8006c9 <vprintfmt+0x27b>
  8006a2:	85 db                	test   %ebx,%ebx
  8006a4:	78 9e                	js     800644 <vprintfmt+0x1f6>
  8006a6:	83 eb 01             	sub    $0x1,%ebx
  8006a9:	79 99                	jns    800644 <vprintfmt+0x1f6>
  8006ab:	89 f8                	mov    %edi,%eax
  8006ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	89 c3                	mov    %eax,%ebx
  8006b5:	eb 1a                	jmp    8006d1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c4:	83 eb 01             	sub    $0x1,%ebx
  8006c7:	eb 08                	jmp    8006d1 <vprintfmt+0x283>
  8006c9:	89 fb                	mov    %edi,%ebx
  8006cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006d1:	85 db                	test   %ebx,%ebx
  8006d3:	7f e2                	jg     8006b7 <vprintfmt+0x269>
  8006d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006db:	e9 93 fd ff ff       	jmp    800473 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e0:	83 fa 01             	cmp    $0x1,%edx
  8006e3:	7e 16                	jle    8006fb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 08             	lea    0x8(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 50 04             	mov    0x4(%eax),%edx
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f9:	eb 32                	jmp    80072d <vprintfmt+0x2df>
	else if (lflag)
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	74 18                	je     800717 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 50 04             	lea    0x4(%eax),%edx
  800705:	89 55 14             	mov    %edx,0x14(%ebp)
  800708:	8b 30                	mov    (%eax),%esi
  80070a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	c1 f8 1f             	sar    $0x1f,%eax
  800712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800715:	eb 16                	jmp    80072d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)
  800720:	8b 30                	mov    (%eax),%esi
  800722:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800725:	89 f0                	mov    %esi,%eax
  800727:	c1 f8 1f             	sar    $0x1f,%eax
  80072a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800733:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800738:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073c:	0f 89 80 00 00 00    	jns    8007c2 <vprintfmt+0x374>
				putch('-', putdat);
  800742:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800746:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800750:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800753:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800756:	f7 d8                	neg    %eax
  800758:	83 d2 00             	adc    $0x0,%edx
  80075b:	f7 da                	neg    %edx
			}
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800762:	eb 5e                	jmp    8007c2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 63 fc ff ff       	call   8003cf <getuint>
			base = 10;
  80076c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800771:	eb 4f                	jmp    8007c2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 54 fc ff ff       	call   8003cf <getuint>
			base = 8;
  80077b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800780:	eb 40                	jmp    8007c2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800782:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800786:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800790:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800794:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b3:	eb 0d                	jmp    8007c2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b8:	e8 12 fc ff ff       	call   8003cf <getuint>
			base = 16;
  8007bd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dc:	89 fa                	mov    %edi,%edx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	e8 fa fa ff ff       	call   8002e0 <printnum>
			break;
  8007e6:	e9 88 fc ff ff       	jmp    800473 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f5:	e9 79 fc ff ff       	jmp    800473 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800805:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	eb 03                	jmp    80080f <vprintfmt+0x3c1>
  80080c:	83 eb 01             	sub    $0x1,%ebx
  80080f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800813:	75 f7                	jne    80080c <vprintfmt+0x3be>
  800815:	e9 59 fc ff ff       	jmp    800473 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80081a:	83 c4 3c             	add    $0x3c,%esp
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5f                   	pop    %edi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 28             	sub    $0x28,%esp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800831:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800835:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800838:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083f:	85 c0                	test   %eax,%eax
  800841:	74 30                	je     800873 <vsnprintf+0x51>
  800843:	85 d2                	test   %edx,%edx
  800845:	7e 2c                	jle    800873 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800847:	8b 45 14             	mov    0x14(%ebp),%eax
  80084a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
  800851:	89 44 24 08          	mov    %eax,0x8(%esp)
  800855:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	c7 04 24 09 04 80 00 	movl   $0x800409,(%esp)
  800863:	e8 e6 fb ff ff       	call   80044e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800868:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800871:	eb 05                	jmp    800878 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800880:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800883:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800887:	8b 45 10             	mov    0x10(%ebp),%eax
  80088a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	89 44 24 04          	mov    %eax,0x4(%esp)
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	89 04 24             	mov    %eax,(%esp)
  80089b:	e8 82 ff ff ff       	call   800822 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    
  8008a2:	66 90                	xchg   %ax,%ax
  8008a4:	66 90                	xchg   %ax,%ax
  8008a6:	66 90                	xchg   %ax,%ax
  8008a8:	66 90                	xchg   %ax,%ax
  8008aa:	66 90                	xchg   %ax,%ax
  8008ac:	66 90                	xchg   %ax,%ax
  8008ae:	66 90                	xchg   %ax,%ax

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 03                	jmp    8008c0 <strlen+0x10>
		n++;
  8008bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c4:	75 f7                	jne    8008bd <strlen+0xd>
		n++;
	return n;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 03                	jmp    8008db <strnlen+0x13>
		n++;
  8008d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	74 06                	je     8008e5 <strnlen+0x1d>
  8008df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e3:	75 f3                	jne    8008d8 <strnlen+0x10>
		n++;
	return n;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	83 c2 01             	add    $0x1,%edx
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800900:	84 db                	test   %bl,%bl
  800902:	75 ef                	jne    8008f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 97 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800920:	01 d8                	add    %ebx,%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 bd ff ff ff       	call   8008e7 <strcpy>
	return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	83 c4 08             	add    $0x8,%esp
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 1d                	jmp    800996 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 0b                	je     800991 <strlcpy+0x32>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	eb 02                	jmp    800993 <strlcpy+0x34>
  800991:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800993:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800996:	29 f0                	sub    %esi,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strcmp+0x11>
		p++, q++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 04                	je     8009b8 <strcmp+0x1c>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	74 ef                	je     8009a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c3                	mov    %eax,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d1:	eb 06                	jmp    8009d9 <strncmp+0x17>
		n--, p++, q++;
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d9:	39 d8                	cmp    %ebx,%eax
  8009db:	74 15                	je     8009f2 <strncmp+0x30>
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	84 c9                	test   %cl,%cl
  8009e2:	74 04                	je     8009e8 <strncmp+0x26>
  8009e4:	3a 0a                	cmp    (%edx),%cl
  8009e6:	74 eb                	je     8009d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
  8009f0:	eb 05                	jmp    8009f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 07                	jmp    800a0d <strchr+0x13>
		if (*s == c)
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	74 0f                	je     800a19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	eb 07                	jmp    800a2e <strfind+0x13>
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 0a                	je     800a35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	74 36                	je     800a7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4d:	75 28                	jne    800a77 <memset+0x40>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 23                	jne    800a77 <memset+0x40>
		c &= 0xFF;
  800a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 18             	shl    $0x18,%esi
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 c2                	or     %eax,%edx
  800a6b:	89 d0                	mov    %edx,%eax
  800a6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a72:	fc                   	cld    
  800a73:	f3 ab                	rep stos %eax,%es:(%edi)
  800a75:	eb 06                	jmp    800a7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 35                	jae    800acb <memmove+0x47>
  800a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	73 2e                	jae    800acb <memmove+0x47>
		s += n;
		d += n;
  800a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaa:	75 13                	jne    800abf <memmove+0x3b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0e                	jne    800abf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab1:	83 ef 04             	sub    $0x4,%edi
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abf:	83 ef 01             	sub    $0x1,%edi
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 1d                	jmp    800ae8 <memmove+0x64>
  800acb:	89 f2                	mov    %esi,%edx
  800acd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	f6 c2 03             	test   $0x3,%dl
  800ad2:	75 0f                	jne    800ae3 <memmove+0x5f>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 0a                	jne    800ae3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	fc                   	cld    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 05                	jmp    800ae8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	fc                   	cld    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af2:	8b 45 10             	mov    0x10(%ebp),%eax
  800af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	89 04 24             	mov    %eax,(%esp)
  800b06:	e8 79 ff ff ff       	call   800a84 <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1d:	eb 1a                	jmp    800b39 <memcmp+0x2c>
		if (*s1 != *s2)
  800b1f:	0f b6 02             	movzbl (%edx),%eax
  800b22:	0f b6 19             	movzbl (%ecx),%ebx
  800b25:	38 d8                	cmp    %bl,%al
  800b27:	74 0a                	je     800b33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c0             	movzbl %al,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 0f                	jmp    800b42 <memcmp+0x35>
		s1++, s2++;
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b39:	39 f2                	cmp    %esi,%edx
  800b3b:	75 e2                	jne    800b1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b54:	eb 07                	jmp    800b5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b56:	38 08                	cmp    %cl,(%eax)
  800b58:	74 07                	je     800b61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	39 d0                	cmp    %edx,%eax
  800b5f:	72 f5                	jb     800b56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6f:	eb 03                	jmp    800b74 <strtol+0x11>
		s++;
  800b71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b74:	0f b6 0a             	movzbl (%edx),%ecx
  800b77:	80 f9 09             	cmp    $0x9,%cl
  800b7a:	74 f5                	je     800b71 <strtol+0xe>
  800b7c:	80 f9 20             	cmp    $0x20,%cl
  800b7f:	74 f0                	je     800b71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b81:	80 f9 2b             	cmp    $0x2b,%cl
  800b84:	75 0a                	jne    800b90 <strtol+0x2d>
		s++;
  800b86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb 11                	jmp    800ba1 <strtol+0x3e>
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b95:	80 f9 2d             	cmp    $0x2d,%cl
  800b98:	75 07                	jne    800ba1 <strtol+0x3e>
		s++, neg = 1;
  800b9a:	8d 52 01             	lea    0x1(%edx),%edx
  800b9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ba6:	75 15                	jne    800bbd <strtol+0x5a>
  800ba8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bab:	75 10                	jne    800bbd <strtol+0x5a>
  800bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb1:	75 0a                	jne    800bbd <strtol+0x5a>
		s += 2, base = 16;
  800bb3:	83 c2 02             	add    $0x2,%edx
  800bb6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bbb:	eb 10                	jmp    800bcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	75 0c                	jne    800bcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc6:	75 05                	jne    800bcd <strtol+0x6a>
		s++, base = 8;
  800bc8:	83 c2 01             	add    $0x1,%edx
  800bcb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 0a             	movzbl (%edx),%ecx
  800bd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bdb:	89 f0                	mov    %esi,%eax
  800bdd:	3c 09                	cmp    $0x9,%al
  800bdf:	77 08                	ja     800be9 <strtol+0x86>
			dig = *s - '0';
  800be1:	0f be c9             	movsbl %cl,%ecx
  800be4:	83 e9 30             	sub    $0x30,%ecx
  800be7:	eb 20                	jmp    800c09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	3c 19                	cmp    $0x19,%al
  800bf0:	77 08                	ja     800bfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800bf2:	0f be c9             	movsbl %cl,%ecx
  800bf5:	83 e9 57             	sub    $0x57,%ecx
  800bf8:	eb 0f                	jmp    800c09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	3c 19                	cmp    $0x19,%al
  800c01:	77 16                	ja     800c19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c03:	0f be c9             	movsbl %cl,%ecx
  800c06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c0c:	7d 0f                	jge    800c1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c17:	eb bc                	jmp    800bd5 <strtol+0x72>
  800c19:	89 d8                	mov    %ebx,%eax
  800c1b:	eb 02                	jmp    800c1f <strtol+0xbc>
  800c1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c23:	74 05                	je     800c2a <strtol+0xc7>
		*endptr = (char *) s;
  800c25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c2a:	f7 d8                	neg    %eax
  800c2c:	85 ff                	test   %edi,%edi
  800c2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	89 c6                	mov    %eax,%esi
  800c4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c81:	b8 03 00 00 00       	mov    $0x3,%eax
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 cb                	mov    %ecx,%ebx
  800c8b:	89 cf                	mov    %ecx,%edi
  800c8d:	89 ce                	mov    %ecx,%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 28                	jle    800cbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb0:	00 
  800cb1:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800cb8:	e8 09 f5 ff ff       	call   8001c6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbd:	83 c4 2c             	add    $0x2c,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 04 00 00 00       	mov    $0x4,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	89 f7                	mov    %esi,%edi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800d4a:	e8 77 f4 ff ff       	call   8001c6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4f:	83 c4 2c             	add    $0x2c,%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	b8 05 00 00 00       	mov    $0x5,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d71:	8b 75 18             	mov    0x18(%ebp),%esi
  800d74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 28                	jle    800da2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d85:	00 
  800d86:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d95:	00 
  800d96:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800d9d:	e8 24 f4 ff ff       	call   8001c6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da2:	83 c4 2c             	add    $0x2c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800df0:	e8 d1 f3 ff ff       	call   8001c6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df5:	83 c4 2c             	add    $0x2c,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 28                	jle    800e48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e33:	00 
  800e34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3b:	00 
  800e3c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e43:	e8 7e f3 ff ff       	call   8001c6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e48:	83 c4 2c             	add    $0x2c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e96:	e8 2b f3 ff ff       	call   8001c6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e9b:	83 c4 2c             	add    $0x2c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800ee9:	e8 d8 f2 ff ff       	call   8001c6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eee:	83 c4 2c             	add    $0x2c,%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2f:	89 cb                	mov    %ecx,%ebx
  800f31:	89 cf                	mov    %ecx,%edi
  800f33:	89 ce                	mov    %ecx,%esi
  800f35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 28                	jle    800f63 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f5e:	e8 63 f2 ff ff       	call   8001c6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f63:	83 c4 2c             	add    $0x2c,%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f71:	ba 00 00 00 00       	mov    $0x0,%edx
  800f76:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f7b:	89 d1                	mov    %edx,%ecx
  800f7d:	89 d3                	mov    %edx,%ebx
  800f7f:	89 d7                	mov    %edx,%edi
  800f81:	89 d6                	mov    %edx,%esi
  800f83:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f98:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 df                	mov    %ebx,%edi
  800fa5:	89 de                	mov    %ebx,%esi
  800fa7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 28                	jle    800fd5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fd0:	e8 f1 f1 ff ff       	call   8001c6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800fd5:	83 c4 2c             	add    $0x2c,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800feb:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff6:	89 df                	mov    %ebx,%edi
  800ff8:	89 de                	mov    %ebx,%esi
  800ffa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	7e 28                	jle    801028 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801000:	89 44 24 10          	mov    %eax,0x10(%esp)
  801004:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80100b:	00 
  80100c:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801013:	00 
  801014:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101b:	00 
  80101c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801023:	e8 9e f1 ff ff       	call   8001c6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801028:	83 c4 2c             	add    $0x2c,%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80104b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801050:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801062:	89 c2                	mov    %eax,%edx
  801064:	c1 ea 16             	shr    $0x16,%edx
  801067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	74 11                	je     801084 <fd_alloc+0x2d>
  801073:	89 c2                	mov    %eax,%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	75 09                	jne    80108d <fd_alloc+0x36>
			*fd_store = fd;
  801084:	89 01                	mov    %eax,(%ecx)
			return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	eb 17                	jmp    8010a4 <fd_alloc+0x4d>
  80108d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801092:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801097:	75 c9                	jne    801062 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801099:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ac:	83 f8 1f             	cmp    $0x1f,%eax
  8010af:	77 36                	ja     8010e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b1:	c1 e0 0c             	shl    $0xc,%eax
  8010b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 24                	je     8010ee <fd_lookup+0x48>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 1a                	je     8010f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	eb 13                	jmp    8010fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 0c                	jmp    8010fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f3:	eb 05                	jmp    8010fa <fd_lookup+0x54>
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 18             	sub    $0x18,%esp
  801102:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	eb 13                	jmp    80111f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80110c:	39 08                	cmp    %ecx,(%eax)
  80110e:	75 0c                	jne    80111c <dev_lookup+0x20>
			*dev = devtab[i];
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	89 01                	mov    %eax,(%ecx)
			return 0;
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	eb 38                	jmp    801154 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111c:	83 c2 01             	add    $0x1,%edx
  80111f:	8b 04 95 48 2c 80 00 	mov    0x802c48(,%edx,4),%eax
  801126:	85 c0                	test   %eax,%eax
  801128:	75 e2                	jne    80110c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80112a:	a1 20 60 80 00       	mov    0x806020,%eax
  80112f:	8b 40 48             	mov    0x48(%eax),%eax
  801132:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113a:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  801141:	e8 79 f1 ff ff       	call   8002bf <cprintf>
	*dev = 0;
  801146:	8b 45 0c             	mov    0xc(%ebp),%eax
  801149:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 20             	sub    $0x20,%esp
  80115e:	8b 75 08             	mov    0x8(%ebp),%esi
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801171:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801174:	89 04 24             	mov    %eax,(%esp)
  801177:	e8 2a ff ff ff       	call   8010a6 <fd_lookup>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 05                	js     801185 <fd_close+0x2f>
	    || fd != fd2)
  801180:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801183:	74 0c                	je     801191 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801185:	84 db                	test   %bl,%bl
  801187:	ba 00 00 00 00       	mov    $0x0,%edx
  80118c:	0f 44 c2             	cmove  %edx,%eax
  80118f:	eb 3f                	jmp    8011d0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801191:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801194:	89 44 24 04          	mov    %eax,0x4(%esp)
  801198:	8b 06                	mov    (%esi),%eax
  80119a:	89 04 24             	mov    %eax,(%esp)
  80119d:	e8 5a ff ff ff       	call   8010fc <dev_lookup>
  8011a2:	89 c3                	mov    %eax,%ebx
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 16                	js     8011be <fd_close+0x68>
		if (dev->dev_close)
  8011a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 07                	je     8011be <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011b7:	89 34 24             	mov    %esi,(%esp)
  8011ba:	ff d0                	call   *%eax
  8011bc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c9:	e8 dc fb ff ff       	call   800daa <sys_page_unmap>
	return r;
  8011ce:	89 d8                	mov    %ebx,%eax
}
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	e8 b7 fe ff ff       	call   8010a6 <fd_lookup>
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	78 13                	js     801208 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8011f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011fc:	00 
  8011fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801200:	89 04 24             	mov    %eax,(%esp)
  801203:	e8 4e ff ff ff       	call   801156 <fd_close>
}
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <close_all>:

void
close_all(void)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801216:	89 1c 24             	mov    %ebx,(%esp)
  801219:	e8 b9 ff ff ff       	call   8011d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80121e:	83 c3 01             	add    $0x1,%ebx
  801221:	83 fb 20             	cmp    $0x20,%ebx
  801224:	75 f0                	jne    801216 <close_all+0xc>
		close(i);
}
  801226:	83 c4 14             	add    $0x14,%esp
  801229:	5b                   	pop    %ebx
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801235:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 5f fe ff ff       	call   8010a6 <fd_lookup>
  801247:	89 c2                	mov    %eax,%edx
  801249:	85 d2                	test   %edx,%edx
  80124b:	0f 88 e1 00 00 00    	js     801332 <dup+0x106>
		return r;
	close(newfdnum);
  801251:	8b 45 0c             	mov    0xc(%ebp),%eax
  801254:	89 04 24             	mov    %eax,(%esp)
  801257:	e8 7b ff ff ff       	call   8011d7 <close>

	newfd = INDEX2FD(newfdnum);
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125f:	c1 e3 0c             	shl    $0xc,%ebx
  801262:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 cd fd ff ff       	call   801040 <fd2data>
  801273:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801275:	89 1c 24             	mov    %ebx,(%esp)
  801278:	e8 c3 fd ff ff       	call   801040 <fd2data>
  80127d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80127f:	89 f0                	mov    %esi,%eax
  801281:	c1 e8 16             	shr    $0x16,%eax
  801284:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80128b:	a8 01                	test   $0x1,%al
  80128d:	74 43                	je     8012d2 <dup+0xa6>
  80128f:	89 f0                	mov    %esi,%eax
  801291:	c1 e8 0c             	shr    $0xc,%eax
  801294:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 32                	je     8012d2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012bb:	00 
  8012bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c7:	e8 8b fa ff ff       	call   800d57 <sys_page_map>
  8012cc:	89 c6                	mov    %eax,%esi
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 3e                	js     801310 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 0c             	shr    $0xc,%edx
  8012da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012f6:	00 
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801302:	e8 50 fa ff ff       	call   800d57 <sys_page_map>
  801307:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130c:	85 f6                	test   %esi,%esi
  80130e:	79 22                	jns    801332 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801310:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131b:	e8 8a fa ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801320:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132b:	e8 7a fa ff ff       	call   800daa <sys_page_unmap>
	return r;
  801330:	89 f0                	mov    %esi,%eax
}
  801332:	83 c4 3c             	add    $0x3c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 24             	sub    $0x24,%esp
  801341:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801344:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	89 1c 24             	mov    %ebx,(%esp)
  80134e:	e8 53 fd ff ff       	call   8010a6 <fd_lookup>
  801353:	89 c2                	mov    %eax,%edx
  801355:	85 d2                	test   %edx,%edx
  801357:	78 6d                	js     8013c6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801360:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801363:	8b 00                	mov    (%eax),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 8f fd ff ff       	call   8010fc <dev_lookup>
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 55                	js     8013c6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801374:	8b 50 08             	mov    0x8(%eax),%edx
  801377:	83 e2 03             	and    $0x3,%edx
  80137a:	83 fa 01             	cmp    $0x1,%edx
  80137d:	75 23                	jne    8013a2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137f:	a1 20 60 80 00       	mov    0x806020,%eax
  801384:	8b 40 48             	mov    0x48(%eax),%eax
  801387:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  801396:	e8 24 ef ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  80139b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a0:	eb 24                	jmp    8013c6 <read+0x8c>
	}
	if (!dev->dev_read)
  8013a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a5:	8b 52 08             	mov    0x8(%edx),%edx
  8013a8:	85 d2                	test   %edx,%edx
  8013aa:	74 15                	je     8013c1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	ff d2                	call   *%edx
  8013bf:	eb 05                	jmp    8013c6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013c6:	83 c4 24             	add    $0x24,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	57                   	push   %edi
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 1c             	sub    $0x1c,%esp
  8013d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e0:	eb 23                	jmp    801405 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e2:	89 f0                	mov    %esi,%eax
  8013e4:	29 d8                	sub    %ebx,%eax
  8013e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ea:	89 d8                	mov    %ebx,%eax
  8013ec:	03 45 0c             	add    0xc(%ebp),%eax
  8013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	e8 3f ff ff ff       	call   80133a <read>
		if (m < 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 10                	js     80140f <readn+0x43>
			return m;
		if (m == 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	74 0a                	je     80140d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801403:	01 c3                	add    %eax,%ebx
  801405:	39 f3                	cmp    %esi,%ebx
  801407:	72 d9                	jb     8013e2 <readn+0x16>
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	eb 02                	jmp    80140f <readn+0x43>
  80140d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140f:	83 c4 1c             	add    $0x1c,%esp
  801412:	5b                   	pop    %ebx
  801413:	5e                   	pop    %esi
  801414:	5f                   	pop    %edi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 24             	sub    $0x24,%esp
  80141e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801421:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 76 fc ff ff       	call   8010a6 <fd_lookup>
  801430:	89 c2                	mov    %eax,%edx
  801432:	85 d2                	test   %edx,%edx
  801434:	78 68                	js     80149e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	8b 00                	mov    (%eax),%eax
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	e8 b2 fc ff ff       	call   8010fc <dev_lookup>
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 50                	js     80149e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80144e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801451:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801455:	75 23                	jne    80147a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801457:	a1 20 60 80 00       	mov    0x806020,%eax
  80145c:	8b 40 48             	mov    0x48(%eax),%eax
  80145f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	c7 04 24 29 2c 80 00 	movl   $0x802c29,(%esp)
  80146e:	e8 4c ee ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801478:	eb 24                	jmp    80149e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80147a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147d:	8b 52 0c             	mov    0xc(%edx),%edx
  801480:	85 d2                	test   %edx,%edx
  801482:	74 15                	je     801499 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801484:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801487:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	ff d2                	call   *%edx
  801497:	eb 05                	jmp    80149e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801499:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80149e:	83 c4 24             	add    $0x24,%esp
  8014a1:	5b                   	pop    %ebx
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	89 04 24             	mov    %eax,(%esp)
  8014b7:	e8 ea fb ff ff       	call   8010a6 <fd_lookup>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 0e                	js     8014ce <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 24             	sub    $0x24,%esp
  8014d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e1:	89 1c 24             	mov    %ebx,(%esp)
  8014e4:	e8 bd fb ff ff       	call   8010a6 <fd_lookup>
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	85 d2                	test   %edx,%edx
  8014ed:	78 61                	js     801550 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	8b 00                	mov    (%eax),%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 f9 fb ff ff       	call   8010fc <dev_lookup>
  801503:	85 c0                	test   %eax,%eax
  801505:	78 49                	js     801550 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150e:	75 23                	jne    801533 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801510:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801515:	8b 40 48             	mov    0x48(%eax),%eax
  801518:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80151c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801520:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  801527:	e8 93 ed ff ff       	call   8002bf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801531:	eb 1d                	jmp    801550 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801533:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801536:	8b 52 18             	mov    0x18(%edx),%edx
  801539:	85 d2                	test   %edx,%edx
  80153b:	74 0e                	je     80154b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801540:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	ff d2                	call   *%edx
  801549:	eb 05                	jmp    801550 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80154b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801550:	83 c4 24             	add    $0x24,%esp
  801553:	5b                   	pop    %ebx
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 24             	sub    $0x24,%esp
  80155d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 34 fb ff ff       	call   8010a6 <fd_lookup>
  801572:	89 c2                	mov    %eax,%edx
  801574:	85 d2                	test   %edx,%edx
  801576:	78 52                	js     8015ca <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	8b 00                	mov    (%eax),%eax
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	e8 70 fb ff ff       	call   8010fc <dev_lookup>
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 3a                	js     8015ca <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801593:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801597:	74 2c                	je     8015c5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801599:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a3:	00 00 00 
	stat->st_isdir = 0;
  8015a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ad:	00 00 00 
	stat->st_dev = dev;
  8015b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bd:	89 14 24             	mov    %edx,(%esp)
  8015c0:	ff 50 14             	call   *0x14(%eax)
  8015c3:	eb 05                	jmp    8015ca <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ca:	83 c4 24             	add    $0x24,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015df:	00 
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 28 02 00 00       	call   801813 <open>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	85 db                	test   %ebx,%ebx
  8015ef:	78 1b                	js     80160c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f8:	89 1c 24             	mov    %ebx,(%esp)
  8015fb:	e8 56 ff ff ff       	call   801556 <fstat>
  801600:	89 c6                	mov    %eax,%esi
	close(fd);
  801602:	89 1c 24             	mov    %ebx,(%esp)
  801605:	e8 cd fb ff ff       	call   8011d7 <close>
	return r;
  80160a:	89 f0                	mov    %esi,%eax
}
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 10             	sub    $0x10,%esp
  80161b:	89 c6                	mov    %eax,%esi
  80161d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80161f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801626:	75 11                	jne    801639 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80162f:	e8 e1 0e 00 00       	call   802515 <ipc_find_env>
  801634:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801639:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801640:	00 
  801641:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801648:	00 
  801649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164d:	a1 00 40 80 00       	mov    0x804000,%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 50 0e 00 00       	call   8024aa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801661:	00 
  801662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801666:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166d:	e8 be 0d 00 00       	call   802430 <ipc_recv>
}
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80168a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	b8 02 00 00 00       	mov    $0x2,%eax
  80169c:	e8 72 ff ff ff       	call   801613 <fsipc>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016be:	e8 50 ff ff ff       	call   801613 <fsipc>
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 14             	sub    $0x14,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d5:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
  8016df:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e4:	e8 2a ff ff ff       	call   801613 <fsipc>
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	78 2b                	js     80171a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ef:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8016f6:	00 
  8016f7:	89 1c 24             	mov    %ebx,(%esp)
  8016fa:	e8 e8 f1 ff ff       	call   8008e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ff:	a1 80 70 80 00       	mov    0x807080,%eax
  801704:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170a:	a1 84 70 80 00       	mov    0x807084,%eax
  80170f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801715:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171a:	83 c4 14             	add    $0x14,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 18             	sub    $0x18,%esp
  801726:	8b 45 10             	mov    0x10(%ebp),%eax
  801729:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801733:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801736:	8b 55 08             	mov    0x8(%ebp),%edx
  801739:	8b 52 0c             	mov    0xc(%edx),%edx
  80173c:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801742:	a3 04 70 80 00       	mov    %eax,0x807004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801759:	e8 26 f3 ff ff       	call   800a84 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 04 00 00 00       	mov    $0x4,%eax
  801768:	e8 a6 fe ff ff       	call   801613 <fsipc>
}
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	83 ec 10             	sub    $0x10,%esp
  801777:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801785:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 03 00 00 00       	mov    $0x3,%eax
  801795:	e8 79 fe ff ff       	call   801613 <fsipc>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 6a                	js     80180a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017a0:	39 c6                	cmp    %eax,%esi
  8017a2:	73 24                	jae    8017c8 <devfile_read+0x59>
  8017a4:	c7 44 24 0c 5c 2c 80 	movl   $0x802c5c,0xc(%esp)
  8017ab:	00 
  8017ac:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  8017b3:	00 
  8017b4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017bb:	00 
  8017bc:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8017c3:	e8 fe e9 ff ff       	call   8001c6 <_panic>
	assert(r <= PGSIZE);
  8017c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cd:	7e 24                	jle    8017f3 <devfile_read+0x84>
  8017cf:	c7 44 24 0c 83 2c 80 	movl   $0x802c83,0xc(%esp)
  8017d6:	00 
  8017d7:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  8017de:	00 
  8017df:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017e6:	00 
  8017e7:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8017ee:	e8 d3 e9 ff ff       	call   8001c6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f7:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8017fe:	00 
  8017ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 7a f2 ff ff       	call   800a84 <memmove>
	return r;
}
  80180a:	89 d8                	mov    %ebx,%eax
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 24             	sub    $0x24,%esp
  80181a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181d:	89 1c 24             	mov    %ebx,(%esp)
  801820:	e8 8b f0 ff ff       	call   8008b0 <strlen>
  801825:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182a:	7f 60                	jg     80188c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 20 f8 ff ff       	call   801057 <fd_alloc>
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	78 54                	js     801891 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801841:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801848:	e8 9a f0 ff ff       	call   8008e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801855:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801858:	b8 01 00 00 00       	mov    $0x1,%eax
  80185d:	e8 b1 fd ff ff       	call   801613 <fsipc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	85 c0                	test   %eax,%eax
  801866:	79 17                	jns    80187f <open+0x6c>
		fd_close(fd, 0);
  801868:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80186f:	00 
  801870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 db f8 ff ff       	call   801156 <fd_close>
		return r;
  80187b:	89 d8                	mov    %ebx,%eax
  80187d:	eb 12                	jmp    801891 <open+0x7e>
	}

	return fd2num(fd);
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	89 04 24             	mov    %eax,(%esp)
  801885:	e8 a6 f7 ff ff       	call   801030 <fd2num>
  80188a:	eb 05                	jmp    801891 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801891:	83 c4 24             	add    $0x24,%esp
  801894:	5b                   	pop    %ebx
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a7:	e8 67 fd ff ff       	call   801613 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 14             	sub    $0x14,%esp
  8018b5:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8018b7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018bb:	7e 31                	jle    8018ee <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018bd:	8b 40 04             	mov    0x4(%eax),%eax
  8018c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c4:	8d 43 10             	lea    0x10(%ebx),%eax
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	8b 03                	mov    (%ebx),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 42 fb ff ff       	call   801417 <write>
		if (result > 0)
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	7e 03                	jle    8018dc <writebuf+0x2e>
			b->result += result;
  8018d9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018dc:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018df:	74 0d                	je     8018ee <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	0f 4f c2             	cmovg  %edx,%eax
  8018eb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018ee:	83 c4 14             	add    $0x14,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <putch>:

static void
putch(int ch, void *thunk)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018fe:	8b 53 04             	mov    0x4(%ebx),%edx
  801901:	8d 42 01             	lea    0x1(%edx),%eax
  801904:	89 43 04             	mov    %eax,0x4(%ebx)
  801907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80190a:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80190e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801913:	75 0e                	jne    801923 <putch+0x2f>
		writebuf(b);
  801915:	89 d8                	mov    %ebx,%eax
  801917:	e8 92 ff ff ff       	call   8018ae <writebuf>
		b->idx = 0;
  80191c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801923:	83 c4 04             	add    $0x4,%esp
  801926:	5b                   	pop    %ebx
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80193b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801942:	00 00 00 
	b.result = 0;
  801945:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80194c:	00 00 00 
	b.error = 1;
  80194f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801956:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801959:	8b 45 10             	mov    0x10(%ebp),%eax
  80195c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801960:	8b 45 0c             	mov    0xc(%ebp),%eax
  801963:	89 44 24 08          	mov    %eax,0x8(%esp)
  801967:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	c7 04 24 f4 18 80 00 	movl   $0x8018f4,(%esp)
  801978:	e8 d1 ea ff ff       	call   80044e <vprintfmt>
	if (b.idx > 0)
  80197d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801984:	7e 0b                	jle    801991 <vfprintf+0x68>
		writebuf(&b);
  801986:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80198c:	e8 1d ff ff ff       	call   8018ae <writebuf>

	return (b.result ? b.result : b.error);
  801991:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801997:	85 c0                	test   %eax,%eax
  801999:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019a8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	89 04 24             	mov    %eax,(%esp)
  8019bc:	e8 68 ff ff ff       	call   801929 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <printf>:

int
printf(const char *fmt, ...)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019de:	e8 46 ff ff ff       	call   801929 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    
  8019e5:	66 90                	xchg   %ax,%ax
  8019e7:	66 90                	xchg   %ax,%ax
  8019e9:	66 90                	xchg   %ax,%ax
  8019eb:	66 90                	xchg   %ax,%ax
  8019ed:	66 90                	xchg   %ax,%ax
  8019ef:	90                   	nop

008019f0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8019f6:	c7 44 24 04 8f 2c 80 	movl   $0x802c8f,0x4(%esp)
  8019fd:	00 
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 de ee ff ff       	call   8008e7 <strcpy>
	return 0;
}
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 14             	sub    $0x14,%esp
  801a17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a1a:	89 1c 24             	mov    %ebx,(%esp)
  801a1d:	e8 2b 0b 00 00       	call   80254d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a27:	83 f8 01             	cmp    $0x1,%eax
  801a2a:	75 0d                	jne    801a39 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801a2c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a2f:	89 04 24             	mov    %eax,(%esp)
  801a32:	e8 29 03 00 00       	call   801d60 <nsipc_close>
  801a37:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801a39:	89 d0                	mov    %edx,%eax
  801a3b:	83 c4 14             	add    $0x14,%esp
  801a3e:	5b                   	pop    %ebx
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a47:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a4e:	00 
  801a4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a52:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	8b 40 0c             	mov    0xc(%eax),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 f0 03 00 00       	call   801e5b <nsipc_send>
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a73:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a7a:	00 
  801a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 44 03 00 00       	call   801ddb <nsipc_recv>
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a9f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aa2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa6:	89 04 24             	mov    %eax,(%esp)
  801aa9:	e8 f8 f5 ff ff       	call   8010a6 <fd_lookup>
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 17                	js     801ac9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801abb:	39 08                	cmp    %ecx,(%eax)
  801abd:	75 05                	jne    801ac4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801abf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac2:	eb 05                	jmp    801ac9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ac4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    

00801acb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 20             	sub    $0x20,%esp
  801ad3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ad5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad8:	89 04 24             	mov    %eax,(%esp)
  801adb:	e8 77 f5 ff ff       	call   801057 <fd_alloc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 21                	js     801b07 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ae6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aed:	00 
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afc:	e8 02 f2 ff ff       	call   800d03 <sys_page_alloc>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	85 c0                	test   %eax,%eax
  801b05:	79 0c                	jns    801b13 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801b07:	89 34 24             	mov    %esi,(%esp)
  801b0a:	e8 51 02 00 00       	call   801d60 <nsipc_close>
		return r;
  801b0f:	89 d8                	mov    %ebx,%eax
  801b11:	eb 20                	jmp    801b33 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b21:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b28:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b2b:	89 14 24             	mov    %edx,(%esp)
  801b2e:	e8 fd f4 ff ff       	call   801030 <fd2num>
}
  801b33:	83 c4 20             	add    $0x20,%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5e                   	pop    %esi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	e8 51 ff ff ff       	call   801a99 <fd2sockid>
		return r;
  801b48:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 23                	js     801b71 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b4e:	8b 55 10             	mov    0x10(%ebp),%edx
  801b51:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b58:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 45 01 00 00       	call   801ca9 <nsipc_accept>
		return r;
  801b64:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 07                	js     801b71 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801b6a:	e8 5c ff ff ff       	call   801acb <alloc_sockfd>
  801b6f:	89 c1                	mov    %eax,%ecx
}
  801b71:	89 c8                	mov    %ecx,%eax
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	e8 16 ff ff ff       	call   801a99 <fd2sockid>
  801b83:	89 c2                	mov    %eax,%edx
  801b85:	85 d2                	test   %edx,%edx
  801b87:	78 16                	js     801b9f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	89 14 24             	mov    %edx,(%esp)
  801b9a:	e8 60 01 00 00       	call   801cff <nsipc_bind>
}
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    

00801ba1 <shutdown>:

int
shutdown(int s, int how)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	e8 ea fe ff ff       	call   801a99 <fd2sockid>
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	85 d2                	test   %edx,%edx
  801bb3:	78 0f                	js     801bc4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	89 14 24             	mov    %edx,(%esp)
  801bbf:	e8 7a 01 00 00       	call   801d3e <nsipc_shutdown>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	e8 c5 fe ff ff       	call   801a99 <fd2sockid>
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	85 d2                	test   %edx,%edx
  801bd8:	78 16                	js     801bf0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801bda:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	89 14 24             	mov    %edx,(%esp)
  801beb:	e8 8a 01 00 00       	call   801d7a <nsipc_connect>
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <listen>:

int
listen(int s, int backlog)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	e8 99 fe ff ff       	call   801a99 <fd2sockid>
  801c00:	89 c2                	mov    %eax,%edx
  801c02:	85 d2                	test   %edx,%edx
  801c04:	78 0f                	js     801c15 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	89 14 24             	mov    %edx,(%esp)
  801c10:	e8 a4 01 00 00       	call   801db9 <nsipc_listen>
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c20:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	e8 98 02 00 00       	call   801ece <nsipc_socket>
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	85 d2                	test   %edx,%edx
  801c3a:	78 05                	js     801c41 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801c3c:	e8 8a fe ff ff       	call   801acb <alloc_sockfd>
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	53                   	push   %ebx
  801c47:	83 ec 14             	sub    $0x14,%esp
  801c4a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c4c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c53:	75 11                	jne    801c66 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c5c:	e8 b4 08 00 00       	call   802515 <ipc_find_env>
  801c61:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c66:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c6d:	00 
  801c6e:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  801c75:	00 
  801c76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 23 08 00 00       	call   8024aa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c96:	00 
  801c97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9e:	e8 8d 07 00 00       	call   802430 <ipc_recv>
}
  801ca3:	83 c4 14             	add    $0x14,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	56                   	push   %esi
  801cad:	53                   	push   %ebx
  801cae:	83 ec 10             	sub    $0x10,%esp
  801cb1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cbc:	8b 06                	mov    (%esi),%eax
  801cbe:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc8:	e8 76 ff ff ff       	call   801c43 <nsipc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 23                	js     801cf6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cd3:	a1 10 80 80 00       	mov    0x808010,%eax
  801cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cdc:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801ce3:	00 
  801ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce7:	89 04 24             	mov    %eax,(%esp)
  801cea:	e8 95 ed ff ff       	call   800a84 <memmove>
		*addrlen = ret->ret_addrlen;
  801cef:	a1 10 80 80 00       	mov    0x808010,%eax
  801cf4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	53                   	push   %ebx
  801d03:	83 ec 14             	sub    $0x14,%esp
  801d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d11:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1c:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801d23:	e8 5c ed ff ff       	call   800a84 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d28:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801d2e:	b8 02 00 00 00       	mov    $0x2,%eax
  801d33:	e8 0b ff ff ff       	call   801c43 <nsipc>
}
  801d38:	83 c4 14             	add    $0x14,%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4f:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801d54:	b8 03 00 00 00       	mov    $0x3,%eax
  801d59:	e8 e5 fe ff ff       	call   801c43 <nsipc>
}
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <nsipc_close>:

int
nsipc_close(int s)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801d6e:	b8 04 00 00 00       	mov    $0x4,%eax
  801d73:	e8 cb fe ff ff       	call   801c43 <nsipc>
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 14             	sub    $0x14,%esp
  801d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d8c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d97:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801d9e:	e8 e1 ec ff ff       	call   800a84 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801da3:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801da9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dae:	e8 90 fe ff ff       	call   801c43 <nsipc>
}
  801db3:	83 c4 14             	add    $0x14,%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    

00801db9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dca:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801dcf:	b8 06 00 00 00       	mov    $0x6,%eax
  801dd4:	e8 6a fe ff ff       	call   801c43 <nsipc>
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 10             	sub    $0x10,%esp
  801de3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801dee:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801df4:	8b 45 14             	mov    0x14(%ebp),%eax
  801df7:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dfc:	b8 07 00 00 00       	mov    $0x7,%eax
  801e01:	e8 3d fe ff ff       	call   801c43 <nsipc>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 46                	js     801e52 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e0c:	39 f0                	cmp    %esi,%eax
  801e0e:	7f 07                	jg     801e17 <nsipc_recv+0x3c>
  801e10:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e15:	7e 24                	jle    801e3b <nsipc_recv+0x60>
  801e17:	c7 44 24 0c 9b 2c 80 	movl   $0x802c9b,0xc(%esp)
  801e1e:	00 
  801e1f:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  801e26:	00 
  801e27:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801e2e:	00 
  801e2f:	c7 04 24 b0 2c 80 00 	movl   $0x802cb0,(%esp)
  801e36:	e8 8b e3 ff ff       	call   8001c6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3f:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801e46:	00 
  801e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4a:	89 04 24             	mov    %eax,(%esp)
  801e4d:	e8 32 ec ff ff       	call   800a84 <memmove>
	}

	return r;
}
  801e52:	89 d8                	mov    %ebx,%eax
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	53                   	push   %ebx
  801e5f:	83 ec 14             	sub    $0x14,%esp
  801e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801e6d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e73:	7e 24                	jle    801e99 <nsipc_send+0x3e>
  801e75:	c7 44 24 0c bc 2c 80 	movl   $0x802cbc,0xc(%esp)
  801e7c:	00 
  801e7d:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  801e84:	00 
  801e85:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801e8c:	00 
  801e8d:	c7 04 24 b0 2c 80 00 	movl   $0x802cb0,(%esp)
  801e94:	e8 2d e3 ff ff       	call   8001c6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea4:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  801eab:	e8 d4 eb ff ff       	call   800a84 <memmove>
	nsipcbuf.send.req_size = size;
  801eb0:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801eb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb9:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801ebe:	b8 08 00 00 00       	mov    $0x8,%eax
  801ec3:	e8 7b fd ff ff       	call   801c43 <nsipc>
}
  801ec8:	83 c4 14             	add    $0x14,%esp
  801ecb:	5b                   	pop    %ebx
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edf:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee7:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801eec:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef1:	e8 4d fd ff ff       	call   801c43 <nsipc>
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 10             	sub    $0x10,%esp
  801f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	89 04 24             	mov    %eax,(%esp)
  801f09:	e8 32 f1 ff ff       	call   801040 <fd2data>
  801f0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f10:	c7 44 24 04 c8 2c 80 	movl   $0x802cc8,0x4(%esp)
  801f17:	00 
  801f18:	89 1c 24             	mov    %ebx,(%esp)
  801f1b:	e8 c7 e9 ff ff       	call   8008e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f20:	8b 46 04             	mov    0x4(%esi),%eax
  801f23:	2b 06                	sub    (%esi),%eax
  801f25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f2b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f32:	00 00 00 
	stat->st_dev = &devpipe;
  801f35:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f3c:	30 80 00 
	return 0;
}
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 14             	sub    $0x14,%esp
  801f52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f60:	e8 45 ee ff ff       	call   800daa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f65:	89 1c 24             	mov    %ebx,(%esp)
  801f68:	e8 d3 f0 ff ff       	call   801040 <fd2data>
  801f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f78:	e8 2d ee ff ff       	call   800daa <sys_page_unmap>
}
  801f7d:	83 c4 14             	add    $0x14,%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    

00801f83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	57                   	push   %edi
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	83 ec 2c             	sub    $0x2c,%esp
  801f8c:	89 c6                	mov    %eax,%esi
  801f8e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f91:	a1 20 60 80 00       	mov    0x806020,%eax
  801f96:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f99:	89 34 24             	mov    %esi,(%esp)
  801f9c:	e8 ac 05 00 00       	call   80254d <pageref>
  801fa1:	89 c7                	mov    %eax,%edi
  801fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa6:	89 04 24             	mov    %eax,(%esp)
  801fa9:	e8 9f 05 00 00       	call   80254d <pageref>
  801fae:	39 c7                	cmp    %eax,%edi
  801fb0:	0f 94 c2             	sete   %dl
  801fb3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fb6:	8b 0d 20 60 80 00    	mov    0x806020,%ecx
  801fbc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801fbf:	39 fb                	cmp    %edi,%ebx
  801fc1:	74 21                	je     801fe4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fc3:	84 d2                	test   %dl,%dl
  801fc5:	74 ca                	je     801f91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fc7:	8b 51 58             	mov    0x58(%ecx),%edx
  801fca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fce:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fd6:	c7 04 24 cf 2c 80 00 	movl   $0x802ccf,(%esp)
  801fdd:	e8 dd e2 ff ff       	call   8002bf <cprintf>
  801fe2:	eb ad                	jmp    801f91 <_pipeisclosed+0xe>
	}
}
  801fe4:	83 c4 2c             	add    $0x2c,%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5f                   	pop    %edi
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    

00801fec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	57                   	push   %edi
  801ff0:	56                   	push   %esi
  801ff1:	53                   	push   %ebx
  801ff2:	83 ec 1c             	sub    $0x1c,%esp
  801ff5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ff8:	89 34 24             	mov    %esi,(%esp)
  801ffb:	e8 40 f0 ff ff       	call   801040 <fd2data>
  802000:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802002:	bf 00 00 00 00       	mov    $0x0,%edi
  802007:	eb 45                	jmp    80204e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802009:	89 da                	mov    %ebx,%edx
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	e8 71 ff ff ff       	call   801f83 <_pipeisclosed>
  802012:	85 c0                	test   %eax,%eax
  802014:	75 41                	jne    802057 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802016:	e8 c9 ec ff ff       	call   800ce4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80201b:	8b 43 04             	mov    0x4(%ebx),%eax
  80201e:	8b 0b                	mov    (%ebx),%ecx
  802020:	8d 51 20             	lea    0x20(%ecx),%edx
  802023:	39 d0                	cmp    %edx,%eax
  802025:	73 e2                	jae    802009 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80202e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802031:	99                   	cltd   
  802032:	c1 ea 1b             	shr    $0x1b,%edx
  802035:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802038:	83 e1 1f             	and    $0x1f,%ecx
  80203b:	29 d1                	sub    %edx,%ecx
  80203d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802041:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802045:	83 c0 01             	add    $0x1,%eax
  802048:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204b:	83 c7 01             	add    $0x1,%edi
  80204e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802051:	75 c8                	jne    80201b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802053:	89 f8                	mov    %edi,%eax
  802055:	eb 05                	jmp    80205c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	57                   	push   %edi
  802068:	56                   	push   %esi
  802069:	53                   	push   %ebx
  80206a:	83 ec 1c             	sub    $0x1c,%esp
  80206d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802070:	89 3c 24             	mov    %edi,(%esp)
  802073:	e8 c8 ef ff ff       	call   801040 <fd2data>
  802078:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80207a:	be 00 00 00 00       	mov    $0x0,%esi
  80207f:	eb 3d                	jmp    8020be <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802081:	85 f6                	test   %esi,%esi
  802083:	74 04                	je     802089 <devpipe_read+0x25>
				return i;
  802085:	89 f0                	mov    %esi,%eax
  802087:	eb 43                	jmp    8020cc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802089:	89 da                	mov    %ebx,%edx
  80208b:	89 f8                	mov    %edi,%eax
  80208d:	e8 f1 fe ff ff       	call   801f83 <_pipeisclosed>
  802092:	85 c0                	test   %eax,%eax
  802094:	75 31                	jne    8020c7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802096:	e8 49 ec ff ff       	call   800ce4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80209b:	8b 03                	mov    (%ebx),%eax
  80209d:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020a0:	74 df                	je     802081 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020a2:	99                   	cltd   
  8020a3:	c1 ea 1b             	shr    $0x1b,%edx
  8020a6:	01 d0                	add    %edx,%eax
  8020a8:	83 e0 1f             	and    $0x1f,%eax
  8020ab:	29 d0                	sub    %edx,%eax
  8020ad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020b8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020bb:	83 c6 01             	add    $0x1,%esi
  8020be:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020c1:	75 d8                	jne    80209b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020c3:	89 f0                	mov    %esi,%eax
  8020c5:	eb 05                	jmp    8020cc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	56                   	push   %esi
  8020d8:	53                   	push   %ebx
  8020d9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020df:	89 04 24             	mov    %eax,(%esp)
  8020e2:	e8 70 ef ff ff       	call   801057 <fd_alloc>
  8020e7:	89 c2                	mov    %eax,%edx
  8020e9:	85 d2                	test   %edx,%edx
  8020eb:	0f 88 4d 01 00 00    	js     80223e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020f8:	00 
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802107:	e8 f7 eb ff ff       	call   800d03 <sys_page_alloc>
  80210c:	89 c2                	mov    %eax,%edx
  80210e:	85 d2                	test   %edx,%edx
  802110:	0f 88 28 01 00 00    	js     80223e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802119:	89 04 24             	mov    %eax,(%esp)
  80211c:	e8 36 ef ff ff       	call   801057 <fd_alloc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	85 c0                	test   %eax,%eax
  802125:	0f 88 fe 00 00 00    	js     802229 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802132:	00 
  802133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802141:	e8 bd eb ff ff       	call   800d03 <sys_page_alloc>
  802146:	89 c3                	mov    %eax,%ebx
  802148:	85 c0                	test   %eax,%eax
  80214a:	0f 88 d9 00 00 00    	js     802229 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 e5 ee ff ff       	call   801040 <fd2data>
  80215b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802164:	00 
  802165:	89 44 24 04          	mov    %eax,0x4(%esp)
  802169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802170:	e8 8e eb ff ff       	call   800d03 <sys_page_alloc>
  802175:	89 c3                	mov    %eax,%ebx
  802177:	85 c0                	test   %eax,%eax
  802179:	0f 88 97 00 00 00    	js     802216 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802182:	89 04 24             	mov    %eax,(%esp)
  802185:	e8 b6 ee ff ff       	call   801040 <fd2data>
  80218a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802191:	00 
  802192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802196:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80219d:	00 
  80219e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a9:	e8 a9 eb ff ff       	call   800d57 <sys_page_map>
  8021ae:	89 c3                	mov    %eax,%ebx
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	78 52                	js     802206 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021c9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e1:	89 04 24             	mov    %eax,(%esp)
  8021e4:	e8 47 ee ff ff       	call   801030 <fd2num>
  8021e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ec:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f1:	89 04 24             	mov    %eax,(%esp)
  8021f4:	e8 37 ee ff ff       	call   801030 <fd2num>
  8021f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802204:	eb 38                	jmp    80223e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802211:	e8 94 eb ff ff       	call   800daa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802224:	e8 81 eb ff ff       	call   800daa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802230:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802237:	e8 6e eb ff ff       	call   800daa <sys_page_unmap>
  80223c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80223e:	83 c4 30             	add    $0x30,%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802252:	8b 45 08             	mov    0x8(%ebp),%eax
  802255:	89 04 24             	mov    %eax,(%esp)
  802258:	e8 49 ee ff ff       	call   8010a6 <fd_lookup>
  80225d:	89 c2                	mov    %eax,%edx
  80225f:	85 d2                	test   %edx,%edx
  802261:	78 15                	js     802278 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802266:	89 04 24             	mov    %eax,(%esp)
  802269:	e8 d2 ed ff ff       	call   801040 <fd2data>
	return _pipeisclosed(fd, p);
  80226e:	89 c2                	mov    %eax,%edx
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	e8 0b fd ff ff       	call   801f83 <_pipeisclosed>
}
  802278:	c9                   	leave  
  802279:	c3                   	ret    
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802283:	b8 00 00 00 00       	mov    $0x0,%eax
  802288:	5d                   	pop    %ebp
  802289:	c3                   	ret    

0080228a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802290:	c7 44 24 04 e7 2c 80 	movl   $0x802ce7,0x4(%esp)
  802297:	00 
  802298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229b:	89 04 24             	mov    %eax,(%esp)
  80229e:	e8 44 e6 ff ff       	call   8008e7 <strcpy>
	return 0;
}
  8022a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	57                   	push   %edi
  8022ae:	56                   	push   %esi
  8022af:	53                   	push   %ebx
  8022b0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c1:	eb 31                	jmp    8022f4 <devcons_write+0x4a>
		m = n - tot;
  8022c3:	8b 75 10             	mov    0x10(%ebp),%esi
  8022c6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8022c8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022cb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022d0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022d7:	03 45 0c             	add    0xc(%ebp),%eax
  8022da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022de:	89 3c 24             	mov    %edi,(%esp)
  8022e1:	e8 9e e7 ff ff       	call   800a84 <memmove>
		sys_cputs(buf, m);
  8022e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ea:	89 3c 24             	mov    %edi,(%esp)
  8022ed:	e8 44 e9 ff ff       	call   800c36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f2:	01 f3                	add    %esi,%ebx
  8022f4:	89 d8                	mov    %ebx,%eax
  8022f6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022f9:	72 c8                	jb     8022c3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022fb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5f                   	pop    %edi
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80230c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802311:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802315:	75 07                	jne    80231e <devcons_read+0x18>
  802317:	eb 2a                	jmp    802343 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802319:	e8 c6 e9 ff ff       	call   800ce4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80231e:	66 90                	xchg   %ax,%ax
  802320:	e8 2f e9 ff ff       	call   800c54 <sys_cgetc>
  802325:	85 c0                	test   %eax,%eax
  802327:	74 f0                	je     802319 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 16                	js     802343 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80232d:	83 f8 04             	cmp    $0x4,%eax
  802330:	74 0c                	je     80233e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802332:	8b 55 0c             	mov    0xc(%ebp),%edx
  802335:	88 02                	mov    %al,(%edx)
	return 1;
  802337:	b8 01 00 00 00       	mov    $0x1,%eax
  80233c:	eb 05                	jmp    802343 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802343:	c9                   	leave  
  802344:	c3                   	ret    

00802345 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802351:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802358:	00 
  802359:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235c:	89 04 24             	mov    %eax,(%esp)
  80235f:	e8 d2 e8 ff ff       	call   800c36 <sys_cputs>
}
  802364:	c9                   	leave  
  802365:	c3                   	ret    

00802366 <getchar>:

int
getchar(void)
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80236c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802373:	00 
  802374:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802382:	e8 b3 ef ff ff       	call   80133a <read>
	if (r < 0)
  802387:	85 c0                	test   %eax,%eax
  802389:	78 0f                	js     80239a <getchar+0x34>
		return r;
	if (r < 1)
  80238b:	85 c0                	test   %eax,%eax
  80238d:	7e 06                	jle    802395 <getchar+0x2f>
		return -E_EOF;
	return c;
  80238f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802393:	eb 05                	jmp    80239a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802395:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80239a:	c9                   	leave  
  80239b:	c3                   	ret    

0080239c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80239c:	55                   	push   %ebp
  80239d:	89 e5                	mov    %esp,%ebp
  80239f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ac:	89 04 24             	mov    %eax,(%esp)
  8023af:	e8 f2 ec ff ff       	call   8010a6 <fd_lookup>
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	78 11                	js     8023c9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023c1:	39 10                	cmp    %edx,(%eax)
  8023c3:	0f 94 c0             	sete   %al
  8023c6:	0f b6 c0             	movzbl %al,%eax
}
  8023c9:	c9                   	leave  
  8023ca:	c3                   	ret    

008023cb <opencons>:

int
opencons(void)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d4:	89 04 24             	mov    %eax,(%esp)
  8023d7:	e8 7b ec ff ff       	call   801057 <fd_alloc>
		return r;
  8023dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 40                	js     802422 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023e9:	00 
  8023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f8:	e8 06 e9 ff ff       	call   800d03 <sys_page_alloc>
		return r;
  8023fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 1f                	js     802422 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802403:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802411:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802418:	89 04 24             	mov    %eax,(%esp)
  80241b:	e8 10 ec ff ff       	call   801030 <fd2num>
  802420:	89 c2                	mov    %eax,%edx
}
  802422:	89 d0                	mov    %edx,%eax
  802424:	c9                   	leave  
  802425:	c3                   	ret    
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	56                   	push   %esi
  802434:	53                   	push   %ebx
  802435:	83 ec 10             	sub    $0x10,%esp
  802438:	8b 75 08             	mov    0x8(%ebp),%esi
  80243b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80243e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802441:	85 c0                	test   %eax,%eax
  802443:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802448:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80244b:	89 04 24             	mov    %eax,(%esp)
  80244e:	e8 c6 ea ff ff       	call   800f19 <sys_ipc_recv>

	if(ret < 0) {
  802453:	85 c0                	test   %eax,%eax
  802455:	79 16                	jns    80246d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802457:	85 f6                	test   %esi,%esi
  802459:	74 06                	je     802461 <ipc_recv+0x31>
  80245b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802461:	85 db                	test   %ebx,%ebx
  802463:	74 3e                	je     8024a3 <ipc_recv+0x73>
  802465:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80246b:	eb 36                	jmp    8024a3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80246d:	e8 53 e8 ff ff       	call   800cc5 <sys_getenvid>
  802472:	25 ff 03 00 00       	and    $0x3ff,%eax
  802477:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80247a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80247f:	a3 20 60 80 00       	mov    %eax,0x806020

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802484:	85 f6                	test   %esi,%esi
  802486:	74 05                	je     80248d <ipc_recv+0x5d>
  802488:	8b 40 74             	mov    0x74(%eax),%eax
  80248b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80248d:	85 db                	test   %ebx,%ebx
  80248f:	74 0a                	je     80249b <ipc_recv+0x6b>
  802491:	a1 20 60 80 00       	mov    0x806020,%eax
  802496:	8b 40 78             	mov    0x78(%eax),%eax
  802499:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80249b:	a1 20 60 80 00       	mov    0x806020,%eax
  8024a0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024a3:	83 c4 10             	add    $0x10,%esp
  8024a6:	5b                   	pop    %ebx
  8024a7:	5e                   	pop    %esi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    

008024aa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	57                   	push   %edi
  8024ae:	56                   	push   %esi
  8024af:	53                   	push   %ebx
  8024b0:	83 ec 1c             	sub    $0x1c,%esp
  8024b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8024bc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8024be:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024c3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8024c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d5:	89 3c 24             	mov    %edi,(%esp)
  8024d8:	e8 19 ea ff ff       	call   800ef6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	79 2c                	jns    80250d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8024e1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024e4:	74 20                	je     802506 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8024e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ea:	c7 44 24 08 f4 2c 80 	movl   $0x802cf4,0x8(%esp)
  8024f1:	00 
  8024f2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024f9:	00 
  8024fa:	c7 04 24 24 2d 80 00 	movl   $0x802d24,(%esp)
  802501:	e8 c0 dc ff ff       	call   8001c6 <_panic>
		}
		sys_yield();
  802506:	e8 d9 e7 ff ff       	call   800ce4 <sys_yield>
	}
  80250b:	eb b9                	jmp    8024c6 <ipc_send+0x1c>
}
  80250d:	83 c4 1c             	add    $0x1c,%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80251b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802520:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802523:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802529:	8b 52 50             	mov    0x50(%edx),%edx
  80252c:	39 ca                	cmp    %ecx,%edx
  80252e:	75 0d                	jne    80253d <ipc_find_env+0x28>
			return envs[i].env_id;
  802530:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802533:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802538:	8b 40 40             	mov    0x40(%eax),%eax
  80253b:	eb 0e                	jmp    80254b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80253d:	83 c0 01             	add    $0x1,%eax
  802540:	3d 00 04 00 00       	cmp    $0x400,%eax
  802545:	75 d9                	jne    802520 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802547:	66 b8 00 00          	mov    $0x0,%ax
}
  80254b:	5d                   	pop    %ebp
  80254c:	c3                   	ret    

0080254d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80254d:	55                   	push   %ebp
  80254e:	89 e5                	mov    %esp,%ebp
  802550:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802553:	89 d0                	mov    %edx,%eax
  802555:	c1 e8 16             	shr    $0x16,%eax
  802558:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80255f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802564:	f6 c1 01             	test   $0x1,%cl
  802567:	74 1d                	je     802586 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802569:	c1 ea 0c             	shr    $0xc,%edx
  80256c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802573:	f6 c2 01             	test   $0x1,%dl
  802576:	74 0e                	je     802586 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802578:	c1 ea 0c             	shr    $0xc,%edx
  80257b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802582:	ef 
  802583:	0f b7 c0             	movzwl %ax,%eax
}
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 0c             	sub    $0xc,%esp
  802596:	8b 44 24 28          	mov    0x28(%esp),%eax
  80259a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80259e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8025a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8025a6:	85 c0                	test   %eax,%eax
  8025a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025ac:	89 ea                	mov    %ebp,%edx
  8025ae:	89 0c 24             	mov    %ecx,(%esp)
  8025b1:	75 2d                	jne    8025e0 <__udivdi3+0x50>
  8025b3:	39 e9                	cmp    %ebp,%ecx
  8025b5:	77 61                	ja     802618 <__udivdi3+0x88>
  8025b7:	85 c9                	test   %ecx,%ecx
  8025b9:	89 ce                	mov    %ecx,%esi
  8025bb:	75 0b                	jne    8025c8 <__udivdi3+0x38>
  8025bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c2:	31 d2                	xor    %edx,%edx
  8025c4:	f7 f1                	div    %ecx
  8025c6:	89 c6                	mov    %eax,%esi
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	89 e8                	mov    %ebp,%eax
  8025cc:	f7 f6                	div    %esi
  8025ce:	89 c5                	mov    %eax,%ebp
  8025d0:	89 f8                	mov    %edi,%eax
  8025d2:	f7 f6                	div    %esi
  8025d4:	89 ea                	mov    %ebp,%edx
  8025d6:	83 c4 0c             	add    $0xc,%esp
  8025d9:	5e                   	pop    %esi
  8025da:	5f                   	pop    %edi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    
  8025dd:	8d 76 00             	lea    0x0(%esi),%esi
  8025e0:	39 e8                	cmp    %ebp,%eax
  8025e2:	77 24                	ja     802608 <__udivdi3+0x78>
  8025e4:	0f bd e8             	bsr    %eax,%ebp
  8025e7:	83 f5 1f             	xor    $0x1f,%ebp
  8025ea:	75 3c                	jne    802628 <__udivdi3+0x98>
  8025ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025f0:	39 34 24             	cmp    %esi,(%esp)
  8025f3:	0f 86 9f 00 00 00    	jbe    802698 <__udivdi3+0x108>
  8025f9:	39 d0                	cmp    %edx,%eax
  8025fb:	0f 82 97 00 00 00    	jb     802698 <__udivdi3+0x108>
  802601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802608:	31 d2                	xor    %edx,%edx
  80260a:	31 c0                	xor    %eax,%eax
  80260c:	83 c4 0c             	add    $0xc,%esp
  80260f:	5e                   	pop    %esi
  802610:	5f                   	pop    %edi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	89 f8                	mov    %edi,%eax
  80261a:	f7 f1                	div    %ecx
  80261c:	31 d2                	xor    %edx,%edx
  80261e:	83 c4 0c             	add    $0xc,%esp
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	8b 3c 24             	mov    (%esp),%edi
  80262d:	d3 e0                	shl    %cl,%eax
  80262f:	89 c6                	mov    %eax,%esi
  802631:	b8 20 00 00 00       	mov    $0x20,%eax
  802636:	29 e8                	sub    %ebp,%eax
  802638:	89 c1                	mov    %eax,%ecx
  80263a:	d3 ef                	shr    %cl,%edi
  80263c:	89 e9                	mov    %ebp,%ecx
  80263e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802642:	8b 3c 24             	mov    (%esp),%edi
  802645:	09 74 24 08          	or     %esi,0x8(%esp)
  802649:	89 d6                	mov    %edx,%esi
  80264b:	d3 e7                	shl    %cl,%edi
  80264d:	89 c1                	mov    %eax,%ecx
  80264f:	89 3c 24             	mov    %edi,(%esp)
  802652:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802656:	d3 ee                	shr    %cl,%esi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	d3 e2                	shl    %cl,%edx
  80265c:	89 c1                	mov    %eax,%ecx
  80265e:	d3 ef                	shr    %cl,%edi
  802660:	09 d7                	or     %edx,%edi
  802662:	89 f2                	mov    %esi,%edx
  802664:	89 f8                	mov    %edi,%eax
  802666:	f7 74 24 08          	divl   0x8(%esp)
  80266a:	89 d6                	mov    %edx,%esi
  80266c:	89 c7                	mov    %eax,%edi
  80266e:	f7 24 24             	mull   (%esp)
  802671:	39 d6                	cmp    %edx,%esi
  802673:	89 14 24             	mov    %edx,(%esp)
  802676:	72 30                	jb     8026a8 <__udivdi3+0x118>
  802678:	8b 54 24 04          	mov    0x4(%esp),%edx
  80267c:	89 e9                	mov    %ebp,%ecx
  80267e:	d3 e2                	shl    %cl,%edx
  802680:	39 c2                	cmp    %eax,%edx
  802682:	73 05                	jae    802689 <__udivdi3+0xf9>
  802684:	3b 34 24             	cmp    (%esp),%esi
  802687:	74 1f                	je     8026a8 <__udivdi3+0x118>
  802689:	89 f8                	mov    %edi,%eax
  80268b:	31 d2                	xor    %edx,%edx
  80268d:	e9 7a ff ff ff       	jmp    80260c <__udivdi3+0x7c>
  802692:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802698:	31 d2                	xor    %edx,%edx
  80269a:	b8 01 00 00 00       	mov    $0x1,%eax
  80269f:	e9 68 ff ff ff       	jmp    80260c <__udivdi3+0x7c>
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	83 c4 0c             	add    $0xc,%esp
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	83 ec 14             	sub    $0x14,%esp
  8026c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8026ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8026ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8026d2:	89 c7                	mov    %eax,%edi
  8026d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026e0:	89 34 24             	mov    %esi,(%esp)
  8026e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e7:	85 c0                	test   %eax,%eax
  8026e9:	89 c2                	mov    %eax,%edx
  8026eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026ef:	75 17                	jne    802708 <__umoddi3+0x48>
  8026f1:	39 fe                	cmp    %edi,%esi
  8026f3:	76 4b                	jbe    802740 <__umoddi3+0x80>
  8026f5:	89 c8                	mov    %ecx,%eax
  8026f7:	89 fa                	mov    %edi,%edx
  8026f9:	f7 f6                	div    %esi
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	31 d2                	xor    %edx,%edx
  8026ff:	83 c4 14             	add    $0x14,%esp
  802702:	5e                   	pop    %esi
  802703:	5f                   	pop    %edi
  802704:	5d                   	pop    %ebp
  802705:	c3                   	ret    
  802706:	66 90                	xchg   %ax,%ax
  802708:	39 f8                	cmp    %edi,%eax
  80270a:	77 54                	ja     802760 <__umoddi3+0xa0>
  80270c:	0f bd e8             	bsr    %eax,%ebp
  80270f:	83 f5 1f             	xor    $0x1f,%ebp
  802712:	75 5c                	jne    802770 <__umoddi3+0xb0>
  802714:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802718:	39 3c 24             	cmp    %edi,(%esp)
  80271b:	0f 87 e7 00 00 00    	ja     802808 <__umoddi3+0x148>
  802721:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802725:	29 f1                	sub    %esi,%ecx
  802727:	19 c7                	sbb    %eax,%edi
  802729:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802731:	8b 44 24 08          	mov    0x8(%esp),%eax
  802735:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802739:	83 c4 14             	add    $0x14,%esp
  80273c:	5e                   	pop    %esi
  80273d:	5f                   	pop    %edi
  80273e:	5d                   	pop    %ebp
  80273f:	c3                   	ret    
  802740:	85 f6                	test   %esi,%esi
  802742:	89 f5                	mov    %esi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f6                	div    %esi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	8b 44 24 04          	mov    0x4(%esp),%eax
  802755:	31 d2                	xor    %edx,%edx
  802757:	f7 f5                	div    %ebp
  802759:	89 c8                	mov    %ecx,%eax
  80275b:	f7 f5                	div    %ebp
  80275d:	eb 9c                	jmp    8026fb <__umoddi3+0x3b>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 fa                	mov    %edi,%edx
  802764:	83 c4 14             	add    $0x14,%esp
  802767:	5e                   	pop    %esi
  802768:	5f                   	pop    %edi
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    
  80276b:	90                   	nop
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 04 24             	mov    (%esp),%eax
  802773:	be 20 00 00 00       	mov    $0x20,%esi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ee                	sub    %ebp,%esi
  80277c:	d3 e2                	shl    %cl,%edx
  80277e:	89 f1                	mov    %esi,%ecx
  802780:	d3 e8                	shr    %cl,%eax
  802782:	89 e9                	mov    %ebp,%ecx
  802784:	89 44 24 04          	mov    %eax,0x4(%esp)
  802788:	8b 04 24             	mov    (%esp),%eax
  80278b:	09 54 24 04          	or     %edx,0x4(%esp)
  80278f:	89 fa                	mov    %edi,%edx
  802791:	d3 e0                	shl    %cl,%eax
  802793:	89 f1                	mov    %esi,%ecx
  802795:	89 44 24 08          	mov    %eax,0x8(%esp)
  802799:	8b 44 24 10          	mov    0x10(%esp),%eax
  80279d:	d3 ea                	shr    %cl,%edx
  80279f:	89 e9                	mov    %ebp,%ecx
  8027a1:	d3 e7                	shl    %cl,%edi
  8027a3:	89 f1                	mov    %esi,%ecx
  8027a5:	d3 e8                	shr    %cl,%eax
  8027a7:	89 e9                	mov    %ebp,%ecx
  8027a9:	09 f8                	or     %edi,%eax
  8027ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8027af:	f7 74 24 04          	divl   0x4(%esp)
  8027b3:	d3 e7                	shl    %cl,%edi
  8027b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027b9:	89 d7                	mov    %edx,%edi
  8027bb:	f7 64 24 08          	mull   0x8(%esp)
  8027bf:	39 d7                	cmp    %edx,%edi
  8027c1:	89 c1                	mov    %eax,%ecx
  8027c3:	89 14 24             	mov    %edx,(%esp)
  8027c6:	72 2c                	jb     8027f4 <__umoddi3+0x134>
  8027c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8027cc:	72 22                	jb     8027f0 <__umoddi3+0x130>
  8027ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027d2:	29 c8                	sub    %ecx,%eax
  8027d4:	19 d7                	sbb    %edx,%edi
  8027d6:	89 e9                	mov    %ebp,%ecx
  8027d8:	89 fa                	mov    %edi,%edx
  8027da:	d3 e8                	shr    %cl,%eax
  8027dc:	89 f1                	mov    %esi,%ecx
  8027de:	d3 e2                	shl    %cl,%edx
  8027e0:	89 e9                	mov    %ebp,%ecx
  8027e2:	d3 ef                	shr    %cl,%edi
  8027e4:	09 d0                	or     %edx,%eax
  8027e6:	89 fa                	mov    %edi,%edx
  8027e8:	83 c4 14             	add    $0x14,%esp
  8027eb:	5e                   	pop    %esi
  8027ec:	5f                   	pop    %edi
  8027ed:	5d                   	pop    %ebp
  8027ee:	c3                   	ret    
  8027ef:	90                   	nop
  8027f0:	39 d7                	cmp    %edx,%edi
  8027f2:	75 da                	jne    8027ce <__umoddi3+0x10e>
  8027f4:	8b 14 24             	mov    (%esp),%edx
  8027f7:	89 c1                	mov    %eax,%ecx
  8027f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8027fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802801:	eb cb                	jmp    8027ce <__umoddi3+0x10e>
  802803:	90                   	nop
  802804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802808:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80280c:	0f 82 0f ff ff ff    	jb     802721 <__umoddi3+0x61>
  802812:	e9 1a ff ff ff       	jmp    802731 <__umoddi3+0x71>
