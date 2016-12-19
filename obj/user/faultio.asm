
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 0c                	je     80004c <umain+0x19>
		cprintf("eflags wrong\n");
  800040:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  800047:	e8 1d 01 00 00       	call   800169 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80004c:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800051:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800056:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  800057:	c7 04 24 ee 25 80 00 	movl   $0x8025ee,(%esp)
  80005e:	e8 06 01 00 00       	call   800169 <cprintf>
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	83 ec 10             	sub    $0x10,%esp
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800073:	e8 fd 0a 00 00       	call   800b75 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x30>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	89 74 24 04          	mov    %esi,0x4(%esp)
  800099:	89 1c 24             	mov    %ebx,(%esp)
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 07 00 00 00       	call   8000ad <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b3:	e8 02 10 00 00       	call   8010ba <close_all>
	sys_env_destroy(0);
  8000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bf:	e8 5f 0a 00 00       	call   800b23 <sys_env_destroy>
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 14             	sub    $0x14,%esp
  8000cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d0:	8b 13                	mov    (%ebx),%edx
  8000d2:	8d 42 01             	lea    0x1(%edx),%eax
  8000d5:	89 03                	mov    %eax,(%ebx)
  8000d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 ee 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800102:	83 c4 14             	add    $0x14,%esp
  800105:	5b                   	pop    %ebx
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012c:	8b 45 08             	mov    0x8(%ebp),%eax
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	c7 04 24 c6 00 80 00 	movl   $0x8000c6,(%esp)
  800144:	e8 b5 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800149:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 85 09 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 87 ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    
  800183:	66 90                	xchg   %ax,%ax
  800185:	66 90                	xchg   %ax,%ax
  800187:	66 90                	xchg   %ax,%ax
  800189:	66 90                	xchg   %ax,%ax
  80018b:	66 90                	xchg   %ax,%ax
  80018d:	66 90                	xchg   %ax,%ax
  80018f:	90                   	nop

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 c3                	mov    %eax,%ebx
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bd:	39 d9                	cmp    %ebx,%ecx
  8001bf:	72 05                	jb     8001c6 <printnum+0x36>
  8001c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c4:	77 69                	ja     80022f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001cd:	83 ee 01             	sub    $0x1,%esi
  8001d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e0:	89 c3                	mov    %eax,%ebx
  8001e2:	89 d6                	mov    %edx,%esi
  8001e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	e8 4c 21 00 00       	call   802350 <__udivdi3>
  800204:	89 d9                	mov    %ebx,%ecx
  800206:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
  800215:	89 fa                	mov    %edi,%edx
  800217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021a:	e8 71 ff ff ff       	call   800190 <printnum>
  80021f:	eb 1b                	jmp    80023c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	8b 45 18             	mov    0x18(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	ff d3                	call   *%ebx
  80022d:	eb 03                	jmp    800232 <printnum+0xa2>
  80022f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800232:	83 ee 01             	sub    $0x1,%esi
  800235:	85 f6                	test   %esi,%esi
  800237:	7f e8                	jg     800221 <printnum+0x91>
  800239:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800247:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80024a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	e8 1c 22 00 00       	call   802480 <__umoddi3>
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	0f be 80 12 26 80 00 	movsbl 0x802612(%eax),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800275:	ff d0                	call   *%eax
}
  800277:	83 c4 3c             	add    $0x3c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800282:	83 fa 01             	cmp    $0x1,%edx
  800285:	7e 0e                	jle    800295 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800287:	8b 10                	mov    (%eax),%edx
  800289:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 02                	mov    (%edx),%eax
  800290:	8b 52 04             	mov    0x4(%edx),%edx
  800293:	eb 22                	jmp    8002b7 <getuint+0x38>
	else if (lflag)
  800295:	85 d2                	test   %edx,%edx
  800297:	74 10                	je     8002a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	eb 0e                	jmp    8002b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 0a                	jae    8002d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	88 02                	mov    %al,(%edx)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 02 00 00 00       	call   8002fe <vprintfmt>
	va_end(ap);
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 3c             	sub    $0x3c,%esp
  800307:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80030a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030d:	eb 14                	jmp    800323 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030f:	85 c0                	test   %eax,%eax
  800311:	0f 84 b3 03 00 00    	je     8006ca <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800317:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800321:	89 f3                	mov    %esi,%ebx
  800323:	8d 73 01             	lea    0x1(%ebx),%esi
  800326:	0f b6 03             	movzbl (%ebx),%eax
  800329:	83 f8 25             	cmp    $0x25,%eax
  80032c:	75 e1                	jne    80030f <vprintfmt+0x11>
  80032e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800332:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800339:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800340:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800347:	ba 00 00 00 00       	mov    $0x0,%edx
  80034c:	eb 1d                	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800350:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800354:	eb 15                	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800358:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80035c:	eb 0d                	jmp    80036b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800361:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800364:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80036e:	0f b6 0e             	movzbl (%esi),%ecx
  800371:	0f b6 c1             	movzbl %cl,%eax
  800374:	83 e9 23             	sub    $0x23,%ecx
  800377:	80 f9 55             	cmp    $0x55,%cl
  80037a:	0f 87 2a 03 00 00    	ja     8006aa <vprintfmt+0x3ac>
  800380:	0f b6 c9             	movzbl %cl,%ecx
  800383:	ff 24 8d 60 27 80 00 	jmp    *0x802760(,%ecx,4)
  80038a:	89 de                	mov    %ebx,%esi
  80038c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800391:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800394:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800398:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80039e:	83 fb 09             	cmp    $0x9,%ebx
  8003a1:	77 36                	ja     8003d9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b8:	eb 22                	jmp    8003dc <vprintfmt+0xde>
  8003ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003bd:	85 c9                	test   %ecx,%ecx
  8003bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c4:	0f 49 c1             	cmovns %ecx,%eax
  8003c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
  8003cc:	eb 9d                	jmp    80036b <vprintfmt+0x6d>
  8003ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003d7:	eb 92                	jmp    80036b <vprintfmt+0x6d>
  8003d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8003dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003e0:	79 89                	jns    80036b <vprintfmt+0x6d>
  8003e2:	e9 77 ff ff ff       	jmp    80035e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 7a ff ff ff       	jmp    80036b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 08             	call   *0x8(%ebp)
			break;
  800406:	e9 18 ff ff ff       	jmp    800323 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	99                   	cltd   
  800417:	31 d0                	xor    %edx,%eax
  800419:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 0f             	cmp    $0xf,%eax
  80041e:	7f 0b                	jg     80042b <vprintfmt+0x12d>
  800420:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	75 20                	jne    80044b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	c7 44 24 08 2a 26 80 	movl   $0x80262a,0x8(%esp)
  800436:	00 
  800437:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	e8 90 fe ff ff       	call   8002d6 <printfmt>
  800446:	e9 d8 fe ff ff       	jmp    800323 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044f:	c7 44 24 08 f5 29 80 	movl   $0x8029f5,0x8(%esp)
  800456:	00 
  800457:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	89 04 24             	mov    %eax,(%esp)
  800461:	e8 70 fe ff ff       	call   8002d6 <printfmt>
  800466:	e9 b8 fe ff ff       	jmp    800323 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80046e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800471:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80047f:	85 f6                	test   %esi,%esi
  800481:	b8 23 26 80 00       	mov    $0x802623,%eax
  800486:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800489:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048d:	0f 84 97 00 00 00    	je     80052a <vprintfmt+0x22c>
  800493:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800497:	0f 8e 9b 00 00 00    	jle    800538 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a1:	89 34 24             	mov    %esi,(%esp)
  8004a4:	e8 cf 02 00 00       	call   800778 <strnlen>
  8004a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ac:	29 c2                	sub    %eax,%edx
  8004ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	eb 0f                	jmp    8004d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f ed                	jg     8004c5 <vprintfmt+0x1c7>
  8004d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	0f 49 c2             	cmovns %edx,%eax
  8004e8:	29 c2                	sub    %eax,%edx
  8004ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004ed:	89 d7                	mov    %edx,%edi
  8004ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004f2:	eb 50                	jmp    800544 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f8:	74 1e                	je     800518 <vprintfmt+0x21a>
  8004fa:	0f be d2             	movsbl %dl,%edx
  8004fd:	83 ea 20             	sub    $0x20,%edx
  800500:	83 fa 5e             	cmp    $0x5e,%edx
  800503:	76 13                	jbe    800518 <vprintfmt+0x21a>
					putch('?', putdat);
  800505:	8b 45 0c             	mov    0xc(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
  800516:	eb 0d                	jmp    800525 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800518:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	eb 1a                	jmp    800544 <vprintfmt+0x246>
  80052a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80052d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800530:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800533:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800536:	eb 0c                	jmp    800544 <vprintfmt+0x246>
  800538:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80053e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800541:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800544:	83 c6 01             	add    $0x1,%esi
  800547:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80054b:	0f be c2             	movsbl %dl,%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 27                	je     800579 <vprintfmt+0x27b>
  800552:	85 db                	test   %ebx,%ebx
  800554:	78 9e                	js     8004f4 <vprintfmt+0x1f6>
  800556:	83 eb 01             	sub    $0x1,%ebx
  800559:	79 99                	jns    8004f4 <vprintfmt+0x1f6>
  80055b:	89 f8                	mov    %edi,%eax
  80055d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	89 c3                	mov    %eax,%ebx
  800565:	eb 1a                	jmp    800581 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800567:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	eb 08                	jmp    800581 <vprintfmt+0x283>
  800579:	89 fb                	mov    %edi,%ebx
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800581:	85 db                	test   %ebx,%ebx
  800583:	7f e2                	jg     800567 <vprintfmt+0x269>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80058b:	e9 93 fd ff ff       	jmp    800323 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 fa 01             	cmp    $0x1,%edx
  800593:	7e 16                	jle    8005ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 08             	lea    0x8(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a9:	eb 32                	jmp    8005dd <vprintfmt+0x2df>
	else if (lflag)
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 30                	mov    (%eax),%esi
  8005ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005bd:	89 f0                	mov    %esi,%eax
  8005bf:	c1 f8 1f             	sar    $0x1f,%eax
  8005c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 30                	mov    (%eax),%esi
  8005d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005d5:	89 f0                	mov    %esi,%eax
  8005d7:	c1 f8 1f             	sar    $0x1f,%eax
  8005da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ec:	0f 89 80 00 00 00    	jns    800672 <vprintfmt+0x374>
				putch('-', putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800600:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800606:	f7 d8                	neg    %eax
  800608:	83 d2 00             	adc    $0x0,%edx
  80060b:	f7 da                	neg    %edx
			}
			base = 10;
  80060d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800612:	eb 5e                	jmp    800672 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 63 fc ff ff       	call   80027f <getuint>
			base = 10;
  80061c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800621:	eb 4f                	jmp    800672 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 54 fc ff ff       	call   80027f <getuint>
			base = 8;
  80062b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800630:	eb 40                	jmp    800672 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80063d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800640:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800644:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800663:	eb 0d                	jmp    800672 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 12 fc ff ff       	call   80027f <getuint>
			base = 16;
  80066d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800672:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800676:	89 74 24 10          	mov    %esi,0x10(%esp)
  80067a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80067d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800681:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800685:	89 04 24             	mov    %eax,(%esp)
  800688:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068c:	89 fa                	mov    %edi,%edx
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	e8 fa fa ff ff       	call   800190 <printnum>
			break;
  800696:	e9 88 fc ff ff       	jmp    800323 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006a5:	e9 79 fc ff ff       	jmp    800323 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	89 f3                	mov    %esi,%ebx
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x3c1>
  8006bc:	83 eb 01             	sub    $0x1,%ebx
  8006bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x3be>
  8006c5:	e9 59 fc ff ff       	jmp    800323 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	83 c4 3c             	add    $0x3c,%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 28             	sub    $0x28,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 30                	je     800723 <vsnprintf+0x51>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 2c                	jle    800723 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800701:	89 44 24 08          	mov    %eax,0x8(%esp)
  800705:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	c7 04 24 b9 02 80 00 	movl   $0x8002b9,(%esp)
  800713:	e8 e6 fb ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	eb 05                	jmp    800728 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800733:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	89 04 24             	mov    %eax,(%esp)
  80074b:	e8 82 ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    
  800752:	66 90                	xchg   %ax,%ax
  800754:	66 90                	xchg   %ax,%ax
  800756:	66 90                	xchg   %ax,%ax
  800758:	66 90                	xchg   %ax,%ax
  80075a:	66 90                	xchg   %ax,%ax
  80075c:	66 90                	xchg   %ax,%ax
  80075e:	66 90                	xchg   %ax,%ax

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1d>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	89 1c 24             	mov    %ebx,(%esp)
  8007c4:	e8 97 ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d0:	01 d8                	add    %ebx,%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 bd ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	5b                   	pop    %ebx
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	eb 0f                	jmp    800805 <strncpy+0x23>
		*dst++ = *src;
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	0f b6 01             	movzbl (%ecx),%eax
  8007fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800802:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	39 da                	cmp    %ebx,%edx
  800807:	75 ed                	jne    8007f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800809:	89 f0                	mov    %esi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 c9                	test   %ecx,%ecx
  800825:	75 0b                	jne    800832 <strlcpy+0x23>
  800827:	eb 1d                	jmp    800846 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800832:	39 d8                	cmp    %ebx,%eax
  800834:	74 0b                	je     800841 <strlcpy+0x32>
  800836:	0f b6 0a             	movzbl (%edx),%ecx
  800839:	84 c9                	test   %cl,%cl
  80083b:	75 ec                	jne    800829 <strlcpy+0x1a>
  80083d:	89 c2                	mov    %eax,%edx
  80083f:	eb 02                	jmp    800843 <strlcpy+0x34>
  800841:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800843:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	eb 06                	jmp    80085d <strcmp+0x11>
		p++, q++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 04                	je     800868 <strcmp+0x1c>
  800864:	3a 02                	cmp    (%edx),%al
  800866:	74 ef                	je     800857 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800881:	eb 06                	jmp    800889 <strncmp+0x17>
		n--, p++, q++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 15                	je     8008a2 <strncmp+0x30>
  80088d:	0f b6 08             	movzbl (%eax),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	74 04                	je     800898 <strncmp+0x26>
  800894:	3a 0a                	cmp    (%edx),%cl
  800896:	74 eb                	je     800883 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb 05                	jmp    8008a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	eb 07                	jmp    8008bd <strchr+0x13>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 0f                	je     8008c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 07                	jmp    8008de <strfind+0x13>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 0a                	je     8008e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 36                	je     80092d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fd:	75 28                	jne    800927 <memset+0x40>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 23                	jne    800927 <memset+0x40>
		c &= 0xFF;
  800904:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	89 d3                	mov    %edx,%ebx
  80090a:	c1 e3 08             	shl    $0x8,%ebx
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 18             	shl    $0x18,%esi
  800912:	89 d0                	mov    %edx,%eax
  800914:	c1 e0 10             	shl    $0x10,%eax
  800917:	09 f0                	or     %esi,%eax
  800919:	09 c2                	or     %eax,%edx
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800922:	fc                   	cld    
  800923:	f3 ab                	rep stos %eax,%es:(%edi)
  800925:	eb 06                	jmp    80092d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 35                	jae    80097b <memmove+0x47>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 d0                	cmp    %edx,%eax
  80094b:	73 2e                	jae    80097b <memmove+0x47>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800950:	89 d6                	mov    %edx,%esi
  800952:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 13                	jne    80096f <memmove+0x3b>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0e                	jne    80096f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800961:	83 ef 04             	sub    $0x4,%edi
  800964:	8d 72 fc             	lea    -0x4(%edx),%esi
  800967:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096a:	fd                   	std    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 09                	jmp    800978 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096f:	83 ef 01             	sub    $0x1,%edi
  800972:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	fd                   	std    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800978:	fc                   	cld    
  800979:	eb 1d                	jmp    800998 <memmove+0x64>
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	75 0f                	jne    800993 <memmove+0x5f>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 0a                	jne    800993 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800989:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 05                	jmp    800998 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 79 ff ff ff       	call   800934 <memmove>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	eb 1a                	jmp    8009e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cf:	0f b6 02             	movzbl (%edx),%eax
  8009d2:	0f b6 19             	movzbl (%ecx),%ebx
  8009d5:	38 d8                	cmp    %bl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 db             	movzbl %bl,%ebx
  8009df:	29 d8                	sub    %ebx,%eax
  8009e1:	eb 0f                	jmp    8009f2 <memcmp+0x35>
		s1++, s2++;
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e9:	39 f2                	cmp    %esi,%edx
  8009eb:	75 e2                	jne    8009cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a04:	eb 07                	jmp    800a0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 07                	je     800a11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	72 f5                	jb     800a06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 03                	jmp    800a24 <strtol+0x11>
		s++;
  800a21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a24:	0f b6 0a             	movzbl (%edx),%ecx
  800a27:	80 f9 09             	cmp    $0x9,%cl
  800a2a:	74 f5                	je     800a21 <strtol+0xe>
  800a2c:	80 f9 20             	cmp    $0x20,%cl
  800a2f:	74 f0                	je     800a21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	80 f9 2b             	cmp    $0x2b,%cl
  800a34:	75 0a                	jne    800a40 <strtol+0x2d>
		s++;
  800a36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3e:	eb 11                	jmp    800a51 <strtol+0x3e>
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a45:	80 f9 2d             	cmp    $0x2d,%cl
  800a48:	75 07                	jne    800a51 <strtol+0x3e>
		s++, neg = 1;
  800a4a:	8d 52 01             	lea    0x1(%edx),%edx
  800a4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a56:	75 15                	jne    800a6d <strtol+0x5a>
  800a58:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5b:	75 10                	jne    800a6d <strtol+0x5a>
  800a5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a61:	75 0a                	jne    800a6d <strtol+0x5a>
		s += 2, base = 16;
  800a63:	83 c2 02             	add    $0x2,%edx
  800a66:	b8 10 00 00 00       	mov    $0x10,%eax
  800a6b:	eb 10                	jmp    800a7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	75 0c                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	80 3a 30             	cmpb   $0x30,(%edx)
  800a76:	75 05                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a85:	0f b6 0a             	movzbl (%edx),%ecx
  800a88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	3c 09                	cmp    $0x9,%al
  800a8f:	77 08                	ja     800a99 <strtol+0x86>
			dig = *s - '0';
  800a91:	0f be c9             	movsbl %cl,%ecx
  800a94:	83 e9 30             	sub    $0x30,%ecx
  800a97:	eb 20                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	3c 19                	cmp    $0x19,%al
  800aa0:	77 08                	ja     800aaa <strtol+0x97>
			dig = *s - 'a' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 57             	sub    $0x57,%ecx
  800aa8:	eb 0f                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	3c 19                	cmp    $0x19,%al
  800ab1:	77 16                	ja     800ac9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800abc:	7d 0f                	jge    800acd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c2 01             	add    $0x1,%edx
  800ac1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ac5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ac7:	eb bc                	jmp    800a85 <strtol+0x72>
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	eb 02                	jmp    800acf <strtol+0xbc>
  800acd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 05                	je     800ada <strtol+0xc7>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ada:	f7 d8                	neg    %eax
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 44 c3             	cmove  %ebx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	89 c7                	mov    %eax,%edi
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 cb                	mov    %ecx,%ebx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	89 ce                	mov    %ecx,%esi
  800b3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 28                	jle    800b6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b50:	00 
  800b51:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800b58:	00 
  800b59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b60:	00 
  800b61:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800b68:	e8 29 16 00 00       	call   802196 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6d:	83 c4 2c             	add    $0x2c,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 02 00 00 00       	mov    $0x2,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_yield>:

void
sys_yield(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	be 00 00 00 00       	mov    $0x0,%esi
  800bc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcf:	89 f7                	mov    %esi,%edi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800bfa:	e8 97 15 00 00       	call   802196 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 75 18             	mov    0x18(%ebp),%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 28                	jle    800c52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c35:	00 
  800c36:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c45:	00 
  800c46:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800c4d:	e8 44 15 00 00       	call   802196 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c52:	83 c4 2c             	add    $0x2c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800ca0:	e8 f1 14 00 00       	call   802196 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800cf3:	e8 9e 14 00 00       	call   802196 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 28                	jle    800d4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800d46:	e8 4b 14 00 00       	call   802196 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4b:	83 c4 2c             	add    $0x2c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800d99:	e8 f8 13 00 00       	call   802196 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9e:	83 c4 2c             	add    $0x2c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	be 00 00 00 00       	mov    $0x0,%esi
  800db1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	89 cf                	mov    %ecx,%edi
  800de3:	89 ce                	mov    %ecx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800e0e:	e8 83 13 00 00       	call   802196 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e13:	83 c4 2c             	add    $0x2c,%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e21:	ba 00 00 00 00       	mov    $0x0,%edx
  800e26:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e2b:	89 d1                	mov    %edx,%ecx
  800e2d:	89 d3                	mov    %edx,%ebx
  800e2f:	89 d7                	mov    %edx,%edi
  800e31:	89 d6                	mov    %edx,%esi
  800e33:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 28                	jle    800e85 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e61:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800e68:	00 
  800e69:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800e70:	00 
  800e71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e78:	00 
  800e79:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800e80:	e8 11 13 00 00       	call   802196 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800e85:	83 c4 2c             	add    $0x2c,%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9b:	b8 10 00 00 00       	mov    $0x10,%eax
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 df                	mov    %ebx,%edi
  800ea8:	89 de                	mov    %ebx,%esi
  800eaa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	7e 28                	jle    800ed8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800ed3:	e8 be 12 00 00       	call   802196 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800ed8:	83 c4 2c             	add    $0x2c,%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	05 00 00 00 30       	add    $0x30000000,%eax
  800eeb:	c1 e8 0c             	shr    $0xc,%eax
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 16             	shr    $0x16,%edx
  800f17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 11                	je     800f34 <fd_alloc+0x2d>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 0c             	shr    $0xc,%edx
  800f28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	75 09                	jne    800f3d <fd_alloc+0x36>
			*fd_store = fd;
  800f34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 17                	jmp    800f54 <fd_alloc+0x4d>
  800f3d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f42:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f47:	75 c9                	jne    800f12 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f49:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f4f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5c:	83 f8 1f             	cmp    $0x1f,%eax
  800f5f:	77 36                	ja     800f97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f61:	c1 e0 0c             	shl    $0xc,%eax
  800f64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 16             	shr    $0x16,%edx
  800f6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 24                	je     800f9e <fd_lookup+0x48>
  800f7a:	89 c2                	mov    %eax,%edx
  800f7c:	c1 ea 0c             	shr    $0xc,%edx
  800f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	74 1a                	je     800fa5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb 13                	jmp    800faa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9c:	eb 0c                	jmp    800faa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa3:	eb 05                	jmp    800faa <fd_lookup+0x54>
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 18             	sub    $0x18,%esp
  800fb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	eb 13                	jmp    800fcf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800fbc:	39 08                	cmp    %ecx,(%eax)
  800fbe:	75 0c                	jne    800fcc <dev_lookup+0x20>
			*dev = devtab[i];
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	eb 38                	jmp    801004 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcc:	83 c2 01             	add    $0x1,%edx
  800fcf:	8b 04 95 c8 29 80 00 	mov    0x8029c8(,%edx,4),%eax
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	75 e2                	jne    800fbc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fda:	a1 08 40 80 00       	mov    0x804008,%eax
  800fdf:	8b 40 48             	mov    0x48(%eax),%eax
  800fe2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fea:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  800ff1:	e8 73 f1 ff ff       	call   800169 <cprintf>
	*dev = 0;
  800ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 20             	sub    $0x20,%esp
  80100e:	8b 75 08             	mov    0x8(%ebp),%esi
  801011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801017:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80101b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801021:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801024:	89 04 24             	mov    %eax,(%esp)
  801027:	e8 2a ff ff ff       	call   800f56 <fd_lookup>
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 05                	js     801035 <fd_close+0x2f>
	    || fd != fd2)
  801030:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801033:	74 0c                	je     801041 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801035:	84 db                	test   %bl,%bl
  801037:	ba 00 00 00 00       	mov    $0x0,%edx
  80103c:	0f 44 c2             	cmove  %edx,%eax
  80103f:	eb 3f                	jmp    801080 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801041:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801044:	89 44 24 04          	mov    %eax,0x4(%esp)
  801048:	8b 06                	mov    (%esi),%eax
  80104a:	89 04 24             	mov    %eax,(%esp)
  80104d:	e8 5a ff ff ff       	call   800fac <dev_lookup>
  801052:	89 c3                	mov    %eax,%ebx
  801054:	85 c0                	test   %eax,%eax
  801056:	78 16                	js     80106e <fd_close+0x68>
		if (dev->dev_close)
  801058:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80105e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801063:	85 c0                	test   %eax,%eax
  801065:	74 07                	je     80106e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	ff d0                	call   *%eax
  80106c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80106e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801079:	e8 dc fb ff ff       	call   800c5a <sys_page_unmap>
	return r;
  80107e:	89 d8                	mov    %ebx,%eax
}
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801090:	89 44 24 04          	mov    %eax,0x4(%esp)
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	e8 b7 fe ff ff       	call   800f56 <fd_lookup>
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	85 d2                	test   %edx,%edx
  8010a3:	78 13                	js     8010b8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ac:	00 
  8010ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b0:	89 04 24             	mov    %eax,(%esp)
  8010b3:	e8 4e ff ff ff       	call   801006 <fd_close>
}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <close_all>:

void
close_all(void)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c6:	89 1c 24             	mov    %ebx,(%esp)
  8010c9:	e8 b9 ff ff ff       	call   801087 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ce:	83 c3 01             	add    $0x1,%ebx
  8010d1:	83 fb 20             	cmp    $0x20,%ebx
  8010d4:	75 f0                	jne    8010c6 <close_all+0xc>
		close(i);
}
  8010d6:	83 c4 14             	add    $0x14,%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 5f fe ff ff       	call   800f56 <fd_lookup>
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	85 d2                	test   %edx,%edx
  8010fb:	0f 88 e1 00 00 00    	js     8011e2 <dup+0x106>
		return r;
	close(newfdnum);
  801101:	8b 45 0c             	mov    0xc(%ebp),%eax
  801104:	89 04 24             	mov    %eax,(%esp)
  801107:	e8 7b ff ff ff       	call   801087 <close>

	newfd = INDEX2FD(newfdnum);
  80110c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80110f:	c1 e3 0c             	shl    $0xc,%ebx
  801112:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111b:	89 04 24             	mov    %eax,(%esp)
  80111e:	e8 cd fd ff ff       	call   800ef0 <fd2data>
  801123:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801125:	89 1c 24             	mov    %ebx,(%esp)
  801128:	e8 c3 fd ff ff       	call   800ef0 <fd2data>
  80112d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112f:	89 f0                	mov    %esi,%eax
  801131:	c1 e8 16             	shr    $0x16,%eax
  801134:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113b:	a8 01                	test   $0x1,%al
  80113d:	74 43                	je     801182 <dup+0xa6>
  80113f:	89 f0                	mov    %esi,%eax
  801141:	c1 e8 0c             	shr    $0xc,%eax
  801144:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80114b:	f6 c2 01             	test   $0x1,%dl
  80114e:	74 32                	je     801182 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801150:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801157:	25 07 0e 00 00       	and    $0xe07,%eax
  80115c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801160:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80116b:	00 
  80116c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801177:	e8 8b fa ff ff       	call   800c07 <sys_page_map>
  80117c:	89 c6                	mov    %eax,%esi
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 3e                	js     8011c0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 0c             	shr    $0xc,%edx
  80118a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801191:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801197:	89 54 24 10          	mov    %edx,0x10(%esp)
  80119b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80119f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a6:	00 
  8011a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b2:	e8 50 fa ff ff       	call   800c07 <sys_page_map>
  8011b7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bc:	85 f6                	test   %esi,%esi
  8011be:	79 22                	jns    8011e2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cb:	e8 8a fa ff ff       	call   800c5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011db:	e8 7a fa ff ff       	call   800c5a <sys_page_unmap>
	return r;
  8011e0:	89 f0                	mov    %esi,%eax
}
  8011e2:	83 c4 3c             	add    $0x3c,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 24             	sub    $0x24,%esp
  8011f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fb:	89 1c 24             	mov    %ebx,(%esp)
  8011fe:	e8 53 fd ff ff       	call   800f56 <fd_lookup>
  801203:	89 c2                	mov    %eax,%edx
  801205:	85 d2                	test   %edx,%edx
  801207:	78 6d                	js     801276 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801213:	8b 00                	mov    (%eax),%eax
  801215:	89 04 24             	mov    %eax,(%esp)
  801218:	e8 8f fd ff ff       	call   800fac <dev_lookup>
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 55                	js     801276 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	8b 50 08             	mov    0x8(%eax),%edx
  801227:	83 e2 03             	and    $0x3,%edx
  80122a:	83 fa 01             	cmp    $0x1,%edx
  80122d:	75 23                	jne    801252 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122f:	a1 08 40 80 00       	mov    0x804008,%eax
  801234:	8b 40 48             	mov    0x48(%eax),%eax
  801237:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123f:	c7 04 24 8d 29 80 00 	movl   $0x80298d,(%esp)
  801246:	e8 1e ef ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  80124b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801250:	eb 24                	jmp    801276 <read+0x8c>
	}
	if (!dev->dev_read)
  801252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801255:	8b 52 08             	mov    0x8(%edx),%edx
  801258:	85 d2                	test   %edx,%edx
  80125a:	74 15                	je     801271 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80125c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80125f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801266:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	ff d2                	call   *%edx
  80126f:	eb 05                	jmp    801276 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801271:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801276:	83 c4 24             	add    $0x24,%esp
  801279:	5b                   	pop    %ebx
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	57                   	push   %edi
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
  801282:	83 ec 1c             	sub    $0x1c,%esp
  801285:	8b 7d 08             	mov    0x8(%ebp),%edi
  801288:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801290:	eb 23                	jmp    8012b5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801292:	89 f0                	mov    %esi,%eax
  801294:	29 d8                	sub    %ebx,%eax
  801296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129a:	89 d8                	mov    %ebx,%eax
  80129c:	03 45 0c             	add    0xc(%ebp),%eax
  80129f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a3:	89 3c 24             	mov    %edi,(%esp)
  8012a6:	e8 3f ff ff ff       	call   8011ea <read>
		if (m < 0)
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 10                	js     8012bf <readn+0x43>
			return m;
		if (m == 0)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	74 0a                	je     8012bd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b3:	01 c3                	add    %eax,%ebx
  8012b5:	39 f3                	cmp    %esi,%ebx
  8012b7:	72 d9                	jb     801292 <readn+0x16>
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	eb 02                	jmp    8012bf <readn+0x43>
  8012bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012bf:	83 c4 1c             	add    $0x1c,%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 24             	sub    $0x24,%esp
  8012ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	89 1c 24             	mov    %ebx,(%esp)
  8012db:	e8 76 fc ff ff       	call   800f56 <fd_lookup>
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	85 d2                	test   %edx,%edx
  8012e4:	78 68                	js     80134e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	8b 00                	mov    (%eax),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 b2 fc ff ff       	call   800fac <dev_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 50                	js     80134e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801305:	75 23                	jne    80132a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801307:	a1 08 40 80 00       	mov    0x804008,%eax
  80130c:	8b 40 48             	mov    0x48(%eax),%eax
  80130f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  80131e:	e8 46 ee ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 24                	jmp    80134e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132d:	8b 52 0c             	mov    0xc(%edx),%edx
  801330:	85 d2                	test   %edx,%edx
  801332:	74 15                	je     801349 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801337:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	ff d2                	call   *%edx
  801347:	eb 05                	jmp    80134e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801349:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80134e:	83 c4 24             	add    $0x24,%esp
  801351:	5b                   	pop    %ebx
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <seek>:

int
seek(int fdnum, off_t offset)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	89 04 24             	mov    %eax,(%esp)
  801367:	e8 ea fb ff ff       	call   800f56 <fd_lookup>
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 0e                	js     80137e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801370:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801373:	8b 55 0c             	mov    0xc(%ebp),%edx
  801376:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 24             	sub    $0x24,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801391:	89 1c 24             	mov    %ebx,(%esp)
  801394:	e8 bd fb ff ff       	call   800f56 <fd_lookup>
  801399:	89 c2                	mov    %eax,%edx
  80139b:	85 d2                	test   %edx,%edx
  80139d:	78 61                	js     801400 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	8b 00                	mov    (%eax),%eax
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 f9 fb ff ff       	call   800fac <dev_lookup>
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 49                	js     801400 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013be:	75 23                	jne    8013e3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c5:	8b 40 48             	mov    0x48(%eax),%eax
  8013c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d0:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  8013d7:	e8 8d ed ff ff       	call   800169 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e1:	eb 1d                	jmp    801400 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8013e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e6:	8b 52 18             	mov    0x18(%edx),%edx
  8013e9:	85 d2                	test   %edx,%edx
  8013eb:	74 0e                	je     8013fb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013f4:	89 04 24             	mov    %eax,(%esp)
  8013f7:	ff d2                	call   *%edx
  8013f9:	eb 05                	jmp    801400 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801400:	83 c4 24             	add    $0x24,%esp
  801403:	5b                   	pop    %ebx
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 24             	sub    $0x24,%esp
  80140d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801410:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	e8 34 fb ff ff       	call   800f56 <fd_lookup>
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	78 52                	js     80147a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	8b 00                	mov    (%eax),%eax
  801434:	89 04 24             	mov    %eax,(%esp)
  801437:	e8 70 fb ff ff       	call   800fac <dev_lookup>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 3a                	js     80147a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801443:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801447:	74 2c                	je     801475 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801449:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801453:	00 00 00 
	stat->st_isdir = 0;
  801456:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145d:	00 00 00 
	stat->st_dev = dev;
  801460:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801466:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146d:	89 14 24             	mov    %edx,(%esp)
  801470:	ff 50 14             	call   *0x14(%eax)
  801473:	eb 05                	jmp    80147a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801475:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80147a:	83 c4 24             	add    $0x24,%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80148f:	00 
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 28 02 00 00       	call   8016c3 <open>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	85 db                	test   %ebx,%ebx
  80149f:	78 1b                	js     8014bc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	89 1c 24             	mov    %ebx,(%esp)
  8014ab:	e8 56 ff ff ff       	call   801406 <fstat>
  8014b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b2:	89 1c 24             	mov    %ebx,(%esp)
  8014b5:	e8 cd fb ff ff       	call   801087 <close>
	return r;
  8014ba:	89 f0                	mov    %esi,%eax
}
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 10             	sub    $0x10,%esp
  8014cb:	89 c6                	mov    %eax,%esi
  8014cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014cf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d6:	75 11                	jne    8014e9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014df:	e8 f1 0d 00 00       	call   8022d5 <ipc_find_env>
  8014e4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014f0:	00 
  8014f1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014f8:	00 
  8014f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fd:	a1 00 40 80 00       	mov    0x804000,%eax
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	e8 60 0d 00 00       	call   80226a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80150a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801511:	00 
  801512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801516:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151d:	e8 ce 0c 00 00       	call   8021f0 <ipc_recv>
}
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	8b 40 0c             	mov    0xc(%eax),%eax
  801535:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 02 00 00 00       	mov    $0x2,%eax
  80154c:	e8 72 ff ff ff       	call   8014c3 <fsipc>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
  80155c:	8b 40 0c             	mov    0xc(%eax),%eax
  80155f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 06 00 00 00       	mov    $0x6,%eax
  80156e:	e8 50 ff ff ff       	call   8014c3 <fsipc>
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 14             	sub    $0x14,%esp
  80157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	8b 40 0c             	mov    0xc(%eax),%eax
  801585:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158a:	ba 00 00 00 00       	mov    $0x0,%edx
  80158f:	b8 05 00 00 00       	mov    $0x5,%eax
  801594:	e8 2a ff ff ff       	call   8014c3 <fsipc>
  801599:	89 c2                	mov    %eax,%edx
  80159b:	85 d2                	test   %edx,%edx
  80159d:	78 2b                	js     8015ca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80159f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015a6:	00 
  8015a7:	89 1c 24             	mov    %ebx,(%esp)
  8015aa:	e8 e8 f1 ff ff       	call   800797 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015af:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8015bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ca:	83 c4 14             	add    $0x14,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 18             	sub    $0x18,%esp
  8015d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015de:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015e3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015f2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8015f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801602:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801609:	e8 26 f3 ff ff       	call   800934 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 04 00 00 00       	mov    $0x4,%eax
  801618:	e8 a6 fe ff ff       	call   8014c3 <fsipc>
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 10             	sub    $0x10,%esp
  801627:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	8b 40 0c             	mov    0xc(%eax),%eax
  801630:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801635:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 03 00 00 00       	mov    $0x3,%eax
  801645:	e8 79 fe ff ff       	call   8014c3 <fsipc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 6a                	js     8016ba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801650:	39 c6                	cmp    %eax,%esi
  801652:	73 24                	jae    801678 <devfile_read+0x59>
  801654:	c7 44 24 0c dc 29 80 	movl   $0x8029dc,0xc(%esp)
  80165b:	00 
  80165c:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801663:	00 
  801664:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80166b:	00 
  80166c:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  801673:	e8 1e 0b 00 00       	call   802196 <_panic>
	assert(r <= PGSIZE);
  801678:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167d:	7e 24                	jle    8016a3 <devfile_read+0x84>
  80167f:	c7 44 24 0c 03 2a 80 	movl   $0x802a03,0xc(%esp)
  801686:	00 
  801687:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  80168e:	00 
  80168f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801696:	00 
  801697:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  80169e:	e8 f3 0a 00 00       	call   802196 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016ae:	00 
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 7a f2 ff ff       	call   800934 <memmove>
	return r;
}
  8016ba:	89 d8                	mov    %ebx,%eax
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 24             	sub    $0x24,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 8b f0 ff ff       	call   800760 <strlen>
  8016d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016da:	7f 60                	jg     80173c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	89 04 24             	mov    %eax,(%esp)
  8016e2:	e8 20 f8 ff ff       	call   800f07 <fd_alloc>
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	85 d2                	test   %edx,%edx
  8016eb:	78 54                	js     801741 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016f8:	e8 9a f0 ff ff       	call   800797 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801705:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801708:	b8 01 00 00 00       	mov    $0x1,%eax
  80170d:	e8 b1 fd ff ff       	call   8014c3 <fsipc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	85 c0                	test   %eax,%eax
  801716:	79 17                	jns    80172f <open+0x6c>
		fd_close(fd, 0);
  801718:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80171f:	00 
  801720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 db f8 ff ff       	call   801006 <fd_close>
		return r;
  80172b:	89 d8                	mov    %ebx,%eax
  80172d:	eb 12                	jmp    801741 <open+0x7e>
	}

	return fd2num(fd);
  80172f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801732:	89 04 24             	mov    %eax,(%esp)
  801735:	e8 a6 f7 ff ff       	call   800ee0 <fd2num>
  80173a:	eb 05                	jmp    801741 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801741:	83 c4 24             	add    $0x24,%esp
  801744:	5b                   	pop    %ebx
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 08 00 00 00       	mov    $0x8,%eax
  801757:	e8 67 fd ff ff       	call   8014c3 <fsipc>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    
  80175e:	66 90                	xchg   %ax,%ax

00801760 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801766:	c7 44 24 04 0f 2a 80 	movl   $0x802a0f,0x4(%esp)
  80176d:	00 
  80176e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 1e f0 ff ff       	call   800797 <strcpy>
	return 0;
}
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 14             	sub    $0x14,%esp
  801787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80178a:	89 1c 24             	mov    %ebx,(%esp)
  80178d:	e8 7b 0b 00 00       	call   80230d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801797:	83 f8 01             	cmp    $0x1,%eax
  80179a:	75 0d                	jne    8017a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80179c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80179f:	89 04 24             	mov    %eax,(%esp)
  8017a2:	e8 29 03 00 00       	call   801ad0 <nsipc_close>
  8017a7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8017a9:	89 d0                	mov    %edx,%eax
  8017ab:	83 c4 14             	add    $0x14,%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017be:	00 
  8017bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	89 04 24             	mov    %eax,(%esp)
  8017d6:	e8 f0 03 00 00       	call   801bcb <nsipc_send>
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017ea:	00 
  8017eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 44 03 00 00       	call   801b4b <nsipc_recv>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80180f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801812:	89 54 24 04          	mov    %edx,0x4(%esp)
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 38 f7 ff ff       	call   800f56 <fd_lookup>
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 17                	js     801839 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801825:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80182b:	39 08                	cmp    %ecx,(%eax)
  80182d:	75 05                	jne    801834 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	eb 05                	jmp    801839 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801834:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	56                   	push   %esi
  80183f:	53                   	push   %ebx
  801840:	83 ec 20             	sub    $0x20,%esp
  801843:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	e8 b7 f6 ff ff       	call   800f07 <fd_alloc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	85 c0                	test   %eax,%eax
  801854:	78 21                	js     801877 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801856:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80185d:	00 
  80185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186c:	e8 42 f3 ff ff       	call   800bb3 <sys_page_alloc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	85 c0                	test   %eax,%eax
  801875:	79 0c                	jns    801883 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801877:	89 34 24             	mov    %esi,(%esp)
  80187a:	e8 51 02 00 00       	call   801ad0 <nsipc_close>
		return r;
  80187f:	89 d8                	mov    %ebx,%eax
  801881:	eb 20                	jmp    8018a3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801883:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80188e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801891:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801898:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80189b:	89 14 24             	mov    %edx,(%esp)
  80189e:	e8 3d f6 ff ff       	call   800ee0 <fd2num>
}
  8018a3:	83 c4 20             	add    $0x20,%esp
  8018a6:	5b                   	pop    %ebx
  8018a7:	5e                   	pop    %esi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	e8 51 ff ff ff       	call   801809 <fd2sockid>
		return r;
  8018b8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 23                	js     8018e1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018be:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	e8 45 01 00 00       	call   801a19 <nsipc_accept>
		return r;
  8018d4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 07                	js     8018e1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  8018da:	e8 5c ff ff ff       	call   80183b <alloc_sockfd>
  8018df:	89 c1                	mov    %eax,%ecx
}
  8018e1:	89 c8                	mov    %ecx,%eax
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	e8 16 ff ff ff       	call   801809 <fd2sockid>
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	85 d2                	test   %edx,%edx
  8018f7:	78 16                	js     80190f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8018f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8018fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801900:	8b 45 0c             	mov    0xc(%ebp),%eax
  801903:	89 44 24 04          	mov    %eax,0x4(%esp)
  801907:	89 14 24             	mov    %edx,(%esp)
  80190a:	e8 60 01 00 00       	call   801a6f <nsipc_bind>
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <shutdown>:

int
shutdown(int s, int how)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	e8 ea fe ff ff       	call   801809 <fd2sockid>
  80191f:	89 c2                	mov    %eax,%edx
  801921:	85 d2                	test   %edx,%edx
  801923:	78 0f                	js     801934 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192c:	89 14 24             	mov    %edx,(%esp)
  80192f:	e8 7a 01 00 00       	call   801aae <nsipc_shutdown>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	e8 c5 fe ff ff       	call   801809 <fd2sockid>
  801944:	89 c2                	mov    %eax,%edx
  801946:	85 d2                	test   %edx,%edx
  801948:	78 16                	js     801960 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80194a:	8b 45 10             	mov    0x10(%ebp),%eax
  80194d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801951:	8b 45 0c             	mov    0xc(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	89 14 24             	mov    %edx,(%esp)
  80195b:	e8 8a 01 00 00       	call   801aea <nsipc_connect>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <listen>:

int
listen(int s, int backlog)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	e8 99 fe ff ff       	call   801809 <fd2sockid>
  801970:	89 c2                	mov    %eax,%edx
  801972:	85 d2                	test   %edx,%edx
  801974:	78 0f                	js     801985 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197d:	89 14 24             	mov    %edx,(%esp)
  801980:	e8 a4 01 00 00       	call   801b29 <nsipc_listen>
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80198d:	8b 45 10             	mov    0x10(%ebp),%eax
  801990:	89 44 24 08          	mov    %eax,0x8(%esp)
  801994:	8b 45 0c             	mov    0xc(%ebp),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 98 02 00 00       	call   801c3e <nsipc_socket>
  8019a6:	89 c2                	mov    %eax,%edx
  8019a8:	85 d2                	test   %edx,%edx
  8019aa:	78 05                	js     8019b1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  8019ac:	e8 8a fe ff ff       	call   80183b <alloc_sockfd>
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	53                   	push   %ebx
  8019b7:	83 ec 14             	sub    $0x14,%esp
  8019ba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019bc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019c3:	75 11                	jne    8019d6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019cc:	e8 04 09 00 00       	call   8022d5 <ipc_find_env>
  8019d1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019dd:	00 
  8019de:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019e5:	00 
  8019e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8019ef:	89 04 24             	mov    %eax,(%esp)
  8019f2:	e8 73 08 00 00       	call   80226a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019fe:	00 
  8019ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a06:	00 
  801a07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0e:	e8 dd 07 00 00       	call   8021f0 <ipc_recv>
}
  801a13:	83 c4 14             	add    $0x14,%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 10             	sub    $0x10,%esp
  801a21:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a2c:	8b 06                	mov    (%esi),%eax
  801a2e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a33:	b8 01 00 00 00       	mov    $0x1,%eax
  801a38:	e8 76 ff ff ff       	call   8019b3 <nsipc>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 23                	js     801a66 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a43:	a1 10 60 80 00       	mov    0x806010,%eax
  801a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a53:	00 
  801a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a57:	89 04 24             	mov    %eax,(%esp)
  801a5a:	e8 d5 ee ff ff       	call   800934 <memmove>
		*addrlen = ret->ret_addrlen;
  801a5f:	a1 10 60 80 00       	mov    0x806010,%eax
  801a64:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801a66:	89 d8                	mov    %ebx,%eax
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	53                   	push   %ebx
  801a73:	83 ec 14             	sub    $0x14,%esp
  801a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a81:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a93:	e8 9c ee ff ff       	call   800934 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a98:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a9e:	b8 02 00 00 00       	mov    $0x2,%eax
  801aa3:	e8 0b ff ff ff       	call   8019b3 <nsipc>
}
  801aa8:	83 c4 14             	add    $0x14,%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ac4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac9:	e8 e5 fe ff ff       	call   8019b3 <nsipc>
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ade:	b8 04 00 00 00       	mov    $0x4,%eax
  801ae3:	e8 cb fe ff ff       	call   8019b3 <nsipc>
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	83 ec 14             	sub    $0x14,%esp
  801af1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801afc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b07:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b0e:	e8 21 ee ff ff       	call   800934 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b13:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b19:	b8 05 00 00 00       	mov    $0x5,%eax
  801b1e:	e8 90 fe ff ff       	call   8019b3 <nsipc>
}
  801b23:	83 c4 14             	add    $0x14,%esp
  801b26:	5b                   	pop    %ebx
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b3f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b44:	e8 6a fe ff ff       	call   8019b3 <nsipc>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	56                   	push   %esi
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 10             	sub    $0x10,%esp
  801b53:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b5e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b64:	8b 45 14             	mov    0x14(%ebp),%eax
  801b67:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b6c:	b8 07 00 00 00       	mov    $0x7,%eax
  801b71:	e8 3d fe ff ff       	call   8019b3 <nsipc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 46                	js     801bc2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801b7c:	39 f0                	cmp    %esi,%eax
  801b7e:	7f 07                	jg     801b87 <nsipc_recv+0x3c>
  801b80:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b85:	7e 24                	jle    801bab <nsipc_recv+0x60>
  801b87:	c7 44 24 0c 1b 2a 80 	movl   $0x802a1b,0xc(%esp)
  801b8e:	00 
  801b8f:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801b96:	00 
  801b97:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801b9e:	00 
  801b9f:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801ba6:	e8 eb 05 00 00       	call   802196 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801baf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bb6:	00 
  801bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bba:	89 04 24             	mov    %eax,(%esp)
  801bbd:	e8 72 ed ff ff       	call   800934 <memmove>
	}

	return r;
}
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 14             	sub    $0x14,%esp
  801bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bdd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801be3:	7e 24                	jle    801c09 <nsipc_send+0x3e>
  801be5:	c7 44 24 0c 3c 2a 80 	movl   $0x802a3c,0xc(%esp)
  801bec:	00 
  801bed:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801bf4:	00 
  801bf5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801bfc:	00 
  801bfd:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801c04:	e8 8d 05 00 00       	call   802196 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c14:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801c1b:	e8 14 ed ff ff       	call   800934 <memmove>
	nsipcbuf.send.req_size = size;
  801c20:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c26:	8b 45 14             	mov    0x14(%ebp),%eax
  801c29:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c2e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c33:	e8 7b fd ff ff       	call   8019b3 <nsipc>
}
  801c38:	83 c4 14             	add    $0x14,%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c54:	8b 45 10             	mov    0x10(%ebp),%eax
  801c57:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c5c:	b8 09 00 00 00       	mov    $0x9,%eax
  801c61:	e8 4d fd ff ff       	call   8019b3 <nsipc>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 10             	sub    $0x10,%esp
  801c70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	89 04 24             	mov    %eax,(%esp)
  801c79:	e8 72 f2 ff ff       	call   800ef0 <fd2data>
  801c7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c80:	c7 44 24 04 48 2a 80 	movl   $0x802a48,0x4(%esp)
  801c87:	00 
  801c88:	89 1c 24             	mov    %ebx,(%esp)
  801c8b:	e8 07 eb ff ff       	call   800797 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c90:	8b 46 04             	mov    0x4(%esi),%eax
  801c93:	2b 06                	sub    (%esi),%eax
  801c95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ca2:	00 00 00 
	stat->st_dev = &devpipe;
  801ca5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cac:	30 80 00 
	return 0;
}
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	53                   	push   %ebx
  801cbf:	83 ec 14             	sub    $0x14,%esp
  801cc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd0:	e8 85 ef ff ff       	call   800c5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd5:	89 1c 24             	mov    %ebx,(%esp)
  801cd8:	e8 13 f2 ff ff       	call   800ef0 <fd2data>
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce8:	e8 6d ef ff ff       	call   800c5a <sys_page_unmap>
}
  801ced:	83 c4 14             	add    $0x14,%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	57                   	push   %edi
  801cf7:	56                   	push   %esi
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 2c             	sub    $0x2c,%esp
  801cfc:	89 c6                	mov    %eax,%esi
  801cfe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d01:	a1 08 40 80 00       	mov    0x804008,%eax
  801d06:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d09:	89 34 24             	mov    %esi,(%esp)
  801d0c:	e8 fc 05 00 00       	call   80230d <pageref>
  801d11:	89 c7                	mov    %eax,%edi
  801d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 ef 05 00 00       	call   80230d <pageref>
  801d1e:	39 c7                	cmp    %eax,%edi
  801d20:	0f 94 c2             	sete   %dl
  801d23:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d26:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d2c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d2f:	39 fb                	cmp    %edi,%ebx
  801d31:	74 21                	je     801d54 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d33:	84 d2                	test   %dl,%dl
  801d35:	74 ca                	je     801d01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d37:	8b 51 58             	mov    0x58(%ecx),%edx
  801d3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d46:	c7 04 24 4f 2a 80 00 	movl   $0x802a4f,(%esp)
  801d4d:	e8 17 e4 ff ff       	call   800169 <cprintf>
  801d52:	eb ad                	jmp    801d01 <_pipeisclosed+0xe>
	}
}
  801d54:	83 c4 2c             	add    $0x2c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	57                   	push   %edi
  801d60:	56                   	push   %esi
  801d61:	53                   	push   %ebx
  801d62:	83 ec 1c             	sub    $0x1c,%esp
  801d65:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d68:	89 34 24             	mov    %esi,(%esp)
  801d6b:	e8 80 f1 ff ff       	call   800ef0 <fd2data>
  801d70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d72:	bf 00 00 00 00       	mov    $0x0,%edi
  801d77:	eb 45                	jmp    801dbe <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d79:	89 da                	mov    %ebx,%edx
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	e8 71 ff ff ff       	call   801cf3 <_pipeisclosed>
  801d82:	85 c0                	test   %eax,%eax
  801d84:	75 41                	jne    801dc7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d86:	e8 09 ee ff ff       	call   800b94 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d8e:	8b 0b                	mov    (%ebx),%ecx
  801d90:	8d 51 20             	lea    0x20(%ecx),%edx
  801d93:	39 d0                	cmp    %edx,%eax
  801d95:	73 e2                	jae    801d79 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801da1:	99                   	cltd   
  801da2:	c1 ea 1b             	shr    $0x1b,%edx
  801da5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801da8:	83 e1 1f             	and    $0x1f,%ecx
  801dab:	29 d1                	sub    %edx,%ecx
  801dad:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801db1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801db5:	83 c0 01             	add    $0x1,%eax
  801db8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbb:	83 c7 01             	add    $0x1,%edi
  801dbe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dc1:	75 c8                	jne    801d8b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dc3:	89 f8                	mov    %edi,%eax
  801dc5:	eb 05                	jmp    801dcc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dcc:	83 c4 1c             	add    $0x1c,%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	57                   	push   %edi
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 1c             	sub    $0x1c,%esp
  801ddd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801de0:	89 3c 24             	mov    %edi,(%esp)
  801de3:	e8 08 f1 ff ff       	call   800ef0 <fd2data>
  801de8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dea:	be 00 00 00 00       	mov    $0x0,%esi
  801def:	eb 3d                	jmp    801e2e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801df1:	85 f6                	test   %esi,%esi
  801df3:	74 04                	je     801df9 <devpipe_read+0x25>
				return i;
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	eb 43                	jmp    801e3c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801df9:	89 da                	mov    %ebx,%edx
  801dfb:	89 f8                	mov    %edi,%eax
  801dfd:	e8 f1 fe ff ff       	call   801cf3 <_pipeisclosed>
  801e02:	85 c0                	test   %eax,%eax
  801e04:	75 31                	jne    801e37 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e06:	e8 89 ed ff ff       	call   800b94 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e0b:	8b 03                	mov    (%ebx),%eax
  801e0d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e10:	74 df                	je     801df1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e12:	99                   	cltd   
  801e13:	c1 ea 1b             	shr    $0x1b,%edx
  801e16:	01 d0                	add    %edx,%eax
  801e18:	83 e0 1f             	and    $0x1f,%eax
  801e1b:	29 d0                	sub    %edx,%eax
  801e1d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e25:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e28:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2b:	83 c6 01             	add    $0x1,%esi
  801e2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e31:	75 d8                	jne    801e0b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e33:	89 f0                	mov    %esi,%eax
  801e35:	eb 05                	jmp    801e3c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e37:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e3c:	83 c4 1c             	add    $0x1c,%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4f:	89 04 24             	mov    %eax,(%esp)
  801e52:	e8 b0 f0 ff ff       	call   800f07 <fd_alloc>
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	85 d2                	test   %edx,%edx
  801e5b:	0f 88 4d 01 00 00    	js     801fae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e61:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e68:	00 
  801e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e77:	e8 37 ed ff ff       	call   800bb3 <sys_page_alloc>
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	85 d2                	test   %edx,%edx
  801e80:	0f 88 28 01 00 00    	js     801fae <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e89:	89 04 24             	mov    %eax,(%esp)
  801e8c:	e8 76 f0 ff ff       	call   800f07 <fd_alloc>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	85 c0                	test   %eax,%eax
  801e95:	0f 88 fe 00 00 00    	js     801f99 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ea2:	00 
  801ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eaa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb1:	e8 fd ec ff ff       	call   800bb3 <sys_page_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	0f 88 d9 00 00 00    	js     801f99 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	89 04 24             	mov    %eax,(%esp)
  801ec6:	e8 25 f0 ff ff       	call   800ef0 <fd2data>
  801ecb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed4:	00 
  801ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee0:	e8 ce ec ff ff       	call   800bb3 <sys_page_alloc>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	0f 88 97 00 00 00    	js     801f86 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 f6 ef ff ff       	call   800ef0 <fd2data>
  801efa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f01:	00 
  801f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f0d:	00 
  801f0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f19:	e8 e9 ec ff ff       	call   800c07 <sys_page_map>
  801f1e:	89 c3                	mov    %eax,%ebx
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 52                	js     801f76 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f39:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f42:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f47:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 87 ef ff ff       	call   800ee0 <fd2num>
  801f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 77 ef ff ff       	call   800ee0 <fd2num>
  801f69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f74:	eb 38                	jmp    801fae <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f81:	e8 d4 ec ff ff       	call   800c5a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f94:	e8 c1 ec ff ff       	call   800c5a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa7:	e8 ae ec ff ff       	call   800c5a <sys_page_unmap>
  801fac:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801fae:	83 c4 30             	add    $0x30,%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	89 04 24             	mov    %eax,(%esp)
  801fc8:	e8 89 ef ff ff       	call   800f56 <fd_lookup>
  801fcd:	89 c2                	mov    %eax,%edx
  801fcf:	85 d2                	test   %edx,%edx
  801fd1:	78 15                	js     801fe8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 12 ef ff ff       	call   800ef0 <fd2data>
	return _pipeisclosed(fd, p);
  801fde:	89 c2                	mov    %eax,%edx
  801fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe3:	e8 0b fd ff ff       	call   801cf3 <_pipeisclosed>
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802000:	c7 44 24 04 67 2a 80 	movl   $0x802a67,0x4(%esp)
  802007:	00 
  802008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 84 e7 ff ff       	call   800797 <strcpy>
	return 0;
}
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802026:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80202b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802031:	eb 31                	jmp    802064 <devcons_write+0x4a>
		m = n - tot;
  802033:	8b 75 10             	mov    0x10(%ebp),%esi
  802036:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802038:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80203b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802040:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802043:	89 74 24 08          	mov    %esi,0x8(%esp)
  802047:	03 45 0c             	add    0xc(%ebp),%eax
  80204a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204e:	89 3c 24             	mov    %edi,(%esp)
  802051:	e8 de e8 ff ff       	call   800934 <memmove>
		sys_cputs(buf, m);
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	89 3c 24             	mov    %edi,(%esp)
  80205d:	e8 84 ea ff ff       	call   800ae6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802062:	01 f3                	add    %esi,%ebx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802069:	72 c8                	jb     802033 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80206b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80207c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802081:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802085:	75 07                	jne    80208e <devcons_read+0x18>
  802087:	eb 2a                	jmp    8020b3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802089:	e8 06 eb ff ff       	call   800b94 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80208e:	66 90                	xchg   %ax,%ax
  802090:	e8 6f ea ff ff       	call   800b04 <sys_cgetc>
  802095:	85 c0                	test   %eax,%eax
  802097:	74 f0                	je     802089 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 16                	js     8020b3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80209d:	83 f8 04             	cmp    $0x4,%eax
  8020a0:	74 0c                	je     8020ae <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8020a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a5:	88 02                	mov    %al,(%edx)
	return 1;
  8020a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ac:	eb 05                	jmp    8020b3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020c8:	00 
  8020c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cc:	89 04 24             	mov    %eax,(%esp)
  8020cf:	e8 12 ea ff ff       	call   800ae6 <sys_cputs>
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <getchar>:

int
getchar(void)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020e3:	00 
  8020e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f2:	e8 f3 f0 ff ff       	call   8011ea <read>
	if (r < 0)
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 0f                	js     80210a <getchar+0x34>
		return r;
	if (r < 1)
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	7e 06                	jle    802105 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802103:	eb 05                	jmp    80210a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802105:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	89 44 24 04          	mov    %eax,0x4(%esp)
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	89 04 24             	mov    %eax,(%esp)
  80211f:	e8 32 ee ff ff       	call   800f56 <fd_lookup>
  802124:	85 c0                	test   %eax,%eax
  802126:	78 11                	js     802139 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802131:	39 10                	cmp    %edx,(%eax)
  802133:	0f 94 c0             	sete   %al
  802136:	0f b6 c0             	movzbl %al,%eax
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    

0080213b <opencons>:

int
opencons(void)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802144:	89 04 24             	mov    %eax,(%esp)
  802147:	e8 bb ed ff ff       	call   800f07 <fd_alloc>
		return r;
  80214c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 40                	js     802192 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802159:	00 
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802168:	e8 46 ea ff ff       	call   800bb3 <sys_page_alloc>
		return r;
  80216d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 1f                	js     802192 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802173:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802188:	89 04 24             	mov    %eax,(%esp)
  80218b:	e8 50 ed ff ff       	call   800ee0 <fd2num>
  802190:	89 c2                	mov    %eax,%edx
}
  802192:	89 d0                	mov    %edx,%eax
  802194:	c9                   	leave  
  802195:	c3                   	ret    

00802196 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	56                   	push   %esi
  80219a:	53                   	push   %ebx
  80219b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80219e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021a1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021a7:	e8 c9 e9 ff ff       	call   800b75 <sys_getenvid>
  8021ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8021b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c2:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  8021c9:	e8 9b df ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 2b df ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  8021dd:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  8021e4:	e8 80 df ff ff       	call   800169 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021e9:	cc                   	int3   
  8021ea:	eb fd                	jmp    8021e9 <_panic+0x53>
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	56                   	push   %esi
  8021f4:	53                   	push   %ebx
  8021f5:	83 ec 10             	sub    $0x10,%esp
  8021f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802201:	85 c0                	test   %eax,%eax
  802203:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802208:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80220b:	89 04 24             	mov    %eax,(%esp)
  80220e:	e8 b6 eb ff ff       	call   800dc9 <sys_ipc_recv>

	if(ret < 0) {
  802213:	85 c0                	test   %eax,%eax
  802215:	79 16                	jns    80222d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802217:	85 f6                	test   %esi,%esi
  802219:	74 06                	je     802221 <ipc_recv+0x31>
  80221b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802221:	85 db                	test   %ebx,%ebx
  802223:	74 3e                	je     802263 <ipc_recv+0x73>
  802225:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80222b:	eb 36                	jmp    802263 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80222d:	e8 43 e9 ff ff       	call   800b75 <sys_getenvid>
  802232:	25 ff 03 00 00       	and    $0x3ff,%eax
  802237:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80223a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80223f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802244:	85 f6                	test   %esi,%esi
  802246:	74 05                	je     80224d <ipc_recv+0x5d>
  802248:	8b 40 74             	mov    0x74(%eax),%eax
  80224b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80224d:	85 db                	test   %ebx,%ebx
  80224f:	74 0a                	je     80225b <ipc_recv+0x6b>
  802251:	a1 08 40 80 00       	mov    0x804008,%eax
  802256:	8b 40 78             	mov    0x78(%eax),%eax
  802259:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80225b:	a1 08 40 80 00       	mov    0x804008,%eax
  802260:	8b 40 70             	mov    0x70(%eax),%eax
}
  802263:	83 c4 10             	add    $0x10,%esp
  802266:	5b                   	pop    %ebx
  802267:	5e                   	pop    %esi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	57                   	push   %edi
  80226e:	56                   	push   %esi
  80226f:	53                   	push   %ebx
  802270:	83 ec 1c             	sub    $0x1c,%esp
  802273:	8b 7d 08             	mov    0x8(%ebp),%edi
  802276:	8b 75 0c             	mov    0xc(%ebp),%esi
  802279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80227c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80227e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802283:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802286:	8b 45 14             	mov    0x14(%ebp),%eax
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802291:	89 74 24 04          	mov    %esi,0x4(%esp)
  802295:	89 3c 24             	mov    %edi,(%esp)
  802298:	e8 09 eb ff ff       	call   800da6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80229d:	85 c0                	test   %eax,%eax
  80229f:	79 2c                	jns    8022cd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8022a1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022a4:	74 20                	je     8022c6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8022a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022aa:	c7 44 24 08 98 2a 80 	movl   $0x802a98,0x8(%esp)
  8022b1:	00 
  8022b2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8022b9:	00 
  8022ba:	c7 04 24 c8 2a 80 00 	movl   $0x802ac8,(%esp)
  8022c1:	e8 d0 fe ff ff       	call   802196 <_panic>
		}
		sys_yield();
  8022c6:	e8 c9 e8 ff ff       	call   800b94 <sys_yield>
	}
  8022cb:	eb b9                	jmp    802286 <ipc_send+0x1c>
}
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022db:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022e0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022e3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022e9:	8b 52 50             	mov    0x50(%edx),%edx
  8022ec:	39 ca                	cmp    %ecx,%edx
  8022ee:	75 0d                	jne    8022fd <ipc_find_env+0x28>
			return envs[i].env_id;
  8022f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022f8:	8b 40 40             	mov    0x40(%eax),%eax
  8022fb:	eb 0e                	jmp    80230b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022fd:	83 c0 01             	add    $0x1,%eax
  802300:	3d 00 04 00 00       	cmp    $0x400,%eax
  802305:	75 d9                	jne    8022e0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802307:	66 b8 00 00          	mov    $0x0,%ax
}
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802313:	89 d0                	mov    %edx,%eax
  802315:	c1 e8 16             	shr    $0x16,%eax
  802318:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802324:	f6 c1 01             	test   $0x1,%cl
  802327:	74 1d                	je     802346 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802329:	c1 ea 0c             	shr    $0xc,%edx
  80232c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802333:	f6 c2 01             	test   $0x1,%dl
  802336:	74 0e                	je     802346 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802338:	c1 ea 0c             	shr    $0xc,%edx
  80233b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802342:	ef 
  802343:	0f b7 c0             	movzwl %ax,%eax
}
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__udivdi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	8b 44 24 28          	mov    0x28(%esp),%eax
  80235a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80235e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802362:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802366:	85 c0                	test   %eax,%eax
  802368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80236c:	89 ea                	mov    %ebp,%edx
  80236e:	89 0c 24             	mov    %ecx,(%esp)
  802371:	75 2d                	jne    8023a0 <__udivdi3+0x50>
  802373:	39 e9                	cmp    %ebp,%ecx
  802375:	77 61                	ja     8023d8 <__udivdi3+0x88>
  802377:	85 c9                	test   %ecx,%ecx
  802379:	89 ce                	mov    %ecx,%esi
  80237b:	75 0b                	jne    802388 <__udivdi3+0x38>
  80237d:	b8 01 00 00 00       	mov    $0x1,%eax
  802382:	31 d2                	xor    %edx,%edx
  802384:	f7 f1                	div    %ecx
  802386:	89 c6                	mov    %eax,%esi
  802388:	31 d2                	xor    %edx,%edx
  80238a:	89 e8                	mov    %ebp,%eax
  80238c:	f7 f6                	div    %esi
  80238e:	89 c5                	mov    %eax,%ebp
  802390:	89 f8                	mov    %edi,%eax
  802392:	f7 f6                	div    %esi
  802394:	89 ea                	mov    %ebp,%edx
  802396:	83 c4 0c             	add    $0xc,%esp
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	39 e8                	cmp    %ebp,%eax
  8023a2:	77 24                	ja     8023c8 <__udivdi3+0x78>
  8023a4:	0f bd e8             	bsr    %eax,%ebp
  8023a7:	83 f5 1f             	xor    $0x1f,%ebp
  8023aa:	75 3c                	jne    8023e8 <__udivdi3+0x98>
  8023ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023b0:	39 34 24             	cmp    %esi,(%esp)
  8023b3:	0f 86 9f 00 00 00    	jbe    802458 <__udivdi3+0x108>
  8023b9:	39 d0                	cmp    %edx,%eax
  8023bb:	0f 82 97 00 00 00    	jb     802458 <__udivdi3+0x108>
  8023c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	31 c0                	xor    %eax,%eax
  8023cc:	83 c4 0c             	add    $0xc,%esp
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
  8023d3:	90                   	nop
  8023d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	89 f8                	mov    %edi,%eax
  8023da:	f7 f1                	div    %ecx
  8023dc:	31 d2                	xor    %edx,%edx
  8023de:	83 c4 0c             	add    $0xc,%esp
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	8b 3c 24             	mov    (%esp),%edi
  8023ed:	d3 e0                	shl    %cl,%eax
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f6:	29 e8                	sub    %ebp,%eax
  8023f8:	89 c1                	mov    %eax,%ecx
  8023fa:	d3 ef                	shr    %cl,%edi
  8023fc:	89 e9                	mov    %ebp,%ecx
  8023fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802402:	8b 3c 24             	mov    (%esp),%edi
  802405:	09 74 24 08          	or     %esi,0x8(%esp)
  802409:	89 d6                	mov    %edx,%esi
  80240b:	d3 e7                	shl    %cl,%edi
  80240d:	89 c1                	mov    %eax,%ecx
  80240f:	89 3c 24             	mov    %edi,(%esp)
  802412:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802416:	d3 ee                	shr    %cl,%esi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	d3 e2                	shl    %cl,%edx
  80241c:	89 c1                	mov    %eax,%ecx
  80241e:	d3 ef                	shr    %cl,%edi
  802420:	09 d7                	or     %edx,%edi
  802422:	89 f2                	mov    %esi,%edx
  802424:	89 f8                	mov    %edi,%eax
  802426:	f7 74 24 08          	divl   0x8(%esp)
  80242a:	89 d6                	mov    %edx,%esi
  80242c:	89 c7                	mov    %eax,%edi
  80242e:	f7 24 24             	mull   (%esp)
  802431:	39 d6                	cmp    %edx,%esi
  802433:	89 14 24             	mov    %edx,(%esp)
  802436:	72 30                	jb     802468 <__udivdi3+0x118>
  802438:	8b 54 24 04          	mov    0x4(%esp),%edx
  80243c:	89 e9                	mov    %ebp,%ecx
  80243e:	d3 e2                	shl    %cl,%edx
  802440:	39 c2                	cmp    %eax,%edx
  802442:	73 05                	jae    802449 <__udivdi3+0xf9>
  802444:	3b 34 24             	cmp    (%esp),%esi
  802447:	74 1f                	je     802468 <__udivdi3+0x118>
  802449:	89 f8                	mov    %edi,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	e9 7a ff ff ff       	jmp    8023cc <__udivdi3+0x7c>
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 d2                	xor    %edx,%edx
  80245a:	b8 01 00 00 00       	mov    $0x1,%eax
  80245f:	e9 68 ff ff ff       	jmp    8023cc <__udivdi3+0x7c>
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	8d 47 ff             	lea    -0x1(%edi),%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	83 c4 0c             	add    $0xc,%esp
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    
  802474:	66 90                	xchg   %ax,%ax
  802476:	66 90                	xchg   %ax,%ax
  802478:	66 90                	xchg   %ax,%ax
  80247a:	66 90                	xchg   %ax,%ax
  80247c:	66 90                	xchg   %ax,%ax
  80247e:	66 90                	xchg   %ax,%ax

00802480 <__umoddi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	83 ec 14             	sub    $0x14,%esp
  802486:	8b 44 24 28          	mov    0x28(%esp),%eax
  80248a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80248e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802492:	89 c7                	mov    %eax,%edi
  802494:	89 44 24 04          	mov    %eax,0x4(%esp)
  802498:	8b 44 24 30          	mov    0x30(%esp),%eax
  80249c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024a0:	89 34 24             	mov    %esi,(%esp)
  8024a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	89 c2                	mov    %eax,%edx
  8024ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024af:	75 17                	jne    8024c8 <__umoddi3+0x48>
  8024b1:	39 fe                	cmp    %edi,%esi
  8024b3:	76 4b                	jbe    802500 <__umoddi3+0x80>
  8024b5:	89 c8                	mov    %ecx,%eax
  8024b7:	89 fa                	mov    %edi,%edx
  8024b9:	f7 f6                	div    %esi
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	31 d2                	xor    %edx,%edx
  8024bf:	83 c4 14             	add    $0x14,%esp
  8024c2:	5e                   	pop    %esi
  8024c3:	5f                   	pop    %edi
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	39 f8                	cmp    %edi,%eax
  8024ca:	77 54                	ja     802520 <__umoddi3+0xa0>
  8024cc:	0f bd e8             	bsr    %eax,%ebp
  8024cf:	83 f5 1f             	xor    $0x1f,%ebp
  8024d2:	75 5c                	jne    802530 <__umoddi3+0xb0>
  8024d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024d8:	39 3c 24             	cmp    %edi,(%esp)
  8024db:	0f 87 e7 00 00 00    	ja     8025c8 <__umoddi3+0x148>
  8024e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024e5:	29 f1                	sub    %esi,%ecx
  8024e7:	19 c7                	sbb    %eax,%edi
  8024e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024f9:	83 c4 14             	add    $0x14,%esp
  8024fc:	5e                   	pop    %esi
  8024fd:	5f                   	pop    %edi
  8024fe:	5d                   	pop    %ebp
  8024ff:	c3                   	ret    
  802500:	85 f6                	test   %esi,%esi
  802502:	89 f5                	mov    %esi,%ebp
  802504:	75 0b                	jne    802511 <__umoddi3+0x91>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f6                	div    %esi
  80250f:	89 c5                	mov    %eax,%ebp
  802511:	8b 44 24 04          	mov    0x4(%esp),%eax
  802515:	31 d2                	xor    %edx,%edx
  802517:	f7 f5                	div    %ebp
  802519:	89 c8                	mov    %ecx,%eax
  80251b:	f7 f5                	div    %ebp
  80251d:	eb 9c                	jmp    8024bb <__umoddi3+0x3b>
  80251f:	90                   	nop
  802520:	89 c8                	mov    %ecx,%eax
  802522:	89 fa                	mov    %edi,%edx
  802524:	83 c4 14             	add    $0x14,%esp
  802527:	5e                   	pop    %esi
  802528:	5f                   	pop    %edi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    
  80252b:	90                   	nop
  80252c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802530:	8b 04 24             	mov    (%esp),%eax
  802533:	be 20 00 00 00       	mov    $0x20,%esi
  802538:	89 e9                	mov    %ebp,%ecx
  80253a:	29 ee                	sub    %ebp,%esi
  80253c:	d3 e2                	shl    %cl,%edx
  80253e:	89 f1                	mov    %esi,%ecx
  802540:	d3 e8                	shr    %cl,%eax
  802542:	89 e9                	mov    %ebp,%ecx
  802544:	89 44 24 04          	mov    %eax,0x4(%esp)
  802548:	8b 04 24             	mov    (%esp),%eax
  80254b:	09 54 24 04          	or     %edx,0x4(%esp)
  80254f:	89 fa                	mov    %edi,%edx
  802551:	d3 e0                	shl    %cl,%eax
  802553:	89 f1                	mov    %esi,%ecx
  802555:	89 44 24 08          	mov    %eax,0x8(%esp)
  802559:	8b 44 24 10          	mov    0x10(%esp),%eax
  80255d:	d3 ea                	shr    %cl,%edx
  80255f:	89 e9                	mov    %ebp,%ecx
  802561:	d3 e7                	shl    %cl,%edi
  802563:	89 f1                	mov    %esi,%ecx
  802565:	d3 e8                	shr    %cl,%eax
  802567:	89 e9                	mov    %ebp,%ecx
  802569:	09 f8                	or     %edi,%eax
  80256b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80256f:	f7 74 24 04          	divl   0x4(%esp)
  802573:	d3 e7                	shl    %cl,%edi
  802575:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802579:	89 d7                	mov    %edx,%edi
  80257b:	f7 64 24 08          	mull   0x8(%esp)
  80257f:	39 d7                	cmp    %edx,%edi
  802581:	89 c1                	mov    %eax,%ecx
  802583:	89 14 24             	mov    %edx,(%esp)
  802586:	72 2c                	jb     8025b4 <__umoddi3+0x134>
  802588:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80258c:	72 22                	jb     8025b0 <__umoddi3+0x130>
  80258e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802592:	29 c8                	sub    %ecx,%eax
  802594:	19 d7                	sbb    %edx,%edi
  802596:	89 e9                	mov    %ebp,%ecx
  802598:	89 fa                	mov    %edi,%edx
  80259a:	d3 e8                	shr    %cl,%eax
  80259c:	89 f1                	mov    %esi,%ecx
  80259e:	d3 e2                	shl    %cl,%edx
  8025a0:	89 e9                	mov    %ebp,%ecx
  8025a2:	d3 ef                	shr    %cl,%edi
  8025a4:	09 d0                	or     %edx,%eax
  8025a6:	89 fa                	mov    %edi,%edx
  8025a8:	83 c4 14             	add    $0x14,%esp
  8025ab:	5e                   	pop    %esi
  8025ac:	5f                   	pop    %edi
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
  8025af:	90                   	nop
  8025b0:	39 d7                	cmp    %edx,%edi
  8025b2:	75 da                	jne    80258e <__umoddi3+0x10e>
  8025b4:	8b 14 24             	mov    (%esp),%edx
  8025b7:	89 c1                	mov    %eax,%ecx
  8025b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025c1:	eb cb                	jmp    80258e <__umoddi3+0x10e>
  8025c3:	90                   	nop
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025cc:	0f 82 0f ff ff ff    	jb     8024e1 <__umoddi3+0x61>
  8025d2:	e9 1a ff ff ff       	jmp    8024f1 <__umoddi3+0x71>
