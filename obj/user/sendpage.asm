
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 16 11 00 00       	call   801154 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 bd 00 00 00    	jne    800106 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800050:	00 
  800051:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800058:	00 
  800059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 fc 12 00 00       	call   801360 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800064:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006b:	00 
  80006c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800073:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  80007a:	e8 65 02 00 00       	call   8002e4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80007f:	a1 04 40 80 00       	mov    0x804004,%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 44 08 00 00       	call   8008d0 <strlen>
  80008c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800090:	a1 04 40 80 00       	mov    0x804004,%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a0:	e8 3d 09 00 00       	call   8009e2 <strncmp>
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 0c                	jne    8000b5 <umain+0x82>
			cprintf("child received correct message\n");
  8000a9:	c7 04 24 f4 2a 80 00 	movl   $0x802af4,(%esp)
  8000b0:	e8 2f 02 00 00       	call   8002e4 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b5:	a1 00 40 80 00       	mov    0x804000,%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 0e 08 00 00       	call   8008d0 <strlen>
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c9:	a1 00 40 80 00       	mov    0x804000,%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d9:	e8 2e 0a 00 00       	call   800b0c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f5:	00 
  8000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f9:	89 04 24             	mov    %eax,(%esp)
  8000fc:	e8 d9 12 00 00       	call   8013da <ipc_send>
		return;
  800101:	e9 d8 00 00 00       	jmp    8001de <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800106:	a1 08 50 80 00       	mov    0x805008,%eax
  80010b:	8b 40 48             	mov    0x48(%eax),%eax
  80010e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011d:	00 
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 fd 0b 00 00       	call   800d23 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800126:	a1 04 40 80 00       	mov    0x804004,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 9d 07 00 00       	call   8008d0 <strlen>
  800133:	83 c0 01             	add    $0x1,%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	a1 04 40 80 00       	mov    0x804004,%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014a:	e8 bd 09 00 00       	call   800b0c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800166:	00 
  800167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 68 12 00 00       	call   8013da <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800179:	00 
  80017a:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800181:	00 
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 d3 11 00 00       	call   801360 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018d:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800194:	00 
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  8001a3:	e8 3c 01 00 00       	call   8002e4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 1b 07 00 00       	call   8008d0 <strlen>
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	a1 00 40 80 00       	mov    0x804000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c9:	e8 14 08 00 00       	call   8009e2 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 0c                	jne    8001de <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d2:	c7 04 24 14 2b 80 00 	movl   $0x802b14,(%esp)
  8001d9:	e8 06 01 00 00       	call   8002e4 <cprintf>
	return;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ee:	e8 f2 0a 00 00       	call   800ce5 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800200:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 db                	test   %ebx,%ebx
  800207:	7e 07                	jle    800210 <libmain+0x30>
		binaryname = argv[0];
  800209:	8b 06                	mov    (%esi),%eax
  80020b:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	89 1c 24             	mov    %ebx,(%esp)
  800217:	e8 17 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021c:	e8 07 00 00 00       	call   800228 <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80022e:	e8 27 14 00 00       	call   80165a <close_all>
	sys_env_destroy(0);
  800233:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023a:	e8 54 0a 00 00       	call   800c93 <sys_env_destroy>
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	53                   	push   %ebx
  800245:	83 ec 14             	sub    $0x14,%esp
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024b:	8b 13                	mov    (%ebx),%edx
  80024d:	8d 42 01             	lea    0x1(%edx),%eax
  800250:	89 03                	mov    %eax,(%ebx)
  800252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800255:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800259:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025e:	75 19                	jne    800279 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800260:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800267:	00 
  800268:	8d 43 08             	lea    0x8(%ebx),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 e3 09 00 00       	call   800c56 <sys_cputs>
		b->idx = 0;
  800273:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800279:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	5b                   	pop    %ebx
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800293:	00 00 00 
	b.cnt = 0;
  800296:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 41 02 80 00 	movl   $0x800241,(%esp)
  8002bf:	e8 aa 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 7a 09 00 00       	call   800c56 <sys_cputs>

	return b.cnt;
}
  8002dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 87 ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    
  8002fe:	66 90                	xchg   %ax,%ax

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 c3                	mov    %eax,%ebx
  800319:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032d:	39 d9                	cmp    %ebx,%ecx
  80032f:	72 05                	jb     800336 <printnum+0x36>
  800331:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800334:	77 69                	ja     80039f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800339:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80033d:	83 ee 01             	sub    $0x1,%esi
  800340:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 44 24 08          	mov    0x8(%esp),%eax
  80034c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800350:	89 c3                	mov    %eax,%ebx
  800352:	89 d6                	mov    %edx,%esi
  800354:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800357:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80035a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80035e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 cc 24 00 00       	call   802840 <__udivdi3>
  800374:	89 d9                	mov    %ebx,%ecx
  800376:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	89 54 24 04          	mov    %edx,0x4(%esp)
  800385:	89 fa                	mov    %edi,%edx
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	e8 71 ff ff ff       	call   800300 <printnum>
  80038f:	eb 1b                	jmp    8003ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	8b 45 18             	mov    0x18(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff d3                	call   *%ebx
  80039d:	eb 03                	jmp    8003a2 <printnum+0xa2>
  80039f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a2:	83 ee 01             	sub    $0x1,%esi
  8003a5:	85 f6                	test   %esi,%esi
  8003a7:	7f e8                	jg     800391 <printnum+0x91>
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 9c 25 00 00       	call   802970 <__umoddi3>
  8003d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d8:	0f be 80 8c 2b 80 00 	movsbl 0x802b8c(%eax),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003e5:	ff d0                	call   *%eax
}
  8003e7:	83 c4 3c             	add    $0x3c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f2:	83 fa 01             	cmp    $0x1,%edx
  8003f5:	7e 0e                	jle    800405 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003fc:	89 08                	mov    %ecx,(%eax)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	8b 52 04             	mov    0x4(%edx),%edx
  800403:	eb 22                	jmp    800427 <getuint+0x38>
	else if (lflag)
  800405:	85 d2                	test   %edx,%edx
  800407:	74 10                	je     800419 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040e:	89 08                	mov    %ecx,(%eax)
  800410:	8b 02                	mov    (%edx),%eax
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	eb 0e                	jmp    800427 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041e:	89 08                	mov    %ecx,(%eax)
  800420:	8b 02                	mov    (%edx),%eax
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800433:	8b 10                	mov    (%eax),%edx
  800435:	3b 50 04             	cmp    0x4(%eax),%edx
  800438:	73 0a                	jae    800444 <sprintputch+0x1b>
		*b->buf++ = ch;
  80043a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	88 02                	mov    %al,(%edx)
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80044c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 10             	mov    0x10(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	e8 02 00 00 00       	call   80046e <vprintfmt>
	va_end(ap);
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 3c             	sub    $0x3c,%esp
  800477:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80047a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80047d:	eb 14                	jmp    800493 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80047f:	85 c0                	test   %eax,%eax
  800481:	0f 84 b3 03 00 00    	je     80083a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800491:	89 f3                	mov    %esi,%ebx
  800493:	8d 73 01             	lea    0x1(%ebx),%esi
  800496:	0f b6 03             	movzbl (%ebx),%eax
  800499:	83 f8 25             	cmp    $0x25,%eax
  80049c:	75 e1                	jne    80047f <vprintfmt+0x11>
  80049e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004b0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bc:	eb 1d                	jmp    8004db <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004c4:	eb 15                	jmp    8004db <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004cc:	eb 0d                	jmp    8004db <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004d4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004de:	0f b6 0e             	movzbl (%esi),%ecx
  8004e1:	0f b6 c1             	movzbl %cl,%eax
  8004e4:	83 e9 23             	sub    $0x23,%ecx
  8004e7:	80 f9 55             	cmp    $0x55,%cl
  8004ea:	0f 87 2a 03 00 00    	ja     80081a <vprintfmt+0x3ac>
  8004f0:	0f b6 c9             	movzbl %cl,%ecx
  8004f3:	ff 24 8d c0 2c 80 00 	jmp    *0x802cc0(,%ecx,4)
  8004fa:	89 de                	mov    %ebx,%esi
  8004fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800501:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800504:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800508:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80050b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80050e:	83 fb 09             	cmp    $0x9,%ebx
  800511:	77 36                	ja     800549 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800513:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800516:	eb e9                	jmp    800501 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 48 04             	lea    0x4(%eax),%ecx
  80051e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800528:	eb 22                	jmp    80054c <vprintfmt+0xde>
  80052a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	b8 00 00 00 00       	mov    $0x0,%eax
  800534:	0f 49 c1             	cmovns %ecx,%eax
  800537:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
  80053c:	eb 9d                	jmp    8004db <vprintfmt+0x6d>
  80053e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800540:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800547:	eb 92                	jmp    8004db <vprintfmt+0x6d>
  800549:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80054c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800550:	79 89                	jns    8004db <vprintfmt+0x6d>
  800552:	e9 77 ff ff ff       	jmp    8004ce <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800557:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055c:	e9 7a ff ff ff       	jmp    8004db <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
			break;
  800576:	e9 18 ff ff ff       	jmp    800493 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 00                	mov    (%eax),%eax
  800586:	99                   	cltd   
  800587:	31 d0                	xor    %edx,%eax
  800589:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058b:	83 f8 0f             	cmp    $0xf,%eax
  80058e:	7f 0b                	jg     80059b <vprintfmt+0x12d>
  800590:	8b 14 85 20 2e 80 00 	mov    0x802e20(,%eax,4),%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	75 20                	jne    8005bb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80059b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059f:	c7 44 24 08 a4 2b 80 	movl   $0x802ba4,0x8(%esp)
  8005a6:	00 
  8005a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 90 fe ff ff       	call   800446 <printfmt>
  8005b6:	e9 d8 fe ff ff       	jmp    800493 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005bf:	c7 44 24 08 09 30 80 	movl   $0x803009,0x8(%esp)
  8005c6:	00 
  8005c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	e8 70 fe ff ff       	call   800446 <printfmt>
  8005d6:	e9 b8 fe ff ff       	jmp    800493 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005ef:	85 f6                	test   %esi,%esi
  8005f1:	b8 9d 2b 80 00       	mov    $0x802b9d,%eax
  8005f6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005fd:	0f 84 97 00 00 00    	je     80069a <vprintfmt+0x22c>
  800603:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800607:	0f 8e 9b 00 00 00    	jle    8006a8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800611:	89 34 24             	mov    %esi,(%esp)
  800614:	e8 cf 02 00 00       	call   8008e8 <strnlen>
  800619:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80061c:	29 c2                	sub    %eax,%edx
  80061e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800621:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800625:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800628:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80062b:	8b 75 08             	mov    0x8(%ebp),%esi
  80062e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800631:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	eb 0f                	jmp    800644 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f ed                	jg     800635 <vprintfmt+0x1c7>
  800648:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80064b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064e:	85 d2                	test   %edx,%edx
  800650:	b8 00 00 00 00       	mov    $0x0,%eax
  800655:	0f 49 c2             	cmovns %edx,%eax
  800658:	29 c2                	sub    %eax,%edx
  80065a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065d:	89 d7                	mov    %edx,%edi
  80065f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800662:	eb 50                	jmp    8006b4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800664:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800668:	74 1e                	je     800688 <vprintfmt+0x21a>
  80066a:	0f be d2             	movsbl %dl,%edx
  80066d:	83 ea 20             	sub    $0x20,%edx
  800670:	83 fa 5e             	cmp    $0x5e,%edx
  800673:	76 13                	jbe    800688 <vprintfmt+0x21a>
					putch('?', putdat);
  800675:	8b 45 0c             	mov    0xc(%ebp),%eax
  800678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
  800686:	eb 0d                	jmp    800695 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800688:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800695:	83 ef 01             	sub    $0x1,%edi
  800698:	eb 1a                	jmp    8006b4 <vprintfmt+0x246>
  80069a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80069d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006a0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a6:	eb 0c                	jmp    8006b4 <vprintfmt+0x246>
  8006a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ab:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006b4:	83 c6 01             	add    $0x1,%esi
  8006b7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006bb:	0f be c2             	movsbl %dl,%eax
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	74 27                	je     8006e9 <vprintfmt+0x27b>
  8006c2:	85 db                	test   %ebx,%ebx
  8006c4:	78 9e                	js     800664 <vprintfmt+0x1f6>
  8006c6:	83 eb 01             	sub    $0x1,%ebx
  8006c9:	79 99                	jns    800664 <vprintfmt+0x1f6>
  8006cb:	89 f8                	mov    %edi,%eax
  8006cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d3:	89 c3                	mov    %eax,%ebx
  8006d5:	eb 1a                	jmp    8006f1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e4:	83 eb 01             	sub    $0x1,%ebx
  8006e7:	eb 08                	jmp    8006f1 <vprintfmt+0x283>
  8006e9:	89 fb                	mov    %edi,%ebx
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006f1:	85 db                	test   %ebx,%ebx
  8006f3:	7f e2                	jg     8006d7 <vprintfmt+0x269>
  8006f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006fb:	e9 93 fd ff ff       	jmp    800493 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800700:	83 fa 01             	cmp    $0x1,%edx
  800703:	7e 16                	jle    80071b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 08             	lea    0x8(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 50 04             	mov    0x4(%eax),%edx
  800711:	8b 00                	mov    (%eax),%eax
  800713:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800716:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800719:	eb 32                	jmp    80074d <vprintfmt+0x2df>
	else if (lflag)
  80071b:	85 d2                	test   %edx,%edx
  80071d:	74 18                	je     800737 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	8b 30                	mov    (%eax),%esi
  80072a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	c1 f8 1f             	sar    $0x1f,%eax
  800732:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800735:	eb 16                	jmp    80074d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8d 50 04             	lea    0x4(%eax),%edx
  80073d:	89 55 14             	mov    %edx,0x14(%ebp)
  800740:	8b 30                	mov    (%eax),%esi
  800742:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800745:	89 f0                	mov    %esi,%eax
  800747:	c1 f8 1f             	sar    $0x1f,%eax
  80074a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800753:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800758:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075c:	0f 89 80 00 00 00    	jns    8007e2 <vprintfmt+0x374>
				putch('-', putdat);
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800770:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800773:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800776:	f7 d8                	neg    %eax
  800778:	83 d2 00             	adc    $0x0,%edx
  80077b:	f7 da                	neg    %edx
			}
			base = 10;
  80077d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800782:	eb 5e                	jmp    8007e2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800784:	8d 45 14             	lea    0x14(%ebp),%eax
  800787:	e8 63 fc ff ff       	call   8003ef <getuint>
			base = 10;
  80078c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800791:	eb 4f                	jmp    8007e2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	e8 54 fc ff ff       	call   8003ef <getuint>
			base = 8;
  80079b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007a0:	eb 40                	jmp    8007e2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 50 04             	lea    0x4(%eax),%edx
  8007c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ce:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007d3:	eb 0d                	jmp    8007e2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d8:	e8 12 fc ff ff       	call   8003ef <getuint>
			base = 16;
  8007dd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007e6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ea:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007f5:	89 04 24             	mov    %eax,(%esp)
  8007f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fc:	89 fa                	mov    %edi,%edx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	e8 fa fa ff ff       	call   800300 <printnum>
			break;
  800806:	e9 88 fc ff ff       	jmp    800493 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80080b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	ff 55 08             	call   *0x8(%ebp)
			break;
  800815:	e9 79 fc ff ff       	jmp    800493 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800825:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	eb 03                	jmp    80082f <vprintfmt+0x3c1>
  80082c:	83 eb 01             	sub    $0x1,%ebx
  80082f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800833:	75 f7                	jne    80082c <vprintfmt+0x3be>
  800835:	e9 59 fc ff ff       	jmp    800493 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80083a:	83 c4 3c             	add    $0x3c,%esp
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 28             	sub    $0x28,%esp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800851:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800855:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 30                	je     800893 <vsnprintf+0x51>
  800863:	85 d2                	test   %edx,%edx
  800865:	7e 2c                	jle    800893 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086e:	8b 45 10             	mov    0x10(%ebp),%eax
  800871:	89 44 24 08          	mov    %eax,0x8(%esp)
  800875:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087c:	c7 04 24 29 04 80 00 	movl   $0x800429,(%esp)
  800883:	e8 e6 fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800888:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800891:	eb 05                	jmp    800898 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800893:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	e8 82 ff ff ff       	call   800842 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    
  8008c2:	66 90                	xchg   %ax,%ax
  8008c4:	66 90                	xchg   %ax,%ax
  8008c6:	66 90                	xchg   %ax,%ax
  8008c8:	66 90                	xchg   %ax,%ax
  8008ca:	66 90                	xchg   %ax,%ax
  8008cc:	66 90                	xchg   %ax,%ax
  8008ce:	66 90                	xchg   %ax,%ax

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strlen+0x10>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e4:	75 f7                	jne    8008dd <strlen+0xd>
		n++;
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 03                	jmp    8008fb <strnlen+0x13>
		n++;
  8008f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	74 06                	je     800905 <strnlen+0x1d>
  8008ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800903:	75 f3                	jne    8008f8 <strnlen+0x10>
		n++;
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800911:	89 c2                	mov    %eax,%edx
  800913:	83 c2 01             	add    $0x1,%edx
  800916:	83 c1 01             	add    $0x1,%ecx
  800919:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80091d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800920:	84 db                	test   %bl,%bl
  800922:	75 ef                	jne    800913 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 97 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	01 d8                	add    %ebx,%eax
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	e8 bd ff ff ff       	call   800907 <strcpy>
	return dst;
}
  80094a:	89 d8                	mov    %ebx,%eax
  80094c:	83 c4 08             	add    $0x8,%esp
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 75 08             	mov    0x8(%ebp),%esi
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	89 f3                	mov    %esi,%ebx
  80095f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	89 f2                	mov    %esi,%edx
  800964:	eb 0f                	jmp    800975 <strncpy+0x23>
		*dst++ = *src;
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096f:	80 39 01             	cmpb   $0x1,(%ecx)
  800972:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800975:	39 da                	cmp    %ebx,%edx
  800977:	75 ed                	jne    800966 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800979:	89 f0                	mov    %esi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80098d:	89 f0                	mov    %esi,%eax
  80098f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800993:	85 c9                	test   %ecx,%ecx
  800995:	75 0b                	jne    8009a2 <strlcpy+0x23>
  800997:	eb 1d                	jmp    8009b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a2:	39 d8                	cmp    %ebx,%eax
  8009a4:	74 0b                	je     8009b1 <strlcpy+0x32>
  8009a6:	0f b6 0a             	movzbl (%edx),%ecx
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	75 ec                	jne    800999 <strlcpy+0x1a>
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	eb 02                	jmp    8009b3 <strlcpy+0x34>
  8009b1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009b3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009b6:	29 f0                	sub    %esi,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c5:	eb 06                	jmp    8009cd <strcmp+0x11>
		p++, q++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cd:	0f b6 01             	movzbl (%ecx),%eax
  8009d0:	84 c0                	test   %al,%al
  8009d2:	74 04                	je     8009d8 <strcmp+0x1c>
  8009d4:	3a 02                	cmp    (%edx),%al
  8009d6:	74 ef                	je     8009c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 c0             	movzbl %al,%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strncmp+0x17>
		n--, p++, q++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f9:	39 d8                	cmp    %ebx,%eax
  8009fb:	74 15                	je     800a12 <strncmp+0x30>
  8009fd:	0f b6 08             	movzbl (%eax),%ecx
  800a00:	84 c9                	test   %cl,%cl
  800a02:	74 04                	je     800a08 <strncmp+0x26>
  800a04:	3a 0a                	cmp    (%edx),%cl
  800a06:	74 eb                	je     8009f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
  800a10:	eb 05                	jmp    800a17 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	eb 07                	jmp    800a2d <strchr+0x13>
		if (*s == c)
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 0f                	je     800a39 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f2                	jne    800a26 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	eb 07                	jmp    800a4e <strfind+0x13>
		if (*s == c)
  800a47:	38 ca                	cmp    %cl,%dl
  800a49:	74 0a                	je     800a55 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	0f b6 10             	movzbl (%eax),%edx
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f2                	jne    800a47 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	74 36                	je     800a9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6d:	75 28                	jne    800a97 <memset+0x40>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 23                	jne    800a97 <memset+0x40>
		c &= 0xFF;
  800a74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	c1 e3 08             	shl    $0x8,%ebx
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	c1 e6 18             	shl    $0x18,%esi
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	c1 e0 10             	shl    $0x10,%eax
  800a87:	09 f0                	or     %esi,%eax
  800a89:	09 c2                	or     %eax,%edx
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a92:	fc                   	cld    
  800a93:	f3 ab                	rep stos %eax,%es:(%edi)
  800a95:	eb 06                	jmp    800a9d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	fc                   	cld    
  800a9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9d:	89 f8                	mov    %edi,%eax
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 35                	jae    800aeb <memmove+0x47>
  800ab6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	73 2e                	jae    800aeb <memmove+0x47>
		s += n;
		d += n;
  800abd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aca:	75 13                	jne    800adf <memmove+0x3b>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0e                	jne    800adf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad1:	83 ef 04             	sub    $0x4,%edi
  800ad4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ada:	fd                   	std    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 09                	jmp    800ae8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adf:	83 ef 01             	sub    $0x1,%edi
  800ae2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae8:	fc                   	cld    
  800ae9:	eb 1d                	jmp    800b08 <memmove+0x64>
  800aeb:	89 f2                	mov    %esi,%edx
  800aed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	f6 c2 03             	test   $0x3,%dl
  800af2:	75 0f                	jne    800b03 <memmove+0x5f>
  800af4:	f6 c1 03             	test   $0x3,%cl
  800af7:	75 0a                	jne    800b03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800afc:	89 c7                	mov    %eax,%edi
  800afe:	fc                   	cld    
  800aff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b01:	eb 05                	jmp    800b08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	fc                   	cld    
  800b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 79 ff ff ff       	call   800aa4 <memmove>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3d:	eb 1a                	jmp    800b59 <memcmp+0x2c>
		if (*s1 != *s2)
  800b3f:	0f b6 02             	movzbl (%edx),%eax
  800b42:	0f b6 19             	movzbl (%ecx),%ebx
  800b45:	38 d8                	cmp    %bl,%al
  800b47:	74 0a                	je     800b53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b49:	0f b6 c0             	movzbl %al,%eax
  800b4c:	0f b6 db             	movzbl %bl,%ebx
  800b4f:	29 d8                	sub    %ebx,%eax
  800b51:	eb 0f                	jmp    800b62 <memcmp+0x35>
		s1++, s2++;
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b59:	39 f2                	cmp    %esi,%edx
  800b5b:	75 e2                	jne    800b3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b74:	eb 07                	jmp    800b7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b76:	38 08                	cmp    %cl,(%eax)
  800b78:	74 07                	je     800b81 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	39 d0                	cmp    %edx,%eax
  800b7f:	72 f5                	jb     800b76 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8f:	eb 03                	jmp    800b94 <strtol+0x11>
		s++;
  800b91:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b94:	0f b6 0a             	movzbl (%edx),%ecx
  800b97:	80 f9 09             	cmp    $0x9,%cl
  800b9a:	74 f5                	je     800b91 <strtol+0xe>
  800b9c:	80 f9 20             	cmp    $0x20,%cl
  800b9f:	74 f0                	je     800b91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba1:	80 f9 2b             	cmp    $0x2b,%cl
  800ba4:	75 0a                	jne    800bb0 <strtol+0x2d>
		s++;
  800ba6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	eb 11                	jmp    800bc1 <strtol+0x3e>
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb5:	80 f9 2d             	cmp    $0x2d,%cl
  800bb8:	75 07                	jne    800bc1 <strtol+0x3e>
		s++, neg = 1;
  800bba:	8d 52 01             	lea    0x1(%edx),%edx
  800bbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bc6:	75 15                	jne    800bdd <strtol+0x5a>
  800bc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcb:	75 10                	jne    800bdd <strtol+0x5a>
  800bcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd1:	75 0a                	jne    800bdd <strtol+0x5a>
		s += 2, base = 16;
  800bd3:	83 c2 02             	add    $0x2,%edx
  800bd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bdb:	eb 10                	jmp    800bed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	75 0c                	jne    800bed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be3:	80 3a 30             	cmpb   $0x30,(%edx)
  800be6:	75 05                	jne    800bed <strtol+0x6a>
		s++, base = 8;
  800be8:	83 c2 01             	add    $0x1,%edx
  800beb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 0a             	movzbl (%edx),%ecx
  800bf8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bfb:	89 f0                	mov    %esi,%eax
  800bfd:	3c 09                	cmp    $0x9,%al
  800bff:	77 08                	ja     800c09 <strtol+0x86>
			dig = *s - '0';
  800c01:	0f be c9             	movsbl %cl,%ecx
  800c04:	83 e9 30             	sub    $0x30,%ecx
  800c07:	eb 20                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c0c:	89 f0                	mov    %esi,%eax
  800c0e:	3c 19                	cmp    $0x19,%al
  800c10:	77 08                	ja     800c1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c12:	0f be c9             	movsbl %cl,%ecx
  800c15:	83 e9 57             	sub    $0x57,%ecx
  800c18:	eb 0f                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c1d:	89 f0                	mov    %esi,%eax
  800c1f:	3c 19                	cmp    $0x19,%al
  800c21:	77 16                	ja     800c39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c23:	0f be c9             	movsbl %cl,%ecx
  800c26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c2c:	7d 0f                	jge    800c3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c37:	eb bc                	jmp    800bf5 <strtol+0x72>
  800c39:	89 d8                	mov    %ebx,%eax
  800c3b:	eb 02                	jmp    800c3f <strtol+0xbc>
  800c3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c43:	74 05                	je     800c4a <strtol+0xc7>
		*endptr = (char *) s;
  800c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c4a:	f7 d8                	neg    %eax
  800c4c:	85 ff                	test   %edi,%edi
  800c4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	89 c6                	mov    %eax,%esi
  800c6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 cb                	mov    %ecx,%ebx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	89 ce                	mov    %ecx,%esi
  800caf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 28                	jle    800cdd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd0:	00 
  800cd1:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800cd8:	e8 59 1a 00 00       	call   802736 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdd:	83 c4 2c             	add    $0x2c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_yield>:

void
sys_yield(void)
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
  800d0f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 04 00 00 00       	mov    $0x4,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	89 f7                	mov    %esi,%edi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 28                	jle    800d6f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800d6a:	e8 c7 19 00 00       	call   802736 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6f:	83 c4 2c             	add    $0x2c,%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d80:	b8 05 00 00 00       	mov    $0x5,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	8b 75 18             	mov    0x18(%ebp),%esi
  800d94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	7e 28                	jle    800dc2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da5:	00 
  800da6:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800dad:	00 
  800dae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db5:	00 
  800db6:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800dbd:	e8 74 19 00 00       	call   802736 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc2:	83 c4 2c             	add    $0x2c,%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 28                	jle    800e15 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df8:	00 
  800df9:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800e00:	00 
  800e01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e08:	00 
  800e09:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800e10:	e8 21 19 00 00       	call   802736 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e15:	83 c4 2c             	add    $0x2c,%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 df                	mov    %ebx,%edi
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7e 28                	jle    800e68 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800e53:	00 
  800e54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5b:	00 
  800e5c:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800e63:	e8 ce 18 00 00       	call   802736 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e68:	83 c4 2c             	add    $0x2c,%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 28                	jle    800ebb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e97:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800eb6:	e8 7b 18 00 00       	call   802736 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebb:	83 c4 2c             	add    $0x2c,%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 28                	jle    800f0e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eea:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f01:	00 
  800f02:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800f09:	e8 28 18 00 00       	call   802736 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0e:	83 c4 2c             	add    $0x2c,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
  800f21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f32:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4f:	89 cb                	mov    %ecx,%ebx
  800f51:	89 cf                	mov    %ecx,%edi
  800f53:	89 ce                	mov    %ecx,%esi
  800f55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	7e 28                	jle    800f83 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f66:	00 
  800f67:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f76:	00 
  800f77:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800f7e:	e8 b3 17 00 00       	call   802736 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f83:	83 c4 2c             	add    $0x2c,%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
  800f96:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f9b:	89 d1                	mov    %edx,%ecx
  800f9d:	89 d3                	mov    %edx,%ebx
  800f9f:	89 d7                	mov    %edx,%edi
  800fa1:	89 d6                	mov    %edx,%esi
  800fa3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	89 de                	mov    %ebx,%esi
  800fc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 28                	jle    800ff5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800ff0:	e8 41 17 00 00       	call   802736 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800ff5:	83 c4 2c             	add    $0x2c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100b:	b8 10 00 00 00       	mov    $0x10,%eax
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 df                	mov    %ebx,%edi
  801018:	89 de                	mov    %ebx,%esi
  80101a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  801043:	e8 ee 16 00 00       	call   802736 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801048:	83 c4 2c             	add    $0x2c,%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 20             	sub    $0x20,%esp
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80105b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80105d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801061:	75 20                	jne    801083 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801063:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801067:	c7 44 24 08 aa 2e 80 	movl   $0x802eaa,0x8(%esp)
  80106e:	00 
  80106f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801076:	00 
  801077:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  80107e:	e8 b3 16 00 00       	call   802736 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801083:	89 f0                	mov    %esi,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108f:	f6 c4 08             	test   $0x8,%ah
  801092:	75 1c                	jne    8010b0 <pgfault+0x60>
		panic("Not a COW page");
  801094:	c7 44 24 08 c6 2e 80 	movl   $0x802ec6,0x8(%esp)
  80109b:	00 
  80109c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8010a3:	00 
  8010a4:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  8010ab:	e8 86 16 00 00       	call   802736 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  8010b0:	e8 30 fc ff ff       	call   800ce5 <sys_getenvid>
  8010b5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  8010b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c6:	00 
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	e8 54 fc ff ff       	call   800d23 <sys_page_alloc>
	if(r < 0) {
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 1c                	jns    8010ef <pgfault+0x9f>
		panic("couldn't allocate page");
  8010d3:	c7 44 24 08 d5 2e 80 	movl   $0x802ed5,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  8010ea:	e8 47 16 00 00       	call   802736 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8010ef:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8010f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010fc:	00 
  8010fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801101:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801108:	e8 97 f9 ff ff       	call   800aa4 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80110d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801114:	00 
  801115:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80111d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801124:	00 
  801125:	89 1c 24             	mov    %ebx,(%esp)
  801128:	e8 4a fc ff ff       	call   800d77 <sys_page_map>
	if(r < 0) {
  80112d:	85 c0                	test   %eax,%eax
  80112f:	79 1c                	jns    80114d <pgfault+0xfd>
		panic("couldn't map page");
  801131:	c7 44 24 08 ec 2e 80 	movl   $0x802eec,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  801148:	e8 e9 15 00 00       	call   802736 <_panic>
	}
}
  80114d:	83 c4 20             	add    $0x20,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80115d:	c7 04 24 50 10 80 00 	movl   $0x801050,(%esp)
  801164:	e8 23 16 00 00       	call   80278c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801169:	b8 07 00 00 00       	mov    $0x7,%eax
  80116e:	cd 30                	int    $0x30
  801170:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801173:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801176:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80117d:	bf 00 00 00 00       	mov    $0x0,%edi
  801182:	85 c0                	test   %eax,%eax
  801184:	75 21                	jne    8011a7 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801186:	e8 5a fb ff ff       	call   800ce5 <sys_getenvid>
  80118b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801190:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801193:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801198:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a2:	e9 8d 01 00 00       	jmp    801334 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  8011a7:	89 f8                	mov    %edi,%eax
  8011a9:	c1 e8 16             	shr    $0x16,%eax
  8011ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	0f 84 02 01 00 00    	je     8012bd <fork+0x169>
  8011bb:	89 fa                	mov    %edi,%edx
  8011bd:	c1 ea 0c             	shr    $0xc,%edx
  8011c0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	0f 84 ee 00 00 00    	je     8012bd <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  8011cf:	89 d6                	mov    %edx,%esi
  8011d1:	c1 e6 0c             	shl    $0xc,%esi
  8011d4:	89 f0                	mov    %esi,%eax
  8011d6:	c1 e8 16             	shr    $0x16,%eax
  8011d9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	f6 c1 01             	test   $0x1,%cl
  8011e8:	0f 84 cc 00 00 00    	je     8012ba <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8011ee:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8011f5:	89 d8                	mov    %ebx,%eax
  8011f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011fc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8011ff:	89 d8                	mov    %ebx,%eax
  801201:	83 e0 01             	and    $0x1,%eax
  801204:	0f 84 b0 00 00 00    	je     8012ba <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80120a:	e8 d6 fa ff ff       	call   800ce5 <sys_getenvid>
  80120f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801212:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801219:	74 28                	je     801243 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80121b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80121e:	25 07 0e 00 00       	and    $0xe07,%eax
  801223:	89 44 24 10          	mov    %eax,0x10(%esp)
  801227:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80122b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80122e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801232:	89 74 24 04          	mov    %esi,0x4(%esp)
  801236:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 36 fb ff ff       	call   800d77 <sys_page_map>
  801241:	eb 77                	jmp    8012ba <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801243:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801249:	74 4e                	je     801299 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80124b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801253:	80 cc 08             	or     $0x8,%ah
  801256:	89 c3                	mov    %eax,%ebx
  801258:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801263:	89 44 24 08          	mov    %eax,0x8(%esp)
  801267:	89 74 24 04          	mov    %esi,0x4(%esp)
  80126b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80126e:	89 04 24             	mov    %eax,(%esp)
  801271:	e8 01 fb ff ff       	call   800d77 <sys_page_map>
  801276:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801279:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80127d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801281:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801284:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801288:	89 74 24 04          	mov    %esi,0x4(%esp)
  80128c:	89 0c 24             	mov    %ecx,(%esp)
  80128f:	e8 e3 fa ff ff       	call   800d77 <sys_page_map>
  801294:	03 45 e0             	add    -0x20(%ebp),%eax
  801297:	eb 21                	jmp    8012ba <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801299:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80129c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012b2:	89 04 24             	mov    %eax,(%esp)
  8012b5:	e8 bd fa ff ff       	call   800d77 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  8012ba:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  8012bd:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012c3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  8012c9:	0f 85 d8 fe ff ff    	jne    8011a7 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  8012cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012de:	ee 
  8012df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8012e2:	89 34 24             	mov    %esi,(%esp)
  8012e5:	e8 39 fa ff ff       	call   800d23 <sys_page_alloc>
  8012ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012ed:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012ef:	c7 44 24 04 d9 27 80 	movl   $0x8027d9,0x4(%esp)
  8012f6:	00 
  8012f7:	89 34 24             	mov    %esi,(%esp)
  8012fa:	e8 c4 fb ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  8012ff:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801301:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801308:	00 
  801309:	89 34 24             	mov    %esi,(%esp)
  80130c:	e8 0c fb ff ff       	call   800e1d <sys_env_set_status>

	if(r<0) {
  801311:	01 d8                	add    %ebx,%eax
  801313:	79 1c                	jns    801331 <fork+0x1dd>
	 panic("fork failed!");
  801315:	c7 44 24 08 fe 2e 80 	movl   $0x802efe,0x8(%esp)
  80131c:	00 
  80131d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801324:	00 
  801325:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  80132c:	e8 05 14 00 00       	call   802736 <_panic>
	}

	return envid;
  801331:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801334:	83 c4 3c             	add    $0x3c,%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <sfork>:

// Challenge!
int
sfork(void)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801342:	c7 44 24 08 0b 2f 80 	movl   $0x802f0b,0x8(%esp)
  801349:	00 
  80134a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801351:	00 
  801352:	c7 04 24 bb 2e 80 00 	movl   $0x802ebb,(%esp)
  801359:	e8 d8 13 00 00       	call   802736 <_panic>
  80135e:	66 90                	xchg   %ax,%ax

00801360 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 10             	sub    $0x10,%esp
  801368:	8b 75 08             	mov    0x8(%ebp),%esi
  80136b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801371:	85 c0                	test   %eax,%eax
  801373:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801378:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80137b:	89 04 24             	mov    %eax,(%esp)
  80137e:	e8 b6 fb ff ff       	call   800f39 <sys_ipc_recv>

	if(ret < 0) {
  801383:	85 c0                	test   %eax,%eax
  801385:	79 16                	jns    80139d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  801387:	85 f6                	test   %esi,%esi
  801389:	74 06                	je     801391 <ipc_recv+0x31>
  80138b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801391:	85 db                	test   %ebx,%ebx
  801393:	74 3e                	je     8013d3 <ipc_recv+0x73>
  801395:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80139b:	eb 36                	jmp    8013d3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80139d:	e8 43 f9 ff ff       	call   800ce5 <sys_getenvid>
  8013a2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013a7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013aa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013af:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8013b4:	85 f6                	test   %esi,%esi
  8013b6:	74 05                	je     8013bd <ipc_recv+0x5d>
  8013b8:	8b 40 74             	mov    0x74(%eax),%eax
  8013bb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8013bd:	85 db                	test   %ebx,%ebx
  8013bf:	74 0a                	je     8013cb <ipc_recv+0x6b>
  8013c1:	a1 08 50 80 00       	mov    0x805008,%eax
  8013c6:	8b 40 78             	mov    0x78(%eax),%eax
  8013c9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8013cb:	a1 08 50 80 00       	mov    0x805008,%eax
  8013d0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	57                   	push   %edi
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 1c             	sub    $0x1c,%esp
  8013e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8013ec:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8013ee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013f3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8013f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801401:	89 74 24 04          	mov    %esi,0x4(%esp)
  801405:	89 3c 24             	mov    %edi,(%esp)
  801408:	e8 09 fb ff ff       	call   800f16 <sys_ipc_try_send>

		if(ret >= 0) break;
  80140d:	85 c0                	test   %eax,%eax
  80140f:	79 2c                	jns    80143d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  801411:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801414:	74 20                	je     801436 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  801416:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141a:	c7 44 24 08 24 2f 80 	movl   $0x802f24,0x8(%esp)
  801421:	00 
  801422:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801429:	00 
  80142a:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801431:	e8 00 13 00 00       	call   802736 <_panic>
		}
		sys_yield();
  801436:	e8 c9 f8 ff ff       	call   800d04 <sys_yield>
	}
  80143b:	eb b9                	jmp    8013f6 <ipc_send+0x1c>
}
  80143d:	83 c4 1c             	add    $0x1c,%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801450:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801453:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801459:	8b 52 50             	mov    0x50(%edx),%edx
  80145c:	39 ca                	cmp    %ecx,%edx
  80145e:	75 0d                	jne    80146d <ipc_find_env+0x28>
			return envs[i].env_id;
  801460:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801463:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801468:	8b 40 40             	mov    0x40(%eax),%eax
  80146b:	eb 0e                	jmp    80147b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80146d:	83 c0 01             	add    $0x1,%eax
  801470:	3d 00 04 00 00       	cmp    $0x400,%eax
  801475:	75 d9                	jne    801450 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801477:	66 b8 00 00          	mov    $0x0,%ax
}
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    
  80147d:	66 90                	xchg   %ax,%ax
  80147f:	90                   	nop

00801480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	05 00 00 00 30       	add    $0x30000000,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80149b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	c1 ea 16             	shr    $0x16,%edx
  8014b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014be:	f6 c2 01             	test   $0x1,%dl
  8014c1:	74 11                	je     8014d4 <fd_alloc+0x2d>
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	c1 ea 0c             	shr    $0xc,%edx
  8014c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014cf:	f6 c2 01             	test   $0x1,%dl
  8014d2:	75 09                	jne    8014dd <fd_alloc+0x36>
			*fd_store = fd;
  8014d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014db:	eb 17                	jmp    8014f4 <fd_alloc+0x4d>
  8014dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e7:	75 c9                	jne    8014b2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014fc:	83 f8 1f             	cmp    $0x1f,%eax
  8014ff:	77 36                	ja     801537 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801501:	c1 e0 0c             	shl    $0xc,%eax
  801504:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801509:	89 c2                	mov    %eax,%edx
  80150b:	c1 ea 16             	shr    $0x16,%edx
  80150e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801515:	f6 c2 01             	test   $0x1,%dl
  801518:	74 24                	je     80153e <fd_lookup+0x48>
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	c1 ea 0c             	shr    $0xc,%edx
  80151f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801526:	f6 c2 01             	test   $0x1,%dl
  801529:	74 1a                	je     801545 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80152b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152e:	89 02                	mov    %eax,(%edx)
	return 0;
  801530:	b8 00 00 00 00       	mov    $0x0,%eax
  801535:	eb 13                	jmp    80154a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153c:	eb 0c                	jmp    80154a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801543:	eb 05                	jmp    80154a <fd_lookup+0x54>
  801545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 18             	sub    $0x18,%esp
  801552:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	eb 13                	jmp    80156f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80155c:	39 08                	cmp    %ecx,(%eax)
  80155e:	75 0c                	jne    80156c <dev_lookup+0x20>
			*dev = devtab[i];
  801560:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801563:	89 01                	mov    %eax,(%ecx)
			return 0;
  801565:	b8 00 00 00 00       	mov    $0x0,%eax
  80156a:	eb 38                	jmp    8015a4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80156c:	83 c2 01             	add    $0x1,%edx
  80156f:	8b 04 95 dc 2f 80 00 	mov    0x802fdc(,%edx,4),%eax
  801576:	85 c0                	test   %eax,%eax
  801578:	75 e2                	jne    80155c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80157a:	a1 08 50 80 00       	mov    0x805008,%eax
  80157f:	8b 40 48             	mov    0x48(%eax),%eax
  801582:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	c7 04 24 60 2f 80 00 	movl   $0x802f60,(%esp)
  801591:	e8 4e ed ff ff       	call   8002e4 <cprintf>
	*dev = 0;
  801596:	8b 45 0c             	mov    0xc(%ebp),%eax
  801599:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80159f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 20             	sub    $0x20,%esp
  8015ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015c1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 2a ff ff ff       	call   8014f6 <fd_lookup>
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 05                	js     8015d5 <fd_close+0x2f>
	    || fd != fd2)
  8015d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d3:	74 0c                	je     8015e1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8015d5:	84 db                	test   %bl,%bl
  8015d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015dc:	0f 44 c2             	cmove  %edx,%eax
  8015df:	eb 3f                	jmp    801620 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e8:	8b 06                	mov    (%esi),%eax
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	e8 5a ff ff ff       	call   80154c <dev_lookup>
  8015f2:	89 c3                	mov    %eax,%ebx
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 16                	js     80160e <fd_close+0x68>
		if (dev->dev_close)
  8015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801603:	85 c0                	test   %eax,%eax
  801605:	74 07                	je     80160e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801607:	89 34 24             	mov    %esi,(%esp)
  80160a:	ff d0                	call   *%eax
  80160c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80160e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801612:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801619:	e8 ac f7 ff ff       	call   800dca <sys_page_unmap>
	return r;
  80161e:	89 d8                	mov    %ebx,%eax
}
  801620:	83 c4 20             	add    $0x20,%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 b7 fe ff ff       	call   8014f6 <fd_lookup>
  80163f:	89 c2                	mov    %eax,%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	78 13                	js     801658 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801645:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80164c:	00 
  80164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 4e ff ff ff       	call   8015a6 <fd_close>
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <close_all>:

void
close_all(void)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801661:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801666:	89 1c 24             	mov    %ebx,(%esp)
  801669:	e8 b9 ff ff ff       	call   801627 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80166e:	83 c3 01             	add    $0x1,%ebx
  801671:	83 fb 20             	cmp    $0x20,%ebx
  801674:	75 f0                	jne    801666 <close_all+0xc>
		close(i);
}
  801676:	83 c4 14             	add    $0x14,%esp
  801679:	5b                   	pop    %ebx
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801685:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 5f fe ff ff       	call   8014f6 <fd_lookup>
  801697:	89 c2                	mov    %eax,%edx
  801699:	85 d2                	test   %edx,%edx
  80169b:	0f 88 e1 00 00 00    	js     801782 <dup+0x106>
		return r;
	close(newfdnum);
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 7b ff ff ff       	call   801627 <close>

	newfd = INDEX2FD(newfdnum);
  8016ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016af:	c1 e3 0c             	shl    $0xc,%ebx
  8016b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 cd fd ff ff       	call   801490 <fd2data>
  8016c3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016c5:	89 1c 24             	mov    %ebx,(%esp)
  8016c8:	e8 c3 fd ff ff       	call   801490 <fd2data>
  8016cd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	c1 e8 16             	shr    $0x16,%eax
  8016d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016db:	a8 01                	test   $0x1,%al
  8016dd:	74 43                	je     801722 <dup+0xa6>
  8016df:	89 f0                	mov    %esi,%eax
  8016e1:	c1 e8 0c             	shr    $0xc,%eax
  8016e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016eb:	f6 c2 01             	test   $0x1,%dl
  8016ee:	74 32                	je     801722 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801700:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801704:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170b:	00 
  80170c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801717:	e8 5b f6 ff ff       	call   800d77 <sys_page_map>
  80171c:	89 c6                	mov    %eax,%esi
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 3e                	js     801760 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801725:	89 c2                	mov    %eax,%edx
  801727:	c1 ea 0c             	shr    $0xc,%edx
  80172a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801731:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801737:	89 54 24 10          	mov    %edx,0x10(%esp)
  80173b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80173f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801746:	00 
  801747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801752:	e8 20 f6 ff ff       	call   800d77 <sys_page_map>
  801757:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801759:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175c:	85 f6                	test   %esi,%esi
  80175e:	79 22                	jns    801782 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176b:	e8 5a f6 ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801774:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177b:	e8 4a f6 ff ff       	call   800dca <sys_page_unmap>
	return r;
  801780:	89 f0                	mov    %esi,%eax
}
  801782:	83 c4 3c             	add    $0x3c,%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	83 ec 24             	sub    $0x24,%esp
  801791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801794:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179b:	89 1c 24             	mov    %ebx,(%esp)
  80179e:	e8 53 fd ff ff       	call   8014f6 <fd_lookup>
  8017a3:	89 c2                	mov    %eax,%edx
  8017a5:	85 d2                	test   %edx,%edx
  8017a7:	78 6d                	js     801816 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b3:	8b 00                	mov    (%eax),%eax
  8017b5:	89 04 24             	mov    %eax,(%esp)
  8017b8:	e8 8f fd ff ff       	call   80154c <dev_lookup>
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 55                	js     801816 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c4:	8b 50 08             	mov    0x8(%eax),%edx
  8017c7:	83 e2 03             	and    $0x3,%edx
  8017ca:	83 fa 01             	cmp    $0x1,%edx
  8017cd:	75 23                	jne    8017f2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017cf:	a1 08 50 80 00       	mov    0x805008,%eax
  8017d4:	8b 40 48             	mov    0x48(%eax),%eax
  8017d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	c7 04 24 a1 2f 80 00 	movl   $0x802fa1,(%esp)
  8017e6:	e8 f9 ea ff ff       	call   8002e4 <cprintf>
		return -E_INVAL;
  8017eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f0:	eb 24                	jmp    801816 <read+0x8c>
	}
	if (!dev->dev_read)
  8017f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f5:	8b 52 08             	mov    0x8(%edx),%edx
  8017f8:	85 d2                	test   %edx,%edx
  8017fa:	74 15                	je     801811 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801806:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	ff d2                	call   *%edx
  80180f:	eb 05                	jmp    801816 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801811:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801816:	83 c4 24             	add    $0x24,%esp
  801819:	5b                   	pop    %ebx
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	83 ec 1c             	sub    $0x1c,%esp
  801825:	8b 7d 08             	mov    0x8(%ebp),%edi
  801828:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80182b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801830:	eb 23                	jmp    801855 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801832:	89 f0                	mov    %esi,%eax
  801834:	29 d8                	sub    %ebx,%eax
  801836:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	03 45 0c             	add    0xc(%ebp),%eax
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	89 3c 24             	mov    %edi,(%esp)
  801846:	e8 3f ff ff ff       	call   80178a <read>
		if (m < 0)
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 10                	js     80185f <readn+0x43>
			return m;
		if (m == 0)
  80184f:	85 c0                	test   %eax,%eax
  801851:	74 0a                	je     80185d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801853:	01 c3                	add    %eax,%ebx
  801855:	39 f3                	cmp    %esi,%ebx
  801857:	72 d9                	jb     801832 <readn+0x16>
  801859:	89 d8                	mov    %ebx,%eax
  80185b:	eb 02                	jmp    80185f <readn+0x43>
  80185d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80185f:	83 c4 1c             	add    $0x1c,%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 24             	sub    $0x24,%esp
  80186e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801871:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801874:	89 44 24 04          	mov    %eax,0x4(%esp)
  801878:	89 1c 24             	mov    %ebx,(%esp)
  80187b:	e8 76 fc ff ff       	call   8014f6 <fd_lookup>
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 d2                	test   %edx,%edx
  801884:	78 68                	js     8018ee <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	8b 00                	mov    (%eax),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 b2 fc ff ff       	call   80154c <dev_lookup>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 50                	js     8018ee <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a5:	75 23                	jne    8018ca <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a7:	a1 08 50 80 00       	mov    0x805008,%eax
  8018ac:	8b 40 48             	mov    0x48(%eax),%eax
  8018af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  8018be:	e8 21 ea ff ff       	call   8002e4 <cprintf>
		return -E_INVAL;
  8018c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c8:	eb 24                	jmp    8018ee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	74 15                	je     8018e9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	ff d2                	call   *%edx
  8018e7:	eb 05                	jmp    8018ee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018ee:	83 c4 24             	add    $0x24,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	e8 ea fb ff ff       	call   8014f6 <fd_lookup>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 0e                	js     80191e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801913:	8b 55 0c             	mov    0xc(%ebp),%edx
  801916:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 24             	sub    $0x24,%esp
  801927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	89 1c 24             	mov    %ebx,(%esp)
  801934:	e8 bd fb ff ff       	call   8014f6 <fd_lookup>
  801939:	89 c2                	mov    %eax,%edx
  80193b:	85 d2                	test   %edx,%edx
  80193d:	78 61                	js     8019a0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801942:	89 44 24 04          	mov    %eax,0x4(%esp)
  801946:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801949:	8b 00                	mov    (%eax),%eax
  80194b:	89 04 24             	mov    %eax,(%esp)
  80194e:	e8 f9 fb ff ff       	call   80154c <dev_lookup>
  801953:	85 c0                	test   %eax,%eax
  801955:	78 49                	js     8019a0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801957:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80195e:	75 23                	jne    801983 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801960:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801965:	8b 40 48             	mov    0x48(%eax),%eax
  801968:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80196c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801970:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  801977:	e8 68 e9 ff ff       	call   8002e4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80197c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801981:	eb 1d                	jmp    8019a0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801983:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801986:	8b 52 18             	mov    0x18(%edx),%edx
  801989:	85 d2                	test   %edx,%edx
  80198b:	74 0e                	je     80199b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80198d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801990:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	ff d2                	call   *%edx
  801999:	eb 05                	jmp    8019a0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80199b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019a0:	83 c4 24             	add    $0x24,%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 24             	sub    $0x24,%esp
  8019ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	89 04 24             	mov    %eax,(%esp)
  8019bd:	e8 34 fb ff ff       	call   8014f6 <fd_lookup>
  8019c2:	89 c2                	mov    %eax,%edx
  8019c4:	85 d2                	test   %edx,%edx
  8019c6:	78 52                	js     801a1a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d2:	8b 00                	mov    (%eax),%eax
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	e8 70 fb ff ff       	call   80154c <dev_lookup>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 3a                	js     801a1a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e7:	74 2c                	je     801a15 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f3:	00 00 00 
	stat->st_isdir = 0;
  8019f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fd:	00 00 00 
	stat->st_dev = dev;
  801a00:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a0d:	89 14 24             	mov    %edx,(%esp)
  801a10:	ff 50 14             	call   *0x14(%eax)
  801a13:	eb 05                	jmp    801a1a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a1a:	83 c4 24             	add    $0x24,%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2f:	00 
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	89 04 24             	mov    %eax,(%esp)
  801a36:	e8 28 02 00 00       	call   801c63 <open>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	85 db                	test   %ebx,%ebx
  801a3f:	78 1b                	js     801a5c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a48:	89 1c 24             	mov    %ebx,(%esp)
  801a4b:	e8 56 ff ff ff       	call   8019a6 <fstat>
  801a50:	89 c6                	mov    %eax,%esi
	close(fd);
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 cd fb ff ff       	call   801627 <close>
	return r;
  801a5a:	89 f0                	mov    %esi,%eax
}
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	83 ec 10             	sub    $0x10,%esp
  801a6b:	89 c6                	mov    %eax,%esi
  801a6d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a6f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a76:	75 11                	jne    801a89 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a7f:	e8 c1 f9 ff ff       	call   801445 <ipc_find_env>
  801a84:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a89:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a90:	00 
  801a91:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a98:	00 
  801a99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a9d:	a1 00 50 80 00       	mov    0x805000,%eax
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 30 f9 ff ff       	call   8013da <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801aaa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ab1:	00 
  801ab2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abd:	e8 9e f8 ff ff       	call   801360 <ipc_recv>
}
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	5b                   	pop    %ebx
  801ac6:	5e                   	pop    %esi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  801add:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae7:	b8 02 00 00 00       	mov    $0x2,%eax
  801aec:	e8 72 ff ff ff       	call   801a63 <fsipc>
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 40 0c             	mov    0xc(%eax),%eax
  801aff:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	b8 06 00 00 00       	mov    $0x6,%eax
  801b0e:	e8 50 ff ff ff       	call   801a63 <fsipc>
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 14             	sub    $0x14,%esp
  801b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 40 0c             	mov    0xc(%eax),%eax
  801b25:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b34:	e8 2a ff ff ff       	call   801a63 <fsipc>
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	85 d2                	test   %edx,%edx
  801b3d:	78 2b                	js     801b6a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b46:	00 
  801b47:	89 1c 24             	mov    %ebx,(%esp)
  801b4a:	e8 b8 ed ff ff       	call   800907 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b4f:	a1 80 60 80 00       	mov    0x806080,%eax
  801b54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b5a:	a1 84 60 80 00       	mov    0x806084,%eax
  801b5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6a:	83 c4 14             	add    $0x14,%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 18             	sub    $0x18,%esp
  801b76:	8b 45 10             	mov    0x10(%ebp),%eax
  801b79:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b7e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b83:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b86:	8b 55 08             	mov    0x8(%ebp),%edx
  801b89:	8b 52 0c             	mov    0xc(%edx),%edx
  801b8c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b92:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801b97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801ba9:	e8 f6 ee ff ff       	call   800aa4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801bae:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801bb8:	e8 a6 fe ff ff       	call   801a63 <fsipc>
}
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 10             	sub    $0x10,%esp
  801bc7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bca:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcd:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bd5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801be0:	b8 03 00 00 00       	mov    $0x3,%eax
  801be5:	e8 79 fe ff ff       	call   801a63 <fsipc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 6a                	js     801c5a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bf0:	39 c6                	cmp    %eax,%esi
  801bf2:	73 24                	jae    801c18 <devfile_read+0x59>
  801bf4:	c7 44 24 0c f0 2f 80 	movl   $0x802ff0,0xc(%esp)
  801bfb:	00 
  801bfc:	c7 44 24 08 f7 2f 80 	movl   $0x802ff7,0x8(%esp)
  801c03:	00 
  801c04:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c0b:	00 
  801c0c:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  801c13:	e8 1e 0b 00 00       	call   802736 <_panic>
	assert(r <= PGSIZE);
  801c18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1d:	7e 24                	jle    801c43 <devfile_read+0x84>
  801c1f:	c7 44 24 0c 17 30 80 	movl   $0x803017,0xc(%esp)
  801c26:	00 
  801c27:	c7 44 24 08 f7 2f 80 	movl   $0x802ff7,0x8(%esp)
  801c2e:	00 
  801c2f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c36:	00 
  801c37:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  801c3e:	e8 f3 0a 00 00       	call   802736 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c47:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c4e:	00 
  801c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 4a ee ff ff       	call   800aa4 <memmove>
	return r;
}
  801c5a:	89 d8                	mov    %ebx,%eax
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	53                   	push   %ebx
  801c67:	83 ec 24             	sub    $0x24,%esp
  801c6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 5b ec ff ff       	call   8008d0 <strlen>
  801c75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c7a:	7f 60                	jg     801cdc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 20 f8 ff ff       	call   8014a7 <fd_alloc>
  801c87:	89 c2                	mov    %eax,%edx
  801c89:	85 d2                	test   %edx,%edx
  801c8b:	78 54                	js     801ce1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c91:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c98:	e8 6a ec ff ff       	call   800907 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca8:	b8 01 00 00 00       	mov    $0x1,%eax
  801cad:	e8 b1 fd ff ff       	call   801a63 <fsipc>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	79 17                	jns    801ccf <open+0x6c>
		fd_close(fd, 0);
  801cb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cbf:	00 
  801cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc3:	89 04 24             	mov    %eax,(%esp)
  801cc6:	e8 db f8 ff ff       	call   8015a6 <fd_close>
		return r;
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	eb 12                	jmp    801ce1 <open+0x7e>
	}

	return fd2num(fd);
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 a6 f7 ff ff       	call   801480 <fd2num>
  801cda:	eb 05                	jmp    801ce1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cdc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce1:	83 c4 24             	add    $0x24,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ced:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf2:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf7:	e8 67 fd ff ff       	call   801a63 <fsipc>
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d06:	c7 44 24 04 23 30 80 	movl   $0x803023,0x4(%esp)
  801d0d:	00 
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 ee eb ff ff       	call   800907 <strcpy>
	return 0;
}
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 14             	sub    $0x14,%esp
  801d27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d2a:	89 1c 24             	mov    %ebx,(%esp)
  801d2d:	e8 cb 0a 00 00       	call   8027fd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d32:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d37:	83 f8 01             	cmp    $0x1,%eax
  801d3a:	75 0d                	jne    801d49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801d3c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d3f:	89 04 24             	mov    %eax,(%esp)
  801d42:	e8 29 03 00 00       	call   802070 <nsipc_close>
  801d47:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801d49:	89 d0                	mov    %edx,%eax
  801d4b:	83 c4 14             	add    $0x14,%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d5e:	00 
  801d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	8b 40 0c             	mov    0xc(%eax),%eax
  801d73:	89 04 24             	mov    %eax,(%esp)
  801d76:	e8 f0 03 00 00       	call   80216b <nsipc_send>
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d83:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d8a:	00 
  801d8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9f:	89 04 24             	mov    %eax,(%esp)
  801da2:	e8 44 03 00 00       	call   8020eb <nsipc_recv>
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801daf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801db2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db6:	89 04 24             	mov    %eax,(%esp)
  801db9:	e8 38 f7 ff ff       	call   8014f6 <fd_lookup>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 17                	js     801dd9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801dcb:	39 08                	cmp    %ecx,(%eax)
  801dcd:	75 05                	jne    801dd4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dcf:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd2:	eb 05                	jmp    801dd9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801dd4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 20             	sub    $0x20,%esp
  801de3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	89 04 24             	mov    %eax,(%esp)
  801deb:	e8 b7 f6 ff ff       	call   8014a7 <fd_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 21                	js     801e17 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 12 ef ff ff       	call   800d23 <sys_page_alloc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	79 0c                	jns    801e23 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801e17:	89 34 24             	mov    %esi,(%esp)
  801e1a:	e8 51 02 00 00       	call   802070 <nsipc_close>
		return r;
  801e1f:	89 d8                	mov    %ebx,%eax
  801e21:	eb 20                	jmp    801e43 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e23:	8b 15 28 40 80 00    	mov    0x804028,%edx
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e31:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801e38:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801e3b:	89 14 24             	mov    %edx,(%esp)
  801e3e:	e8 3d f6 ff ff       	call   801480 <fd2num>
}
  801e43:	83 c4 20             	add    $0x20,%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e50:	8b 45 08             	mov    0x8(%ebp),%eax
  801e53:	e8 51 ff ff ff       	call   801da9 <fd2sockid>
		return r;
  801e58:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 23                	js     801e81 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e5e:	8b 55 10             	mov    0x10(%ebp),%edx
  801e61:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e68:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e6c:	89 04 24             	mov    %eax,(%esp)
  801e6f:	e8 45 01 00 00       	call   801fb9 <nsipc_accept>
		return r;
  801e74:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 07                	js     801e81 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801e7a:	e8 5c ff ff ff       	call   801ddb <alloc_sockfd>
  801e7f:	89 c1                	mov    %eax,%ecx
}
  801e81:	89 c8                	mov    %ecx,%eax
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	e8 16 ff ff ff       	call   801da9 <fd2sockid>
  801e93:	89 c2                	mov    %eax,%edx
  801e95:	85 d2                	test   %edx,%edx
  801e97:	78 16                	js     801eaf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801e99:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea7:	89 14 24             	mov    %edx,(%esp)
  801eaa:	e8 60 01 00 00       	call   80200f <nsipc_bind>
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <shutdown>:

int
shutdown(int s, int how)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	e8 ea fe ff ff       	call   801da9 <fd2sockid>
  801ebf:	89 c2                	mov    %eax,%edx
  801ec1:	85 d2                	test   %edx,%edx
  801ec3:	78 0f                	js     801ed4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	89 14 24             	mov    %edx,(%esp)
  801ecf:	e8 7a 01 00 00       	call   80204e <nsipc_shutdown>
}
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801edc:	8b 45 08             	mov    0x8(%ebp),%eax
  801edf:	e8 c5 fe ff ff       	call   801da9 <fd2sockid>
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	85 d2                	test   %edx,%edx
  801ee8:	78 16                	js     801f00 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801eea:	8b 45 10             	mov    0x10(%ebp),%eax
  801eed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef8:	89 14 24             	mov    %edx,(%esp)
  801efb:	e8 8a 01 00 00       	call   80208a <nsipc_connect>
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <listen>:

int
listen(int s, int backlog)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	e8 99 fe ff ff       	call   801da9 <fd2sockid>
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	85 d2                	test   %edx,%edx
  801f14:	78 0f                	js     801f25 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1d:	89 14 24             	mov    %edx,(%esp)
  801f20:	e8 a4 01 00 00       	call   8020c9 <nsipc_listen>
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 98 02 00 00       	call   8021de <nsipc_socket>
  801f46:	89 c2                	mov    %eax,%edx
  801f48:	85 d2                	test   %edx,%edx
  801f4a:	78 05                	js     801f51 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801f4c:	e8 8a fe ff ff       	call   801ddb <alloc_sockfd>
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	53                   	push   %ebx
  801f57:	83 ec 14             	sub    $0x14,%esp
  801f5a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f5c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f63:	75 11                	jne    801f76 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f6c:	e8 d4 f4 ff ff       	call   801445 <ipc_find_env>
  801f71:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f7d:	00 
  801f7e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801f85:	00 
  801f86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f8a:	a1 04 50 80 00       	mov    0x805004,%eax
  801f8f:	89 04 24             	mov    %eax,(%esp)
  801f92:	e8 43 f4 ff ff       	call   8013da <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f9e:	00 
  801f9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fa6:	00 
  801fa7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fae:	e8 ad f3 ff ff       	call   801360 <ipc_recv>
}
  801fb3:	83 c4 14             	add    $0x14,%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 10             	sub    $0x10,%esp
  801fc1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fcc:	8b 06                	mov    (%esi),%eax
  801fce:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd8:	e8 76 ff ff ff       	call   801f53 <nsipc>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 23                	js     802006 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fe3:	a1 10 70 80 00       	mov    0x807010,%eax
  801fe8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fec:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801ff3:	00 
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	89 04 24             	mov    %eax,(%esp)
  801ffa:	e8 a5 ea ff ff       	call   800aa4 <memmove>
		*addrlen = ret->ret_addrlen;
  801fff:	a1 10 70 80 00       	mov    0x807010,%eax
  802004:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802006:	89 d8                	mov    %ebx,%eax
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	53                   	push   %ebx
  802013:	83 ec 14             	sub    $0x14,%esp
  802016:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802021:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802025:	8b 45 0c             	mov    0xc(%ebp),%eax
  802028:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802033:	e8 6c ea ff ff       	call   800aa4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802038:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80203e:	b8 02 00 00 00       	mov    $0x2,%eax
  802043:	e8 0b ff ff ff       	call   801f53 <nsipc>
}
  802048:	83 c4 14             	add    $0x14,%esp
  80204b:	5b                   	pop    %ebx
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802054:	8b 45 08             	mov    0x8(%ebp),%eax
  802057:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802064:	b8 03 00 00 00       	mov    $0x3,%eax
  802069:	e8 e5 fe ff ff       	call   801f53 <nsipc>
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <nsipc_close>:

int
nsipc_close(int s)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80207e:	b8 04 00 00 00       	mov    $0x4,%eax
  802083:	e8 cb fe ff ff       	call   801f53 <nsipc>
}
  802088:	c9                   	leave  
  802089:	c3                   	ret    

0080208a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	53                   	push   %ebx
  80208e:	83 ec 14             	sub    $0x14,%esp
  802091:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80209c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020ae:	e8 f1 e9 ff ff       	call   800aa4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020b3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020be:	e8 90 fe ff ff       	call   801f53 <nsipc>
}
  8020c3:	83 c4 14             	add    $0x14,%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020da:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020df:	b8 06 00 00 00       	mov    $0x6,%eax
  8020e4:	e8 6a fe ff ff       	call   801f53 <nsipc>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	56                   	push   %esi
  8020ef:	53                   	push   %ebx
  8020f0:	83 ec 10             	sub    $0x10,%esp
  8020f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020fe:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802104:	8b 45 14             	mov    0x14(%ebp),%eax
  802107:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80210c:	b8 07 00 00 00       	mov    $0x7,%eax
  802111:	e8 3d fe ff ff       	call   801f53 <nsipc>
  802116:	89 c3                	mov    %eax,%ebx
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 46                	js     802162 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80211c:	39 f0                	cmp    %esi,%eax
  80211e:	7f 07                	jg     802127 <nsipc_recv+0x3c>
  802120:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802125:	7e 24                	jle    80214b <nsipc_recv+0x60>
  802127:	c7 44 24 0c 2f 30 80 	movl   $0x80302f,0xc(%esp)
  80212e:	00 
  80212f:	c7 44 24 08 f7 2f 80 	movl   $0x802ff7,0x8(%esp)
  802136:	00 
  802137:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80213e:	00 
  80213f:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  802146:	e8 eb 05 00 00       	call   802736 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80214b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80214f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802156:	00 
  802157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215a:	89 04 24             	mov    %eax,(%esp)
  80215d:	e8 42 e9 ff ff       	call   800aa4 <memmove>
	}

	return r;
}
  802162:	89 d8                	mov    %ebx,%eax
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	53                   	push   %ebx
  80216f:	83 ec 14             	sub    $0x14,%esp
  802172:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802175:	8b 45 08             	mov    0x8(%ebp),%eax
  802178:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80217d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802183:	7e 24                	jle    8021a9 <nsipc_send+0x3e>
  802185:	c7 44 24 0c 50 30 80 	movl   $0x803050,0xc(%esp)
  80218c:	00 
  80218d:	c7 44 24 08 f7 2f 80 	movl   $0x802ff7,0x8(%esp)
  802194:	00 
  802195:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80219c:	00 
  80219d:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  8021a4:	e8 8d 05 00 00       	call   802736 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8021bb:	e8 e4 e8 ff ff       	call   800aa4 <memmove>
	nsipcbuf.send.req_size = size;
  8021c0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8021d3:	e8 7b fd ff ff       	call   801f53 <nsipc>
}
  8021d8:	83 c4 14             	add    $0x14,%esp
  8021db:	5b                   	pop    %ebx
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    

008021de <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ef:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021f7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021fc:	b8 09 00 00 00       	mov    $0x9,%eax
  802201:	e8 4d fd ff ff       	call   801f53 <nsipc>
}
  802206:	c9                   	leave  
  802207:	c3                   	ret    

00802208 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	56                   	push   %esi
  80220c:	53                   	push   %ebx
  80220d:	83 ec 10             	sub    $0x10,%esp
  802210:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802213:	8b 45 08             	mov    0x8(%ebp),%eax
  802216:	89 04 24             	mov    %eax,(%esp)
  802219:	e8 72 f2 ff ff       	call   801490 <fd2data>
  80221e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802220:	c7 44 24 04 5c 30 80 	movl   $0x80305c,0x4(%esp)
  802227:	00 
  802228:	89 1c 24             	mov    %ebx,(%esp)
  80222b:	e8 d7 e6 ff ff       	call   800907 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802230:	8b 46 04             	mov    0x4(%esi),%eax
  802233:	2b 06                	sub    (%esi),%eax
  802235:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80223b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802242:	00 00 00 
	stat->st_dev = &devpipe;
  802245:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  80224c:	40 80 00 
	return 0;
}
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	53                   	push   %ebx
  80225f:	83 ec 14             	sub    $0x14,%esp
  802262:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802265:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802269:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802270:	e8 55 eb ff ff       	call   800dca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802275:	89 1c 24             	mov    %ebx,(%esp)
  802278:	e8 13 f2 ff ff       	call   801490 <fd2data>
  80227d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802288:	e8 3d eb ff ff       	call   800dca <sys_page_unmap>
}
  80228d:	83 c4 14             	add    $0x14,%esp
  802290:	5b                   	pop    %ebx
  802291:	5d                   	pop    %ebp
  802292:	c3                   	ret    

00802293 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	57                   	push   %edi
  802297:	56                   	push   %esi
  802298:	53                   	push   %ebx
  802299:	83 ec 2c             	sub    $0x2c,%esp
  80229c:	89 c6                	mov    %eax,%esi
  80229e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022a1:	a1 08 50 80 00       	mov    0x805008,%eax
  8022a6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022a9:	89 34 24             	mov    %esi,(%esp)
  8022ac:	e8 4c 05 00 00       	call   8027fd <pageref>
  8022b1:	89 c7                	mov    %eax,%edi
  8022b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022b6:	89 04 24             	mov    %eax,(%esp)
  8022b9:	e8 3f 05 00 00       	call   8027fd <pageref>
  8022be:	39 c7                	cmp    %eax,%edi
  8022c0:	0f 94 c2             	sete   %dl
  8022c3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8022c6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8022cc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8022cf:	39 fb                	cmp    %edi,%ebx
  8022d1:	74 21                	je     8022f4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022d3:	84 d2                	test   %dl,%dl
  8022d5:	74 ca                	je     8022a1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022d7:	8b 51 58             	mov    0x58(%ecx),%edx
  8022da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022e6:	c7 04 24 63 30 80 00 	movl   $0x803063,(%esp)
  8022ed:	e8 f2 df ff ff       	call   8002e4 <cprintf>
  8022f2:	eb ad                	jmp    8022a1 <_pipeisclosed+0xe>
	}
}
  8022f4:	83 c4 2c             	add    $0x2c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    

008022fc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	57                   	push   %edi
  802300:	56                   	push   %esi
  802301:	53                   	push   %ebx
  802302:	83 ec 1c             	sub    $0x1c,%esp
  802305:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802308:	89 34 24             	mov    %esi,(%esp)
  80230b:	e8 80 f1 ff ff       	call   801490 <fd2data>
  802310:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802312:	bf 00 00 00 00       	mov    $0x0,%edi
  802317:	eb 45                	jmp    80235e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802319:	89 da                	mov    %ebx,%edx
  80231b:	89 f0                	mov    %esi,%eax
  80231d:	e8 71 ff ff ff       	call   802293 <_pipeisclosed>
  802322:	85 c0                	test   %eax,%eax
  802324:	75 41                	jne    802367 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802326:	e8 d9 e9 ff ff       	call   800d04 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80232b:	8b 43 04             	mov    0x4(%ebx),%eax
  80232e:	8b 0b                	mov    (%ebx),%ecx
  802330:	8d 51 20             	lea    0x20(%ecx),%edx
  802333:	39 d0                	cmp    %edx,%eax
  802335:	73 e2                	jae    802319 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80233a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80233e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802341:	99                   	cltd   
  802342:	c1 ea 1b             	shr    $0x1b,%edx
  802345:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802348:	83 e1 1f             	and    $0x1f,%ecx
  80234b:	29 d1                	sub    %edx,%ecx
  80234d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802351:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802355:	83 c0 01             	add    $0x1,%eax
  802358:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80235b:	83 c7 01             	add    $0x1,%edi
  80235e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802361:	75 c8                	jne    80232b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802363:	89 f8                	mov    %edi,%eax
  802365:	eb 05                	jmp    80236c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802367:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80236c:	83 c4 1c             	add    $0x1c,%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5f                   	pop    %edi
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    

00802374 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	57                   	push   %edi
  802378:	56                   	push   %esi
  802379:	53                   	push   %ebx
  80237a:	83 ec 1c             	sub    $0x1c,%esp
  80237d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802380:	89 3c 24             	mov    %edi,(%esp)
  802383:	e8 08 f1 ff ff       	call   801490 <fd2data>
  802388:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80238a:	be 00 00 00 00       	mov    $0x0,%esi
  80238f:	eb 3d                	jmp    8023ce <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802391:	85 f6                	test   %esi,%esi
  802393:	74 04                	je     802399 <devpipe_read+0x25>
				return i;
  802395:	89 f0                	mov    %esi,%eax
  802397:	eb 43                	jmp    8023dc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802399:	89 da                	mov    %ebx,%edx
  80239b:	89 f8                	mov    %edi,%eax
  80239d:	e8 f1 fe ff ff       	call   802293 <_pipeisclosed>
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	75 31                	jne    8023d7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023a6:	e8 59 e9 ff ff       	call   800d04 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023ab:	8b 03                	mov    (%ebx),%eax
  8023ad:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023b0:	74 df                	je     802391 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023b2:	99                   	cltd   
  8023b3:	c1 ea 1b             	shr    $0x1b,%edx
  8023b6:	01 d0                	add    %edx,%eax
  8023b8:	83 e0 1f             	and    $0x1f,%eax
  8023bb:	29 d0                	sub    %edx,%eax
  8023bd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8023c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023c5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023c8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023cb:	83 c6 01             	add    $0x1,%esi
  8023ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023d1:	75 d8                	jne    8023ab <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	eb 05                	jmp    8023dc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023d7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023dc:	83 c4 1c             	add    $0x1c,%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	5e                   	pop    %esi
  8023e1:	5f                   	pop    %edi
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    

008023e4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	56                   	push   %esi
  8023e8:	53                   	push   %ebx
  8023e9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ef:	89 04 24             	mov    %eax,(%esp)
  8023f2:	e8 b0 f0 ff ff       	call   8014a7 <fd_alloc>
  8023f7:	89 c2                	mov    %eax,%edx
  8023f9:	85 d2                	test   %edx,%edx
  8023fb:	0f 88 4d 01 00 00    	js     80254e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802401:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802408:	00 
  802409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802410:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802417:	e8 07 e9 ff ff       	call   800d23 <sys_page_alloc>
  80241c:	89 c2                	mov    %eax,%edx
  80241e:	85 d2                	test   %edx,%edx
  802420:	0f 88 28 01 00 00    	js     80254e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802426:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802429:	89 04 24             	mov    %eax,(%esp)
  80242c:	e8 76 f0 ff ff       	call   8014a7 <fd_alloc>
  802431:	89 c3                	mov    %eax,%ebx
  802433:	85 c0                	test   %eax,%eax
  802435:	0f 88 fe 00 00 00    	js     802539 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80243b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802442:	00 
  802443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802451:	e8 cd e8 ff ff       	call   800d23 <sys_page_alloc>
  802456:	89 c3                	mov    %eax,%ebx
  802458:	85 c0                	test   %eax,%eax
  80245a:	0f 88 d9 00 00 00    	js     802539 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802460:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802463:	89 04 24             	mov    %eax,(%esp)
  802466:	e8 25 f0 ff ff       	call   801490 <fd2data>
  80246b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80246d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802474:	00 
  802475:	89 44 24 04          	mov    %eax,0x4(%esp)
  802479:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802480:	e8 9e e8 ff ff       	call   800d23 <sys_page_alloc>
  802485:	89 c3                	mov    %eax,%ebx
  802487:	85 c0                	test   %eax,%eax
  802489:	0f 88 97 00 00 00    	js     802526 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802492:	89 04 24             	mov    %eax,(%esp)
  802495:	e8 f6 ef ff ff       	call   801490 <fd2data>
  80249a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024a1:	00 
  8024a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024ad:	00 
  8024ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b9:	e8 b9 e8 ff ff       	call   800d77 <sys_page_map>
  8024be:	89 c3                	mov    %eax,%ebx
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	78 52                	js     802516 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024c4:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024d9:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f1:	89 04 24             	mov    %eax,(%esp)
  8024f4:	e8 87 ef ff ff       	call   801480 <fd2num>
  8024f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802501:	89 04 24             	mov    %eax,(%esp)
  802504:	e8 77 ef ff ff       	call   801480 <fd2num>
  802509:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80250f:	b8 00 00 00 00       	mov    $0x0,%eax
  802514:	eb 38                	jmp    80254e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802521:	e8 a4 e8 ff ff       	call   800dca <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802534:	e8 91 e8 ff ff       	call   800dca <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802540:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802547:	e8 7e e8 ff ff       	call   800dca <sys_page_unmap>
  80254c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80254e:	83 c4 30             	add    $0x30,%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    

00802555 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80255b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80255e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802562:	8b 45 08             	mov    0x8(%ebp),%eax
  802565:	89 04 24             	mov    %eax,(%esp)
  802568:	e8 89 ef ff ff       	call   8014f6 <fd_lookup>
  80256d:	89 c2                	mov    %eax,%edx
  80256f:	85 d2                	test   %edx,%edx
  802571:	78 15                	js     802588 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802576:	89 04 24             	mov    %eax,(%esp)
  802579:	e8 12 ef ff ff       	call   801490 <fd2data>
	return _pipeisclosed(fd, p);
  80257e:	89 c2                	mov    %eax,%edx
  802580:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802583:	e8 0b fd ff ff       	call   802293 <_pipeisclosed>
}
  802588:	c9                   	leave  
  802589:	c3                   	ret    
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802590:	55                   	push   %ebp
  802591:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    

0080259a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80259a:	55                   	push   %ebp
  80259b:	89 e5                	mov    %esp,%ebp
  80259d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025a0:	c7 44 24 04 7b 30 80 	movl   $0x80307b,0x4(%esp)
  8025a7:	00 
  8025a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ab:	89 04 24             	mov    %eax,(%esp)
  8025ae:	e8 54 e3 ff ff       	call   800907 <strcpy>
	return 0;
}
  8025b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b8:	c9                   	leave  
  8025b9:	c3                   	ret    

008025ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	57                   	push   %edi
  8025be:	56                   	push   %esi
  8025bf:	53                   	push   %ebx
  8025c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025d1:	eb 31                	jmp    802604 <devcons_write+0x4a>
		m = n - tot;
  8025d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8025d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025d8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025e0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025e3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025e7:	03 45 0c             	add    0xc(%ebp),%eax
  8025ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ee:	89 3c 24             	mov    %edi,(%esp)
  8025f1:	e8 ae e4 ff ff       	call   800aa4 <memmove>
		sys_cputs(buf, m);
  8025f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025fa:	89 3c 24             	mov    %edi,(%esp)
  8025fd:	e8 54 e6 ff ff       	call   800c56 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802602:	01 f3                	add    %esi,%ebx
  802604:	89 d8                	mov    %ebx,%eax
  802606:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802609:	72 c8                	jb     8025d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80260b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802611:	5b                   	pop    %ebx
  802612:	5e                   	pop    %esi
  802613:	5f                   	pop    %edi
  802614:	5d                   	pop    %ebp
  802615:	c3                   	ret    

00802616 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
  802619:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80261c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802621:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802625:	75 07                	jne    80262e <devcons_read+0x18>
  802627:	eb 2a                	jmp    802653 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802629:	e8 d6 e6 ff ff       	call   800d04 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80262e:	66 90                	xchg   %ax,%ax
  802630:	e8 3f e6 ff ff       	call   800c74 <sys_cgetc>
  802635:	85 c0                	test   %eax,%eax
  802637:	74 f0                	je     802629 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802639:	85 c0                	test   %eax,%eax
  80263b:	78 16                	js     802653 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80263d:	83 f8 04             	cmp    $0x4,%eax
  802640:	74 0c                	je     80264e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802642:	8b 55 0c             	mov    0xc(%ebp),%edx
  802645:	88 02                	mov    %al,(%edx)
	return 1;
  802647:	b8 01 00 00 00       	mov    $0x1,%eax
  80264c:	eb 05                	jmp    802653 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80264e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802653:	c9                   	leave  
  802654:	c3                   	ret    

00802655 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802655:	55                   	push   %ebp
  802656:	89 e5                	mov    %esp,%ebp
  802658:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80265b:	8b 45 08             	mov    0x8(%ebp),%eax
  80265e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802661:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802668:	00 
  802669:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80266c:	89 04 24             	mov    %eax,(%esp)
  80266f:	e8 e2 e5 ff ff       	call   800c56 <sys_cputs>
}
  802674:	c9                   	leave  
  802675:	c3                   	ret    

00802676 <getchar>:

int
getchar(void)
{
  802676:	55                   	push   %ebp
  802677:	89 e5                	mov    %esp,%ebp
  802679:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80267c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802683:	00 
  802684:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80268b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802692:	e8 f3 f0 ff ff       	call   80178a <read>
	if (r < 0)
  802697:	85 c0                	test   %eax,%eax
  802699:	78 0f                	js     8026aa <getchar+0x34>
		return r;
	if (r < 1)
  80269b:	85 c0                	test   %eax,%eax
  80269d:	7e 06                	jle    8026a5 <getchar+0x2f>
		return -E_EOF;
	return c;
  80269f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026a3:	eb 05                	jmp    8026aa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026aa:	c9                   	leave  
  8026ab:	c3                   	ret    

008026ac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026ac:	55                   	push   %ebp
  8026ad:	89 e5                	mov    %esp,%ebp
  8026af:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026bc:	89 04 24             	mov    %eax,(%esp)
  8026bf:	e8 32 ee ff ff       	call   8014f6 <fd_lookup>
  8026c4:	85 c0                	test   %eax,%eax
  8026c6:	78 11                	js     8026d9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cb:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8026d1:	39 10                	cmp    %edx,(%eax)
  8026d3:	0f 94 c0             	sete   %al
  8026d6:	0f b6 c0             	movzbl %al,%eax
}
  8026d9:	c9                   	leave  
  8026da:	c3                   	ret    

008026db <opencons>:

int
opencons(void)
{
  8026db:	55                   	push   %ebp
  8026dc:	89 e5                	mov    %esp,%ebp
  8026de:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026e4:	89 04 24             	mov    %eax,(%esp)
  8026e7:	e8 bb ed ff ff       	call   8014a7 <fd_alloc>
		return r;
  8026ec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026ee:	85 c0                	test   %eax,%eax
  8026f0:	78 40                	js     802732 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026f9:	00 
  8026fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802701:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802708:	e8 16 e6 ff ff       	call   800d23 <sys_page_alloc>
		return r;
  80270d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80270f:	85 c0                	test   %eax,%eax
  802711:	78 1f                	js     802732 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802713:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80271e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802721:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802728:	89 04 24             	mov    %eax,(%esp)
  80272b:	e8 50 ed ff ff       	call   801480 <fd2num>
  802730:	89 c2                	mov    %eax,%edx
}
  802732:	89 d0                	mov    %edx,%eax
  802734:	c9                   	leave  
  802735:	c3                   	ret    

00802736 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	56                   	push   %esi
  80273a:	53                   	push   %ebx
  80273b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80273e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802741:	8b 35 08 40 80 00    	mov    0x804008,%esi
  802747:	e8 99 e5 ff ff       	call   800ce5 <sys_getenvid>
  80274c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80274f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802753:	8b 55 08             	mov    0x8(%ebp),%edx
  802756:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80275a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80275e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802762:	c7 04 24 88 30 80 00 	movl   $0x803088,(%esp)
  802769:	e8 76 db ff ff       	call   8002e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80276e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802772:	8b 45 10             	mov    0x10(%ebp),%eax
  802775:	89 04 24             	mov    %eax,(%esp)
  802778:	e8 06 db ff ff       	call   800283 <vcprintf>
	cprintf("\n");
  80277d:	c7 04 24 74 30 80 00 	movl   $0x803074,(%esp)
  802784:	e8 5b db ff ff       	call   8002e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802789:	cc                   	int3   
  80278a:	eb fd                	jmp    802789 <_panic+0x53>

0080278c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80278c:	55                   	push   %ebp
  80278d:	89 e5                	mov    %esp,%ebp
  80278f:	53                   	push   %ebx
  802790:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802793:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80279a:	75 2f                	jne    8027cb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80279c:	e8 44 e5 ff ff       	call   800ce5 <sys_getenvid>
  8027a1:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  8027a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027aa:	00 
  8027ab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8027b2:	ee 
  8027b3:	89 04 24             	mov    %eax,(%esp)
  8027b6:	e8 68 e5 ff ff       	call   800d23 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  8027bb:	c7 44 24 04 d9 27 80 	movl   $0x8027d9,0x4(%esp)
  8027c2:	00 
  8027c3:	89 1c 24             	mov    %ebx,(%esp)
  8027c6:	e8 f8 e6 ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ce:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8027d3:	83 c4 14             	add    $0x14,%esp
  8027d6:	5b                   	pop    %ebx
  8027d7:	5d                   	pop    %ebp
  8027d8:	c3                   	ret    

008027d9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027d9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027da:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8027df:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027e1:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8027e4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8027e9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8027ed:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8027f1:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8027f3:	83 c4 08             	add    $0x8,%esp
	popal
  8027f6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8027f7:	83 c4 04             	add    $0x4,%esp
	popfl
  8027fa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027fb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027fc:	c3                   	ret    

008027fd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027fd:	55                   	push   %ebp
  8027fe:	89 e5                	mov    %esp,%ebp
  802800:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802803:	89 d0                	mov    %edx,%eax
  802805:	c1 e8 16             	shr    $0x16,%eax
  802808:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80280f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802814:	f6 c1 01             	test   $0x1,%cl
  802817:	74 1d                	je     802836 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802819:	c1 ea 0c             	shr    $0xc,%edx
  80281c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802823:	f6 c2 01             	test   $0x1,%dl
  802826:	74 0e                	je     802836 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802828:	c1 ea 0c             	shr    $0xc,%edx
  80282b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802832:	ef 
  802833:	0f b7 c0             	movzwl %ax,%eax
}
  802836:	5d                   	pop    %ebp
  802837:	c3                   	ret    
  802838:	66 90                	xchg   %ax,%ax
  80283a:	66 90                	xchg   %ax,%ax
  80283c:	66 90                	xchg   %ax,%ax
  80283e:	66 90                	xchg   %ax,%ax

00802840 <__udivdi3>:
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	83 ec 0c             	sub    $0xc,%esp
  802846:	8b 44 24 28          	mov    0x28(%esp),%eax
  80284a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80284e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802852:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802856:	85 c0                	test   %eax,%eax
  802858:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80285c:	89 ea                	mov    %ebp,%edx
  80285e:	89 0c 24             	mov    %ecx,(%esp)
  802861:	75 2d                	jne    802890 <__udivdi3+0x50>
  802863:	39 e9                	cmp    %ebp,%ecx
  802865:	77 61                	ja     8028c8 <__udivdi3+0x88>
  802867:	85 c9                	test   %ecx,%ecx
  802869:	89 ce                	mov    %ecx,%esi
  80286b:	75 0b                	jne    802878 <__udivdi3+0x38>
  80286d:	b8 01 00 00 00       	mov    $0x1,%eax
  802872:	31 d2                	xor    %edx,%edx
  802874:	f7 f1                	div    %ecx
  802876:	89 c6                	mov    %eax,%esi
  802878:	31 d2                	xor    %edx,%edx
  80287a:	89 e8                	mov    %ebp,%eax
  80287c:	f7 f6                	div    %esi
  80287e:	89 c5                	mov    %eax,%ebp
  802880:	89 f8                	mov    %edi,%eax
  802882:	f7 f6                	div    %esi
  802884:	89 ea                	mov    %ebp,%edx
  802886:	83 c4 0c             	add    $0xc,%esp
  802889:	5e                   	pop    %esi
  80288a:	5f                   	pop    %edi
  80288b:	5d                   	pop    %ebp
  80288c:	c3                   	ret    
  80288d:	8d 76 00             	lea    0x0(%esi),%esi
  802890:	39 e8                	cmp    %ebp,%eax
  802892:	77 24                	ja     8028b8 <__udivdi3+0x78>
  802894:	0f bd e8             	bsr    %eax,%ebp
  802897:	83 f5 1f             	xor    $0x1f,%ebp
  80289a:	75 3c                	jne    8028d8 <__udivdi3+0x98>
  80289c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8028a0:	39 34 24             	cmp    %esi,(%esp)
  8028a3:	0f 86 9f 00 00 00    	jbe    802948 <__udivdi3+0x108>
  8028a9:	39 d0                	cmp    %edx,%eax
  8028ab:	0f 82 97 00 00 00    	jb     802948 <__udivdi3+0x108>
  8028b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028b8:	31 d2                	xor    %edx,%edx
  8028ba:	31 c0                	xor    %eax,%eax
  8028bc:	83 c4 0c             	add    $0xc,%esp
  8028bf:	5e                   	pop    %esi
  8028c0:	5f                   	pop    %edi
  8028c1:	5d                   	pop    %ebp
  8028c2:	c3                   	ret    
  8028c3:	90                   	nop
  8028c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028c8:	89 f8                	mov    %edi,%eax
  8028ca:	f7 f1                	div    %ecx
  8028cc:	31 d2                	xor    %edx,%edx
  8028ce:	83 c4 0c             	add    $0xc,%esp
  8028d1:	5e                   	pop    %esi
  8028d2:	5f                   	pop    %edi
  8028d3:	5d                   	pop    %ebp
  8028d4:	c3                   	ret    
  8028d5:	8d 76 00             	lea    0x0(%esi),%esi
  8028d8:	89 e9                	mov    %ebp,%ecx
  8028da:	8b 3c 24             	mov    (%esp),%edi
  8028dd:	d3 e0                	shl    %cl,%eax
  8028df:	89 c6                	mov    %eax,%esi
  8028e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8028e6:	29 e8                	sub    %ebp,%eax
  8028e8:	89 c1                	mov    %eax,%ecx
  8028ea:	d3 ef                	shr    %cl,%edi
  8028ec:	89 e9                	mov    %ebp,%ecx
  8028ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8028f2:	8b 3c 24             	mov    (%esp),%edi
  8028f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8028f9:	89 d6                	mov    %edx,%esi
  8028fb:	d3 e7                	shl    %cl,%edi
  8028fd:	89 c1                	mov    %eax,%ecx
  8028ff:	89 3c 24             	mov    %edi,(%esp)
  802902:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802906:	d3 ee                	shr    %cl,%esi
  802908:	89 e9                	mov    %ebp,%ecx
  80290a:	d3 e2                	shl    %cl,%edx
  80290c:	89 c1                	mov    %eax,%ecx
  80290e:	d3 ef                	shr    %cl,%edi
  802910:	09 d7                	or     %edx,%edi
  802912:	89 f2                	mov    %esi,%edx
  802914:	89 f8                	mov    %edi,%eax
  802916:	f7 74 24 08          	divl   0x8(%esp)
  80291a:	89 d6                	mov    %edx,%esi
  80291c:	89 c7                	mov    %eax,%edi
  80291e:	f7 24 24             	mull   (%esp)
  802921:	39 d6                	cmp    %edx,%esi
  802923:	89 14 24             	mov    %edx,(%esp)
  802926:	72 30                	jb     802958 <__udivdi3+0x118>
  802928:	8b 54 24 04          	mov    0x4(%esp),%edx
  80292c:	89 e9                	mov    %ebp,%ecx
  80292e:	d3 e2                	shl    %cl,%edx
  802930:	39 c2                	cmp    %eax,%edx
  802932:	73 05                	jae    802939 <__udivdi3+0xf9>
  802934:	3b 34 24             	cmp    (%esp),%esi
  802937:	74 1f                	je     802958 <__udivdi3+0x118>
  802939:	89 f8                	mov    %edi,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	e9 7a ff ff ff       	jmp    8028bc <__udivdi3+0x7c>
  802942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802948:	31 d2                	xor    %edx,%edx
  80294a:	b8 01 00 00 00       	mov    $0x1,%eax
  80294f:	e9 68 ff ff ff       	jmp    8028bc <__udivdi3+0x7c>
  802954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802958:	8d 47 ff             	lea    -0x1(%edi),%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	83 c4 0c             	add    $0xc,%esp
  802960:	5e                   	pop    %esi
  802961:	5f                   	pop    %edi
  802962:	5d                   	pop    %ebp
  802963:	c3                   	ret    
  802964:	66 90                	xchg   %ax,%ax
  802966:	66 90                	xchg   %ax,%ax
  802968:	66 90                	xchg   %ax,%ax
  80296a:	66 90                	xchg   %ax,%ax
  80296c:	66 90                	xchg   %ax,%ax
  80296e:	66 90                	xchg   %ax,%ax

00802970 <__umoddi3>:
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	83 ec 14             	sub    $0x14,%esp
  802976:	8b 44 24 28          	mov    0x28(%esp),%eax
  80297a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80297e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802982:	89 c7                	mov    %eax,%edi
  802984:	89 44 24 04          	mov    %eax,0x4(%esp)
  802988:	8b 44 24 30          	mov    0x30(%esp),%eax
  80298c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802990:	89 34 24             	mov    %esi,(%esp)
  802993:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802997:	85 c0                	test   %eax,%eax
  802999:	89 c2                	mov    %eax,%edx
  80299b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80299f:	75 17                	jne    8029b8 <__umoddi3+0x48>
  8029a1:	39 fe                	cmp    %edi,%esi
  8029a3:	76 4b                	jbe    8029f0 <__umoddi3+0x80>
  8029a5:	89 c8                	mov    %ecx,%eax
  8029a7:	89 fa                	mov    %edi,%edx
  8029a9:	f7 f6                	div    %esi
  8029ab:	89 d0                	mov    %edx,%eax
  8029ad:	31 d2                	xor    %edx,%edx
  8029af:	83 c4 14             	add    $0x14,%esp
  8029b2:	5e                   	pop    %esi
  8029b3:	5f                   	pop    %edi
  8029b4:	5d                   	pop    %ebp
  8029b5:	c3                   	ret    
  8029b6:	66 90                	xchg   %ax,%ax
  8029b8:	39 f8                	cmp    %edi,%eax
  8029ba:	77 54                	ja     802a10 <__umoddi3+0xa0>
  8029bc:	0f bd e8             	bsr    %eax,%ebp
  8029bf:	83 f5 1f             	xor    $0x1f,%ebp
  8029c2:	75 5c                	jne    802a20 <__umoddi3+0xb0>
  8029c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029c8:	39 3c 24             	cmp    %edi,(%esp)
  8029cb:	0f 87 e7 00 00 00    	ja     802ab8 <__umoddi3+0x148>
  8029d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029d5:	29 f1                	sub    %esi,%ecx
  8029d7:	19 c7                	sbb    %eax,%edi
  8029d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029e9:	83 c4 14             	add    $0x14,%esp
  8029ec:	5e                   	pop    %esi
  8029ed:	5f                   	pop    %edi
  8029ee:	5d                   	pop    %ebp
  8029ef:	c3                   	ret    
  8029f0:	85 f6                	test   %esi,%esi
  8029f2:	89 f5                	mov    %esi,%ebp
  8029f4:	75 0b                	jne    802a01 <__umoddi3+0x91>
  8029f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029fb:	31 d2                	xor    %edx,%edx
  8029fd:	f7 f6                	div    %esi
  8029ff:	89 c5                	mov    %eax,%ebp
  802a01:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a05:	31 d2                	xor    %edx,%edx
  802a07:	f7 f5                	div    %ebp
  802a09:	89 c8                	mov    %ecx,%eax
  802a0b:	f7 f5                	div    %ebp
  802a0d:	eb 9c                	jmp    8029ab <__umoddi3+0x3b>
  802a0f:	90                   	nop
  802a10:	89 c8                	mov    %ecx,%eax
  802a12:	89 fa                	mov    %edi,%edx
  802a14:	83 c4 14             	add    $0x14,%esp
  802a17:	5e                   	pop    %esi
  802a18:	5f                   	pop    %edi
  802a19:	5d                   	pop    %ebp
  802a1a:	c3                   	ret    
  802a1b:	90                   	nop
  802a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a20:	8b 04 24             	mov    (%esp),%eax
  802a23:	be 20 00 00 00       	mov    $0x20,%esi
  802a28:	89 e9                	mov    %ebp,%ecx
  802a2a:	29 ee                	sub    %ebp,%esi
  802a2c:	d3 e2                	shl    %cl,%edx
  802a2e:	89 f1                	mov    %esi,%ecx
  802a30:	d3 e8                	shr    %cl,%eax
  802a32:	89 e9                	mov    %ebp,%ecx
  802a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a38:	8b 04 24             	mov    (%esp),%eax
  802a3b:	09 54 24 04          	or     %edx,0x4(%esp)
  802a3f:	89 fa                	mov    %edi,%edx
  802a41:	d3 e0                	shl    %cl,%eax
  802a43:	89 f1                	mov    %esi,%ecx
  802a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a49:	8b 44 24 10          	mov    0x10(%esp),%eax
  802a4d:	d3 ea                	shr    %cl,%edx
  802a4f:	89 e9                	mov    %ebp,%ecx
  802a51:	d3 e7                	shl    %cl,%edi
  802a53:	89 f1                	mov    %esi,%ecx
  802a55:	d3 e8                	shr    %cl,%eax
  802a57:	89 e9                	mov    %ebp,%ecx
  802a59:	09 f8                	or     %edi,%eax
  802a5b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802a5f:	f7 74 24 04          	divl   0x4(%esp)
  802a63:	d3 e7                	shl    %cl,%edi
  802a65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a69:	89 d7                	mov    %edx,%edi
  802a6b:	f7 64 24 08          	mull   0x8(%esp)
  802a6f:	39 d7                	cmp    %edx,%edi
  802a71:	89 c1                	mov    %eax,%ecx
  802a73:	89 14 24             	mov    %edx,(%esp)
  802a76:	72 2c                	jb     802aa4 <__umoddi3+0x134>
  802a78:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802a7c:	72 22                	jb     802aa0 <__umoddi3+0x130>
  802a7e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a82:	29 c8                	sub    %ecx,%eax
  802a84:	19 d7                	sbb    %edx,%edi
  802a86:	89 e9                	mov    %ebp,%ecx
  802a88:	89 fa                	mov    %edi,%edx
  802a8a:	d3 e8                	shr    %cl,%eax
  802a8c:	89 f1                	mov    %esi,%ecx
  802a8e:	d3 e2                	shl    %cl,%edx
  802a90:	89 e9                	mov    %ebp,%ecx
  802a92:	d3 ef                	shr    %cl,%edi
  802a94:	09 d0                	or     %edx,%eax
  802a96:	89 fa                	mov    %edi,%edx
  802a98:	83 c4 14             	add    $0x14,%esp
  802a9b:	5e                   	pop    %esi
  802a9c:	5f                   	pop    %edi
  802a9d:	5d                   	pop    %ebp
  802a9e:	c3                   	ret    
  802a9f:	90                   	nop
  802aa0:	39 d7                	cmp    %edx,%edi
  802aa2:	75 da                	jne    802a7e <__umoddi3+0x10e>
  802aa4:	8b 14 24             	mov    (%esp),%edx
  802aa7:	89 c1                	mov    %eax,%ecx
  802aa9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802aad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802ab1:	eb cb                	jmp    802a7e <__umoddi3+0x10e>
  802ab3:	90                   	nop
  802ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ab8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802abc:	0f 82 0f ff ff ff    	jb     8029d1 <__umoddi3+0x61>
  802ac2:	e9 1a ff ff ff       	jmp    8029e1 <__umoddi3+0x71>
