
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 41 01 00 00       	call   800172 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int packet = 42;
  80003e:	c7 45 f4 2a 00 00 00 	movl   $0x2a,-0xc(%ebp)
	sys_try_send_packet((void *)&packet, 1);
  800045:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80004c:	00 
  80004d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 42 0f 00 00       	call   800f9a <sys_try_send_packet>
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  800058:	c7 05 00 40 80 00 40 	movl   $0x802d40,0x804000
  80005f:	2d 80 00 

	cprintf("icode startup\n");
  800062:	c7 04 24 46 2d 80 00 	movl   $0x802d46,(%esp)
  800069:	e8 5e 02 00 00       	call   8002cc <cprintf>

	cprintf("icode: open /motd\n");
  80006e:	c7 04 24 55 2d 80 00 	movl   $0x802d55,(%esp)
  800075:	e8 52 02 00 00       	call   8002cc <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80007a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800081:	00 
  800082:	c7 04 24 68 2d 80 00 	movl   $0x802d68,(%esp)
  800089:	e8 95 17 00 00       	call   801823 <open>
  80008e:	89 c6                	mov    %eax,%esi
  800090:	85 c0                	test   %eax,%eax
  800092:	79 20                	jns    8000b4 <umain+0x81>
		panic("icode: open /motd: %e", fd);
  800094:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800098:	c7 44 24 08 6e 2d 80 	movl   $0x802d6e,0x8(%esp)
  80009f:	00 
  8000a0:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  8000a7:	00 
  8000a8:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  8000af:	e8 1f 01 00 00       	call   8001d3 <_panic>

	cprintf("icode: read /motd\n");
  8000b4:	c7 04 24 91 2d 80 00 	movl   $0x802d91,(%esp)
  8000bb:	e8 0c 02 00 00       	call   8002cc <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000c0:	8d 9d f3 fd ff ff    	lea    -0x20d(%ebp),%ebx
  8000c6:	eb 0c                	jmp    8000d4 <umain+0xa1>
		sys_cputs(buf, n);
  8000c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000cc:	89 1c 24             	mov    %ebx,(%esp)
  8000cf:	e8 72 0b 00 00       	call   800c46 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000d4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	89 34 24             	mov    %esi,(%esp)
  8000e3:	e8 62 12 00 00       	call   80134a <read>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	7f dc                	jg     8000c8 <umain+0x95>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000ec:	c7 04 24 a4 2d 80 00 	movl   $0x802da4,(%esp)
  8000f3:	e8 d4 01 00 00       	call   8002cc <cprintf>
	close(fd);
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 e7 10 00 00       	call   8011e7 <close>

	cprintf("icode: spawn /init\n");
  800100:	c7 04 24 b8 2d 80 00 	movl   $0x802db8,(%esp)
  800107:	e8 c0 01 00 00       	call   8002cc <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  80010c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800113:	00 
  800114:	c7 44 24 0c cc 2d 80 	movl   $0x802dcc,0xc(%esp)
  80011b:	00 
  80011c:	c7 44 24 08 d5 2d 80 	movl   $0x802dd5,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 df 2d 80 	movl   $0x802ddf,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 de 2d 80 00 	movl   $0x802dde,(%esp)
  800133:	e8 5f 1d 00 00       	call   801e97 <spawnl>
  800138:	85 c0                	test   %eax,%eax
  80013a:	79 20                	jns    80015c <umain+0x129>
		panic("icode: spawn /init: %e", r);
  80013c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800140:	c7 44 24 08 e4 2d 80 	movl   $0x802de4,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80014f:	00 
  800150:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  800157:	e8 77 00 00 00       	call   8001d3 <_panic>

	cprintf("icode: exiting\n");
  80015c:	c7 04 24 fb 2d 80 00 	movl   $0x802dfb,(%esp)
  800163:	e8 64 01 00 00       	call   8002cc <cprintf>
}
  800168:	81 c4 30 02 00 00    	add    $0x230,%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 10             	sub    $0x10,%esp
  80017a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80017d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800180:	e8 50 0b 00 00       	call   800cd5 <sys_getenvid>
  800185:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80018d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800192:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800197:	85 db                	test   %ebx,%ebx
  800199:	7e 07                	jle    8001a2 <libmain+0x30>
		binaryname = argv[0];
  80019b:	8b 06                	mov    (%esi),%eax
  80019d:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 1c 24             	mov    %ebx,(%esp)
  8001a9:	e8 85 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ae:	e8 07 00 00 00       	call   8001ba <exit>
}
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    

008001ba <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001c0:	e8 55 10 00 00       	call   80121a <close_all>
	sys_env_destroy(0);
  8001c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001cc:	e8 b2 0a 00 00       	call   800c83 <sys_env_destroy>
}
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001de:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8001e4:	e8 ec 0a 00 00       	call   800cd5 <sys_getenvid>
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	c7 04 24 18 2e 80 00 	movl   $0x802e18,(%esp)
  800206:	e8 c1 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80020f:	8b 45 10             	mov    0x10(%ebp),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 51 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  80021a:	c7 04 24 47 33 80 00 	movl   $0x803347,(%esp)
  800221:	e8 a6 00 00 00       	call   8002cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800226:	cc                   	int3   
  800227:	eb fd                	jmp    800226 <_panic+0x53>

00800229 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	53                   	push   %ebx
  80022d:	83 ec 14             	sub    $0x14,%esp
  800230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800233:	8b 13                	mov    (%ebx),%edx
  800235:	8d 42 01             	lea    0x1(%edx),%eax
  800238:	89 03                	mov    %eax,(%ebx)
  80023a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800241:	3d ff 00 00 00       	cmp    $0xff,%eax
  800246:	75 19                	jne    800261 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800248:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80024f:	00 
  800250:	8d 43 08             	lea    0x8(%ebx),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 eb 09 00 00       	call   800c46 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800261:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	5b                   	pop    %ebx
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	c7 04 24 29 02 80 00 	movl   $0x800229,(%esp)
  8002a7:	e8 b2 01 00 00       	call   80045e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 82 09 00 00       	call   800c46 <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 87 ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
  8002e6:	66 90                	xchg   %ax,%ax
  8002e8:	66 90                	xchg   %ax,%ax
  8002ea:	66 90                	xchg   %ax,%ax
  8002ec:	66 90                	xchg   %ax,%ax
  8002ee:	66 90                	xchg   %ax,%ax

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 3c             	sub    $0x3c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d7                	mov    %edx,%edi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	89 c3                	mov    %eax,%ebx
  800309:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80031d:	39 d9                	cmp    %ebx,%ecx
  80031f:	72 05                	jb     800326 <printnum+0x36>
  800321:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800324:	77 69                	ja     80038f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800326:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800329:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80032d:	83 ee 01             	sub    $0x1,%esi
  800330:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	8b 44 24 08          	mov    0x8(%esp),%eax
  80033c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800340:	89 c3                	mov    %eax,%ebx
  800342:	89 d6                	mov    %edx,%esi
  800344:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800347:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80034a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80034e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	e8 4c 27 00 00       	call   802ab0 <__udivdi3>
  800364:	89 d9                	mov    %ebx,%ecx
  800366:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80036a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	89 54 24 04          	mov    %edx,0x4(%esp)
  800375:	89 fa                	mov    %edi,%edx
  800377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037a:	e8 71 ff ff ff       	call   8002f0 <printnum>
  80037f:	eb 1b                	jmp    80039c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800381:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800385:	8b 45 18             	mov    0x18(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff d3                	call   *%ebx
  80038d:	eb 03                	jmp    800392 <printnum+0xa2>
  80038f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800392:	83 ee 01             	sub    $0x1,%esi
  800395:	85 f6                	test   %esi,%esi
  800397:	7f e8                	jg     800381 <printnum+0x91>
  800399:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bf:	e8 1c 28 00 00       	call   802be0 <__umoddi3>
  8003c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c8:	0f be 80 3b 2e 80 00 	movsbl 0x802e3b(%eax),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d5:	ff d0                	call   *%eax
}
  8003d7:	83 c4 3c             	add    $0x3c,%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5e                   	pop    %esi
  8003dc:	5f                   	pop    %edi
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e2:	83 fa 01             	cmp    $0x1,%edx
  8003e5:	7e 0e                	jle    8003f5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ec:	89 08                	mov    %ecx,(%eax)
  8003ee:	8b 02                	mov    (%edx),%eax
  8003f0:	8b 52 04             	mov    0x4(%edx),%edx
  8003f3:	eb 22                	jmp    800417 <getuint+0x38>
	else if (lflag)
  8003f5:	85 d2                	test   %edx,%edx
  8003f7:	74 10                	je     800409 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
  800407:	eb 0e                	jmp    800417 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040e:	89 08                	mov    %ecx,(%eax)
  800410:	8b 02                	mov    (%edx),%eax
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800423:	8b 10                	mov    (%eax),%edx
  800425:	3b 50 04             	cmp    0x4(%eax),%edx
  800428:	73 0a                	jae    800434 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	88 02                	mov    %al,(%edx)
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80043c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 10             	mov    0x10(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	e8 02 00 00 00       	call   80045e <vprintfmt>
	va_end(ap);
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	57                   	push   %edi
  800462:	56                   	push   %esi
  800463:	53                   	push   %ebx
  800464:	83 ec 3c             	sub    $0x3c,%esp
  800467:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80046a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80046d:	eb 14                	jmp    800483 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80046f:	85 c0                	test   %eax,%eax
  800471:	0f 84 b3 03 00 00    	je     80082a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800477:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800481:	89 f3                	mov    %esi,%ebx
  800483:	8d 73 01             	lea    0x1(%ebx),%esi
  800486:	0f b6 03             	movzbl (%ebx),%eax
  800489:	83 f8 25             	cmp    $0x25,%eax
  80048c:	75 e1                	jne    80046f <vprintfmt+0x11>
  80048e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800492:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800499:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004a0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ac:	eb 1d                	jmp    8004cb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004b4:	eb 15                	jmp    8004cb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004bc:	eb 0d                	jmp    8004cb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004ce:	0f b6 0e             	movzbl (%esi),%ecx
  8004d1:	0f b6 c1             	movzbl %cl,%eax
  8004d4:	83 e9 23             	sub    $0x23,%ecx
  8004d7:	80 f9 55             	cmp    $0x55,%cl
  8004da:	0f 87 2a 03 00 00    	ja     80080a <vprintfmt+0x3ac>
  8004e0:	0f b6 c9             	movzbl %cl,%ecx
  8004e3:	ff 24 8d 80 2f 80 00 	jmp    *0x802f80(,%ecx,4)
  8004ea:	89 de                	mov    %ebx,%esi
  8004ec:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004f4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004f8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004fb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004fe:	83 fb 09             	cmp    $0x9,%ebx
  800501:	77 36                	ja     800539 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800503:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800506:	eb e9                	jmp    8004f1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 48 04             	lea    0x4(%eax),%ecx
  80050e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800518:	eb 22                	jmp    80053c <vprintfmt+0xde>
  80051a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	b8 00 00 00 00       	mov    $0x0,%eax
  800524:	0f 49 c1             	cmovns %ecx,%eax
  800527:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	89 de                	mov    %ebx,%esi
  80052c:	eb 9d                	jmp    8004cb <vprintfmt+0x6d>
  80052e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800530:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800537:	eb 92                	jmp    8004cb <vprintfmt+0x6d>
  800539:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80053c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800540:	79 89                	jns    8004cb <vprintfmt+0x6d>
  800542:	e9 77 ff ff ff       	jmp    8004be <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800547:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 7a ff ff ff       	jmp    8004cb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
			break;
  800566:	e9 18 ff ff ff       	jmp    800483 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 00                	mov    (%eax),%eax
  800576:	99                   	cltd   
  800577:	31 d0                	xor    %edx,%eax
  800579:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057b:	83 f8 0f             	cmp    $0xf,%eax
  80057e:	7f 0b                	jg     80058b <vprintfmt+0x12d>
  800580:	8b 14 85 e0 30 80 00 	mov    0x8030e0(,%eax,4),%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	75 20                	jne    8005ab <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80058b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058f:	c7 44 24 08 53 2e 80 	movl   $0x802e53,0x8(%esp)
  800596:	00 
  800597:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059b:	8b 45 08             	mov    0x8(%ebp),%eax
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	e8 90 fe ff ff       	call   800436 <printfmt>
  8005a6:	e9 d8 fe ff ff       	jmp    800483 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005af:	c7 44 24 08 15 32 80 	movl   $0x803215,0x8(%esp)
  8005b6:	00 
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	e8 70 fe ff ff       	call   800436 <printfmt>
  8005c6:	e9 b8 fe ff ff       	jmp    800483 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005df:	85 f6                	test   %esi,%esi
  8005e1:	b8 4c 2e 80 00       	mov    $0x802e4c,%eax
  8005e6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005e9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005ed:	0f 84 97 00 00 00    	je     80068a <vprintfmt+0x22c>
  8005f3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f7:	0f 8e 9b 00 00 00    	jle    800698 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800601:	89 34 24             	mov    %esi,(%esp)
  800604:	e8 cf 02 00 00       	call   8008d8 <strnlen>
  800609:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80060c:	29 c2                	sub    %eax,%edx
  80060e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800611:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800615:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800618:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800621:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	eb 0f                	jmp    800634 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800625:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800629:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	85 db                	test   %ebx,%ebx
  800636:	7f ed                	jg     800625 <vprintfmt+0x1c7>
  800638:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80063b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	b8 00 00 00 00       	mov    $0x0,%eax
  800645:	0f 49 c2             	cmovns %edx,%eax
  800648:	29 c2                	sub    %eax,%edx
  80064a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064d:	89 d7                	mov    %edx,%edi
  80064f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800652:	eb 50                	jmp    8006a4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800658:	74 1e                	je     800678 <vprintfmt+0x21a>
  80065a:	0f be d2             	movsbl %dl,%edx
  80065d:	83 ea 20             	sub    $0x20,%edx
  800660:	83 fa 5e             	cmp    $0x5e,%edx
  800663:	76 13                	jbe    800678 <vprintfmt+0x21a>
					putch('?', putdat);
  800665:	8b 45 0c             	mov    0xc(%ebp),%eax
  800668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
  800676:	eb 0d                	jmp    800685 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067f:	89 04 24             	mov    %eax,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	eb 1a                	jmp    8006a4 <vprintfmt+0x246>
  80068a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800690:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800693:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800696:	eb 0c                	jmp    8006a4 <vprintfmt+0x246>
  800698:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80069b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80069e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a4:	83 c6 01             	add    $0x1,%esi
  8006a7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006ab:	0f be c2             	movsbl %dl,%eax
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	74 27                	je     8006d9 <vprintfmt+0x27b>
  8006b2:	85 db                	test   %ebx,%ebx
  8006b4:	78 9e                	js     800654 <vprintfmt+0x1f6>
  8006b6:	83 eb 01             	sub    $0x1,%ebx
  8006b9:	79 99                	jns    800654 <vprintfmt+0x1f6>
  8006bb:	89 f8                	mov    %edi,%eax
  8006bd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c3:	89 c3                	mov    %eax,%ebx
  8006c5:	eb 1a                	jmp    8006e1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d4:	83 eb 01             	sub    $0x1,%ebx
  8006d7:	eb 08                	jmp    8006e1 <vprintfmt+0x283>
  8006d9:	89 fb                	mov    %edi,%ebx
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	7f e2                	jg     8006c7 <vprintfmt+0x269>
  8006e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006eb:	e9 93 fd ff ff       	jmp    800483 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f0:	83 fa 01             	cmp    $0x1,%edx
  8006f3:	7e 16                	jle    80070b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 08             	lea    0x8(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 50 04             	mov    0x4(%eax),%edx
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800709:	eb 32                	jmp    80073d <vprintfmt+0x2df>
	else if (lflag)
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 18                	je     800727 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 30                	mov    (%eax),%esi
  80071a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	c1 f8 1f             	sar    $0x1f,%eax
  800722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800725:	eb 16                	jmp    80073d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 50 04             	lea    0x4(%eax),%edx
  80072d:	89 55 14             	mov    %edx,0x14(%ebp)
  800730:	8b 30                	mov    (%eax),%esi
  800732:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800735:	89 f0                	mov    %esi,%eax
  800737:	c1 f8 1f             	sar    $0x1f,%eax
  80073a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800740:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800743:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800748:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074c:	0f 89 80 00 00 00    	jns    8007d2 <vprintfmt+0x374>
				putch('-', putdat);
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80075d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800760:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800763:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800766:	f7 d8                	neg    %eax
  800768:	83 d2 00             	adc    $0x0,%edx
  80076b:	f7 da                	neg    %edx
			}
			base = 10;
  80076d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800772:	eb 5e                	jmp    8007d2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
  800777:	e8 63 fc ff ff       	call   8003df <getuint>
			base = 10;
  80077c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800781:	eb 4f                	jmp    8007d2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 54 fc ff ff       	call   8003df <getuint>
			base = 8;
  80078b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800790:	eb 40                	jmp    8007d2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800792:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800796:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80079d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007be:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c3:	eb 0d                	jmp    8007d2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c8:	e8 12 fc ff ff       	call   8003df <getuint>
			base = 16;
  8007cd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007d6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007da:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ec:	89 fa                	mov    %edi,%edx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	e8 fa fa ff ff       	call   8002f0 <printnum>
			break;
  8007f6:	e9 88 fc ff ff       	jmp    800483 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	ff 55 08             	call   *0x8(%ebp)
			break;
  800805:	e9 79 fc ff ff       	jmp    800483 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800815:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800818:	89 f3                	mov    %esi,%ebx
  80081a:	eb 03                	jmp    80081f <vprintfmt+0x3c1>
  80081c:	83 eb 01             	sub    $0x1,%ebx
  80081f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800823:	75 f7                	jne    80081c <vprintfmt+0x3be>
  800825:	e9 59 fc ff ff       	jmp    800483 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80082a:	83 c4 3c             	add    $0x3c,%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 28             	sub    $0x28,%esp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800841:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800845:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 30                	je     800883 <vsnprintf+0x51>
  800853:	85 d2                	test   %edx,%edx
  800855:	7e 2c                	jle    800883 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
  800861:	89 44 24 08          	mov    %eax,0x8(%esp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	c7 04 24 19 04 80 00 	movl   $0x800419,(%esp)
  800873:	e8 e6 fb ff ff       	call   80045e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	eb 05                	jmp    800888 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800897:	8b 45 10             	mov    0x10(%ebp),%eax
  80089a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	89 04 24             	mov    %eax,(%esp)
  8008ab:	e8 82 ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    
  8008b2:	66 90                	xchg   %ax,%ax
  8008b4:	66 90                	xchg   %ax,%ax
  8008b6:	66 90                	xchg   %ax,%ax
  8008b8:	66 90                	xchg   %ax,%ax
  8008ba:	66 90                	xchg   %ax,%ax
  8008bc:	66 90                	xchg   %ax,%ax
  8008be:	66 90                	xchg   %ax,%ax

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 03                	jmp    8008d0 <strlen+0x10>
		n++;
  8008cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d4:	75 f7                	jne    8008cd <strlen+0xd>
		n++;
	return n;
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb 03                	jmp    8008eb <strnlen+0x13>
		n++;
  8008e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008eb:	39 d0                	cmp    %edx,%eax
  8008ed:	74 06                	je     8008f5 <strnlen+0x1d>
  8008ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f3:	75 f3                	jne    8008e8 <strnlen+0x10>
		n++;
	return n;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800901:	89 c2                	mov    %eax,%edx
  800903:	83 c2 01             	add    $0x1,%edx
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800910:	84 db                	test   %bl,%bl
  800912:	75 ef                	jne    800903 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	53                   	push   %ebx
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800921:	89 1c 24             	mov    %ebx,(%esp)
  800924:	e8 97 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800930:	01 d8                	add    %ebx,%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	e8 bd ff ff ff       	call   8008f7 <strcpy>
	return dst;
}
  80093a:	89 d8                	mov    %ebx,%eax
  80093c:	83 c4 08             	add    $0x8,%esp
  80093f:	5b                   	pop    %ebx
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 75 08             	mov    0x8(%ebp),%esi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800952:	89 f2                	mov    %esi,%edx
  800954:	eb 0f                	jmp    800965 <strncpy+0x23>
		*dst++ = *src;
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095f:	80 39 01             	cmpb   $0x1,(%ecx)
  800962:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	39 da                	cmp    %ebx,%edx
  800967:	75 ed                	jne    800956 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800969:	89 f0                	mov    %esi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 75 08             	mov    0x8(%ebp),%esi
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80097d:	89 f0                	mov    %esi,%eax
  80097f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	85 c9                	test   %ecx,%ecx
  800985:	75 0b                	jne    800992 <strlcpy+0x23>
  800987:	eb 1d                	jmp    8009a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 0b                	je     8009a1 <strlcpy+0x32>
  800996:	0f b6 0a             	movzbl (%edx),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	75 ec                	jne    800989 <strlcpy+0x1a>
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	eb 02                	jmp    8009a3 <strlcpy+0x34>
  8009a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009a6:	29 f0                	sub    %esi,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b5:	eb 06                	jmp    8009bd <strcmp+0x11>
		p++, q++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
  8009ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bd:	0f b6 01             	movzbl (%ecx),%eax
  8009c0:	84 c0                	test   %al,%al
  8009c2:	74 04                	je     8009c8 <strcmp+0x1c>
  8009c4:	3a 02                	cmp    (%edx),%al
  8009c6:	74 ef                	je     8009b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 c0             	movzbl %al,%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 c3                	mov    %eax,%ebx
  8009de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e1:	eb 06                	jmp    8009e9 <strncmp+0x17>
		n--, p++, q++;
  8009e3:	83 c0 01             	add    $0x1,%eax
  8009e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e9:	39 d8                	cmp    %ebx,%eax
  8009eb:	74 15                	je     800a02 <strncmp+0x30>
  8009ed:	0f b6 08             	movzbl (%eax),%ecx
  8009f0:	84 c9                	test   %cl,%cl
  8009f2:	74 04                	je     8009f8 <strncmp+0x26>
  8009f4:	3a 0a                	cmp    (%edx),%cl
  8009f6:	74 eb                	je     8009e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f8:	0f b6 00             	movzbl (%eax),%eax
  8009fb:	0f b6 12             	movzbl (%edx),%edx
  8009fe:	29 d0                	sub    %edx,%eax
  800a00:	eb 05                	jmp    800a07 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	eb 07                	jmp    800a1d <strchr+0x13>
		if (*s == c)
  800a16:	38 ca                	cmp    %cl,%dl
  800a18:	74 0f                	je     800a29 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	eb 07                	jmp    800a3e <strfind+0x13>
		if (*s == c)
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	74 0a                	je     800a45 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	0f b6 10             	movzbl (%eax),%edx
  800a41:	84 d2                	test   %dl,%dl
  800a43:	75 f2                	jne    800a37 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a53:	85 c9                	test   %ecx,%ecx
  800a55:	74 36                	je     800a8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a57:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5d:	75 28                	jne    800a87 <memset+0x40>
  800a5f:	f6 c1 03             	test   $0x3,%cl
  800a62:	75 23                	jne    800a87 <memset+0x40>
		c &= 0xFF;
  800a64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	c1 e3 08             	shl    $0x8,%ebx
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	c1 e6 18             	shl    $0x18,%esi
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	c1 e0 10             	shl    $0x10,%eax
  800a77:	09 f0                	or     %esi,%eax
  800a79:	09 c2                	or     %eax,%edx
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a7f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a82:	fc                   	cld    
  800a83:	f3 ab                	rep stos %eax,%es:(%edi)
  800a85:	eb 06                	jmp    800a8d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8d:	89 f8                	mov    %edi,%eax
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 35                	jae    800adb <memmove+0x47>
  800aa6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa9:	39 d0                	cmp    %edx,%eax
  800aab:	73 2e                	jae    800adb <memmove+0x47>
		s += n;
		d += n;
  800aad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aba:	75 13                	jne    800acf <memmove+0x3b>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 0e                	jne    800acf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac1:	83 ef 04             	sub    $0x4,%edi
  800ac4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aca:	fd                   	std    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 09                	jmp    800ad8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acf:	83 ef 01             	sub    $0x1,%edi
  800ad2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad5:	fd                   	std    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad8:	fc                   	cld    
  800ad9:	eb 1d                	jmp    800af8 <memmove+0x64>
  800adb:	89 f2                	mov    %esi,%edx
  800add:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	f6 c2 03             	test   $0x3,%dl
  800ae2:	75 0f                	jne    800af3 <memmove+0x5f>
  800ae4:	f6 c1 03             	test   $0x3,%cl
  800ae7:	75 0a                	jne    800af3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af1:	eb 05                	jmp    800af8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	fc                   	cld    
  800af6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 79 ff ff ff       	call   800a94 <memmove>
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2d:	eb 1a                	jmp    800b49 <memcmp+0x2c>
		if (*s1 != *s2)
  800b2f:	0f b6 02             	movzbl (%edx),%eax
  800b32:	0f b6 19             	movzbl (%ecx),%ebx
  800b35:	38 d8                	cmp    %bl,%al
  800b37:	74 0a                	je     800b43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c0             	movzbl %al,%eax
  800b3c:	0f b6 db             	movzbl %bl,%ebx
  800b3f:	29 d8                	sub    %ebx,%eax
  800b41:	eb 0f                	jmp    800b52 <memcmp+0x35>
		s1++, s2++;
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b49:	39 f2                	cmp    %esi,%edx
  800b4b:	75 e2                	jne    800b2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b5f:	89 c2                	mov    %eax,%edx
  800b61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b64:	eb 07                	jmp    800b6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b66:	38 08                	cmp    %cl,(%eax)
  800b68:	74 07                	je     800b71 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	39 d0                	cmp    %edx,%eax
  800b6f:	72 f5                	jb     800b66 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7f:	eb 03                	jmp    800b84 <strtol+0x11>
		s++;
  800b81:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b84:	0f b6 0a             	movzbl (%edx),%ecx
  800b87:	80 f9 09             	cmp    $0x9,%cl
  800b8a:	74 f5                	je     800b81 <strtol+0xe>
  800b8c:	80 f9 20             	cmp    $0x20,%cl
  800b8f:	74 f0                	je     800b81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b91:	80 f9 2b             	cmp    $0x2b,%cl
  800b94:	75 0a                	jne    800ba0 <strtol+0x2d>
		s++;
  800b96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9e:	eb 11                	jmp    800bb1 <strtol+0x3e>
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba5:	80 f9 2d             	cmp    $0x2d,%cl
  800ba8:	75 07                	jne    800bb1 <strtol+0x3e>
		s++, neg = 1;
  800baa:	8d 52 01             	lea    0x1(%edx),%edx
  800bad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bb6:	75 15                	jne    800bcd <strtol+0x5a>
  800bb8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbb:	75 10                	jne    800bcd <strtol+0x5a>
  800bbd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc1:	75 0a                	jne    800bcd <strtol+0x5a>
		s += 2, base = 16;
  800bc3:	83 c2 02             	add    $0x2,%edx
  800bc6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bcb:	eb 10                	jmp    800bdd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	75 0c                	jne    800bdd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd6:	75 05                	jne    800bdd <strtol+0x6a>
		s++, base = 8;
  800bd8:	83 c2 01             	add    $0x1,%edx
  800bdb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 0a             	movzbl (%edx),%ecx
  800be8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800beb:	89 f0                	mov    %esi,%eax
  800bed:	3c 09                	cmp    $0x9,%al
  800bef:	77 08                	ja     800bf9 <strtol+0x86>
			dig = *s - '0';
  800bf1:	0f be c9             	movsbl %cl,%ecx
  800bf4:	83 e9 30             	sub    $0x30,%ecx
  800bf7:	eb 20                	jmp    800c19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bf9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bfc:	89 f0                	mov    %esi,%eax
  800bfe:	3c 19                	cmp    $0x19,%al
  800c00:	77 08                	ja     800c0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c02:	0f be c9             	movsbl %cl,%ecx
  800c05:	83 e9 57             	sub    $0x57,%ecx
  800c08:	eb 0f                	jmp    800c19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	3c 19                	cmp    $0x19,%al
  800c11:	77 16                	ja     800c29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c13:	0f be c9             	movsbl %cl,%ecx
  800c16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c1c:	7d 0f                	jge    800c2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c27:	eb bc                	jmp    800be5 <strtol+0x72>
  800c29:	89 d8                	mov    %ebx,%eax
  800c2b:	eb 02                	jmp    800c2f <strtol+0xbc>
  800c2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c33:	74 05                	je     800c3a <strtol+0xc7>
		*endptr = (char *) s;
  800c35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c3a:	f7 d8                	neg    %eax
  800c3c:	85 ff                	test   %edi,%edi
  800c3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	89 c7                	mov    %eax,%edi
  800c5b:	89 c6                	mov    %eax,%esi
  800c5d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c91:	b8 03 00 00 00       	mov    $0x3,%eax
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 cb                	mov    %ecx,%ebx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	89 ce                	mov    %ecx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 28                	jle    800ccd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc0:	00 
  800cc1:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800cc8:	e8 06 f5 ff ff       	call   8001d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ccd:	83 c4 2c             	add    $0x2c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_yield>:

void
sys_yield(void)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800cff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d04:	89 d1                	mov    %edx,%ecx
  800d06:	89 d3                	mov    %edx,%ebx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	be 00 00 00 00       	mov    $0x0,%esi
  800d21:	b8 04 00 00 00       	mov    $0x4,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	89 f7                	mov    %esi,%edi
  800d31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800d5a:	e8 74 f4 ff ff       	call   8001d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	83 c4 2c             	add    $0x2c,%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 28                	jle    800db2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d95:	00 
  800d96:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da5:	00 
  800da6:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800dad:	e8 21 f4 ff ff       	call   8001d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db2:	83 c4 2c             	add    $0x2c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800e00:	e8 ce f3 ff ff       	call   8001d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800e53:	e8 7b f3 ff ff       	call   8001d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 df                	mov    %ebx,%edi
  800e7b:	89 de                	mov    %ebx,%esi
  800e7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	7e 28                	jle    800eab <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e87:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800ea6:	e8 28 f3 ff ff       	call   8001d3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eab:	83 c4 2c             	add    $0x2c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 df                	mov    %ebx,%edi
  800ece:	89 de                	mov    %ebx,%esi
  800ed0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	7e 28                	jle    800efe <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800ef9:	e8 d5 f2 ff ff       	call   8001d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efe:	83 c4 2c             	add    $0x2c,%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	be 00 00 00 00       	mov    $0x0,%esi
  800f11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3f:	89 cb                	mov    %ecx,%ebx
  800f41:	89 cf                	mov    %ecx,%edi
  800f43:	89 ce                	mov    %ecx,%esi
  800f45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	7e 28                	jle    800f73 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f56:	00 
  800f57:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800f6e:	e8 60 f2 ff ff       	call   8001d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f73:	83 c4 2c             	add    $0x2c,%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f81:	ba 00 00 00 00       	mov    $0x0,%edx
  800f86:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f8b:	89 d1                	mov    %edx,%ecx
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 d7                	mov    %edx,%edi
  800f91:	89 d6                	mov    %edx,%esi
  800f93:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb3:	89 df                	mov    %ebx,%edi
  800fb5:	89 de                	mov    %ebx,%esi
  800fb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	7e 28                	jle    800fe5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd8:	00 
  800fd9:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  800fe0:	e8 ee f1 ff ff       	call   8001d3 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800fe5:	83 c4 2c             	add    $0x2c,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffb:	b8 10 00 00 00       	mov    $0x10,%eax
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	89 df                	mov    %ebx,%edi
  801008:	89 de                	mov    %ebx,%esi
  80100a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 28                	jle    801038 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	89 44 24 10          	mov    %eax,0x10(%esp)
  801014:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80101b:	00 
  80101c:	c7 44 24 08 3f 31 80 	movl   $0x80313f,0x8(%esp)
  801023:	00 
  801024:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102b:	00 
  80102c:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  801033:	e8 9b f1 ff ff       	call   8001d3 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801038:	83 c4 2c             	add    $0x2c,%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80105b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801060:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 16             	shr    $0x16,%edx
  801077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	74 11                	je     801094 <fd_alloc+0x2d>
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 0c             	shr    $0xc,%edx
  801088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	75 09                	jne    80109d <fd_alloc+0x36>
			*fd_store = fd;
  801094:	89 01                	mov    %eax,(%ecx)
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb 17                	jmp    8010b4 <fd_alloc+0x4d>
  80109d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a7:	75 c9                	jne    801072 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010bc:	83 f8 1f             	cmp    $0x1f,%eax
  8010bf:	77 36                	ja     8010f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c1:	c1 e0 0c             	shl    $0xc,%eax
  8010c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 16             	shr    $0x16,%edx
  8010ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	74 24                	je     8010fe <fd_lookup+0x48>
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 ea 0c             	shr    $0xc,%edx
  8010df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 1a                	je     801105 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	eb 13                	jmp    80110a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fc:	eb 0c                	jmp    80110a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801103:	eb 05                	jmp    80110a <fd_lookup+0x54>
  801105:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801115:	ba 00 00 00 00       	mov    $0x0,%edx
  80111a:	eb 13                	jmp    80112f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80111c:	39 08                	cmp    %ecx,(%eax)
  80111e:	75 0c                	jne    80112c <dev_lookup+0x20>
			*dev = devtab[i];
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	89 01                	mov    %eax,(%ecx)
			return 0;
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
  80112a:	eb 38                	jmp    801164 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80112c:	83 c2 01             	add    $0x1,%edx
  80112f:	8b 04 95 e8 31 80 00 	mov    0x8031e8(,%edx,4),%eax
  801136:	85 c0                	test   %eax,%eax
  801138:	75 e2                	jne    80111c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80113a:	a1 08 50 80 00       	mov    0x805008,%eax
  80113f:	8b 40 48             	mov    0x48(%eax),%eax
  801142:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114a:	c7 04 24 6c 31 80 00 	movl   $0x80316c,(%esp)
  801151:	e8 76 f1 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  801156:	8b 45 0c             	mov    0xc(%ebp),%eax
  801159:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80115f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 20             	sub    $0x20,%esp
  80116e:	8b 75 08             	mov    0x8(%ebp),%esi
  801171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801181:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 2a ff ff ff       	call   8010b6 <fd_lookup>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 05                	js     801195 <fd_close+0x2f>
	    || fd != fd2)
  801190:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801193:	74 0c                	je     8011a1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801195:	84 db                	test   %bl,%bl
  801197:	ba 00 00 00 00       	mov    $0x0,%edx
  80119c:	0f 44 c2             	cmove  %edx,%eax
  80119f:	eb 3f                	jmp    8011e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a8:	8b 06                	mov    (%esi),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 5a ff ff ff       	call   80110c <dev_lookup>
  8011b2:	89 c3                	mov    %eax,%ebx
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 16                	js     8011ce <fd_close+0x68>
		if (dev->dev_close)
  8011b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	74 07                	je     8011ce <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011c7:	89 34 24             	mov    %esi,(%esp)
  8011ca:	ff d0                	call   *%eax
  8011cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 dc fb ff ff       	call   800dba <sys_page_unmap>
	return r;
  8011de:	89 d8                	mov    %ebx,%eax
}
  8011e0:	83 c4 20             	add    $0x20,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	e8 b7 fe ff ff       	call   8010b6 <fd_lookup>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	78 13                	js     801218 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801205:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80120c:	00 
  80120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 4e ff ff ff       	call   801166 <fd_close>
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <close_all>:

void
close_all(void)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801221:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801226:	89 1c 24             	mov    %ebx,(%esp)
  801229:	e8 b9 ff ff ff       	call   8011e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80122e:	83 c3 01             	add    $0x1,%ebx
  801231:	83 fb 20             	cmp    $0x20,%ebx
  801234:	75 f0                	jne    801226 <close_all+0xc>
		close(i);
}
  801236:	83 c4 14             	add    $0x14,%esp
  801239:	5b                   	pop    %ebx
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801245:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 5f fe ff ff       	call   8010b6 <fd_lookup>
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 d2                	test   %edx,%edx
  80125b:	0f 88 e1 00 00 00    	js     801342 <dup+0x106>
		return r;
	close(newfdnum);
  801261:	8b 45 0c             	mov    0xc(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 7b ff ff ff       	call   8011e7 <close>

	newfd = INDEX2FD(newfdnum);
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126f:	c1 e3 0c             	shl    $0xc,%ebx
  801272:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 cd fd ff ff       	call   801050 <fd2data>
  801283:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 c3 fd ff ff       	call   801050 <fd2data>
  80128d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80128f:	89 f0                	mov    %esi,%eax
  801291:	c1 e8 16             	shr    $0x16,%eax
  801294:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129b:	a8 01                	test   $0x1,%al
  80129d:	74 43                	je     8012e2 <dup+0xa6>
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	c1 e8 0c             	shr    $0xc,%eax
  8012a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 32                	je     8012e2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012cb:	00 
  8012cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d7:	e8 8b fa ff ff       	call   800d67 <sys_page_map>
  8012dc:	89 c6                	mov    %eax,%esi
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 3e                	js     801320 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	c1 ea 0c             	shr    $0xc,%edx
  8012ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801306:	00 
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801312:	e8 50 fa ff ff       	call   800d67 <sys_page_map>
  801317:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801319:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131c:	85 f6                	test   %esi,%esi
  80131e:	79 22                	jns    801342 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801320:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132b:	e8 8a fa ff ff       	call   800dba <sys_page_unmap>
	sys_page_unmap(0, nva);
  801330:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801334:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133b:	e8 7a fa ff ff       	call   800dba <sys_page_unmap>
	return r;
  801340:	89 f0                	mov    %esi,%eax
}
  801342:	83 c4 3c             	add    $0x3c,%esp
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5f                   	pop    %edi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 24             	sub    $0x24,%esp
  801351:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801354:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	89 1c 24             	mov    %ebx,(%esp)
  80135e:	e8 53 fd ff ff       	call   8010b6 <fd_lookup>
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	78 6d                	js     8013d6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	8b 00                	mov    (%eax),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	e8 8f fd ff ff       	call   80110c <dev_lookup>
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 55                	js     8013d6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801381:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801384:	8b 50 08             	mov    0x8(%eax),%edx
  801387:	83 e2 03             	and    $0x3,%edx
  80138a:	83 fa 01             	cmp    $0x1,%edx
  80138d:	75 23                	jne    8013b2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138f:	a1 08 50 80 00       	mov    0x805008,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	c7 04 24 ad 31 80 00 	movl   $0x8031ad,(%esp)
  8013a6:	e8 21 ef ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  8013ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b0:	eb 24                	jmp    8013d6 <read+0x8c>
	}
	if (!dev->dev_read)
  8013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b5:	8b 52 08             	mov    0x8(%edx),%edx
  8013b8:	85 d2                	test   %edx,%edx
  8013ba:	74 15                	je     8013d1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	ff d2                	call   *%edx
  8013cf:	eb 05                	jmp    8013d6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013d6:	83 c4 24             	add    $0x24,%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 1c             	sub    $0x1c,%esp
  8013e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f0:	eb 23                	jmp    801415 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	29 d8                	sub    %ebx,%eax
  8013f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	03 45 0c             	add    0xc(%ebp),%eax
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	89 3c 24             	mov    %edi,(%esp)
  801406:	e8 3f ff ff ff       	call   80134a <read>
		if (m < 0)
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 10                	js     80141f <readn+0x43>
			return m;
		if (m == 0)
  80140f:	85 c0                	test   %eax,%eax
  801411:	74 0a                	je     80141d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801413:	01 c3                	add    %eax,%ebx
  801415:	39 f3                	cmp    %esi,%ebx
  801417:	72 d9                	jb     8013f2 <readn+0x16>
  801419:	89 d8                	mov    %ebx,%eax
  80141b:	eb 02                	jmp    80141f <readn+0x43>
  80141d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141f:	83 c4 1c             	add    $0x1c,%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5f                   	pop    %edi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	53                   	push   %ebx
  80142b:	83 ec 24             	sub    $0x24,%esp
  80142e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	89 1c 24             	mov    %ebx,(%esp)
  80143b:	e8 76 fc ff ff       	call   8010b6 <fd_lookup>
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 d2                	test   %edx,%edx
  801444:	78 68                	js     8014ae <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	8b 00                	mov    (%eax),%eax
  801452:	89 04 24             	mov    %eax,(%esp)
  801455:	e8 b2 fc ff ff       	call   80110c <dev_lookup>
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 50                	js     8014ae <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801461:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801465:	75 23                	jne    80148a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801467:	a1 08 50 80 00       	mov    0x805008,%eax
  80146c:	8b 40 48             	mov    0x48(%eax),%eax
  80146f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	c7 04 24 c9 31 80 00 	movl   $0x8031c9,(%esp)
  80147e:	e8 49 ee ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  801483:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801488:	eb 24                	jmp    8014ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148d:	8b 52 0c             	mov    0xc(%edx),%edx
  801490:	85 d2                	test   %edx,%edx
  801492:	74 15                	je     8014a9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801494:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801497:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a2:	89 04 24             	mov    %eax,(%esp)
  8014a5:	ff d2                	call   *%edx
  8014a7:	eb 05                	jmp    8014ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014ae:	83 c4 24             	add    $0x24,%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	e8 ea fb ff ff       	call   8010b6 <fd_lookup>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 0e                	js     8014de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 24             	sub    $0x24,%esp
  8014e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f1:	89 1c 24             	mov    %ebx,(%esp)
  8014f4:	e8 bd fb ff ff       	call   8010b6 <fd_lookup>
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	85 d2                	test   %edx,%edx
  8014fd:	78 61                	js     801560 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	8b 00                	mov    (%eax),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 f9 fb ff ff       	call   80110c <dev_lookup>
  801513:	85 c0                	test   %eax,%eax
  801515:	78 49                	js     801560 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151e:	75 23                	jne    801543 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801520:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801525:	8b 40 48             	mov    0x48(%eax),%eax
  801528:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80152c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801530:	c7 04 24 8c 31 80 00 	movl   $0x80318c,(%esp)
  801537:	e8 90 ed ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801541:	eb 1d                	jmp    801560 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801543:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801546:	8b 52 18             	mov    0x18(%edx),%edx
  801549:	85 d2                	test   %edx,%edx
  80154b:	74 0e                	je     80155b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801550:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	ff d2                	call   *%edx
  801559:	eb 05                	jmp    801560 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801560:	83 c4 24             	add    $0x24,%esp
  801563:	5b                   	pop    %ebx
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 24             	sub    $0x24,%esp
  80156d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 34 fb ff ff       	call   8010b6 <fd_lookup>
  801582:	89 c2                	mov    %eax,%edx
  801584:	85 d2                	test   %edx,%edx
  801586:	78 52                	js     8015da <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	8b 00                	mov    (%eax),%eax
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 70 fb ff ff       	call   80110c <dev_lookup>
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 3a                	js     8015da <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a7:	74 2c                	je     8015d5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b3:	00 00 00 
	stat->st_isdir = 0;
  8015b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015bd:	00 00 00 
	stat->st_dev = dev;
  8015c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cd:	89 14 24             	mov    %edx,(%esp)
  8015d0:	ff 50 14             	call   *0x14(%eax)
  8015d3:	eb 05                	jmp    8015da <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015da:	83 c4 24             	add    $0x24,%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ef:	00 
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 28 02 00 00       	call   801823 <open>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	85 db                	test   %ebx,%ebx
  8015ff:	78 1b                	js     80161c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801601:	8b 45 0c             	mov    0xc(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	89 1c 24             	mov    %ebx,(%esp)
  80160b:	e8 56 ff ff ff       	call   801566 <fstat>
  801610:	89 c6                	mov    %eax,%esi
	close(fd);
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 cd fb ff ff       	call   8011e7 <close>
	return r;
  80161a:	89 f0                	mov    %esi,%eax
}
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	89 c6                	mov    %eax,%esi
  80162d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801636:	75 11                	jne    801649 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801638:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80163f:	e8 f1 13 00 00       	call   802a35 <ipc_find_env>
  801644:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801649:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801650:	00 
  801651:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801658:	00 
  801659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165d:	a1 00 50 80 00       	mov    0x805000,%eax
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 60 13 00 00       	call   8029ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801671:	00 
  801672:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801676:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167d:	e8 ce 12 00 00       	call   802950 <ipc_recv>
}
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 40 0c             	mov    0xc(%eax),%eax
  801695:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ac:	e8 72 ff ff ff       	call   801623 <fsipc>
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ce:	e8 50 ff ff ff       	call   801623 <fsipc>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 14             	sub    $0x14,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f4:	e8 2a ff ff ff       	call   801623 <fsipc>
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	85 d2                	test   %edx,%edx
  8016fd:	78 2b                	js     80172a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ff:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801706:	00 
  801707:	89 1c 24             	mov    %ebx,(%esp)
  80170a:	e8 e8 f1 ff ff       	call   8008f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170f:	a1 80 60 80 00       	mov    0x806080,%eax
  801714:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171a:	a1 84 60 80 00       	mov    0x806084,%eax
  80171f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172a:	83 c4 14             	add    $0x14,%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 18             	sub    $0x18,%esp
  801736:	8b 45 10             	mov    0x10(%ebp),%eax
  801739:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801743:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801746:	8b 55 08             	mov    0x8(%ebp),%edx
  801749:	8b 52 0c             	mov    0xc(%edx),%edx
  80174c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801752:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801769:	e8 26 f3 ff ff       	call   800a94 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 04 00 00 00       	mov    $0x4,%eax
  801778:	e8 a6 fe ff ff       	call   801623 <fsipc>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	83 ec 10             	sub    $0x10,%esp
  801787:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801795:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a5:	e8 79 fe ff ff       	call   801623 <fsipc>
  8017aa:	89 c3                	mov    %eax,%ebx
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 6a                	js     80181a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017b0:	39 c6                	cmp    %eax,%esi
  8017b2:	73 24                	jae    8017d8 <devfile_read+0x59>
  8017b4:	c7 44 24 0c fc 31 80 	movl   $0x8031fc,0xc(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017cb:	00 
  8017cc:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8017d3:	e8 fb e9 ff ff       	call   8001d3 <_panic>
	assert(r <= PGSIZE);
  8017d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017dd:	7e 24                	jle    801803 <devfile_read+0x84>
  8017df:	c7 44 24 0c 23 32 80 	movl   $0x803223,0xc(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  8017ee:	00 
  8017ef:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017f6:	00 
  8017f7:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8017fe:	e8 d0 e9 ff ff       	call   8001d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801803:	89 44 24 08          	mov    %eax,0x8(%esp)
  801807:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80180e:	00 
  80180f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 7a f2 ff ff       	call   800a94 <memmove>
	return r;
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 24             	sub    $0x24,%esp
  80182a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 8b f0 ff ff       	call   8008c0 <strlen>
  801835:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183a:	7f 60                	jg     80189c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 20 f8 ff ff       	call   801067 <fd_alloc>
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 d2                	test   %edx,%edx
  80184b:	78 54                	js     8018a1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801851:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801858:	e8 9a f0 ff ff       	call   8008f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801865:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801868:	b8 01 00 00 00       	mov    $0x1,%eax
  80186d:	e8 b1 fd ff ff       	call   801623 <fsipc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	85 c0                	test   %eax,%eax
  801876:	79 17                	jns    80188f <open+0x6c>
		fd_close(fd, 0);
  801878:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80187f:	00 
  801880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 db f8 ff ff       	call   801166 <fd_close>
		return r;
  80188b:	89 d8                	mov    %ebx,%eax
  80188d:	eb 12                	jmp    8018a1 <open+0x7e>
	}

	return fd2num(fd);
  80188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 a6 f7 ff ff       	call   801040 <fd2num>
  80189a:	eb 05                	jmp    8018a1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80189c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a1:	83 c4 24             	add    $0x24,%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b7:	e8 67 fd ff ff       	call   801623 <fsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    
  8018be:	66 90                	xchg   %ax,%ax

008018c0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018d3:	00 
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 44 ff ff ff       	call   801823 <open>
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	0f 88 3e 05 00 00    	js     801e2d <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018ef:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8018f6:	00 
  8018f7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	89 14 24             	mov    %edx,(%esp)
  801904:	e8 d3 fa ff ff       	call   8013dc <readn>
  801909:	3d 00 02 00 00       	cmp    $0x200,%eax
  80190e:	75 0c                	jne    80191c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801910:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801917:	45 4c 46 
  80191a:	74 36                	je     801952 <spawn+0x92>
		close(fd);
  80191c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 bd f8 ff ff       	call   8011e7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80192a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801931:	46 
  801932:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801938:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193c:	c7 04 24 2f 32 80 00 	movl   $0x80322f,(%esp)
  801943:	e8 84 e9 ff ff       	call   8002cc <cprintf>
		return -E_NOT_EXEC;
  801948:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80194d:	e9 3a 05 00 00       	jmp    801e8c <spawn+0x5cc>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801952:	b8 07 00 00 00       	mov    $0x7,%eax
  801957:	cd 30                	int    $0x30
  801959:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80195f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801965:	85 c0                	test   %eax,%eax
  801967:	0f 88 c8 04 00 00    	js     801e35 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80196d:	89 c6                	mov    %eax,%esi
  80196f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801975:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801978:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80197e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801984:	b9 11 00 00 00       	mov    $0x11,%ecx
  801989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80198b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801991:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801997:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80199c:	be 00 00 00 00       	mov    $0x0,%esi
  8019a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019a4:	eb 0f                	jmp    8019b5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	e8 12 ef ff ff       	call   8008c0 <strlen>
  8019ae:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019b2:	83 c3 01             	add    $0x1,%ebx
  8019b5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019bc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	75 e3                	jne    8019a6 <spawn+0xe6>
  8019c3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8019c9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019cf:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019d4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019d6:	89 fa                	mov    %edi,%edx
  8019d8:	83 e2 fc             	and    $0xfffffffc,%edx
  8019db:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019e2:	29 c2                	sub    %eax,%edx
  8019e4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019ea:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019ed:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019f2:	0f 86 4d 04 00 00    	jbe    801e45 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019f8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019ff:	00 
  801a00:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a07:	00 
  801a08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0f:	e8 ff f2 ff ff       	call   800d13 <sys_page_alloc>
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 70 04 00 00    	js     801e8c <spawn+0x5cc>
  801a1c:	be 00 00 00 00       	mov    $0x0,%esi
  801a21:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a2a:	eb 30                	jmp    801a5c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a2c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a32:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a38:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a3b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a42:	89 3c 24             	mov    %edi,(%esp)
  801a45:	e8 ad ee ff ff       	call   8008f7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a4a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801a4d:	89 04 24             	mov    %eax,(%esp)
  801a50:	e8 6b ee ff ff       	call   8008c0 <strlen>
  801a55:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a59:	83 c6 01             	add    $0x1,%esi
  801a5c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a62:	7f c8                	jg     801a2c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a64:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a6a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801a70:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a77:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a7d:	74 24                	je     801aa3 <spawn+0x1e3>
  801a7f:	c7 44 24 0c a4 32 80 	movl   $0x8032a4,0xc(%esp)
  801a86:	00 
  801a87:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  801a8e:	00 
  801a8f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801a96:	00 
  801a97:	c7 04 24 49 32 80 00 	movl   $0x803249,(%esp)
  801a9e:	e8 30 e7 ff ff       	call   8001d3 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801aa9:	89 c8                	mov    %ecx,%eax
  801aab:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ab0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ab3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ab9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801abc:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801ac2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ac8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801acf:	00 
  801ad0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801ad7:	ee 
  801ad8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ade:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ae9:	00 
  801aea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af1:	e8 71 f2 ff ff       	call   800d67 <sys_page_map>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	85 c0                	test   %eax,%eax
  801afa:	0f 88 76 03 00 00    	js     801e76 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b00:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b07:	00 
  801b08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0f:	e8 a6 f2 ff ff       	call   800dba <sys_page_unmap>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 58 03 00 00    	js     801e76 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b1e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b24:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b2b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b31:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b38:	00 00 00 
  801b3b:	e9 b6 01 00 00       	jmp    801cf6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801b40:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b46:	83 38 01             	cmpl   $0x1,(%eax)
  801b49:	0f 85 99 01 00 00    	jne    801ce8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	8b 40 18             	mov    0x18(%eax),%eax
  801b54:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801b57:	83 f8 01             	cmp    $0x1,%eax
  801b5a:	19 c0                	sbb    %eax,%eax
  801b5c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b62:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801b69:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	8b 52 04             	mov    0x4(%edx),%edx
  801b75:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801b7b:	8b 50 10             	mov    0x10(%eax),%edx
  801b7e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801b84:	8b 48 14             	mov    0x14(%eax),%ecx
  801b87:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801b8d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b90:	89 f0                	mov    %esi,%eax
  801b92:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b97:	74 14                	je     801bad <spawn+0x2ed>
		va -= i;
  801b99:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b9b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801ba1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ba7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb2:	e9 23 01 00 00       	jmp    801cda <spawn+0x41a>
		if (i >= filesz) {
  801bb7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801bbd:	77 2b                	ja     801bea <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bbf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801bd3:	89 04 24             	mov    %eax,(%esp)
  801bd6:	e8 38 f1 ff ff       	call   800d13 <sys_page_alloc>
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 89 eb 00 00 00    	jns    801cce <spawn+0x40e>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	e9 6c 02 00 00       	jmp    801e56 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bea:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bf1:	00 
  801bf2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bf9:	00 
  801bfa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c01:	e8 0d f1 ff ff       	call   800d13 <sys_page_alloc>
  801c06:	85 c0                	test   %eax,%eax
  801c08:	0f 88 3e 02 00 00    	js     801e4c <spawn+0x58c>
  801c0e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c14:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c20:	89 04 24             	mov    %eax,(%esp)
  801c23:	e8 8c f8 ff ff       	call   8014b4 <seek>
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 20 02 00 00    	js     801e50 <spawn+0x590>
  801c30:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801c36:	29 f9                	sub    %edi,%ecx
  801c38:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c3a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  801c40:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c45:	0f 47 c1             	cmova  %ecx,%eax
  801c48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c53:	00 
  801c54:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c5a:	89 04 24             	mov    %eax,(%esp)
  801c5d:	e8 7a f7 ff ff       	call   8013dc <readn>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	0f 88 ea 01 00 00    	js     801e54 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c6a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801c70:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c74:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c78:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c82:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c89:	00 
  801c8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c91:	e8 d1 f0 ff ff       	call   800d67 <sys_page_map>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	79 20                	jns    801cba <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801c9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9e:	c7 44 24 08 55 32 80 	movl   $0x803255,0x8(%esp)
  801ca5:	00 
  801ca6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801cad:	00 
  801cae:	c7 04 24 49 32 80 00 	movl   $0x803249,(%esp)
  801cb5:	e8 19 e5 ff ff       	call   8001d3 <_panic>
			sys_page_unmap(0, UTEMP);
  801cba:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cc1:	00 
  801cc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc9:	e8 ec f0 ff ff       	call   800dba <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cd4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cda:	89 df                	mov    %ebx,%edi
  801cdc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801ce2:	0f 87 cf fe ff ff    	ja     801bb7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ce8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cef:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cf6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cfd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d03:	0f 8c 37 fe ff ff    	jl     801b40 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d09:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 d0 f4 ff ff       	call   8011e7 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  801d17:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  801d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  801d21:	89 d8                	mov    %ebx,%eax
  801d23:	c1 e8 16             	shr    $0x16,%eax
  801d26:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	74 4e                	je     801d7f <spawn+0x4bf>
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	c1 e8 0c             	shr    $0xc,%eax
  801d36:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d3d:	85 d2                	test   %edx,%edx
  801d3f:	74 3e                	je     801d7f <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  801d41:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d48:	f6 c6 04             	test   $0x4,%dh
  801d4b:	74 32                	je     801d7f <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801d4d:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  801d54:	e8 7c ef ff ff       	call   800cd5 <sys_getenvid>
  801d59:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801d5f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801d63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d67:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801d6d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	e8 ea ef ff ff       	call   800d67 <sys_page_map>
  801d7d:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  801d7f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d85:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801d8b:	75 94                	jne    801d21 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  801d8d:	85 f6                	test   %esi,%esi
  801d8f:	79 1c                	jns    801dad <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  801d91:	c7 44 24 08 cc 32 80 	movl   $0x8032cc,0x8(%esp)
  801d98:	00 
  801d99:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  801da0:	00 
  801da1:	c7 04 24 49 32 80 00 	movl   $0x803249,(%esp)
  801da8:	e8 26 e4 ff ff       	call   8001d3 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dad:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801db4:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801db7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801dc7:	89 04 24             	mov    %eax,(%esp)
  801dca:	e8 91 f0 ff ff       	call   800e60 <sys_env_set_trapframe>
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	79 20                	jns    801df3 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  801dd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd7:	c7 44 24 08 72 32 80 	movl   $0x803272,0x8(%esp)
  801dde:	00 
  801ddf:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801de6:	00 
  801de7:	c7 04 24 49 32 80 00 	movl   $0x803249,(%esp)
  801dee:	e8 e0 e3 ff ff       	call   8001d3 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801df3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801dfa:	00 
  801dfb:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e01:	89 04 24             	mov    %eax,(%esp)
  801e04:	e8 04 f0 ff ff       	call   800e0d <sys_env_set_status>
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	79 30                	jns    801e3d <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  801e0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e11:	c7 44 24 08 8c 32 80 	movl   $0x80328c,0x8(%esp)
  801e18:	00 
  801e19:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801e20:	00 
  801e21:	c7 04 24 49 32 80 00 	movl   $0x803249,(%esp)
  801e28:	e8 a6 e3 ff ff       	call   8001d3 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e2d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e33:	eb 57                	jmp    801e8c <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e35:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e3b:	eb 4f                	jmp    801e8c <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e3d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e43:	eb 47                	jmp    801e8c <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e45:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801e4a:	eb 40                	jmp    801e8c <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e4c:	89 c3                	mov    %eax,%ebx
  801e4e:	eb 06                	jmp    801e56 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	eb 02                	jmp    801e56 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e54:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e56:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 1f ee ff ff       	call   800c83 <sys_env_destroy>
	close(fd);
  801e64:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e6a:	89 04 24             	mov    %eax,(%esp)
  801e6d:	e8 75 f3 ff ff       	call   8011e7 <close>
	return r;
  801e72:	89 d8                	mov    %ebx,%eax
  801e74:	eb 16                	jmp    801e8c <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e76:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e7d:	00 
  801e7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e85:	e8 30 ef ff ff       	call   800dba <sys_page_unmap>
  801e8a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e8c:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e9f:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ea2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea7:	eb 03                	jmp    801eac <spawnl+0x15>
		argc++;
  801ea9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eac:	83 c0 04             	add    $0x4,%eax
  801eaf:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801eb3:	75 f4                	jne    801ea9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801eb5:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801ebc:	83 e0 f0             	and    $0xfffffff0,%eax
  801ebf:	29 c4                	sub    %eax,%esp
  801ec1:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801ec5:	c1 e8 02             	shr    $0x2,%eax
  801ec8:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801ecf:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed4:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801edb:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801ee2:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee8:	eb 0a                	jmp    801ef4 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801eea:	83 c0 01             	add    $0x1,%eax
  801eed:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ef1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef4:	39 d0                	cmp    %edx,%eax
  801ef6:	75 f2                	jne    801eea <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ef8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 b9 f9 ff ff       	call   8018c0 <spawn>
}
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f16:	c7 44 24 04 f6 32 80 	movl   $0x8032f6,0x4(%esp)
  801f1d:	00 
  801f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 ce e9 ff ff       	call   8008f7 <strcpy>
	return 0;
}
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	53                   	push   %ebx
  801f34:	83 ec 14             	sub    $0x14,%esp
  801f37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f3a:	89 1c 24             	mov    %ebx,(%esp)
  801f3d:	e8 2b 0b 00 00       	call   802a6d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f42:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f47:	83 f8 01             	cmp    $0x1,%eax
  801f4a:	75 0d                	jne    801f59 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801f4c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 29 03 00 00       	call   802280 <nsipc_close>
  801f57:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	83 c4 14             	add    $0x14,%esp
  801f5e:	5b                   	pop    %ebx
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f6e:	00 
  801f6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f72:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	8b 40 0c             	mov    0xc(%eax),%eax
  801f83:	89 04 24             	mov    %eax,(%esp)
  801f86:	e8 f0 03 00 00       	call   80237b <nsipc_send>
}
  801f8b:	c9                   	leave  
  801f8c:	c3                   	ret    

00801f8d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f9a:	00 
  801f9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	8b 40 0c             	mov    0xc(%eax),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 44 03 00 00       	call   8022fb <nsipc_recv>
}
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fbf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fc2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	e8 e8 f0 ff ff       	call   8010b6 <fd_lookup>
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 17                	js     801fe9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801fdb:	39 08                	cmp    %ecx,(%eax)
  801fdd:	75 05                	jne    801fe4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fdf:	8b 40 0c             	mov    0xc(%eax),%eax
  801fe2:	eb 05                	jmp    801fe9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801fe4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	83 ec 20             	sub    $0x20,%esp
  801ff3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff8:	89 04 24             	mov    %eax,(%esp)
  801ffb:	e8 67 f0 ff ff       	call   801067 <fd_alloc>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	85 c0                	test   %eax,%eax
  802004:	78 21                	js     802027 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802006:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80200d:	00 
  80200e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802011:	89 44 24 04          	mov    %eax,0x4(%esp)
  802015:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201c:	e8 f2 ec ff ff       	call   800d13 <sys_page_alloc>
  802021:	89 c3                	mov    %eax,%ebx
  802023:	85 c0                	test   %eax,%eax
  802025:	79 0c                	jns    802033 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  802027:	89 34 24             	mov    %esi,(%esp)
  80202a:	e8 51 02 00 00       	call   802280 <nsipc_close>
		return r;
  80202f:	89 d8                	mov    %ebx,%eax
  802031:	eb 20                	jmp    802053 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802033:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80203e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802041:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802048:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80204b:	89 14 24             	mov    %edx,(%esp)
  80204e:	e8 ed ef ff ff       	call   801040 <fd2num>
}
  802053:	83 c4 20             	add    $0x20,%esp
  802056:	5b                   	pop    %ebx
  802057:	5e                   	pop    %esi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	e8 51 ff ff ff       	call   801fb9 <fd2sockid>
		return r;
  802068:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80206a:	85 c0                	test   %eax,%eax
  80206c:	78 23                	js     802091 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80206e:	8b 55 10             	mov    0x10(%ebp),%edx
  802071:	89 54 24 08          	mov    %edx,0x8(%esp)
  802075:	8b 55 0c             	mov    0xc(%ebp),%edx
  802078:	89 54 24 04          	mov    %edx,0x4(%esp)
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 45 01 00 00       	call   8021c9 <nsipc_accept>
		return r;
  802084:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802086:	85 c0                	test   %eax,%eax
  802088:	78 07                	js     802091 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80208a:	e8 5c ff ff ff       	call   801feb <alloc_sockfd>
  80208f:	89 c1                	mov    %eax,%ecx
}
  802091:	89 c8                	mov    %ecx,%eax
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	e8 16 ff ff ff       	call   801fb9 <fd2sockid>
  8020a3:	89 c2                	mov    %eax,%edx
  8020a5:	85 d2                	test   %edx,%edx
  8020a7:	78 16                	js     8020bf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8020a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b7:	89 14 24             	mov    %edx,(%esp)
  8020ba:	e8 60 01 00 00       	call   80221f <nsipc_bind>
}
  8020bf:	c9                   	leave  
  8020c0:	c3                   	ret    

008020c1 <shutdown>:

int
shutdown(int s, int how)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	e8 ea fe ff ff       	call   801fb9 <fd2sockid>
  8020cf:	89 c2                	mov    %eax,%edx
  8020d1:	85 d2                	test   %edx,%edx
  8020d3:	78 0f                	js     8020e4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dc:	89 14 24             	mov    %edx,(%esp)
  8020df:	e8 7a 01 00 00       	call   80225e <nsipc_shutdown>
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ef:	e8 c5 fe ff ff       	call   801fb9 <fd2sockid>
  8020f4:	89 c2                	mov    %eax,%edx
  8020f6:	85 d2                	test   %edx,%edx
  8020f8:	78 16                	js     802110 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  8020fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  802101:	8b 45 0c             	mov    0xc(%ebp),%eax
  802104:	89 44 24 04          	mov    %eax,0x4(%esp)
  802108:	89 14 24             	mov    %edx,(%esp)
  80210b:	e8 8a 01 00 00       	call   80229a <nsipc_connect>
}
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <listen>:

int
listen(int s, int backlog)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802118:	8b 45 08             	mov    0x8(%ebp),%eax
  80211b:	e8 99 fe ff ff       	call   801fb9 <fd2sockid>
  802120:	89 c2                	mov    %eax,%edx
  802122:	85 d2                	test   %edx,%edx
  802124:	78 0f                	js     802135 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802126:	8b 45 0c             	mov    0xc(%ebp),%eax
  802129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212d:	89 14 24             	mov    %edx,(%esp)
  802130:	e8 a4 01 00 00       	call   8022d9 <nsipc_listen>
}
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80213d:	8b 45 10             	mov    0x10(%ebp),%eax
  802140:	89 44 24 08          	mov    %eax,0x8(%esp)
  802144:	8b 45 0c             	mov    0xc(%ebp),%eax
  802147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	89 04 24             	mov    %eax,(%esp)
  802151:	e8 98 02 00 00       	call   8023ee <nsipc_socket>
  802156:	89 c2                	mov    %eax,%edx
  802158:	85 d2                	test   %edx,%edx
  80215a:	78 05                	js     802161 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80215c:	e8 8a fe ff ff       	call   801feb <alloc_sockfd>
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	53                   	push   %ebx
  802167:	83 ec 14             	sub    $0x14,%esp
  80216a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80216c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802173:	75 11                	jne    802186 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802175:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80217c:	e8 b4 08 00 00       	call   802a35 <ipc_find_env>
  802181:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802186:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80218d:	00 
  80218e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802195:	00 
  802196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80219a:	a1 04 50 80 00       	mov    0x805004,%eax
  80219f:	89 04 24             	mov    %eax,(%esp)
  8021a2:	e8 23 08 00 00       	call   8029ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021ae:	00 
  8021af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021b6:	00 
  8021b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021be:	e8 8d 07 00 00       	call   802950 <ipc_recv>
}
  8021c3:	83 c4 14             	add    $0x14,%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	56                   	push   %esi
  8021cd:	53                   	push   %ebx
  8021ce:	83 ec 10             	sub    $0x10,%esp
  8021d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021dc:	8b 06                	mov    (%esi),%eax
  8021de:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e8:	e8 76 ff ff ff       	call   802163 <nsipc>
  8021ed:	89 c3                	mov    %eax,%ebx
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 23                	js     802216 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021f3:	a1 10 70 80 00       	mov    0x807010,%eax
  8021f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021fc:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802203:	00 
  802204:	8b 45 0c             	mov    0xc(%ebp),%eax
  802207:	89 04 24             	mov    %eax,(%esp)
  80220a:	e8 85 e8 ff ff       	call   800a94 <memmove>
		*addrlen = ret->ret_addrlen;
  80220f:	a1 10 70 80 00       	mov    0x807010,%eax
  802214:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802216:	89 d8                	mov    %ebx,%eax
  802218:	83 c4 10             	add    $0x10,%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	53                   	push   %ebx
  802223:	83 ec 14             	sub    $0x14,%esp
  802226:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802229:	8b 45 08             	mov    0x8(%ebp),%eax
  80222c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802231:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802235:	8b 45 0c             	mov    0xc(%ebp),%eax
  802238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802243:	e8 4c e8 ff ff       	call   800a94 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802248:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80224e:	b8 02 00 00 00       	mov    $0x2,%eax
  802253:	e8 0b ff ff ff       	call   802163 <nsipc>
}
  802258:	83 c4 14             	add    $0x14,%esp
  80225b:	5b                   	pop    %ebx
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802264:	8b 45 08             	mov    0x8(%ebp),%eax
  802267:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80226c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802274:	b8 03 00 00 00       	mov    $0x3,%eax
  802279:	e8 e5 fe ff ff       	call   802163 <nsipc>
}
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    

00802280 <nsipc_close>:

int
nsipc_close(int s)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802286:	8b 45 08             	mov    0x8(%ebp),%eax
  802289:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80228e:	b8 04 00 00 00       	mov    $0x4,%eax
  802293:	e8 cb fe ff ff       	call   802163 <nsipc>
}
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	53                   	push   %ebx
  80229e:	83 ec 14             	sub    $0x14,%esp
  8022a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8022be:	e8 d1 e7 ff ff       	call   800a94 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022c3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8022c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8022ce:	e8 90 fe ff ff       	call   802163 <nsipc>
}
  8022d3:	83 c4 14             	add    $0x14,%esp
  8022d6:	5b                   	pop    %ebx
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ea:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8022f4:	e8 6a fe ff ff       	call   802163 <nsipc>
}
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    

008022fb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	56                   	push   %esi
  8022ff:	53                   	push   %ebx
  802300:	83 ec 10             	sub    $0x10,%esp
  802303:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802306:	8b 45 08             	mov    0x8(%ebp),%eax
  802309:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80230e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802314:	8b 45 14             	mov    0x14(%ebp),%eax
  802317:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80231c:	b8 07 00 00 00       	mov    $0x7,%eax
  802321:	e8 3d fe ff ff       	call   802163 <nsipc>
  802326:	89 c3                	mov    %eax,%ebx
  802328:	85 c0                	test   %eax,%eax
  80232a:	78 46                	js     802372 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80232c:	39 f0                	cmp    %esi,%eax
  80232e:	7f 07                	jg     802337 <nsipc_recv+0x3c>
  802330:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802335:	7e 24                	jle    80235b <nsipc_recv+0x60>
  802337:	c7 44 24 0c 02 33 80 	movl   $0x803302,0xc(%esp)
  80233e:	00 
  80233f:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  802346:	00 
  802347:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80234e:	00 
  80234f:	c7 04 24 17 33 80 00 	movl   $0x803317,(%esp)
  802356:	e8 78 de ff ff       	call   8001d3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80235b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80235f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802366:	00 
  802367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236a:	89 04 24             	mov    %eax,(%esp)
  80236d:	e8 22 e7 ff ff       	call   800a94 <memmove>
	}

	return r;
}
  802372:	89 d8                	mov    %ebx,%eax
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    

0080237b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	53                   	push   %ebx
  80237f:	83 ec 14             	sub    $0x14,%esp
  802382:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802385:	8b 45 08             	mov    0x8(%ebp),%eax
  802388:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80238d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802393:	7e 24                	jle    8023b9 <nsipc_send+0x3e>
  802395:	c7 44 24 0c 23 33 80 	movl   $0x803323,0xc(%esp)
  80239c:	00 
  80239d:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  8023a4:	00 
  8023a5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8023ac:	00 
  8023ad:	c7 04 24 17 33 80 00 	movl   $0x803317,(%esp)
  8023b4:	e8 1a de ff ff       	call   8001d3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8023cb:	e8 c4 e6 ff ff       	call   800a94 <memmove>
	nsipcbuf.send.req_size = size;
  8023d0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023de:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e3:	e8 7b fd ff ff       	call   802163 <nsipc>
}
  8023e8:	83 c4 14             	add    $0x14,%esp
  8023eb:	5b                   	pop    %ebx
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ff:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802404:	8b 45 10             	mov    0x10(%ebp),%eax
  802407:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80240c:	b8 09 00 00 00       	mov    $0x9,%eax
  802411:	e8 4d fd ff ff       	call   802163 <nsipc>
}
  802416:	c9                   	leave  
  802417:	c3                   	ret    

00802418 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	56                   	push   %esi
  80241c:	53                   	push   %ebx
  80241d:	83 ec 10             	sub    $0x10,%esp
  802420:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802423:	8b 45 08             	mov    0x8(%ebp),%eax
  802426:	89 04 24             	mov    %eax,(%esp)
  802429:	e8 22 ec ff ff       	call   801050 <fd2data>
  80242e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802430:	c7 44 24 04 2f 33 80 	movl   $0x80332f,0x4(%esp)
  802437:	00 
  802438:	89 1c 24             	mov    %ebx,(%esp)
  80243b:	e8 b7 e4 ff ff       	call   8008f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802440:	8b 46 04             	mov    0x4(%esi),%eax
  802443:	2b 06                	sub    (%esi),%eax
  802445:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80244b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802452:	00 00 00 
	stat->st_dev = &devpipe;
  802455:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80245c:	40 80 00 
	return 0;
}
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	53                   	push   %ebx
  80246f:	83 ec 14             	sub    $0x14,%esp
  802472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802475:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802479:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802480:	e8 35 e9 ff ff       	call   800dba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802485:	89 1c 24             	mov    %ebx,(%esp)
  802488:	e8 c3 eb ff ff       	call   801050 <fd2data>
  80248d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802498:	e8 1d e9 ff ff       	call   800dba <sys_page_unmap>
}
  80249d:	83 c4 14             	add    $0x14,%esp
  8024a0:	5b                   	pop    %ebx
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    

008024a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
  8024a6:	57                   	push   %edi
  8024a7:	56                   	push   %esi
  8024a8:	53                   	push   %ebx
  8024a9:	83 ec 2c             	sub    $0x2c,%esp
  8024ac:	89 c6                	mov    %eax,%esi
  8024ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024b1:	a1 08 50 80 00       	mov    0x805008,%eax
  8024b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8024b9:	89 34 24             	mov    %esi,(%esp)
  8024bc:	e8 ac 05 00 00       	call   802a6d <pageref>
  8024c1:	89 c7                	mov    %eax,%edi
  8024c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c6:	89 04 24             	mov    %eax,(%esp)
  8024c9:	e8 9f 05 00 00       	call   802a6d <pageref>
  8024ce:	39 c7                	cmp    %eax,%edi
  8024d0:	0f 94 c2             	sete   %dl
  8024d3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8024d6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8024dc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8024df:	39 fb                	cmp    %edi,%ebx
  8024e1:	74 21                	je     802504 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8024e3:	84 d2                	test   %dl,%dl
  8024e5:	74 ca                	je     8024b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024e7:	8b 51 58             	mov    0x58(%ecx),%edx
  8024ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ee:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024f6:	c7 04 24 36 33 80 00 	movl   $0x803336,(%esp)
  8024fd:	e8 ca dd ff ff       	call   8002cc <cprintf>
  802502:	eb ad                	jmp    8024b1 <_pipeisclosed+0xe>
	}
}
  802504:	83 c4 2c             	add    $0x2c,%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    

0080250c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
  80250f:	57                   	push   %edi
  802510:	56                   	push   %esi
  802511:	53                   	push   %ebx
  802512:	83 ec 1c             	sub    $0x1c,%esp
  802515:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802518:	89 34 24             	mov    %esi,(%esp)
  80251b:	e8 30 eb ff ff       	call   801050 <fd2data>
  802520:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802522:	bf 00 00 00 00       	mov    $0x0,%edi
  802527:	eb 45                	jmp    80256e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802529:	89 da                	mov    %ebx,%edx
  80252b:	89 f0                	mov    %esi,%eax
  80252d:	e8 71 ff ff ff       	call   8024a3 <_pipeisclosed>
  802532:	85 c0                	test   %eax,%eax
  802534:	75 41                	jne    802577 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802536:	e8 b9 e7 ff ff       	call   800cf4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80253b:	8b 43 04             	mov    0x4(%ebx),%eax
  80253e:	8b 0b                	mov    (%ebx),%ecx
  802540:	8d 51 20             	lea    0x20(%ecx),%edx
  802543:	39 d0                	cmp    %edx,%eax
  802545:	73 e2                	jae    802529 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80254a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80254e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802551:	99                   	cltd   
  802552:	c1 ea 1b             	shr    $0x1b,%edx
  802555:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802558:	83 e1 1f             	and    $0x1f,%ecx
  80255b:	29 d1                	sub    %edx,%ecx
  80255d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802561:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802565:	83 c0 01             	add    $0x1,%eax
  802568:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80256b:	83 c7 01             	add    $0x1,%edi
  80256e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802571:	75 c8                	jne    80253b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802573:	89 f8                	mov    %edi,%eax
  802575:	eb 05                	jmp    80257c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802577:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80257c:	83 c4 1c             	add    $0x1c,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    

00802584 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	57                   	push   %edi
  802588:	56                   	push   %esi
  802589:	53                   	push   %ebx
  80258a:	83 ec 1c             	sub    $0x1c,%esp
  80258d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802590:	89 3c 24             	mov    %edi,(%esp)
  802593:	e8 b8 ea ff ff       	call   801050 <fd2data>
  802598:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80259a:	be 00 00 00 00       	mov    $0x0,%esi
  80259f:	eb 3d                	jmp    8025de <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025a1:	85 f6                	test   %esi,%esi
  8025a3:	74 04                	je     8025a9 <devpipe_read+0x25>
				return i;
  8025a5:	89 f0                	mov    %esi,%eax
  8025a7:	eb 43                	jmp    8025ec <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025a9:	89 da                	mov    %ebx,%edx
  8025ab:	89 f8                	mov    %edi,%eax
  8025ad:	e8 f1 fe ff ff       	call   8024a3 <_pipeisclosed>
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	75 31                	jne    8025e7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025b6:	e8 39 e7 ff ff       	call   800cf4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025bb:	8b 03                	mov    (%ebx),%eax
  8025bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8025c0:	74 df                	je     8025a1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025c2:	99                   	cltd   
  8025c3:	c1 ea 1b             	shr    $0x1b,%edx
  8025c6:	01 d0                	add    %edx,%eax
  8025c8:	83 e0 1f             	and    $0x1f,%eax
  8025cb:	29 d0                	sub    %edx,%eax
  8025cd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8025d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025d5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8025d8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025db:	83 c6 01             	add    $0x1,%esi
  8025de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025e1:	75 d8                	jne    8025bb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025e3:	89 f0                	mov    %esi,%eax
  8025e5:	eb 05                	jmp    8025ec <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025e7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025ec:	83 c4 1c             	add    $0x1c,%esp
  8025ef:	5b                   	pop    %ebx
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    

008025f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025f4:	55                   	push   %ebp
  8025f5:	89 e5                	mov    %esp,%ebp
  8025f7:	56                   	push   %esi
  8025f8:	53                   	push   %ebx
  8025f9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ff:	89 04 24             	mov    %eax,(%esp)
  802602:	e8 60 ea ff ff       	call   801067 <fd_alloc>
  802607:	89 c2                	mov    %eax,%edx
  802609:	85 d2                	test   %edx,%edx
  80260b:	0f 88 4d 01 00 00    	js     80275e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802611:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802618:	00 
  802619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802627:	e8 e7 e6 ff ff       	call   800d13 <sys_page_alloc>
  80262c:	89 c2                	mov    %eax,%edx
  80262e:	85 d2                	test   %edx,%edx
  802630:	0f 88 28 01 00 00    	js     80275e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802639:	89 04 24             	mov    %eax,(%esp)
  80263c:	e8 26 ea ff ff       	call   801067 <fd_alloc>
  802641:	89 c3                	mov    %eax,%ebx
  802643:	85 c0                	test   %eax,%eax
  802645:	0f 88 fe 00 00 00    	js     802749 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80264b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802652:	00 
  802653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802661:	e8 ad e6 ff ff       	call   800d13 <sys_page_alloc>
  802666:	89 c3                	mov    %eax,%ebx
  802668:	85 c0                	test   %eax,%eax
  80266a:	0f 88 d9 00 00 00    	js     802749 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802673:	89 04 24             	mov    %eax,(%esp)
  802676:	e8 d5 e9 ff ff       	call   801050 <fd2data>
  80267b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80267d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802684:	00 
  802685:	89 44 24 04          	mov    %eax,0x4(%esp)
  802689:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802690:	e8 7e e6 ff ff       	call   800d13 <sys_page_alloc>
  802695:	89 c3                	mov    %eax,%ebx
  802697:	85 c0                	test   %eax,%eax
  802699:	0f 88 97 00 00 00    	js     802736 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80269f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026a2:	89 04 24             	mov    %eax,(%esp)
  8026a5:	e8 a6 e9 ff ff       	call   801050 <fd2data>
  8026aa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8026b1:	00 
  8026b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026bd:	00 
  8026be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c9:	e8 99 e6 ff ff       	call   800d67 <sys_page_map>
  8026ce:	89 c3                	mov    %eax,%ebx
  8026d0:	85 c0                	test   %eax,%eax
  8026d2:	78 52                	js     802726 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026d4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026e9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802701:	89 04 24             	mov    %eax,(%esp)
  802704:	e8 37 e9 ff ff       	call   801040 <fd2num>
  802709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80270c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80270e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802711:	89 04 24             	mov    %eax,(%esp)
  802714:	e8 27 e9 ff ff       	call   801040 <fd2num>
  802719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80271c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80271f:	b8 00 00 00 00       	mov    $0x0,%eax
  802724:	eb 38                	jmp    80275e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802731:	e8 84 e6 ff ff       	call   800dba <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80273d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802744:	e8 71 e6 ff ff       	call   800dba <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80274c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802757:	e8 5e e6 ff ff       	call   800dba <sys_page_unmap>
  80275c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80275e:	83 c4 30             	add    $0x30,%esp
  802761:	5b                   	pop    %ebx
  802762:	5e                   	pop    %esi
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80276b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80276e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802772:	8b 45 08             	mov    0x8(%ebp),%eax
  802775:	89 04 24             	mov    %eax,(%esp)
  802778:	e8 39 e9 ff ff       	call   8010b6 <fd_lookup>
  80277d:	89 c2                	mov    %eax,%edx
  80277f:	85 d2                	test   %edx,%edx
  802781:	78 15                	js     802798 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802786:	89 04 24             	mov    %eax,(%esp)
  802789:	e8 c2 e8 ff ff       	call   801050 <fd2data>
	return _pipeisclosed(fd, p);
  80278e:	89 c2                	mov    %eax,%edx
  802790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802793:	e8 0b fd ff ff       	call   8024a3 <_pipeisclosed>
}
  802798:	c9                   	leave  
  802799:	c3                   	ret    
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8027a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8027a8:	5d                   	pop    %ebp
  8027a9:	c3                   	ret    

008027aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8027aa:	55                   	push   %ebp
  8027ab:	89 e5                	mov    %esp,%ebp
  8027ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8027b0:	c7 44 24 04 4e 33 80 	movl   $0x80334e,0x4(%esp)
  8027b7:	00 
  8027b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027bb:	89 04 24             	mov    %eax,(%esp)
  8027be:	e8 34 e1 ff ff       	call   8008f7 <strcpy>
	return 0;
}
  8027c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c8:	c9                   	leave  
  8027c9:	c3                   	ret    

008027ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027ca:	55                   	push   %ebp
  8027cb:	89 e5                	mov    %esp,%ebp
  8027cd:	57                   	push   %edi
  8027ce:	56                   	push   %esi
  8027cf:	53                   	push   %ebx
  8027d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027e1:	eb 31                	jmp    802814 <devcons_write+0x4a>
		m = n - tot;
  8027e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8027e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8027e8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027f0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027f7:	03 45 0c             	add    0xc(%ebp),%eax
  8027fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027fe:	89 3c 24             	mov    %edi,(%esp)
  802801:	e8 8e e2 ff ff       	call   800a94 <memmove>
		sys_cputs(buf, m);
  802806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80280a:	89 3c 24             	mov    %edi,(%esp)
  80280d:	e8 34 e4 ff ff       	call   800c46 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802812:	01 f3                	add    %esi,%ebx
  802814:	89 d8                	mov    %ebx,%eax
  802816:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802819:	72 c8                	jb     8027e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80281b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802821:	5b                   	pop    %ebx
  802822:	5e                   	pop    %esi
  802823:	5f                   	pop    %edi
  802824:	5d                   	pop    %ebp
  802825:	c3                   	ret    

00802826 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802826:	55                   	push   %ebp
  802827:	89 e5                	mov    %esp,%ebp
  802829:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80282c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802831:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802835:	75 07                	jne    80283e <devcons_read+0x18>
  802837:	eb 2a                	jmp    802863 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802839:	e8 b6 e4 ff ff       	call   800cf4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80283e:	66 90                	xchg   %ax,%ax
  802840:	e8 1f e4 ff ff       	call   800c64 <sys_cgetc>
  802845:	85 c0                	test   %eax,%eax
  802847:	74 f0                	je     802839 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802849:	85 c0                	test   %eax,%eax
  80284b:	78 16                	js     802863 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80284d:	83 f8 04             	cmp    $0x4,%eax
  802850:	74 0c                	je     80285e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802852:	8b 55 0c             	mov    0xc(%ebp),%edx
  802855:	88 02                	mov    %al,(%edx)
	return 1;
  802857:	b8 01 00 00 00       	mov    $0x1,%eax
  80285c:	eb 05                	jmp    802863 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80285e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802863:	c9                   	leave  
  802864:	c3                   	ret    

00802865 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802865:	55                   	push   %ebp
  802866:	89 e5                	mov    %esp,%ebp
  802868:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80286b:	8b 45 08             	mov    0x8(%ebp),%eax
  80286e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802871:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802878:	00 
  802879:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80287c:	89 04 24             	mov    %eax,(%esp)
  80287f:	e8 c2 e3 ff ff       	call   800c46 <sys_cputs>
}
  802884:	c9                   	leave  
  802885:	c3                   	ret    

00802886 <getchar>:

int
getchar(void)
{
  802886:	55                   	push   %ebp
  802887:	89 e5                	mov    %esp,%ebp
  802889:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80288c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802893:	00 
  802894:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80289b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028a2:	e8 a3 ea ff ff       	call   80134a <read>
	if (r < 0)
  8028a7:	85 c0                	test   %eax,%eax
  8028a9:	78 0f                	js     8028ba <getchar+0x34>
		return r;
	if (r < 1)
  8028ab:	85 c0                	test   %eax,%eax
  8028ad:	7e 06                	jle    8028b5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8028af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028b3:	eb 05                	jmp    8028ba <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028ba:	c9                   	leave  
  8028bb:	c3                   	ret    

008028bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028bc:	55                   	push   %ebp
  8028bd:	89 e5                	mov    %esp,%ebp
  8028bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8028cc:	89 04 24             	mov    %eax,(%esp)
  8028cf:	e8 e2 e7 ff ff       	call   8010b6 <fd_lookup>
  8028d4:	85 c0                	test   %eax,%eax
  8028d6:	78 11                	js     8028e9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028db:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028e1:	39 10                	cmp    %edx,(%eax)
  8028e3:	0f 94 c0             	sete   %al
  8028e6:	0f b6 c0             	movzbl %al,%eax
}
  8028e9:	c9                   	leave  
  8028ea:	c3                   	ret    

008028eb <opencons>:

int
opencons(void)
{
  8028eb:	55                   	push   %ebp
  8028ec:	89 e5                	mov    %esp,%ebp
  8028ee:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028f4:	89 04 24             	mov    %eax,(%esp)
  8028f7:	e8 6b e7 ff ff       	call   801067 <fd_alloc>
		return r;
  8028fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028fe:	85 c0                	test   %eax,%eax
  802900:	78 40                	js     802942 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802902:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802909:	00 
  80290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80290d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802918:	e8 f6 e3 ff ff       	call   800d13 <sys_page_alloc>
		return r;
  80291d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80291f:	85 c0                	test   %eax,%eax
  802921:	78 1f                	js     802942 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802923:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80292c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80292e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802931:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802938:	89 04 24             	mov    %eax,(%esp)
  80293b:	e8 00 e7 ff ff       	call   801040 <fd2num>
  802940:	89 c2                	mov    %eax,%edx
}
  802942:	89 d0                	mov    %edx,%eax
  802944:	c9                   	leave  
  802945:	c3                   	ret    
  802946:	66 90                	xchg   %ax,%ax
  802948:	66 90                	xchg   %ax,%ax
  80294a:	66 90                	xchg   %ax,%ax
  80294c:	66 90                	xchg   %ax,%ax
  80294e:	66 90                	xchg   %ax,%ax

00802950 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
  802953:	56                   	push   %esi
  802954:	53                   	push   %ebx
  802955:	83 ec 10             	sub    $0x10,%esp
  802958:	8b 75 08             	mov    0x8(%ebp),%esi
  80295b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80295e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802961:	85 c0                	test   %eax,%eax
  802963:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802968:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80296b:	89 04 24             	mov    %eax,(%esp)
  80296e:	e8 b6 e5 ff ff       	call   800f29 <sys_ipc_recv>

	if(ret < 0) {
  802973:	85 c0                	test   %eax,%eax
  802975:	79 16                	jns    80298d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802977:	85 f6                	test   %esi,%esi
  802979:	74 06                	je     802981 <ipc_recv+0x31>
  80297b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802981:	85 db                	test   %ebx,%ebx
  802983:	74 3e                	je     8029c3 <ipc_recv+0x73>
  802985:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80298b:	eb 36                	jmp    8029c3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80298d:	e8 43 e3 ff ff       	call   800cd5 <sys_getenvid>
  802992:	25 ff 03 00 00       	and    $0x3ff,%eax
  802997:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80299a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80299f:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8029a4:	85 f6                	test   %esi,%esi
  8029a6:	74 05                	je     8029ad <ipc_recv+0x5d>
  8029a8:	8b 40 74             	mov    0x74(%eax),%eax
  8029ab:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8029ad:	85 db                	test   %ebx,%ebx
  8029af:	74 0a                	je     8029bb <ipc_recv+0x6b>
  8029b1:	a1 08 50 80 00       	mov    0x805008,%eax
  8029b6:	8b 40 78             	mov    0x78(%eax),%eax
  8029b9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8029bb:	a1 08 50 80 00       	mov    0x805008,%eax
  8029c0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029c3:	83 c4 10             	add    $0x10,%esp
  8029c6:	5b                   	pop    %ebx
  8029c7:	5e                   	pop    %esi
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    

008029ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029ca:	55                   	push   %ebp
  8029cb:	89 e5                	mov    %esp,%ebp
  8029cd:	57                   	push   %edi
  8029ce:	56                   	push   %esi
  8029cf:	53                   	push   %ebx
  8029d0:	83 ec 1c             	sub    $0x1c,%esp
  8029d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8029dc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8029de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029e3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8029e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8029e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029f5:	89 3c 24             	mov    %edi,(%esp)
  8029f8:	e8 09 e5 ff ff       	call   800f06 <sys_ipc_try_send>

		if(ret >= 0) break;
  8029fd:	85 c0                	test   %eax,%eax
  8029ff:	79 2c                	jns    802a2d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802a01:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a04:	74 20                	je     802a26 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802a06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a0a:	c7 44 24 08 5c 33 80 	movl   $0x80335c,0x8(%esp)
  802a11:	00 
  802a12:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802a19:	00 
  802a1a:	c7 04 24 8c 33 80 00 	movl   $0x80338c,(%esp)
  802a21:	e8 ad d7 ff ff       	call   8001d3 <_panic>
		}
		sys_yield();
  802a26:	e8 c9 e2 ff ff       	call   800cf4 <sys_yield>
	}
  802a2b:	eb b9                	jmp    8029e6 <ipc_send+0x1c>
}
  802a2d:	83 c4 1c             	add    $0x1c,%esp
  802a30:	5b                   	pop    %ebx
  802a31:	5e                   	pop    %esi
  802a32:	5f                   	pop    %edi
  802a33:	5d                   	pop    %ebp
  802a34:	c3                   	ret    

00802a35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a35:	55                   	push   %ebp
  802a36:	89 e5                	mov    %esp,%ebp
  802a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a40:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a49:	8b 52 50             	mov    0x50(%edx),%edx
  802a4c:	39 ca                	cmp    %ecx,%edx
  802a4e:	75 0d                	jne    802a5d <ipc_find_env+0x28>
			return envs[i].env_id;
  802a50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a53:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802a58:	8b 40 40             	mov    0x40(%eax),%eax
  802a5b:	eb 0e                	jmp    802a6b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a5d:	83 c0 01             	add    $0x1,%eax
  802a60:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a65:	75 d9                	jne    802a40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a67:	66 b8 00 00          	mov    $0x0,%ax
}
  802a6b:	5d                   	pop    %ebp
  802a6c:	c3                   	ret    

00802a6d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a6d:	55                   	push   %ebp
  802a6e:	89 e5                	mov    %esp,%ebp
  802a70:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a73:	89 d0                	mov    %edx,%eax
  802a75:	c1 e8 16             	shr    $0x16,%eax
  802a78:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a7f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a84:	f6 c1 01             	test   $0x1,%cl
  802a87:	74 1d                	je     802aa6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a89:	c1 ea 0c             	shr    $0xc,%edx
  802a8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a93:	f6 c2 01             	test   $0x1,%dl
  802a96:	74 0e                	je     802aa6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a98:	c1 ea 0c             	shr    $0xc,%edx
  802a9b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802aa2:	ef 
  802aa3:	0f b7 c0             	movzwl %ax,%eax
}
  802aa6:	5d                   	pop    %ebp
  802aa7:	c3                   	ret    
  802aa8:	66 90                	xchg   %ax,%ax
  802aaa:	66 90                	xchg   %ax,%ax
  802aac:	66 90                	xchg   %ax,%ax
  802aae:	66 90                	xchg   %ax,%ax

00802ab0 <__udivdi3>:
  802ab0:	55                   	push   %ebp
  802ab1:	57                   	push   %edi
  802ab2:	56                   	push   %esi
  802ab3:	83 ec 0c             	sub    $0xc,%esp
  802ab6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802aba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802abe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802ac2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802ac6:	85 c0                	test   %eax,%eax
  802ac8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802acc:	89 ea                	mov    %ebp,%edx
  802ace:	89 0c 24             	mov    %ecx,(%esp)
  802ad1:	75 2d                	jne    802b00 <__udivdi3+0x50>
  802ad3:	39 e9                	cmp    %ebp,%ecx
  802ad5:	77 61                	ja     802b38 <__udivdi3+0x88>
  802ad7:	85 c9                	test   %ecx,%ecx
  802ad9:	89 ce                	mov    %ecx,%esi
  802adb:	75 0b                	jne    802ae8 <__udivdi3+0x38>
  802add:	b8 01 00 00 00       	mov    $0x1,%eax
  802ae2:	31 d2                	xor    %edx,%edx
  802ae4:	f7 f1                	div    %ecx
  802ae6:	89 c6                	mov    %eax,%esi
  802ae8:	31 d2                	xor    %edx,%edx
  802aea:	89 e8                	mov    %ebp,%eax
  802aec:	f7 f6                	div    %esi
  802aee:	89 c5                	mov    %eax,%ebp
  802af0:	89 f8                	mov    %edi,%eax
  802af2:	f7 f6                	div    %esi
  802af4:	89 ea                	mov    %ebp,%edx
  802af6:	83 c4 0c             	add    $0xc,%esp
  802af9:	5e                   	pop    %esi
  802afa:	5f                   	pop    %edi
  802afb:	5d                   	pop    %ebp
  802afc:	c3                   	ret    
  802afd:	8d 76 00             	lea    0x0(%esi),%esi
  802b00:	39 e8                	cmp    %ebp,%eax
  802b02:	77 24                	ja     802b28 <__udivdi3+0x78>
  802b04:	0f bd e8             	bsr    %eax,%ebp
  802b07:	83 f5 1f             	xor    $0x1f,%ebp
  802b0a:	75 3c                	jne    802b48 <__udivdi3+0x98>
  802b0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802b10:	39 34 24             	cmp    %esi,(%esp)
  802b13:	0f 86 9f 00 00 00    	jbe    802bb8 <__udivdi3+0x108>
  802b19:	39 d0                	cmp    %edx,%eax
  802b1b:	0f 82 97 00 00 00    	jb     802bb8 <__udivdi3+0x108>
  802b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b28:	31 d2                	xor    %edx,%edx
  802b2a:	31 c0                	xor    %eax,%eax
  802b2c:	83 c4 0c             	add    $0xc,%esp
  802b2f:	5e                   	pop    %esi
  802b30:	5f                   	pop    %edi
  802b31:	5d                   	pop    %ebp
  802b32:	c3                   	ret    
  802b33:	90                   	nop
  802b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b38:	89 f8                	mov    %edi,%eax
  802b3a:	f7 f1                	div    %ecx
  802b3c:	31 d2                	xor    %edx,%edx
  802b3e:	83 c4 0c             	add    $0xc,%esp
  802b41:	5e                   	pop    %esi
  802b42:	5f                   	pop    %edi
  802b43:	5d                   	pop    %ebp
  802b44:	c3                   	ret    
  802b45:	8d 76 00             	lea    0x0(%esi),%esi
  802b48:	89 e9                	mov    %ebp,%ecx
  802b4a:	8b 3c 24             	mov    (%esp),%edi
  802b4d:	d3 e0                	shl    %cl,%eax
  802b4f:	89 c6                	mov    %eax,%esi
  802b51:	b8 20 00 00 00       	mov    $0x20,%eax
  802b56:	29 e8                	sub    %ebp,%eax
  802b58:	89 c1                	mov    %eax,%ecx
  802b5a:	d3 ef                	shr    %cl,%edi
  802b5c:	89 e9                	mov    %ebp,%ecx
  802b5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802b62:	8b 3c 24             	mov    (%esp),%edi
  802b65:	09 74 24 08          	or     %esi,0x8(%esp)
  802b69:	89 d6                	mov    %edx,%esi
  802b6b:	d3 e7                	shl    %cl,%edi
  802b6d:	89 c1                	mov    %eax,%ecx
  802b6f:	89 3c 24             	mov    %edi,(%esp)
  802b72:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b76:	d3 ee                	shr    %cl,%esi
  802b78:	89 e9                	mov    %ebp,%ecx
  802b7a:	d3 e2                	shl    %cl,%edx
  802b7c:	89 c1                	mov    %eax,%ecx
  802b7e:	d3 ef                	shr    %cl,%edi
  802b80:	09 d7                	or     %edx,%edi
  802b82:	89 f2                	mov    %esi,%edx
  802b84:	89 f8                	mov    %edi,%eax
  802b86:	f7 74 24 08          	divl   0x8(%esp)
  802b8a:	89 d6                	mov    %edx,%esi
  802b8c:	89 c7                	mov    %eax,%edi
  802b8e:	f7 24 24             	mull   (%esp)
  802b91:	39 d6                	cmp    %edx,%esi
  802b93:	89 14 24             	mov    %edx,(%esp)
  802b96:	72 30                	jb     802bc8 <__udivdi3+0x118>
  802b98:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b9c:	89 e9                	mov    %ebp,%ecx
  802b9e:	d3 e2                	shl    %cl,%edx
  802ba0:	39 c2                	cmp    %eax,%edx
  802ba2:	73 05                	jae    802ba9 <__udivdi3+0xf9>
  802ba4:	3b 34 24             	cmp    (%esp),%esi
  802ba7:	74 1f                	je     802bc8 <__udivdi3+0x118>
  802ba9:	89 f8                	mov    %edi,%eax
  802bab:	31 d2                	xor    %edx,%edx
  802bad:	e9 7a ff ff ff       	jmp    802b2c <__udivdi3+0x7c>
  802bb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bb8:	31 d2                	xor    %edx,%edx
  802bba:	b8 01 00 00 00       	mov    $0x1,%eax
  802bbf:	e9 68 ff ff ff       	jmp    802b2c <__udivdi3+0x7c>
  802bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802bcb:	31 d2                	xor    %edx,%edx
  802bcd:	83 c4 0c             	add    $0xc,%esp
  802bd0:	5e                   	pop    %esi
  802bd1:	5f                   	pop    %edi
  802bd2:	5d                   	pop    %ebp
  802bd3:	c3                   	ret    
  802bd4:	66 90                	xchg   %ax,%ax
  802bd6:	66 90                	xchg   %ax,%ax
  802bd8:	66 90                	xchg   %ax,%ax
  802bda:	66 90                	xchg   %ax,%ax
  802bdc:	66 90                	xchg   %ax,%ax
  802bde:	66 90                	xchg   %ax,%ax

00802be0 <__umoddi3>:
  802be0:	55                   	push   %ebp
  802be1:	57                   	push   %edi
  802be2:	56                   	push   %esi
  802be3:	83 ec 14             	sub    $0x14,%esp
  802be6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802bea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802bee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802bf2:	89 c7                	mov    %eax,%edi
  802bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bf8:	8b 44 24 30          	mov    0x30(%esp),%eax
  802bfc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802c00:	89 34 24             	mov    %esi,(%esp)
  802c03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c07:	85 c0                	test   %eax,%eax
  802c09:	89 c2                	mov    %eax,%edx
  802c0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c0f:	75 17                	jne    802c28 <__umoddi3+0x48>
  802c11:	39 fe                	cmp    %edi,%esi
  802c13:	76 4b                	jbe    802c60 <__umoddi3+0x80>
  802c15:	89 c8                	mov    %ecx,%eax
  802c17:	89 fa                	mov    %edi,%edx
  802c19:	f7 f6                	div    %esi
  802c1b:	89 d0                	mov    %edx,%eax
  802c1d:	31 d2                	xor    %edx,%edx
  802c1f:	83 c4 14             	add    $0x14,%esp
  802c22:	5e                   	pop    %esi
  802c23:	5f                   	pop    %edi
  802c24:	5d                   	pop    %ebp
  802c25:	c3                   	ret    
  802c26:	66 90                	xchg   %ax,%ax
  802c28:	39 f8                	cmp    %edi,%eax
  802c2a:	77 54                	ja     802c80 <__umoddi3+0xa0>
  802c2c:	0f bd e8             	bsr    %eax,%ebp
  802c2f:	83 f5 1f             	xor    $0x1f,%ebp
  802c32:	75 5c                	jne    802c90 <__umoddi3+0xb0>
  802c34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802c38:	39 3c 24             	cmp    %edi,(%esp)
  802c3b:	0f 87 e7 00 00 00    	ja     802d28 <__umoddi3+0x148>
  802c41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c45:	29 f1                	sub    %esi,%ecx
  802c47:	19 c7                	sbb    %eax,%edi
  802c49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c51:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c59:	83 c4 14             	add    $0x14,%esp
  802c5c:	5e                   	pop    %esi
  802c5d:	5f                   	pop    %edi
  802c5e:	5d                   	pop    %ebp
  802c5f:	c3                   	ret    
  802c60:	85 f6                	test   %esi,%esi
  802c62:	89 f5                	mov    %esi,%ebp
  802c64:	75 0b                	jne    802c71 <__umoddi3+0x91>
  802c66:	b8 01 00 00 00       	mov    $0x1,%eax
  802c6b:	31 d2                	xor    %edx,%edx
  802c6d:	f7 f6                	div    %esi
  802c6f:	89 c5                	mov    %eax,%ebp
  802c71:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c75:	31 d2                	xor    %edx,%edx
  802c77:	f7 f5                	div    %ebp
  802c79:	89 c8                	mov    %ecx,%eax
  802c7b:	f7 f5                	div    %ebp
  802c7d:	eb 9c                	jmp    802c1b <__umoddi3+0x3b>
  802c7f:	90                   	nop
  802c80:	89 c8                	mov    %ecx,%eax
  802c82:	89 fa                	mov    %edi,%edx
  802c84:	83 c4 14             	add    $0x14,%esp
  802c87:	5e                   	pop    %esi
  802c88:	5f                   	pop    %edi
  802c89:	5d                   	pop    %ebp
  802c8a:	c3                   	ret    
  802c8b:	90                   	nop
  802c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c90:	8b 04 24             	mov    (%esp),%eax
  802c93:	be 20 00 00 00       	mov    $0x20,%esi
  802c98:	89 e9                	mov    %ebp,%ecx
  802c9a:	29 ee                	sub    %ebp,%esi
  802c9c:	d3 e2                	shl    %cl,%edx
  802c9e:	89 f1                	mov    %esi,%ecx
  802ca0:	d3 e8                	shr    %cl,%eax
  802ca2:	89 e9                	mov    %ebp,%ecx
  802ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ca8:	8b 04 24             	mov    (%esp),%eax
  802cab:	09 54 24 04          	or     %edx,0x4(%esp)
  802caf:	89 fa                	mov    %edi,%edx
  802cb1:	d3 e0                	shl    %cl,%eax
  802cb3:	89 f1                	mov    %esi,%ecx
  802cb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802cb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802cbd:	d3 ea                	shr    %cl,%edx
  802cbf:	89 e9                	mov    %ebp,%ecx
  802cc1:	d3 e7                	shl    %cl,%edi
  802cc3:	89 f1                	mov    %esi,%ecx
  802cc5:	d3 e8                	shr    %cl,%eax
  802cc7:	89 e9                	mov    %ebp,%ecx
  802cc9:	09 f8                	or     %edi,%eax
  802ccb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802ccf:	f7 74 24 04          	divl   0x4(%esp)
  802cd3:	d3 e7                	shl    %cl,%edi
  802cd5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802cd9:	89 d7                	mov    %edx,%edi
  802cdb:	f7 64 24 08          	mull   0x8(%esp)
  802cdf:	39 d7                	cmp    %edx,%edi
  802ce1:	89 c1                	mov    %eax,%ecx
  802ce3:	89 14 24             	mov    %edx,(%esp)
  802ce6:	72 2c                	jb     802d14 <__umoddi3+0x134>
  802ce8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802cec:	72 22                	jb     802d10 <__umoddi3+0x130>
  802cee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802cf2:	29 c8                	sub    %ecx,%eax
  802cf4:	19 d7                	sbb    %edx,%edi
  802cf6:	89 e9                	mov    %ebp,%ecx
  802cf8:	89 fa                	mov    %edi,%edx
  802cfa:	d3 e8                	shr    %cl,%eax
  802cfc:	89 f1                	mov    %esi,%ecx
  802cfe:	d3 e2                	shl    %cl,%edx
  802d00:	89 e9                	mov    %ebp,%ecx
  802d02:	d3 ef                	shr    %cl,%edi
  802d04:	09 d0                	or     %edx,%eax
  802d06:	89 fa                	mov    %edi,%edx
  802d08:	83 c4 14             	add    $0x14,%esp
  802d0b:	5e                   	pop    %esi
  802d0c:	5f                   	pop    %edi
  802d0d:	5d                   	pop    %ebp
  802d0e:	c3                   	ret    
  802d0f:	90                   	nop
  802d10:	39 d7                	cmp    %edx,%edi
  802d12:	75 da                	jne    802cee <__umoddi3+0x10e>
  802d14:	8b 14 24             	mov    (%esp),%edx
  802d17:	89 c1                	mov    %eax,%ecx
  802d19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802d1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802d21:	eb cb                	jmp    802cee <__umoddi3+0x10e>
  802d23:	90                   	nop
  802d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802d2c:	0f 82 0f ff ff ff    	jb     802c41 <__umoddi3+0x61>
  802d32:	e9 1a ff ff ff       	jmp    802c51 <__umoddi3+0x71>
