
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 01 01 00 00       	call   800132 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800040:	e8 f1 01 00 00       	call   800236 <cprintf>
	exit();
  800045:	e8 30 01 00 00       	call   80017a <exit>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <umain>:

void
umain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	57                   	push   %edi
  800050:	56                   	push   %esi
  800051:	53                   	push   %ebx
  800052:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800058:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800062:	8b 45 0c             	mov    0xc(%ebp),%eax
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	8d 45 08             	lea    0x8(%ebp),%eax
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 2c 0f 00 00       	call   800fa0 <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800074:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800079:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007f:	eb 11                	jmp    800092 <umain+0x46>
		if (i == '1')
  800081:	83 f8 31             	cmp    $0x31,%eax
  800084:	75 07                	jne    80008d <umain+0x41>
			usefprint = 1;
  800086:	be 01 00 00 00       	mov    $0x1,%esi
  80008b:	eb 05                	jmp    800092 <umain+0x46>
		else
			usage();
  80008d:	e8 a1 ff ff ff       	call   800033 <usage>
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800092:	89 1c 24             	mov    %ebx,(%esp)
  800095:	e8 3e 0f 00 00       	call   800fd8 <argnext>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 e3                	jns    800081 <umain+0x35>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a3:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000ad:	89 1c 24             	mov    %ebx,(%esp)
  8000b0:	e8 71 15 00 00       	call   801626 <fstat>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 66                	js     80011f <umain+0xd3>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 36                	je     8000f3 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000ca:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000dd:	c7 44 24 04 54 29 80 	movl   $0x802954,0x4(%esp)
  8000e4:	00 
  8000e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ec:	e8 81 19 00 00       	call   801a72 <fprintf>
  8000f1:	eb 2c                	jmp    80011f <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000f6:	8b 40 04             	mov    0x4(%eax),%eax
  8000f9:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800100:	89 44 24 10          	mov    %eax,0x10(%esp)
  800104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800107:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010b:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80010f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800113:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  80011a:	e8 17 01 00 00       	call   800236 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  80011f:	83 c3 01             	add    $0x1,%ebx
  800122:	83 fb 20             	cmp    $0x20,%ebx
  800125:	75 82                	jne    8000a9 <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800127:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
  800137:	83 ec 10             	sub    $0x10,%esp
  80013a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800140:	e8 f0 0a 00 00       	call   800c35 <sys_getenvid>
  800145:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800152:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800157:	85 db                	test   %ebx,%ebx
  800159:	7e 07                	jle    800162 <libmain+0x30>
		binaryname = argv[0];
  80015b:	8b 06                	mov    (%esi),%eax
  80015d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800162:	89 74 24 04          	mov    %esi,0x4(%esp)
  800166:	89 1c 24             	mov    %ebx,(%esp)
  800169:	e8 de fe ff ff       	call   80004c <umain>

	// exit gracefully
	exit();
  80016e:	e8 07 00 00 00       	call   80017a <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800180:	e8 55 11 00 00       	call   8012da <close_all>
	sys_env_destroy(0);
  800185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018c:	e8 52 0a 00 00       	call   800be3 <sys_env_destroy>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 14             	sub    $0x14,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 19                	jne    8001cb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b9:	00 
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 e1 09 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cf:	83 c4 14             	add    $0x14,%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020a:	c7 04 24 93 01 80 00 	movl   $0x800193,(%esp)
  800211:	e8 a8 01 00 00       	call   8003be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 78 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 87 ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c3                	mov    %eax,%ebx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	39 d9                	cmp    %ebx,%ecx
  80027f:	72 05                	jb     800286 <printnum+0x36>
  800281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800284:	77 69                	ja     8002ef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028d:	83 ee 01             	sub    $0x1,%esi
  800290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 ec 23 00 00       	call   8026b0 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 71 ff ff ff       	call   800250 <printnum>
  8002df:	eb 1b                	jmp    8002fc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa2>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	83 ee 01             	sub    $0x1,%esi
  8002f5:	85 f6                	test   %esi,%esi
  8002f7:	7f e8                	jg     8002e1 <printnum+0x91>
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 bc 24 00 00       	call   8027e0 <__umoddi3>
  800324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800328:	0f be 80 86 29 80 00 	movsbl 0x802986(%eax),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800335:	ff d0                	call   *%eax
}
  800337:	83 c4 3c             	add    $0x3c,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800342:	83 fa 01             	cmp    $0x1,%edx
  800345:	7e 0e                	jle    800355 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800347:	8b 10                	mov    (%eax),%edx
  800349:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034c:	89 08                	mov    %ecx,(%eax)
  80034e:	8b 02                	mov    (%edx),%eax
  800350:	8b 52 04             	mov    0x4(%edx),%edx
  800353:	eb 22                	jmp    800377 <getuint+0x38>
	else if (lflag)
  800355:	85 d2                	test   %edx,%edx
  800357:	74 10                	je     800369 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
  800367:	eb 0e                	jmp    800377 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800383:	8b 10                	mov    (%eax),%edx
  800385:	3b 50 04             	cmp    0x4(%eax),%edx
  800388:	73 0a                	jae    800394 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	88 02                	mov    %al,(%edx)
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 02 00 00 00       	call   8003be <vprintfmt>
	va_end(ap);
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 3c             	sub    $0x3c,%esp
  8003c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003cd:	eb 14                	jmp    8003e3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 b3 03 00 00    	je     80078a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8003d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	89 f3                	mov    %esi,%ebx
  8003e3:	8d 73 01             	lea    0x1(%ebx),%esi
  8003e6:	0f b6 03             	movzbl (%ebx),%eax
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e1                	jne    8003cf <vprintfmt+0x11>
  8003ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800400:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
  80040c:	eb 1d                	jmp    80042b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800414:	eb 15                	jmp    80042b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 0d                	jmp    80042b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800421:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800424:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80042e:	0f b6 0e             	movzbl (%esi),%ecx
  800431:	0f b6 c1             	movzbl %cl,%eax
  800434:	83 e9 23             	sub    $0x23,%ecx
  800437:	80 f9 55             	cmp    $0x55,%cl
  80043a:	0f 87 2a 03 00 00    	ja     80076a <vprintfmt+0x3ac>
  800440:	0f b6 c9             	movzbl %cl,%ecx
  800443:	ff 24 8d c0 2a 80 00 	jmp    *0x802ac0(,%ecx,4)
  80044a:	89 de                	mov    %ebx,%esi
  80044c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800454:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800458:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80045b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80045e:	83 fb 09             	cmp    $0x9,%ebx
  800461:	77 36                	ja     800499 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800478:	eb 22                	jmp    80049c <vprintfmt+0xde>
  80047a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80047d:	85 c9                	test   %ecx,%ecx
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	0f 49 c1             	cmovns %ecx,%eax
  800487:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	89 de                	mov    %ebx,%esi
  80048c:	eb 9d                	jmp    80042b <vprintfmt+0x6d>
  80048e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800490:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800497:	eb 92                	jmp    80042b <vprintfmt+0x6d>
  800499:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80049c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004a0:	79 89                	jns    80042b <vprintfmt+0x6d>
  8004a2:	e9 77 ff ff ff       	jmp    80041e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ac:	e9 7a ff ff ff       	jmp    80042b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c6:	e9 18 ff ff ff       	jmp    8003e3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 00                	mov    (%eax),%eax
  8004d6:	99                   	cltd   
  8004d7:	31 d0                	xor    %edx,%eax
  8004d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004db:	83 f8 0f             	cmp    $0xf,%eax
  8004de:	7f 0b                	jg     8004eb <vprintfmt+0x12d>
  8004e0:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	75 20                	jne    80050b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8004eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ef:	c7 44 24 08 9e 29 80 	movl   $0x80299e,0x8(%esp)
  8004f6:	00 
  8004f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	89 04 24             	mov    %eax,(%esp)
  800501:	e8 90 fe ff ff       	call   800396 <printfmt>
  800506:	e9 d8 fe ff ff       	jmp    8003e3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80050b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050f:	c7 44 24 08 55 2d 80 	movl   $0x802d55,0x8(%esp)
  800516:	00 
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 70 fe ff ff       	call   800396 <printfmt>
  800526:	e9 b8 fe ff ff       	jmp    8003e3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80052e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800531:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80053f:	85 f6                	test   %esi,%esi
  800541:	b8 97 29 80 00       	mov    $0x802997,%eax
  800546:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80054d:	0f 84 97 00 00 00    	je     8005ea <vprintfmt+0x22c>
  800553:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800557:	0f 8e 9b 00 00 00    	jle    8005f8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	e8 cf 02 00 00       	call   800838 <strnlen>
  800569:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056c:	29 c2                	sub    %eax,%edx
  80056e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800571:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800575:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800578:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800581:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0f                	jmp    800594 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800589:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ed                	jg     800585 <vprintfmt+0x1c7>
  800598:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	0f 49 c2             	cmovns %edx,%eax
  8005a8:	29 c2                	sub    %eax,%edx
  8005aa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ad:	89 d7                	mov    %edx,%edi
  8005af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005b2:	eb 50                	jmp    800604 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b8:	74 1e                	je     8005d8 <vprintfmt+0x21a>
  8005ba:	0f be d2             	movsbl %dl,%edx
  8005bd:	83 ea 20             	sub    $0x20,%edx
  8005c0:	83 fa 5e             	cmp    $0x5e,%edx
  8005c3:	76 13                	jbe    8005d8 <vprintfmt+0x21a>
					putch('?', putdat);
  8005c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	eb 0d                	jmp    8005e5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e5:	83 ef 01             	sub    $0x1,%edi
  8005e8:	eb 1a                	jmp    800604 <vprintfmt+0x246>
  8005ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ed:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005f0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005f6:	eb 0c                	jmp    800604 <vprintfmt+0x246>
  8005f8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005fb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800601:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800604:	83 c6 01             	add    $0x1,%esi
  800607:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80060b:	0f be c2             	movsbl %dl,%eax
  80060e:	85 c0                	test   %eax,%eax
  800610:	74 27                	je     800639 <vprintfmt+0x27b>
  800612:	85 db                	test   %ebx,%ebx
  800614:	78 9e                	js     8005b4 <vprintfmt+0x1f6>
  800616:	83 eb 01             	sub    $0x1,%ebx
  800619:	79 99                	jns    8005b4 <vprintfmt+0x1f6>
  80061b:	89 f8                	mov    %edi,%eax
  80061d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800620:	8b 75 08             	mov    0x8(%ebp),%esi
  800623:	89 c3                	mov    %eax,%ebx
  800625:	eb 1a                	jmp    800641 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800632:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800634:	83 eb 01             	sub    $0x1,%ebx
  800637:	eb 08                	jmp    800641 <vprintfmt+0x283>
  800639:	89 fb                	mov    %edi,%ebx
  80063b:	8b 75 08             	mov    0x8(%ebp),%esi
  80063e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800641:	85 db                	test   %ebx,%ebx
  800643:	7f e2                	jg     800627 <vprintfmt+0x269>
  800645:	89 75 08             	mov    %esi,0x8(%ebp)
  800648:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80064b:	e9 93 fd ff ff       	jmp    8003e3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800650:	83 fa 01             	cmp    $0x1,%edx
  800653:	7e 16                	jle    80066b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 08             	lea    0x8(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 50 04             	mov    0x4(%eax),%edx
  800661:	8b 00                	mov    (%eax),%eax
  800663:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800666:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800669:	eb 32                	jmp    80069d <vprintfmt+0x2df>
	else if (lflag)
  80066b:	85 d2                	test   %edx,%edx
  80066d:	74 18                	je     800687 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 30                	mov    (%eax),%esi
  80067a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80067d:	89 f0                	mov    %esi,%eax
  80067f:	c1 f8 1f             	sar    $0x1f,%eax
  800682:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800685:	eb 16                	jmp    80069d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 30                	mov    (%eax),%esi
  800692:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800695:	89 f0                	mov    %esi,%eax
  800697:	c1 f8 1f             	sar    $0x1f,%eax
  80069a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ac:	0f 89 80 00 00 00    	jns    800732 <vprintfmt+0x374>
				putch('-', putdat);
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c6:	f7 d8                	neg    %eax
  8006c8:	83 d2 00             	adc    $0x0,%edx
  8006cb:	f7 da                	neg    %edx
			}
			base = 10;
  8006cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006d2:	eb 5e                	jmp    800732 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d7:	e8 63 fc ff ff       	call   80033f <getuint>
			base = 10;
  8006dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006e1:	eb 4f                	jmp    800732 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 54 fc ff ff       	call   80033f <getuint>
			base = 8;
  8006eb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006f0:	eb 40                	jmp    800732 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800704:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800717:	8b 00                	mov    (%eax),%eax
  800719:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80071e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800723:	eb 0d                	jmp    800732 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
  800728:	e8 12 fc ff ff       	call   80033f <getuint>
			base = 16;
  80072d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800732:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800736:	89 74 24 10          	mov    %esi,0x10(%esp)
  80073a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80073d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800741:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074c:	89 fa                	mov    %edi,%edx
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	e8 fa fa ff ff       	call   800250 <printnum>
			break;
  800756:	e9 88 fc ff ff       	jmp    8003e3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
			break;
  800765:	e9 79 fc ff ff       	jmp    8003e3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800778:	89 f3                	mov    %esi,%ebx
  80077a:	eb 03                	jmp    80077f <vprintfmt+0x3c1>
  80077c:	83 eb 01             	sub    $0x1,%ebx
  80077f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800783:	75 f7                	jne    80077c <vprintfmt+0x3be>
  800785:	e9 59 fc ff ff       	jmp    8003e3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80078a:	83 c4 3c             	add    $0x3c,%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 28             	sub    $0x28,%esp
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	74 30                	je     8007e3 <vsnprintf+0x51>
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	7e 2c                	jle    8007e3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	c7 04 24 79 03 80 00 	movl   $0x800379,(%esp)
  8007d3:	e8 e6 fb ff ff       	call   8003be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e1:	eb 05                	jmp    8007e8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	89 04 24             	mov    %eax,(%esp)
  80080b:	e8 82 ff ff ff       	call   800792 <vsnprintf>
	va_end(ap);

	return rc;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    
  800812:	66 90                	xchg   %ax,%ax
  800814:	66 90                	xchg   %ax,%ax
  800816:	66 90                	xchg   %ax,%ax
  800818:	66 90                	xchg   %ax,%ax
  80081a:	66 90                	xchg   %ax,%ax
  80081c:	66 90                	xchg   %ax,%ax
  80081e:	66 90                	xchg   %ax,%ax

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	74 06                	je     800855 <strnlen+0x1d>
  80084f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
		n++;
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800861:	89 c2                	mov    %eax,%edx
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800870:	84 db                	test   %bl,%bl
  800872:	75 ef                	jne    800863 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	89 1c 24             	mov    %ebx,(%esp)
  800884:	e8 97 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800890:	01 d8                	add    %ebx,%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 bd ff ff ff       	call   800857 <strcpy>
	return dst;
}
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ad:	89 f3                	mov    %esi,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b2:	89 f2                	mov    %esi,%edx
  8008b4:	eb 0f                	jmp    8008c5 <strncpy+0x23>
		*dst++ = *src;
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	0f b6 01             	movzbl (%ecx),%eax
  8008bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	39 da                	cmp    %ebx,%edx
  8008c7:	75 ed                	jne    8008b6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c9:	89 f0                	mov    %esi,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008dd:	89 f0                	mov    %esi,%eax
  8008df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	75 0b                	jne    8008f2 <strlcpy+0x23>
  8008e7:	eb 1d                	jmp    800906 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 0b                	je     800901 <strlcpy+0x32>
  8008f6:	0f b6 0a             	movzbl (%edx),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	75 ec                	jne    8008e9 <strlcpy+0x1a>
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	eb 02                	jmp    800903 <strlcpy+0x34>
  800901:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800903:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800906:	29 f0                	sub    %esi,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800915:	eb 06                	jmp    80091d <strcmp+0x11>
		p++, q++;
  800917:	83 c1 01             	add    $0x1,%ecx
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	84 c0                	test   %al,%al
  800922:	74 04                	je     800928 <strcmp+0x1c>
  800924:	3a 02                	cmp    (%edx),%al
  800926:	74 ef                	je     800917 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800941:	eb 06                	jmp    800949 <strncmp+0x17>
		n--, p++, q++;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800949:	39 d8                	cmp    %ebx,%eax
  80094b:	74 15                	je     800962 <strncmp+0x30>
  80094d:	0f b6 08             	movzbl (%eax),%ecx
  800950:	84 c9                	test   %cl,%cl
  800952:	74 04                	je     800958 <strncmp+0x26>
  800954:	3a 0a                	cmp    (%edx),%cl
  800956:	74 eb                	je     800943 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
  800960:	eb 05                	jmp    800967 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	eb 07                	jmp    80097d <strchr+0x13>
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 0f                	je     800989 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 f2                	jne    800976 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	eb 07                	jmp    80099e <strfind+0x13>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 0a                	je     8009a5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f2                	jne    800997 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	74 36                	je     8009ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bd:	75 28                	jne    8009e7 <memset+0x40>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 23                	jne    8009e7 <memset+0x40>
		c &= 0xFF;
  8009c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d6                	mov    %edx,%esi
  8009cf:	c1 e6 18             	shl    $0x18,%esi
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	c1 e0 10             	shl    $0x10,%eax
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009df:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e2:	fc                   	cld    
  8009e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e5:	eb 06                	jmp    8009ed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 35                	jae    800a3b <memmove+0x47>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	73 2e                	jae    800a3b <memmove+0x47>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a10:	89 d6                	mov    %edx,%esi
  800a12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1a:	75 13                	jne    800a2f <memmove+0x3b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 09                	jmp    800a38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	83 ef 01             	sub    $0x1,%edi
  800a32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a35:	fd                   	std    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a38:	fc                   	cld    
  800a39:	eb 1d                	jmp    800a58 <memmove+0x64>
  800a3b:	89 f2                	mov    %esi,%edx
  800a3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	f6 c2 03             	test   $0x3,%dl
  800a42:	75 0f                	jne    800a53 <memmove+0x5f>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0a                	jne    800a53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4c:	89 c7                	mov    %eax,%edi
  800a4e:	fc                   	cld    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 05                	jmp    800a58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	fc                   	cld    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 79 ff ff ff       	call   8009f4 <memmove>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8d:	eb 1a                	jmp    800aa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8f:	0f b6 02             	movzbl (%edx),%eax
  800a92:	0f b6 19             	movzbl (%ecx),%ebx
  800a95:	38 d8                	cmp    %bl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 db             	movzbl %bl,%ebx
  800a9f:	29 d8                	sub    %ebx,%eax
  800aa1:	eb 0f                	jmp    800ab2 <memcmp+0x35>
		s1++, s2++;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa9:	39 f2                	cmp    %esi,%edx
  800aab:	75 e2                	jne    800a8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac4:	eb 07                	jmp    800acd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac6:	38 08                	cmp    %cl,(%eax)
  800ac8:	74 07                	je     800ad1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	39 d0                	cmp    %edx,%eax
  800acf:	72 f5                	jb     800ac6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	eb 03                	jmp    800ae4 <strtol+0x11>
		s++;
  800ae1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae4:	0f b6 0a             	movzbl (%edx),%ecx
  800ae7:	80 f9 09             	cmp    $0x9,%cl
  800aea:	74 f5                	je     800ae1 <strtol+0xe>
  800aec:	80 f9 20             	cmp    $0x20,%cl
  800aef:	74 f0                	je     800ae1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af1:	80 f9 2b             	cmp    $0x2b,%cl
  800af4:	75 0a                	jne    800b00 <strtol+0x2d>
		s++;
  800af6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
  800afe:	eb 11                	jmp    800b11 <strtol+0x3e>
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b05:	80 f9 2d             	cmp    $0x2d,%cl
  800b08:	75 07                	jne    800b11 <strtol+0x3e>
		s++, neg = 1;
  800b0a:	8d 52 01             	lea    0x1(%edx),%edx
  800b0d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b16:	75 15                	jne    800b2d <strtol+0x5a>
  800b18:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1b:	75 10                	jne    800b2d <strtol+0x5a>
  800b1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b21:	75 0a                	jne    800b2d <strtol+0x5a>
		s += 2, base = 16;
  800b23:	83 c2 02             	add    $0x2,%edx
  800b26:	b8 10 00 00 00       	mov    $0x10,%eax
  800b2b:	eb 10                	jmp    800b3d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	75 0c                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b31:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	80 3a 30             	cmpb   $0x30,(%edx)
  800b36:	75 05                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
  800b38:	83 c2 01             	add    $0x1,%edx
  800b3b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b42:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b45:	0f b6 0a             	movzbl (%edx),%ecx
  800b48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b4b:	89 f0                	mov    %esi,%eax
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	77 08                	ja     800b59 <strtol+0x86>
			dig = *s - '0';
  800b51:	0f be c9             	movsbl %cl,%ecx
  800b54:	83 e9 30             	sub    $0x30,%ecx
  800b57:	eb 20                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b5c:	89 f0                	mov    %esi,%eax
  800b5e:	3c 19                	cmp    $0x19,%al
  800b60:	77 08                	ja     800b6a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 57             	sub    $0x57,%ecx
  800b68:	eb 0f                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	3c 19                	cmp    $0x19,%al
  800b71:	77 16                	ja     800b89 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b7c:	7d 0f                	jge    800b8d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b85:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b87:	eb bc                	jmp    800b45 <strtol+0x72>
  800b89:	89 d8                	mov    %ebx,%eax
  800b8b:	eb 02                	jmp    800b8f <strtol+0xbc>
  800b8d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b93:	74 05                	je     800b9a <strtol+0xc7>
		*endptr = (char *) s;
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b9a:	f7 d8                	neg    %eax
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	0f 44 c3             	cmove  %ebx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 c6                	mov    %eax,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 cb                	mov    %ecx,%ebx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	89 ce                	mov    %ecx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800c28:	e8 c9 18 00 00       	call   8024f6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_yield>:

void
sys_yield(void)
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
  800c5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 04 00 00 00       	mov    $0x4,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	89 f7                	mov    %esi,%edi
  800c91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800cba:	e8 37 18 00 00       	call   8024f6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbf:	83 c4 2c             	add    $0x2c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800d0d:	e8 e4 17 00 00       	call   8024f6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800d60:	e8 91 17 00 00       	call   8024f6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800db3:	e8 3e 17 00 00       	call   8024f6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800e06:	e8 eb 16 00 00       	call   8024f6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0b:	83 c4 2c             	add    $0x2c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800e59:	e8 98 16 00 00       	call   8024f6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5e:	83 c4 2c             	add    $0x2c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 cb                	mov    %ecx,%ebx
  800ea1:	89 cf                	mov    %ecx,%edi
  800ea3:	89 ce                	mov    %ecx,%esi
  800ea5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	7e 28                	jle    800ed3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec6:	00 
  800ec7:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800ece:	e8 23 16 00 00       	call   8024f6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed3:	83 c4 2c             	add    $0x2c,%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eeb:	89 d1                	mov    %edx,%ecx
  800eed:	89 d3                	mov    %edx,%ebx
  800eef:	89 d7                	mov    %edx,%edi
  800ef1:	89 d6                	mov    %edx,%esi
  800ef3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f08:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	89 df                	mov    %ebx,%edi
  800f15:	89 de                	mov    %ebx,%esi
  800f17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 28                	jle    800f45 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f21:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f28:	00 
  800f29:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800f30:	00 
  800f31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f38:	00 
  800f39:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800f40:	e8 b1 15 00 00       	call   8024f6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f45:	83 c4 2c             	add    $0x2c,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	89 df                	mov    %ebx,%edi
  800f68:	89 de                	mov    %ebx,%esi
  800f6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	7e 28                	jle    800f98 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f74:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800f83:	00 
  800f84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8b:	00 
  800f8c:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800f93:	e8 5e 15 00 00       	call   8024f6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800f98:	83 c4 2c             	add    $0x2c,%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800faa:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fad:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  800faf:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	83 39 01             	cmpl   $0x1,(%ecx)
  800fba:	7e 0f                	jle    800fcb <argstart+0x2b>
  800fbc:	85 d2                	test   %edx,%edx
  800fbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc3:	bb 51 29 80 00       	mov    $0x802951,%ebx
  800fc8:	0f 44 da             	cmove  %edx,%ebx
  800fcb:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  800fce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fd5:	5b                   	pop    %ebx
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <argnext>:

int
argnext(struct Argstate *args)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 14             	sub    $0x14,%esp
  800fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fe2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fe9:	8b 43 08             	mov    0x8(%ebx),%eax
  800fec:	85 c0                	test   %eax,%eax
  800fee:	74 71                	je     801061 <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  800ff0:	80 38 00             	cmpb   $0x0,(%eax)
  800ff3:	75 50                	jne    801045 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ff5:	8b 0b                	mov    (%ebx),%ecx
  800ff7:	83 39 01             	cmpl   $0x1,(%ecx)
  800ffa:	74 57                	je     801053 <argnext+0x7b>
		    || args->argv[1][0] != '-'
  800ffc:	8b 53 04             	mov    0x4(%ebx),%edx
  800fff:	8b 42 04             	mov    0x4(%edx),%eax
  801002:	80 38 2d             	cmpb   $0x2d,(%eax)
  801005:	75 4c                	jne    801053 <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801007:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80100b:	74 46                	je     801053 <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80100d:	83 c0 01             	add    $0x1,%eax
  801010:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801013:	8b 01                	mov    (%ecx),%eax
  801015:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80101c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801020:	8d 42 08             	lea    0x8(%edx),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	83 c2 04             	add    $0x4,%edx
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	e8 c2 f9 ff ff       	call   8009f4 <memmove>
		(*args->argc)--;
  801032:	8b 03                	mov    (%ebx),%eax
  801034:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801037:	8b 43 08             	mov    0x8(%ebx),%eax
  80103a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80103d:	75 06                	jne    801045 <argnext+0x6d>
  80103f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801043:	74 0e                	je     801053 <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801045:	8b 53 08             	mov    0x8(%ebx),%edx
  801048:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80104b:	83 c2 01             	add    $0x1,%edx
  80104e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801051:	eb 13                	jmp    801066 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  801053:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80105a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80105f:	eb 05                	jmp    801066 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801066:	83 c4 14             	add    $0x14,%esp
  801069:	5b                   	pop    %ebx
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	53                   	push   %ebx
  801070:	83 ec 14             	sub    $0x14,%esp
  801073:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801076:	8b 43 08             	mov    0x8(%ebx),%eax
  801079:	85 c0                	test   %eax,%eax
  80107b:	74 5a                	je     8010d7 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  80107d:	80 38 00             	cmpb   $0x0,(%eax)
  801080:	74 0c                	je     80108e <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801082:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801085:	c7 43 08 51 29 80 00 	movl   $0x802951,0x8(%ebx)
  80108c:	eb 44                	jmp    8010d2 <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  80108e:	8b 03                	mov    (%ebx),%eax
  801090:	83 38 01             	cmpl   $0x1,(%eax)
  801093:	7e 2f                	jle    8010c4 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801095:	8b 53 04             	mov    0x4(%ebx),%edx
  801098:	8b 4a 04             	mov    0x4(%edx),%ecx
  80109b:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80109e:	8b 00                	mov    (%eax),%eax
  8010a0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ab:	8d 42 08             	lea    0x8(%edx),%eax
  8010ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b2:	83 c2 04             	add    $0x4,%edx
  8010b5:	89 14 24             	mov    %edx,(%esp)
  8010b8:	e8 37 f9 ff ff       	call   8009f4 <memmove>
		(*args->argc)--;
  8010bd:	8b 03                	mov    (%ebx),%eax
  8010bf:	83 28 01             	subl   $0x1,(%eax)
  8010c2:	eb 0e                	jmp    8010d2 <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  8010c4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010cb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010d2:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010d5:	eb 05                	jmp    8010dc <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010d7:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010dc:	83 c4 14             	add    $0x14,%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 18             	sub    $0x18,%esp
  8010e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010eb:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010ee:	89 d0                	mov    %edx,%eax
  8010f0:	85 d2                	test   %edx,%edx
  8010f2:	75 08                	jne    8010fc <argvalue+0x1a>
  8010f4:	89 0c 24             	mov    %ecx,(%esp)
  8010f7:	e8 70 ff ff ff       	call   80106c <argnextvalue>
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    
  8010fe:	66 90                	xchg   %ax,%ax

00801100 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	05 00 00 00 30       	add    $0x30000000,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80111b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801120:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 16             	shr    $0x16,%edx
  801137:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 11                	je     801154 <fd_alloc+0x2d>
  801143:	89 c2                	mov    %eax,%edx
  801145:	c1 ea 0c             	shr    $0xc,%edx
  801148:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114f:	f6 c2 01             	test   $0x1,%dl
  801152:	75 09                	jne    80115d <fd_alloc+0x36>
			*fd_store = fd;
  801154:	89 01                	mov    %eax,(%ecx)
			return 0;
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
  80115b:	eb 17                	jmp    801174 <fd_alloc+0x4d>
  80115d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801162:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801167:	75 c9                	jne    801132 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801169:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117c:	83 f8 1f             	cmp    $0x1f,%eax
  80117f:	77 36                	ja     8011b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801181:	c1 e0 0c             	shl    $0xc,%eax
  801184:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801189:	89 c2                	mov    %eax,%edx
  80118b:	c1 ea 16             	shr    $0x16,%edx
  80118e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	74 24                	je     8011be <fd_lookup+0x48>
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	c1 ea 0c             	shr    $0xc,%edx
  80119f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a6:	f6 c2 01             	test   $0x1,%dl
  8011a9:	74 1a                	je     8011c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b5:	eb 13                	jmp    8011ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bc:	eb 0c                	jmp    8011ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c3:	eb 05                	jmp    8011ca <fd_lookup+0x54>
  8011c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 18             	sub    $0x18,%esp
  8011d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011da:	eb 13                	jmp    8011ef <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8011dc:	39 08                	cmp    %ecx,(%eax)
  8011de:	75 0c                	jne    8011ec <dev_lookup+0x20>
			*dev = devtab[i];
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 38                	jmp    801224 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ec:	83 c2 01             	add    $0x1,%edx
  8011ef:	8b 04 95 28 2d 80 00 	mov    0x802d28(,%edx,4),%eax
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	75 e2                	jne    8011dc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ff:	8b 40 48             	mov    0x48(%eax),%eax
  801202:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120a:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  801211:	e8 20 f0 ff ff       	call   800236 <cprintf>
	*dev = 0;
  801216:	8b 45 0c             	mov    0xc(%ebp),%eax
  801219:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	83 ec 20             	sub    $0x20,%esp
  80122e:	8b 75 08             	mov    0x8(%ebp),%esi
  801231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801241:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801244:	89 04 24             	mov    %eax,(%esp)
  801247:	e8 2a ff ff ff       	call   801176 <fd_lookup>
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 05                	js     801255 <fd_close+0x2f>
	    || fd != fd2)
  801250:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801253:	74 0c                	je     801261 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801255:	84 db                	test   %bl,%bl
  801257:	ba 00 00 00 00       	mov    $0x0,%edx
  80125c:	0f 44 c2             	cmove  %edx,%eax
  80125f:	eb 3f                	jmp    8012a0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	89 44 24 04          	mov    %eax,0x4(%esp)
  801268:	8b 06                	mov    (%esi),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 5a ff ff ff       	call   8011cc <dev_lookup>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	85 c0                	test   %eax,%eax
  801276:	78 16                	js     80128e <fd_close+0x68>
		if (dev->dev_close)
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801283:	85 c0                	test   %eax,%eax
  801285:	74 07                	je     80128e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801287:	89 34 24             	mov    %esi,(%esp)
  80128a:	ff d0                	call   *%eax
  80128c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80128e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801299:	e8 7c fa ff ff       	call   800d1a <sys_page_unmap>
	return r;
  80129e:	89 d8                	mov    %ebx,%eax
}
  8012a0:	83 c4 20             	add    $0x20,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 b7 fe ff ff       	call   801176 <fd_lookup>
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	85 d2                	test   %edx,%edx
  8012c3:	78 13                	js     8012d8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8012c5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012cc:	00 
  8012cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 4e ff ff ff       	call   801226 <fd_close>
}
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <close_all>:

void
close_all(void)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 b9 ff ff ff       	call   8012a7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ee:	83 c3 01             	add    $0x1,%ebx
  8012f1:	83 fb 20             	cmp    $0x20,%ebx
  8012f4:	75 f0                	jne    8012e6 <close_all+0xc>
		close(i);
}
  8012f6:	83 c4 14             	add    $0x14,%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	57                   	push   %edi
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
  801302:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	8b 45 08             	mov    0x8(%ebp),%eax
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 5f fe ff ff       	call   801176 <fd_lookup>
  801317:	89 c2                	mov    %eax,%edx
  801319:	85 d2                	test   %edx,%edx
  80131b:	0f 88 e1 00 00 00    	js     801402 <dup+0x106>
		return r;
	close(newfdnum);
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	89 04 24             	mov    %eax,(%esp)
  801327:	e8 7b ff ff ff       	call   8012a7 <close>

	newfd = INDEX2FD(newfdnum);
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80132f:	c1 e3 0c             	shl    $0xc,%ebx
  801332:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 cd fd ff ff       	call   801110 <fd2data>
  801343:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801345:	89 1c 24             	mov    %ebx,(%esp)
  801348:	e8 c3 fd ff ff       	call   801110 <fd2data>
  80134d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134f:	89 f0                	mov    %esi,%eax
  801351:	c1 e8 16             	shr    $0x16,%eax
  801354:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80135b:	a8 01                	test   $0x1,%al
  80135d:	74 43                	je     8013a2 <dup+0xa6>
  80135f:	89 f0                	mov    %esi,%eax
  801361:	c1 e8 0c             	shr    $0xc,%eax
  801364:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80136b:	f6 c2 01             	test   $0x1,%dl
  80136e:	74 32                	je     8013a2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801370:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801377:	25 07 0e 00 00       	and    $0xe07,%eax
  80137c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801380:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80138b:	00 
  80138c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801397:	e8 2b f9 ff ff       	call   800cc7 <sys_page_map>
  80139c:	89 c6                	mov    %eax,%esi
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 3e                	js     8013e0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 0c             	shr    $0xc,%edx
  8013aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c6:	00 
  8013c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d2:	e8 f0 f8 ff ff       	call   800cc7 <sys_page_map>
  8013d7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013dc:	85 f6                	test   %esi,%esi
  8013de:	79 22                	jns    801402 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013eb:	e8 2a f9 ff ff       	call   800d1a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013fb:	e8 1a f9 ff ff       	call   800d1a <sys_page_unmap>
	return r;
  801400:	89 f0                	mov    %esi,%eax
}
  801402:	83 c4 3c             	add    $0x3c,%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 24             	sub    $0x24,%esp
  801411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	89 1c 24             	mov    %ebx,(%esp)
  80141e:	e8 53 fd ff ff       	call   801176 <fd_lookup>
  801423:	89 c2                	mov    %eax,%edx
  801425:	85 d2                	test   %edx,%edx
  801427:	78 6d                	js     801496 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801429:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801430:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801433:	8b 00                	mov    (%eax),%eax
  801435:	89 04 24             	mov    %eax,(%esp)
  801438:	e8 8f fd ff ff       	call   8011cc <dev_lookup>
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 55                	js     801496 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801444:	8b 50 08             	mov    0x8(%eax),%edx
  801447:	83 e2 03             	and    $0x3,%edx
  80144a:	83 fa 01             	cmp    $0x1,%edx
  80144d:	75 23                	jne    801472 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144f:	a1 08 40 80 00       	mov    0x804008,%eax
  801454:	8b 40 48             	mov    0x48(%eax),%eax
  801457:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80145b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145f:	c7 04 24 ed 2c 80 00 	movl   $0x802ced,(%esp)
  801466:	e8 cb ed ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801470:	eb 24                	jmp    801496 <read+0x8c>
	}
	if (!dev->dev_read)
  801472:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801475:	8b 52 08             	mov    0x8(%edx),%edx
  801478:	85 d2                	test   %edx,%edx
  80147a:	74 15                	je     801491 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80147c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80147f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801483:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801486:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80148a:	89 04 24             	mov    %eax,(%esp)
  80148d:	ff d2                	call   *%edx
  80148f:	eb 05                	jmp    801496 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801491:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801496:	83 c4 24             	add    $0x24,%esp
  801499:	5b                   	pop    %ebx
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	57                   	push   %edi
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 1c             	sub    $0x1c,%esp
  8014a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b0:	eb 23                	jmp    8014d5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	29 d8                	sub    %ebx,%eax
  8014b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c3:	89 3c 24             	mov    %edi,(%esp)
  8014c6:	e8 3f ff ff ff       	call   80140a <read>
		if (m < 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 10                	js     8014df <readn+0x43>
			return m;
		if (m == 0)
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	74 0a                	je     8014dd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d3:	01 c3                	add    %eax,%ebx
  8014d5:	39 f3                	cmp    %esi,%ebx
  8014d7:	72 d9                	jb     8014b2 <readn+0x16>
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	eb 02                	jmp    8014df <readn+0x43>
  8014dd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014df:	83 c4 1c             	add    $0x1c,%esp
  8014e2:	5b                   	pop    %ebx
  8014e3:	5e                   	pop    %esi
  8014e4:	5f                   	pop    %edi
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 24             	sub    $0x24,%esp
  8014ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	89 1c 24             	mov    %ebx,(%esp)
  8014fb:	e8 76 fc ff ff       	call   801176 <fd_lookup>
  801500:	89 c2                	mov    %eax,%edx
  801502:	85 d2                	test   %edx,%edx
  801504:	78 68                	js     80156e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	8b 00                	mov    (%eax),%eax
  801512:	89 04 24             	mov    %eax,(%esp)
  801515:	e8 b2 fc ff ff       	call   8011cc <dev_lookup>
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 50                	js     80156e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801525:	75 23                	jne    80154a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801527:	a1 08 40 80 00       	mov    0x804008,%eax
  80152c:	8b 40 48             	mov    0x48(%eax),%eax
  80152f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
  801537:	c7 04 24 09 2d 80 00 	movl   $0x802d09,(%esp)
  80153e:	e8 f3 ec ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801543:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801548:	eb 24                	jmp    80156e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154d:	8b 52 0c             	mov    0xc(%edx),%edx
  801550:	85 d2                	test   %edx,%edx
  801552:	74 15                	je     801569 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801554:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801557:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801562:	89 04 24             	mov    %eax,(%esp)
  801565:	ff d2                	call   *%edx
  801567:	eb 05                	jmp    80156e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801569:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80156e:	83 c4 24             	add    $0x24,%esp
  801571:	5b                   	pop    %ebx
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <seek>:

int
seek(int fdnum, off_t offset)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80157d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	e8 ea fb ff ff       	call   801176 <fd_lookup>
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 0e                	js     80159e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801590:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 24             	sub    $0x24,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b1:	89 1c 24             	mov    %ebx,(%esp)
  8015b4:	e8 bd fb ff ff       	call   801176 <fd_lookup>
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	85 d2                	test   %edx,%edx
  8015bd:	78 61                	js     801620 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	8b 00                	mov    (%eax),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 f9 fb ff ff       	call   8011cc <dev_lookup>
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 49                	js     801620 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015de:	75 23                	jne    801603 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e5:	8b 40 48             	mov    0x48(%eax),%eax
  8015e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f0:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  8015f7:	e8 3a ec ff ff       	call   800236 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801601:	eb 1d                	jmp    801620 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801603:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801606:	8b 52 18             	mov    0x18(%edx),%edx
  801609:	85 d2                	test   %edx,%edx
  80160b:	74 0e                	je     80161b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801610:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801614:	89 04 24             	mov    %eax,(%esp)
  801617:	ff d2                	call   *%edx
  801619:	eb 05                	jmp    801620 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801620:	83 c4 24             	add    $0x24,%esp
  801623:	5b                   	pop    %ebx
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 24             	sub    $0x24,%esp
  80162d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	89 04 24             	mov    %eax,(%esp)
  80163d:	e8 34 fb ff ff       	call   801176 <fd_lookup>
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 d2                	test   %edx,%edx
  801646:	78 52                	js     80169a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	8b 00                	mov    (%eax),%eax
  801654:	89 04 24             	mov    %eax,(%esp)
  801657:	e8 70 fb ff ff       	call   8011cc <dev_lookup>
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 3a                	js     80169a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801667:	74 2c                	je     801695 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801669:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801673:	00 00 00 
	stat->st_isdir = 0;
  801676:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167d:	00 00 00 
	stat->st_dev = dev;
  801680:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80168a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168d:	89 14 24             	mov    %edx,(%esp)
  801690:	ff 50 14             	call   *0x14(%eax)
  801693:	eb 05                	jmp    80169a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80169a:	83 c4 24             	add    $0x24,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016af:	00 
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	e8 28 02 00 00       	call   8018e3 <open>
  8016bb:	89 c3                	mov    %eax,%ebx
  8016bd:	85 db                	test   %ebx,%ebx
  8016bf:	78 1b                	js     8016dc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	89 1c 24             	mov    %ebx,(%esp)
  8016cb:	e8 56 ff ff ff       	call   801626 <fstat>
  8016d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d2:	89 1c 24             	mov    %ebx,(%esp)
  8016d5:	e8 cd fb ff ff       	call   8012a7 <close>
	return r;
  8016da:	89 f0                	mov    %esi,%eax
}
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 10             	sub    $0x10,%esp
  8016eb:	89 c6                	mov    %eax,%esi
  8016ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f6:	75 11                	jne    801709 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8016ff:	e8 31 0f 00 00       	call   802635 <ipc_find_env>
  801704:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801709:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801710:	00 
  801711:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801718:	00 
  801719:	89 74 24 04          	mov    %esi,0x4(%esp)
  80171d:	a1 00 40 80 00       	mov    0x804000,%eax
  801722:	89 04 24             	mov    %eax,(%esp)
  801725:	e8 a0 0e 00 00       	call   8025ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801731:	00 
  801732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801736:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173d:	e8 0e 0e 00 00       	call   802550 <ipc_recv>
}
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801762:	ba 00 00 00 00       	mov    $0x0,%edx
  801767:	b8 02 00 00 00       	mov    $0x2,%eax
  80176c:	e8 72 ff ff ff       	call   8016e3 <fsipc>
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	8b 40 0c             	mov    0xc(%eax),%eax
  80177f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 06 00 00 00       	mov    $0x6,%eax
  80178e:	e8 50 ff ff ff       	call   8016e3 <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 14             	sub    $0x14,%esp
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b4:	e8 2a ff ff ff       	call   8016e3 <fsipc>
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	85 d2                	test   %edx,%edx
  8017bd:	78 2b                	js     8017ea <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017c6:	00 
  8017c7:	89 1c 24             	mov    %ebx,(%esp)
  8017ca:	e8 88 f0 ff ff       	call   800857 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017da:	a1 84 50 80 00       	mov    0x805084,%eax
  8017df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	83 c4 14             	add    $0x14,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 18             	sub    $0x18,%esp
  8017f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017fe:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801803:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801806:	8b 55 08             	mov    0x8(%ebp),%edx
  801809:	8b 52 0c             	mov    0xc(%edx),%edx
  80180c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801812:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801829:	e8 c6 f1 ff ff       	call   8009f4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 04 00 00 00       	mov    $0x4,%eax
  801838:	e8 a6 fe ff ff       	call   8016e3 <fsipc>
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	83 ec 10             	sub    $0x10,%esp
  801847:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	8b 40 0c             	mov    0xc(%eax),%eax
  801850:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801855:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 03 00 00 00       	mov    $0x3,%eax
  801865:	e8 79 fe ff ff       	call   8016e3 <fsipc>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 6a                	js     8018da <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801870:	39 c6                	cmp    %eax,%esi
  801872:	73 24                	jae    801898 <devfile_read+0x59>
  801874:	c7 44 24 0c 3c 2d 80 	movl   $0x802d3c,0xc(%esp)
  80187b:	00 
  80187c:	c7 44 24 08 43 2d 80 	movl   $0x802d43,0x8(%esp)
  801883:	00 
  801884:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80188b:	00 
  80188c:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  801893:	e8 5e 0c 00 00       	call   8024f6 <_panic>
	assert(r <= PGSIZE);
  801898:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80189d:	7e 24                	jle    8018c3 <devfile_read+0x84>
  80189f:	c7 44 24 0c 63 2d 80 	movl   $0x802d63,0xc(%esp)
  8018a6:	00 
  8018a7:	c7 44 24 08 43 2d 80 	movl   $0x802d43,0x8(%esp)
  8018ae:	00 
  8018af:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018b6:	00 
  8018b7:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  8018be:	e8 33 0c 00 00       	call   8024f6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018ce:	00 
  8018cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	e8 1a f1 ff ff       	call   8009f4 <memmove>
	return r;
}
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 24             	sub    $0x24,%esp
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ed:	89 1c 24             	mov    %ebx,(%esp)
  8018f0:	e8 2b ef ff ff       	call   800820 <strlen>
  8018f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fa:	7f 60                	jg     80195c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 20 f8 ff ff       	call   801127 <fd_alloc>
  801907:	89 c2                	mov    %eax,%edx
  801909:	85 d2                	test   %edx,%edx
  80190b:	78 54                	js     801961 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801911:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801918:	e8 3a ef ff ff       	call   800857 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801928:	b8 01 00 00 00       	mov    $0x1,%eax
  80192d:	e8 b1 fd ff ff       	call   8016e3 <fsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	85 c0                	test   %eax,%eax
  801936:	79 17                	jns    80194f <open+0x6c>
		fd_close(fd, 0);
  801938:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80193f:	00 
  801940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 db f8 ff ff       	call   801226 <fd_close>
		return r;
  80194b:	89 d8                	mov    %ebx,%eax
  80194d:	eb 12                	jmp    801961 <open+0x7e>
	}

	return fd2num(fd);
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 a6 f7 ff ff       	call   801100 <fd2num>
  80195a:	eb 05                	jmp    801961 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801961:	83 c4 24             	add    $0x24,%esp
  801964:	5b                   	pop    %ebx
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 08 00 00 00       	mov    $0x8,%eax
  801977:	e8 67 fd ff ff       	call   8016e3 <fsipc>
}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 14             	sub    $0x14,%esp
  801985:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801987:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80198b:	7e 31                	jle    8019be <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80198d:	8b 40 04             	mov    0x4(%eax),%eax
  801990:	89 44 24 08          	mov    %eax,0x8(%esp)
  801994:	8d 43 10             	lea    0x10(%ebx),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	8b 03                	mov    (%ebx),%eax
  80199d:	89 04 24             	mov    %eax,(%esp)
  8019a0:	e8 42 fb ff ff       	call   8014e7 <write>
		if (result > 0)
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	7e 03                	jle    8019ac <writebuf+0x2e>
			b->result += result;
  8019a9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019ac:	39 43 04             	cmp    %eax,0x4(%ebx)
  8019af:	74 0d                	je     8019be <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	0f 4f c2             	cmovg  %edx,%eax
  8019bb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019be:	83 c4 14             	add    $0x14,%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <putch>:

static void
putch(int ch, void *thunk)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019ce:	8b 53 04             	mov    0x4(%ebx),%edx
  8019d1:	8d 42 01             	lea    0x1(%edx),%eax
  8019d4:	89 43 04             	mov    %eax,0x4(%ebx)
  8019d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019da:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019de:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019e3:	75 0e                	jne    8019f3 <putch+0x2f>
		writebuf(b);
  8019e5:	89 d8                	mov    %ebx,%eax
  8019e7:	e8 92 ff ff ff       	call   80197e <writebuf>
		b->idx = 0;
  8019ec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019f3:	83 c4 04             	add    $0x4,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a0b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a12:	00 00 00 
	b.result = 0;
  801a15:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a1c:	00 00 00 
	b.error = 1;
  801a1f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a26:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a29:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a37:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a41:	c7 04 24 c4 19 80 00 	movl   $0x8019c4,(%esp)
  801a48:	e8 71 e9 ff ff       	call   8003be <vprintfmt>
	if (b.idx > 0)
  801a4d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a54:	7e 0b                	jle    801a61 <vfprintf+0x68>
		writebuf(&b);
  801a56:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a5c:	e8 1d ff ff ff       	call   80197e <writebuf>

	return (b.result ? b.result : b.error);
  801a61:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a67:	85 c0                	test   %eax,%eax
  801a69:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a78:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 68 ff ff ff       	call   8019f9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <printf>:

int
printf(const char *fmt, ...)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a99:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aae:	e8 46 ff ff ff       	call   8019f9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    
  801ab5:	66 90                	xchg   %ax,%ax
  801ab7:	66 90                	xchg   %ax,%ax
  801ab9:	66 90                	xchg   %ax,%ax
  801abb:	66 90                	xchg   %ax,%ax
  801abd:	66 90                	xchg   %ax,%ax
  801abf:	90                   	nop

00801ac0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ac6:	c7 44 24 04 6f 2d 80 	movl   $0x802d6f,0x4(%esp)
  801acd:	00 
  801ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 7e ed ff ff       	call   800857 <strcpy>
	return 0;
}
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 14             	sub    $0x14,%esp
  801ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801aea:	89 1c 24             	mov    %ebx,(%esp)
  801aed:	e8 7b 0b 00 00       	call   80266d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801af7:	83 f8 01             	cmp    $0x1,%eax
  801afa:	75 0d                	jne    801b09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801afc:	8b 43 0c             	mov    0xc(%ebx),%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 29 03 00 00       	call   801e30 <nsipc_close>
  801b07:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801b09:	89 d0                	mov    %edx,%eax
  801b0b:	83 c4 14             	add    $0x14,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b1e:	00 
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	8b 40 0c             	mov    0xc(%eax),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 f0 03 00 00       	call   801f2b <nsipc_send>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b4a:	00 
  801b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 44 03 00 00       	call   801eab <nsipc_recv>
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b72:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 f8 f5 ff ff       	call   801176 <fd_lookup>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 17                	js     801b99 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b8b:	39 08                	cmp    %ecx,(%eax)
  801b8d:	75 05                	jne    801b94 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	eb 05                	jmp    801b99 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 20             	sub    $0x20,%esp
  801ba3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	89 04 24             	mov    %eax,(%esp)
  801bab:	e8 77 f5 ff ff       	call   801127 <fd_alloc>
  801bb0:	89 c3                	mov    %eax,%ebx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 21                	js     801bd7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bbd:	00 
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcc:	e8 a2 f0 ff ff       	call   800c73 <sys_page_alloc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	79 0c                	jns    801be3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801bd7:	89 34 24             	mov    %esi,(%esp)
  801bda:	e8 51 02 00 00       	call   801e30 <nsipc_close>
		return r;
  801bdf:	89 d8                	mov    %ebx,%eax
  801be1:	eb 20                	jmp    801c03 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801be3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801bf8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801bfb:	89 14 24             	mov    %edx,(%esp)
  801bfe:	e8 fd f4 ff ff       	call   801100 <fd2num>
}
  801c03:	83 c4 20             	add    $0x20,%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	e8 51 ff ff ff       	call   801b69 <fd2sockid>
		return r;
  801c18:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 23                	js     801c41 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1e:	8b 55 10             	mov    0x10(%ebp),%edx
  801c21:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 45 01 00 00       	call   801d79 <nsipc_accept>
		return r;
  801c34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 07                	js     801c41 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801c3a:	e8 5c ff ff ff       	call   801b9b <alloc_sockfd>
  801c3f:	89 c1                	mov    %eax,%ecx
}
  801c41:	89 c8                	mov    %ecx,%eax
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	e8 16 ff ff ff       	call   801b69 <fd2sockid>
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	85 d2                	test   %edx,%edx
  801c57:	78 16                	js     801c6f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801c59:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	89 14 24             	mov    %edx,(%esp)
  801c6a:	e8 60 01 00 00       	call   801dcf <nsipc_bind>
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <shutdown>:

int
shutdown(int s, int how)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	e8 ea fe ff ff       	call   801b69 <fd2sockid>
  801c7f:	89 c2                	mov    %eax,%edx
  801c81:	85 d2                	test   %edx,%edx
  801c83:	78 0f                	js     801c94 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	89 14 24             	mov    %edx,(%esp)
  801c8f:	e8 7a 01 00 00       	call   801e0e <nsipc_shutdown>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	e8 c5 fe ff ff       	call   801b69 <fd2sockid>
  801ca4:	89 c2                	mov    %eax,%edx
  801ca6:	85 d2                	test   %edx,%edx
  801ca8:	78 16                	js     801cc0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801caa:	8b 45 10             	mov    0x10(%ebp),%eax
  801cad:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb8:	89 14 24             	mov    %edx,(%esp)
  801cbb:	e8 8a 01 00 00       	call   801e4a <nsipc_connect>
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <listen>:

int
listen(int s, int backlog)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	e8 99 fe ff ff       	call   801b69 <fd2sockid>
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	85 d2                	test   %edx,%edx
  801cd4:	78 0f                	js     801ce5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	89 14 24             	mov    %edx,(%esp)
  801ce0:	e8 a4 01 00 00       	call   801e89 <nsipc_listen>
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ced:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 98 02 00 00       	call   801f9e <nsipc_socket>
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	85 d2                	test   %edx,%edx
  801d0a:	78 05                	js     801d11 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801d0c:	e8 8a fe ff ff       	call   801b9b <alloc_sockfd>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
  801d1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d23:	75 11                	jne    801d36 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d2c:	e8 04 09 00 00       	call   802635 <ipc_find_env>
  801d31:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d3d:	00 
  801d3e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d45:	00 
  801d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d4f:	89 04 24             	mov    %eax,(%esp)
  801d52:	e8 73 08 00 00       	call   8025ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d5e:	00 
  801d5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d66:	00 
  801d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6e:	e8 dd 07 00 00       	call   802550 <ipc_recv>
}
  801d73:	83 c4 14             	add    $0x14,%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 10             	sub    $0x10,%esp
  801d81:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d8c:	8b 06                	mov    (%esi),%eax
  801d8e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d93:	b8 01 00 00 00       	mov    $0x1,%eax
  801d98:	e8 76 ff ff ff       	call   801d13 <nsipc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 23                	js     801dc6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801da3:	a1 10 60 80 00       	mov    0x806010,%eax
  801da8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dac:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801db3:	00 
  801db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 35 ec ff ff       	call   8009f4 <memmove>
		*addrlen = ret->ret_addrlen;
  801dbf:	a1 10 60 80 00       	mov    0x806010,%eax
  801dc4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 14             	sub    $0x14,%esp
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801de1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801df3:	e8 fc eb ff ff       	call   8009f4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801df8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dfe:	b8 02 00 00 00       	mov    $0x2,%eax
  801e03:	e8 0b ff ff ff       	call   801d13 <nsipc>
}
  801e08:	83 c4 14             	add    $0x14,%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e24:	b8 03 00 00 00       	mov    $0x3,%eax
  801e29:	e8 e5 fe ff ff       	call   801d13 <nsipc>
}
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <nsipc_close>:

int
nsipc_close(int s)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e3e:	b8 04 00 00 00       	mov    $0x4,%eax
  801e43:	e8 cb fe ff ff       	call   801d13 <nsipc>
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 14             	sub    $0x14,%esp
  801e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e54:	8b 45 08             	mov    0x8(%ebp),%eax
  801e57:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e6e:	e8 81 eb ff ff       	call   8009f4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e79:	b8 05 00 00 00       	mov    $0x5,%eax
  801e7e:	e8 90 fe ff ff       	call   801d13 <nsipc>
}
  801e83:	83 c4 14             	add    $0x14,%esp
  801e86:	5b                   	pop    %ebx
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e9f:	b8 06 00 00 00       	mov    $0x6,%eax
  801ea4:	e8 6a fe ff ff       	call   801d13 <nsipc>
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 10             	sub    $0x10,%esp
  801eb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ebe:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ec4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ecc:	b8 07 00 00 00       	mov    $0x7,%eax
  801ed1:	e8 3d fe ff ff       	call   801d13 <nsipc>
  801ed6:	89 c3                	mov    %eax,%ebx
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 46                	js     801f22 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801edc:	39 f0                	cmp    %esi,%eax
  801ede:	7f 07                	jg     801ee7 <nsipc_recv+0x3c>
  801ee0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ee5:	7e 24                	jle    801f0b <nsipc_recv+0x60>
  801ee7:	c7 44 24 0c 7b 2d 80 	movl   $0x802d7b,0xc(%esp)
  801eee:	00 
  801eef:	c7 44 24 08 43 2d 80 	movl   $0x802d43,0x8(%esp)
  801ef6:	00 
  801ef7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801efe:	00 
  801eff:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  801f06:	e8 eb 05 00 00       	call   8024f6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f0f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f16:	00 
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	89 04 24             	mov    %eax,(%esp)
  801f1d:	e8 d2 ea ff ff       	call   8009f4 <memmove>
	}

	return r;
}
  801f22:	89 d8                	mov    %ebx,%eax
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	53                   	push   %ebx
  801f2f:	83 ec 14             	sub    $0x14,%esp
  801f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f3d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f43:	7e 24                	jle    801f69 <nsipc_send+0x3e>
  801f45:	c7 44 24 0c 9c 2d 80 	movl   $0x802d9c,0xc(%esp)
  801f4c:	00 
  801f4d:	c7 44 24 08 43 2d 80 	movl   $0x802d43,0x8(%esp)
  801f54:	00 
  801f55:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801f5c:	00 
  801f5d:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  801f64:	e8 8d 05 00 00       	call   8024f6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f7b:	e8 74 ea ff ff       	call   8009f4 <memmove>
	nsipcbuf.send.req_size = size;
  801f80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f86:	8b 45 14             	mov    0x14(%ebp),%eax
  801f89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801f93:	e8 7b fd ff ff       	call   801d13 <nsipc>
}
  801f98:	83 c4 14             	add    $0x14,%esp
  801f9b:	5b                   	pop    %ebx
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faf:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fbc:	b8 09 00 00 00       	mov    $0x9,%eax
  801fc1:	e8 4d fd ff ff       	call   801d13 <nsipc>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 10             	sub    $0x10,%esp
  801fd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 32 f1 ff ff       	call   801110 <fd2data>
  801fde:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fe0:	c7 44 24 04 a8 2d 80 	movl   $0x802da8,0x4(%esp)
  801fe7:	00 
  801fe8:	89 1c 24             	mov    %ebx,(%esp)
  801feb:	e8 67 e8 ff ff       	call   800857 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ff0:	8b 46 04             	mov    0x4(%esi),%eax
  801ff3:	2b 06                	sub    (%esi),%eax
  801ff5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ffb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802002:	00 00 00 
	stat->st_dev = &devpipe;
  802005:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80200c:	30 80 00 
	return 0;
}
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	83 ec 14             	sub    $0x14,%esp
  802022:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802025:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802029:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802030:	e8 e5 ec ff ff       	call   800d1a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802035:	89 1c 24             	mov    %ebx,(%esp)
  802038:	e8 d3 f0 ff ff       	call   801110 <fd2data>
  80203d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802048:	e8 cd ec ff ff       	call   800d1a <sys_page_unmap>
}
  80204d:	83 c4 14             	add    $0x14,%esp
  802050:	5b                   	pop    %ebx
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	57                   	push   %edi
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	83 ec 2c             	sub    $0x2c,%esp
  80205c:	89 c6                	mov    %eax,%esi
  80205e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802061:	a1 08 40 80 00       	mov    0x804008,%eax
  802066:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802069:	89 34 24             	mov    %esi,(%esp)
  80206c:	e8 fc 05 00 00       	call   80266d <pageref>
  802071:	89 c7                	mov    %eax,%edi
  802073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 ef 05 00 00       	call   80266d <pageref>
  80207e:	39 c7                	cmp    %eax,%edi
  802080:	0f 94 c2             	sete   %dl
  802083:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802086:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80208c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80208f:	39 fb                	cmp    %edi,%ebx
  802091:	74 21                	je     8020b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802093:	84 d2                	test   %dl,%dl
  802095:	74 ca                	je     802061 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802097:	8b 51 58             	mov    0x58(%ecx),%edx
  80209a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209e:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a6:	c7 04 24 af 2d 80 00 	movl   $0x802daf,(%esp)
  8020ad:	e8 84 e1 ff ff       	call   800236 <cprintf>
  8020b2:	eb ad                	jmp    802061 <_pipeisclosed+0xe>
	}
}
  8020b4:	83 c4 2c             	add    $0x2c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	57                   	push   %edi
  8020c0:	56                   	push   %esi
  8020c1:	53                   	push   %ebx
  8020c2:	83 ec 1c             	sub    $0x1c,%esp
  8020c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020c8:	89 34 24             	mov    %esi,(%esp)
  8020cb:	e8 40 f0 ff ff       	call   801110 <fd2data>
  8020d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8020d7:	eb 45                	jmp    80211e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020d9:	89 da                	mov    %ebx,%edx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	e8 71 ff ff ff       	call   802053 <_pipeisclosed>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 41                	jne    802127 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020e6:	e8 69 eb ff ff       	call   800c54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ee:	8b 0b                	mov    (%ebx),%ecx
  8020f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8020f3:	39 d0                	cmp    %edx,%eax
  8020f5:	73 e2                	jae    8020d9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802101:	99                   	cltd   
  802102:	c1 ea 1b             	shr    $0x1b,%edx
  802105:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802108:	83 e1 1f             	and    $0x1f,%ecx
  80210b:	29 d1                	sub    %edx,%ecx
  80210d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802111:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80211b:	83 c7 01             	add    $0x1,%edi
  80211e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802121:	75 c8                	jne    8020eb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802123:	89 f8                	mov    %edi,%eax
  802125:	eb 05                	jmp    80212c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	83 ec 1c             	sub    $0x1c,%esp
  80213d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802140:	89 3c 24             	mov    %edi,(%esp)
  802143:	e8 c8 ef ff ff       	call   801110 <fd2data>
  802148:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214a:	be 00 00 00 00       	mov    $0x0,%esi
  80214f:	eb 3d                	jmp    80218e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802151:	85 f6                	test   %esi,%esi
  802153:	74 04                	je     802159 <devpipe_read+0x25>
				return i;
  802155:	89 f0                	mov    %esi,%eax
  802157:	eb 43                	jmp    80219c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802159:	89 da                	mov    %ebx,%edx
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	e8 f1 fe ff ff       	call   802053 <_pipeisclosed>
  802162:	85 c0                	test   %eax,%eax
  802164:	75 31                	jne    802197 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802166:	e8 e9 ea ff ff       	call   800c54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80216b:	8b 03                	mov    (%ebx),%eax
  80216d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802170:	74 df                	je     802151 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802172:	99                   	cltd   
  802173:	c1 ea 1b             	shr    $0x1b,%edx
  802176:	01 d0                	add    %edx,%eax
  802178:	83 e0 1f             	and    $0x1f,%eax
  80217b:	29 d0                	sub    %edx,%eax
  80217d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802185:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802188:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218b:	83 c6 01             	add    $0x1,%esi
  80218e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802191:	75 d8                	jne    80216b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802193:	89 f0                	mov    %esi,%eax
  802195:	eb 05                	jmp    80219c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802197:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    

008021a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021af:	89 04 24             	mov    %eax,(%esp)
  8021b2:	e8 70 ef ff ff       	call   801127 <fd_alloc>
  8021b7:	89 c2                	mov    %eax,%edx
  8021b9:	85 d2                	test   %edx,%edx
  8021bb:	0f 88 4d 01 00 00    	js     80230e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021c8:	00 
  8021c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d7:	e8 97 ea ff ff       	call   800c73 <sys_page_alloc>
  8021dc:	89 c2                	mov    %eax,%edx
  8021de:	85 d2                	test   %edx,%edx
  8021e0:	0f 88 28 01 00 00    	js     80230e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e9:	89 04 24             	mov    %eax,(%esp)
  8021ec:	e8 36 ef ff ff       	call   801127 <fd_alloc>
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	0f 88 fe 00 00 00    	js     8022f9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021fb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802202:	00 
  802203:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802211:	e8 5d ea ff ff       	call   800c73 <sys_page_alloc>
  802216:	89 c3                	mov    %eax,%ebx
  802218:	85 c0                	test   %eax,%eax
  80221a:	0f 88 d9 00 00 00    	js     8022f9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	89 04 24             	mov    %eax,(%esp)
  802226:	e8 e5 ee ff ff       	call   801110 <fd2data>
  80222b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802234:	00 
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802240:	e8 2e ea ff ff       	call   800c73 <sys_page_alloc>
  802245:	89 c3                	mov    %eax,%ebx
  802247:	85 c0                	test   %eax,%eax
  802249:	0f 88 97 00 00 00    	js     8022e6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802252:	89 04 24             	mov    %eax,(%esp)
  802255:	e8 b6 ee ff ff       	call   801110 <fd2data>
  80225a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802261:	00 
  802262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802266:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80226d:	00 
  80226e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802279:	e8 49 ea ff ff       	call   800cc7 <sys_page_map>
  80227e:	89 c3                	mov    %eax,%ebx
  802280:	85 c0                	test   %eax,%eax
  802282:	78 52                	js     8022d6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802284:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80228f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802292:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802299:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80229f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	89 04 24             	mov    %eax,(%esp)
  8022b4:	e8 47 ee ff ff       	call   801100 <fd2num>
  8022b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 37 ee ff ff       	call   801100 <fd2num>
  8022c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d4:	eb 38                	jmp    80230e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e1:	e8 34 ea ff ff       	call   800d1a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f4:	e8 21 ea ff ff       	call   800d1a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802300:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802307:	e8 0e ea ff ff       	call   800d1a <sys_page_unmap>
  80230c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80230e:	83 c4 30             	add    $0x30,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80231b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802322:	8b 45 08             	mov    0x8(%ebp),%eax
  802325:	89 04 24             	mov    %eax,(%esp)
  802328:	e8 49 ee ff ff       	call   801176 <fd_lookup>
  80232d:	89 c2                	mov    %eax,%edx
  80232f:	85 d2                	test   %edx,%edx
  802331:	78 15                	js     802348 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802336:	89 04 24             	mov    %eax,(%esp)
  802339:	e8 d2 ed ff ff       	call   801110 <fd2data>
	return _pipeisclosed(fd, p);
  80233e:	89 c2                	mov    %eax,%edx
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	e8 0b fd ff ff       	call   802053 <_pipeisclosed>
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802353:	b8 00 00 00 00       	mov    $0x0,%eax
  802358:	5d                   	pop    %ebp
  802359:	c3                   	ret    

0080235a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802360:	c7 44 24 04 c7 2d 80 	movl   $0x802dc7,0x4(%esp)
  802367:	00 
  802368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236b:	89 04 24             	mov    %eax,(%esp)
  80236e:	e8 e4 e4 ff ff       	call   800857 <strcpy>
	return 0;
}
  802373:	b8 00 00 00 00       	mov    $0x0,%eax
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	57                   	push   %edi
  80237e:	56                   	push   %esi
  80237f:	53                   	push   %ebx
  802380:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802386:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80238b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802391:	eb 31                	jmp    8023c4 <devcons_write+0x4a>
		m = n - tot;
  802393:	8b 75 10             	mov    0x10(%ebp),%esi
  802396:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802398:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80239b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023a0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023a7:	03 45 0c             	add    0xc(%ebp),%eax
  8023aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ae:	89 3c 24             	mov    %edi,(%esp)
  8023b1:	e8 3e e6 ff ff       	call   8009f4 <memmove>
		sys_cputs(buf, m);
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	89 3c 24             	mov    %edi,(%esp)
  8023bd:	e8 e4 e7 ff ff       	call   800ba6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c2:	01 f3                	add    %esi,%ebx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023c9:	72 c8                	jb     802393 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023cb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    

008023d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023dc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023e5:	75 07                	jne    8023ee <devcons_read+0x18>
  8023e7:	eb 2a                	jmp    802413 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e9:	e8 66 e8 ff ff       	call   800c54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023ee:	66 90                	xchg   %ax,%ax
  8023f0:	e8 cf e7 ff ff       	call   800bc4 <sys_cgetc>
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	74 f0                	je     8023e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 16                	js     802413 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023fd:	83 f8 04             	cmp    $0x4,%eax
  802400:	74 0c                	je     80240e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802402:	8b 55 0c             	mov    0xc(%ebp),%edx
  802405:	88 02                	mov    %al,(%edx)
	return 1;
  802407:	b8 01 00 00 00       	mov    $0x1,%eax
  80240c:	eb 05                	jmp    802413 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80240e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80241b:	8b 45 08             	mov    0x8(%ebp),%eax
  80241e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802421:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802428:	00 
  802429:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80242c:	89 04 24             	mov    %eax,(%esp)
  80242f:	e8 72 e7 ff ff       	call   800ba6 <sys_cputs>
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <getchar>:

int
getchar(void)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80243c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802443:	00 
  802444:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802452:	e8 b3 ef ff ff       	call   80140a <read>
	if (r < 0)
  802457:	85 c0                	test   %eax,%eax
  802459:	78 0f                	js     80246a <getchar+0x34>
		return r;
	if (r < 1)
  80245b:	85 c0                	test   %eax,%eax
  80245d:	7e 06                	jle    802465 <getchar+0x2f>
		return -E_EOF;
	return c;
  80245f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802463:	eb 05                	jmp    80246a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802465:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    

0080246c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802475:	89 44 24 04          	mov    %eax,0x4(%esp)
  802479:	8b 45 08             	mov    0x8(%ebp),%eax
  80247c:	89 04 24             	mov    %eax,(%esp)
  80247f:	e8 f2 ec ff ff       	call   801176 <fd_lookup>
  802484:	85 c0                	test   %eax,%eax
  802486:	78 11                	js     802499 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802491:	39 10                	cmp    %edx,(%eax)
  802493:	0f 94 c0             	sete   %al
  802496:	0f b6 c0             	movzbl %al,%eax
}
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <opencons>:

int
opencons(void)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a4:	89 04 24             	mov    %eax,(%esp)
  8024a7:	e8 7b ec ff ff       	call   801127 <fd_alloc>
		return r;
  8024ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	78 40                	js     8024f2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024b9:	00 
  8024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c8:	e8 a6 e7 ff ff       	call   800c73 <sys_page_alloc>
		return r;
  8024cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024cf:	85 c0                	test   %eax,%eax
  8024d1:	78 1f                	js     8024f2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e8:	89 04 24             	mov    %eax,(%esp)
  8024eb:	e8 10 ec ff ff       	call   801100 <fd2num>
  8024f0:	89 c2                	mov    %eax,%edx
}
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    

008024f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	56                   	push   %esi
  8024fa:	53                   	push   %ebx
  8024fb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8024fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802501:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802507:	e8 29 e7 ff ff       	call   800c35 <sys_getenvid>
  80250c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80250f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802513:	8b 55 08             	mov    0x8(%ebp),%edx
  802516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80251a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80251e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802522:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  802529:	e8 08 dd ff ff       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80252e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802532:	8b 45 10             	mov    0x10(%ebp),%eax
  802535:	89 04 24             	mov    %eax,(%esp)
  802538:	e8 98 dc ff ff       	call   8001d5 <vcprintf>
	cprintf("\n");
  80253d:	c7 04 24 50 29 80 00 	movl   $0x802950,(%esp)
  802544:	e8 ed dc ff ff       	call   800236 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802549:	cc                   	int3   
  80254a:	eb fd                	jmp    802549 <_panic+0x53>
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	56                   	push   %esi
  802554:	53                   	push   %ebx
  802555:	83 ec 10             	sub    $0x10,%esp
  802558:	8b 75 08             	mov    0x8(%ebp),%esi
  80255b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802561:	85 c0                	test   %eax,%eax
  802563:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802568:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80256b:	89 04 24             	mov    %eax,(%esp)
  80256e:	e8 16 e9 ff ff       	call   800e89 <sys_ipc_recv>

	if(ret < 0) {
  802573:	85 c0                	test   %eax,%eax
  802575:	79 16                	jns    80258d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802577:	85 f6                	test   %esi,%esi
  802579:	74 06                	je     802581 <ipc_recv+0x31>
  80257b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802581:	85 db                	test   %ebx,%ebx
  802583:	74 3e                	je     8025c3 <ipc_recv+0x73>
  802585:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80258b:	eb 36                	jmp    8025c3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80258d:	e8 a3 e6 ff ff       	call   800c35 <sys_getenvid>
  802592:	25 ff 03 00 00       	and    $0x3ff,%eax
  802597:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80259a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80259f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8025a4:	85 f6                	test   %esi,%esi
  8025a6:	74 05                	je     8025ad <ipc_recv+0x5d>
  8025a8:	8b 40 74             	mov    0x74(%eax),%eax
  8025ab:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8025ad:	85 db                	test   %ebx,%ebx
  8025af:	74 0a                	je     8025bb <ipc_recv+0x6b>
  8025b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8025b6:	8b 40 78             	mov    0x78(%eax),%eax
  8025b9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8025bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8025c0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025c3:	83 c4 10             	add    $0x10,%esp
  8025c6:	5b                   	pop    %ebx
  8025c7:	5e                   	pop    %esi
  8025c8:	5d                   	pop    %ebp
  8025c9:	c3                   	ret    

008025ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025ca:	55                   	push   %ebp
  8025cb:	89 e5                	mov    %esp,%ebp
  8025cd:	57                   	push   %edi
  8025ce:	56                   	push   %esi
  8025cf:	53                   	push   %ebx
  8025d0:	83 ec 1c             	sub    $0x1c,%esp
  8025d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8025dc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8025de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025e3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8025e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8025e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f5:	89 3c 24             	mov    %edi,(%esp)
  8025f8:	e8 69 e8 ff ff       	call   800e66 <sys_ipc_try_send>

		if(ret >= 0) break;
  8025fd:	85 c0                	test   %eax,%eax
  8025ff:	79 2c                	jns    80262d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802601:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802604:	74 20                	je     802626 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802606:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260a:	c7 44 24 08 f8 2d 80 	movl   $0x802df8,0x8(%esp)
  802611:	00 
  802612:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802619:	00 
  80261a:	c7 04 24 28 2e 80 00 	movl   $0x802e28,(%esp)
  802621:	e8 d0 fe ff ff       	call   8024f6 <_panic>
		}
		sys_yield();
  802626:	e8 29 e6 ff ff       	call   800c54 <sys_yield>
	}
  80262b:	eb b9                	jmp    8025e6 <ipc_send+0x1c>
}
  80262d:	83 c4 1c             	add    $0x1c,%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    

00802635 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802635:	55                   	push   %ebp
  802636:	89 e5                	mov    %esp,%ebp
  802638:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80263b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802640:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802643:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802649:	8b 52 50             	mov    0x50(%edx),%edx
  80264c:	39 ca                	cmp    %ecx,%edx
  80264e:	75 0d                	jne    80265d <ipc_find_env+0x28>
			return envs[i].env_id;
  802650:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802653:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802658:	8b 40 40             	mov    0x40(%eax),%eax
  80265b:	eb 0e                	jmp    80266b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80265d:	83 c0 01             	add    $0x1,%eax
  802660:	3d 00 04 00 00       	cmp    $0x400,%eax
  802665:	75 d9                	jne    802640 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802667:	66 b8 00 00          	mov    $0x0,%ax
}
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    

0080266d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80266d:	55                   	push   %ebp
  80266e:	89 e5                	mov    %esp,%ebp
  802670:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802673:	89 d0                	mov    %edx,%eax
  802675:	c1 e8 16             	shr    $0x16,%eax
  802678:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80267f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802684:	f6 c1 01             	test   $0x1,%cl
  802687:	74 1d                	je     8026a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802689:	c1 ea 0c             	shr    $0xc,%edx
  80268c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802693:	f6 c2 01             	test   $0x1,%dl
  802696:	74 0e                	je     8026a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802698:	c1 ea 0c             	shr    $0xc,%edx
  80269b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026a2:	ef 
  8026a3:	0f b7 c0             	movzwl %ax,%eax
}
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__udivdi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	83 ec 0c             	sub    $0xc,%esp
  8026b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8026ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8026be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8026c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8026c6:	85 c0                	test   %eax,%eax
  8026c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026cc:	89 ea                	mov    %ebp,%edx
  8026ce:	89 0c 24             	mov    %ecx,(%esp)
  8026d1:	75 2d                	jne    802700 <__udivdi3+0x50>
  8026d3:	39 e9                	cmp    %ebp,%ecx
  8026d5:	77 61                	ja     802738 <__udivdi3+0x88>
  8026d7:	85 c9                	test   %ecx,%ecx
  8026d9:	89 ce                	mov    %ecx,%esi
  8026db:	75 0b                	jne    8026e8 <__udivdi3+0x38>
  8026dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e2:	31 d2                	xor    %edx,%edx
  8026e4:	f7 f1                	div    %ecx
  8026e6:	89 c6                	mov    %eax,%esi
  8026e8:	31 d2                	xor    %edx,%edx
  8026ea:	89 e8                	mov    %ebp,%eax
  8026ec:	f7 f6                	div    %esi
  8026ee:	89 c5                	mov    %eax,%ebp
  8026f0:	89 f8                	mov    %edi,%eax
  8026f2:	f7 f6                	div    %esi
  8026f4:	89 ea                	mov    %ebp,%edx
  8026f6:	83 c4 0c             	add    $0xc,%esp
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	39 e8                	cmp    %ebp,%eax
  802702:	77 24                	ja     802728 <__udivdi3+0x78>
  802704:	0f bd e8             	bsr    %eax,%ebp
  802707:	83 f5 1f             	xor    $0x1f,%ebp
  80270a:	75 3c                	jne    802748 <__udivdi3+0x98>
  80270c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802710:	39 34 24             	cmp    %esi,(%esp)
  802713:	0f 86 9f 00 00 00    	jbe    8027b8 <__udivdi3+0x108>
  802719:	39 d0                	cmp    %edx,%eax
  80271b:	0f 82 97 00 00 00    	jb     8027b8 <__udivdi3+0x108>
  802721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802728:	31 d2                	xor    %edx,%edx
  80272a:	31 c0                	xor    %eax,%eax
  80272c:	83 c4 0c             	add    $0xc,%esp
  80272f:	5e                   	pop    %esi
  802730:	5f                   	pop    %edi
  802731:	5d                   	pop    %ebp
  802732:	c3                   	ret    
  802733:	90                   	nop
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	89 f8                	mov    %edi,%eax
  80273a:	f7 f1                	div    %ecx
  80273c:	31 d2                	xor    %edx,%edx
  80273e:	83 c4 0c             	add    $0xc,%esp
  802741:	5e                   	pop    %esi
  802742:	5f                   	pop    %edi
  802743:	5d                   	pop    %ebp
  802744:	c3                   	ret    
  802745:	8d 76 00             	lea    0x0(%esi),%esi
  802748:	89 e9                	mov    %ebp,%ecx
  80274a:	8b 3c 24             	mov    (%esp),%edi
  80274d:	d3 e0                	shl    %cl,%eax
  80274f:	89 c6                	mov    %eax,%esi
  802751:	b8 20 00 00 00       	mov    $0x20,%eax
  802756:	29 e8                	sub    %ebp,%eax
  802758:	89 c1                	mov    %eax,%ecx
  80275a:	d3 ef                	shr    %cl,%edi
  80275c:	89 e9                	mov    %ebp,%ecx
  80275e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802762:	8b 3c 24             	mov    (%esp),%edi
  802765:	09 74 24 08          	or     %esi,0x8(%esp)
  802769:	89 d6                	mov    %edx,%esi
  80276b:	d3 e7                	shl    %cl,%edi
  80276d:	89 c1                	mov    %eax,%ecx
  80276f:	89 3c 24             	mov    %edi,(%esp)
  802772:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802776:	d3 ee                	shr    %cl,%esi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	d3 e2                	shl    %cl,%edx
  80277c:	89 c1                	mov    %eax,%ecx
  80277e:	d3 ef                	shr    %cl,%edi
  802780:	09 d7                	or     %edx,%edi
  802782:	89 f2                	mov    %esi,%edx
  802784:	89 f8                	mov    %edi,%eax
  802786:	f7 74 24 08          	divl   0x8(%esp)
  80278a:	89 d6                	mov    %edx,%esi
  80278c:	89 c7                	mov    %eax,%edi
  80278e:	f7 24 24             	mull   (%esp)
  802791:	39 d6                	cmp    %edx,%esi
  802793:	89 14 24             	mov    %edx,(%esp)
  802796:	72 30                	jb     8027c8 <__udivdi3+0x118>
  802798:	8b 54 24 04          	mov    0x4(%esp),%edx
  80279c:	89 e9                	mov    %ebp,%ecx
  80279e:	d3 e2                	shl    %cl,%edx
  8027a0:	39 c2                	cmp    %eax,%edx
  8027a2:	73 05                	jae    8027a9 <__udivdi3+0xf9>
  8027a4:	3b 34 24             	cmp    (%esp),%esi
  8027a7:	74 1f                	je     8027c8 <__udivdi3+0x118>
  8027a9:	89 f8                	mov    %edi,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	e9 7a ff ff ff       	jmp    80272c <__udivdi3+0x7c>
  8027b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bf:	e9 68 ff ff ff       	jmp    80272c <__udivdi3+0x7c>
  8027c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8027cb:	31 d2                	xor    %edx,%edx
  8027cd:	83 c4 0c             	add    $0xc,%esp
  8027d0:	5e                   	pop    %esi
  8027d1:	5f                   	pop    %edi
  8027d2:	5d                   	pop    %ebp
  8027d3:	c3                   	ret    
  8027d4:	66 90                	xchg   %ax,%ax
  8027d6:	66 90                	xchg   %ax,%ax
  8027d8:	66 90                	xchg   %ax,%ax
  8027da:	66 90                	xchg   %ax,%ax
  8027dc:	66 90                	xchg   %ax,%ax
  8027de:	66 90                	xchg   %ax,%ax

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	83 ec 14             	sub    $0x14,%esp
  8027e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8027ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8027ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8027f2:	89 c7                	mov    %eax,%edi
  8027f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8027fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802800:	89 34 24             	mov    %esi,(%esp)
  802803:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802807:	85 c0                	test   %eax,%eax
  802809:	89 c2                	mov    %eax,%edx
  80280b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80280f:	75 17                	jne    802828 <__umoddi3+0x48>
  802811:	39 fe                	cmp    %edi,%esi
  802813:	76 4b                	jbe    802860 <__umoddi3+0x80>
  802815:	89 c8                	mov    %ecx,%eax
  802817:	89 fa                	mov    %edi,%edx
  802819:	f7 f6                	div    %esi
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	31 d2                	xor    %edx,%edx
  80281f:	83 c4 14             	add    $0x14,%esp
  802822:	5e                   	pop    %esi
  802823:	5f                   	pop    %edi
  802824:	5d                   	pop    %ebp
  802825:	c3                   	ret    
  802826:	66 90                	xchg   %ax,%ax
  802828:	39 f8                	cmp    %edi,%eax
  80282a:	77 54                	ja     802880 <__umoddi3+0xa0>
  80282c:	0f bd e8             	bsr    %eax,%ebp
  80282f:	83 f5 1f             	xor    $0x1f,%ebp
  802832:	75 5c                	jne    802890 <__umoddi3+0xb0>
  802834:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802838:	39 3c 24             	cmp    %edi,(%esp)
  80283b:	0f 87 e7 00 00 00    	ja     802928 <__umoddi3+0x148>
  802841:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802845:	29 f1                	sub    %esi,%ecx
  802847:	19 c7                	sbb    %eax,%edi
  802849:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80284d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802851:	8b 44 24 08          	mov    0x8(%esp),%eax
  802855:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802859:	83 c4 14             	add    $0x14,%esp
  80285c:	5e                   	pop    %esi
  80285d:	5f                   	pop    %edi
  80285e:	5d                   	pop    %ebp
  80285f:	c3                   	ret    
  802860:	85 f6                	test   %esi,%esi
  802862:	89 f5                	mov    %esi,%ebp
  802864:	75 0b                	jne    802871 <__umoddi3+0x91>
  802866:	b8 01 00 00 00       	mov    $0x1,%eax
  80286b:	31 d2                	xor    %edx,%edx
  80286d:	f7 f6                	div    %esi
  80286f:	89 c5                	mov    %eax,%ebp
  802871:	8b 44 24 04          	mov    0x4(%esp),%eax
  802875:	31 d2                	xor    %edx,%edx
  802877:	f7 f5                	div    %ebp
  802879:	89 c8                	mov    %ecx,%eax
  80287b:	f7 f5                	div    %ebp
  80287d:	eb 9c                	jmp    80281b <__umoddi3+0x3b>
  80287f:	90                   	nop
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 fa                	mov    %edi,%edx
  802884:	83 c4 14             	add    $0x14,%esp
  802887:	5e                   	pop    %esi
  802888:	5f                   	pop    %edi
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    
  80288b:	90                   	nop
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	8b 04 24             	mov    (%esp),%eax
  802893:	be 20 00 00 00       	mov    $0x20,%esi
  802898:	89 e9                	mov    %ebp,%ecx
  80289a:	29 ee                	sub    %ebp,%esi
  80289c:	d3 e2                	shl    %cl,%edx
  80289e:	89 f1                	mov    %esi,%ecx
  8028a0:	d3 e8                	shr    %cl,%eax
  8028a2:	89 e9                	mov    %ebp,%ecx
  8028a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028a8:	8b 04 24             	mov    (%esp),%eax
  8028ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8028af:	89 fa                	mov    %edi,%edx
  8028b1:	d3 e0                	shl    %cl,%eax
  8028b3:	89 f1                	mov    %esi,%ecx
  8028b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8028bd:	d3 ea                	shr    %cl,%edx
  8028bf:	89 e9                	mov    %ebp,%ecx
  8028c1:	d3 e7                	shl    %cl,%edi
  8028c3:	89 f1                	mov    %esi,%ecx
  8028c5:	d3 e8                	shr    %cl,%eax
  8028c7:	89 e9                	mov    %ebp,%ecx
  8028c9:	09 f8                	or     %edi,%eax
  8028cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8028cf:	f7 74 24 04          	divl   0x4(%esp)
  8028d3:	d3 e7                	shl    %cl,%edi
  8028d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028d9:	89 d7                	mov    %edx,%edi
  8028db:	f7 64 24 08          	mull   0x8(%esp)
  8028df:	39 d7                	cmp    %edx,%edi
  8028e1:	89 c1                	mov    %eax,%ecx
  8028e3:	89 14 24             	mov    %edx,(%esp)
  8028e6:	72 2c                	jb     802914 <__umoddi3+0x134>
  8028e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8028ec:	72 22                	jb     802910 <__umoddi3+0x130>
  8028ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028f2:	29 c8                	sub    %ecx,%eax
  8028f4:	19 d7                	sbb    %edx,%edi
  8028f6:	89 e9                	mov    %ebp,%ecx
  8028f8:	89 fa                	mov    %edi,%edx
  8028fa:	d3 e8                	shr    %cl,%eax
  8028fc:	89 f1                	mov    %esi,%ecx
  8028fe:	d3 e2                	shl    %cl,%edx
  802900:	89 e9                	mov    %ebp,%ecx
  802902:	d3 ef                	shr    %cl,%edi
  802904:	09 d0                	or     %edx,%eax
  802906:	89 fa                	mov    %edi,%edx
  802908:	83 c4 14             	add    $0x14,%esp
  80290b:	5e                   	pop    %esi
  80290c:	5f                   	pop    %edi
  80290d:	5d                   	pop    %ebp
  80290e:	c3                   	ret    
  80290f:	90                   	nop
  802910:	39 d7                	cmp    %edx,%edi
  802912:	75 da                	jne    8028ee <__umoddi3+0x10e>
  802914:	8b 14 24             	mov    (%esp),%edx
  802917:	89 c1                	mov    %eax,%ecx
  802919:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80291d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802921:	eb cb                	jmp    8028ee <__umoddi3+0x10e>
  802923:	90                   	nop
  802924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802928:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80292c:	0f 82 0f ff ff ff    	jb     802841 <__umoddi3+0x61>
  802932:	e9 1a ff ff ff       	jmp    802851 <__umoddi3+0x71>
