
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 1d 02 00 00       	call   80024e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 91 0d 00 00       	call   800df3 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 e0 27 80 	movl   $0x8027e0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  800081:	e8 29 02 00 00       	call   8002af <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 9d 0d 00 00       	call   800e47 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 03 28 80 	movl   $0x802803,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  8000c9:	e8 e1 01 00 00       	call   8002af <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 8e 0a 00 00       	call   800b74 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 a0 0d 00 00       	call   800e9a <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  800119:	e8 91 01 00 00       	call   8002af <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 27 28 80 	movl   $0x802827,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  800155:	e8 55 01 00 00       	call   8002af <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1e                	jne    80017e <dumbfork+0x59>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 50 0c 00 00       	call   800db5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	eb 71                	jmp    8001ef <dumbfork+0xca>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800185:	eb 13                	jmp    80019a <dumbfork+0x75>
		duppage(envid, addr);
  800187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 ad fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019d:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  8001a3:	72 e2                	jb     800187 <dumbfork+0x62>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 87 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 24 0d 00 00       	call   800eed <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xc8>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 37 28 80 	movl   $0x802837,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  8001e8:	e8 c2 00 00 00       	call   8002af <_panic>

	return envid;
  8001ed:	89 f0                	mov    %esi,%eax
}
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fe:	e8 22 ff ff ff       	call   800125 <dumbfork>
  800203:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	eb 28                	jmp    800234 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020c:	b8 55 28 80 00       	mov    $0x802855,%eax
  800211:	eb 05                	jmp    800218 <umain+0x22>
  800213:	b8 4e 28 80 00       	mov    $0x80284e,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800220:	c7 04 24 5b 28 80 00 	movl   $0x80285b,(%esp)
  800227:	e8 7c 01 00 00       	call   8003a8 <cprintf>
		sys_yield();
  80022c:	e8 a3 0b 00 00       	call   800dd4 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	83 c3 01             	add    $0x1,%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	75 0a                	jne    800242 <umain+0x4c>
  800238:	83 fb 13             	cmp    $0x13,%ebx
  80023b:	7e cf                	jle    80020c <umain+0x16>
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	eb 05                	jmp    800247 <umain+0x51>
  800242:	83 fb 09             	cmp    $0x9,%ebx
  800245:	7e cc                	jle    800213 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 10             	sub    $0x10,%esp
  800256:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800259:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80025c:	e8 54 0b 00 00       	call   800db5 <sys_getenvid>
  800261:	25 ff 03 00 00       	and    $0x3ff,%eax
  800266:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800269:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80026e:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800273:	85 db                	test   %ebx,%ebx
  800275:	7e 07                	jle    80027e <libmain+0x30>
		binaryname = argv[0];
  800277:	8b 06                	mov    (%esi),%eax
  800279:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80027e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800282:	89 1c 24             	mov    %ebx,(%esp)
  800285:	e8 6c ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  80028a:	e8 07 00 00 00       	call   800296 <exit>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80029c:	e8 59 10 00 00       	call   8012fa <close_all>
	sys_env_destroy(0);
  8002a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a8:	e8 b6 0a 00 00       	call   800d63 <sys_env_destroy>
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002c0:	e8 f0 0a 00 00       	call   800db5 <sys_getenvid>
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002db:	c7 04 24 78 28 80 00 	movl   $0x802878,(%esp)
  8002e2:	e8 c1 00 00 00       	call   8003a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 51 00 00 00       	call   800347 <vcprintf>
	cprintf("\n");
  8002f6:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  8002fd:	e8 a6 00 00 00       	call   8003a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800302:	cc                   	int3   
  800303:	eb fd                	jmp    800302 <_panic+0x53>

00800305 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	53                   	push   %ebx
  800309:	83 ec 14             	sub    $0x14,%esp
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030f:	8b 13                	mov    (%ebx),%edx
  800311:	8d 42 01             	lea    0x1(%edx),%eax
  800314:	89 03                	mov    %eax,(%ebx)
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800322:	75 19                	jne    80033d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800324:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032b:	00 
  80032c:	8d 43 08             	lea    0x8(%ebx),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	e8 ef 09 00 00       	call   800d26 <sys_cputs>
		b->idx = 0;
  800337:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80033d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	5b                   	pop    %ebx
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800350:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800357:	00 00 00 
	b.cnt = 0;
  80035a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800361:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037c:	c7 04 24 05 03 80 00 	movl   $0x800305,(%esp)
  800383:	e8 b6 01 00 00       	call   80053e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 86 09 00 00       	call   800d26 <sys_cputs>

	return b.cnt;
}
  8003a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 87 ff ff ff       	call   800347 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    
  8003c2:	66 90                	xchg   %ax,%ax
  8003c4:	66 90                	xchg   %ax,%ax
  8003c6:	66 90                	xchg   %ax,%ax
  8003c8:	66 90                	xchg   %ax,%ax
  8003ca:	66 90                	xchg   %ax,%ax
  8003cc:	66 90                	xchg   %ax,%ax
  8003ce:	66 90                	xchg   %ax,%ax

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 c3                	mov    %eax,%ebx
  8003e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003fd:	39 d9                	cmp    %ebx,%ecx
  8003ff:	72 05                	jb     800406 <printnum+0x36>
  800401:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800404:	77 69                	ja     80046f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800409:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80040d:	83 ee 01             	sub    $0x1,%esi
  800410:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	8b 44 24 08          	mov    0x8(%esp),%eax
  80041c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800420:	89 c3                	mov    %eax,%ebx
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800427:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80042a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80042e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800432:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043f:	e8 fc 20 00 00       	call   802540 <__udivdi3>
  800444:	89 d9                	mov    %ebx,%ecx
  800446:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80044a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	89 54 24 04          	mov    %edx,0x4(%esp)
  800455:	89 fa                	mov    %edi,%edx
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	e8 71 ff ff ff       	call   8003d0 <printnum>
  80045f:	eb 1b                	jmp    80047c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800465:	8b 45 18             	mov    0x18(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff d3                	call   *%ebx
  80046d:	eb 03                	jmp    800472 <printnum+0xa2>
  80046f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 ee 01             	sub    $0x1,%esi
  800475:	85 f6                	test   %esi,%esi
  800477:	7f e8                	jg     800461 <printnum+0x91>
  800479:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800480:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800484:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800487:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	e8 cc 21 00 00       	call   802670 <__umoddi3>
  8004a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a8:	0f be 80 9b 28 80 00 	movsbl 0x80289b(%eax),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b5:	ff d0                	call   *%eax
}
  8004b7:	83 c4 3c             	add    $0x3c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c2:	83 fa 01             	cmp    $0x1,%edx
  8004c5:	7e 0e                	jle    8004d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	8b 52 04             	mov    0x4(%edx),%edx
  8004d3:	eb 22                	jmp    8004f7 <getuint+0x38>
	else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 10                	je     8004e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	eb 0e                	jmp    8004f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 02                	mov    (%edx),%eax
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	88 02                	mov    %al,(%edx)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 10             	mov    0x10(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 02 00 00 00       	call   80053e <vprintfmt>
	va_end(ap);
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 3c             	sub    $0x3c,%esp
  800547:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80054a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80054d:	eb 14                	jmp    800563 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 84 b3 03 00 00    	je     80090a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800557:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800561:	89 f3                	mov    %esi,%ebx
  800563:	8d 73 01             	lea    0x1(%ebx),%esi
  800566:	0f b6 03             	movzbl (%ebx),%eax
  800569:	83 f8 25             	cmp    $0x25,%eax
  80056c:	75 e1                	jne    80054f <vprintfmt+0x11>
  80056e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800572:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800579:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800580:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	eb 1d                	jmp    8005ab <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800590:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800594:	eb 15                	jmp    8005ab <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800598:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80059c:	eb 0d                	jmp    8005ab <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80059e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005ae:	0f b6 0e             	movzbl (%esi),%ecx
  8005b1:	0f b6 c1             	movzbl %cl,%eax
  8005b4:	83 e9 23             	sub    $0x23,%ecx
  8005b7:	80 f9 55             	cmp    $0x55,%cl
  8005ba:	0f 87 2a 03 00 00    	ja     8008ea <vprintfmt+0x3ac>
  8005c0:	0f b6 c9             	movzbl %cl,%ecx
  8005c3:	ff 24 8d e0 29 80 00 	jmp    *0x8029e0(,%ecx,4)
  8005ca:	89 de                	mov    %ebx,%esi
  8005cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005d4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005d8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005db:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005de:	83 fb 09             	cmp    $0x9,%ebx
  8005e1:	77 36                	ja     800619 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e6:	eb e9                	jmp    8005d1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f8:	eb 22                	jmp    80061c <vprintfmt+0xde>
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	85 c9                	test   %ecx,%ecx
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	0f 49 c1             	cmovns %ecx,%eax
  800607:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	89 de                	mov    %ebx,%esi
  80060c:	eb 9d                	jmp    8005ab <vprintfmt+0x6d>
  80060e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800610:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800617:	eb 92                	jmp    8005ab <vprintfmt+0x6d>
  800619:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80061c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800620:	79 89                	jns    8005ab <vprintfmt+0x6d>
  800622:	e9 77 ff ff ff       	jmp    80059e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800627:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062c:	e9 7a ff ff ff       	jmp    8005ab <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
			break;
  800646:	e9 18 ff ff ff       	jmp    800563 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	8b 00                	mov    (%eax),%eax
  800656:	99                   	cltd   
  800657:	31 d0                	xor    %edx,%eax
  800659:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065b:	83 f8 0f             	cmp    $0xf,%eax
  80065e:	7f 0b                	jg     80066b <vprintfmt+0x12d>
  800660:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800667:	85 d2                	test   %edx,%edx
  800669:	75 20                	jne    80068b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80066b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80066f:	c7 44 24 08 b3 28 80 	movl   $0x8028b3,0x8(%esp)
  800676:	00 
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 90 fe ff ff       	call   800516 <printfmt>
  800686:	e9 d8 fe ff ff       	jmp    800563 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80068b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068f:	c7 44 24 08 75 2c 80 	movl   $0x802c75,0x8(%esp)
  800696:	00 
  800697:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	e8 70 fe ff ff       	call   800516 <printfmt>
  8006a6:	e9 b8 fe ff ff       	jmp    800563 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006bf:	85 f6                	test   %esi,%esi
  8006c1:	b8 ac 28 80 00       	mov    $0x8028ac,%eax
  8006c6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006c9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006cd:	0f 84 97 00 00 00    	je     80076a <vprintfmt+0x22c>
  8006d3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006d7:	0f 8e 9b 00 00 00    	jle    800778 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e1:	89 34 24             	mov    %esi,(%esp)
  8006e4:	e8 cf 02 00 00       	call   8009b8 <strnlen>
  8006e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ec:	29 c2                	sub    %eax,%edx
  8006ee:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800701:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800703:	eb 0f                	jmp    800714 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	85 db                	test   %ebx,%ebx
  800716:	7f ed                	jg     800705 <vprintfmt+0x1c7>
  800718:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80071b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80071e:	85 d2                	test   %edx,%edx
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	0f 49 c2             	cmovns %edx,%eax
  800728:	29 c2                	sub    %eax,%edx
  80072a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80072d:	89 d7                	mov    %edx,%edi
  80072f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800732:	eb 50                	jmp    800784 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800738:	74 1e                	je     800758 <vprintfmt+0x21a>
  80073a:	0f be d2             	movsbl %dl,%edx
  80073d:	83 ea 20             	sub    $0x20,%edx
  800740:	83 fa 5e             	cmp    $0x5e,%edx
  800743:	76 13                	jbe    800758 <vprintfmt+0x21a>
					putch('?', putdat);
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
  800756:	eb 0d                	jmp    800765 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	83 ef 01             	sub    $0x1,%edi
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x246>
  80076a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80076d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800770:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800776:	eb 0c                	jmp    800784 <vprintfmt+0x246>
  800778:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80077b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80077e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800781:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800784:	83 c6 01             	add    $0x1,%esi
  800787:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80078b:	0f be c2             	movsbl %dl,%eax
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 27                	je     8007b9 <vprintfmt+0x27b>
  800792:	85 db                	test   %ebx,%ebx
  800794:	78 9e                	js     800734 <vprintfmt+0x1f6>
  800796:	83 eb 01             	sub    $0x1,%ebx
  800799:	79 99                	jns    800734 <vprintfmt+0x1f6>
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	89 c3                	mov    %eax,%ebx
  8007a5:	eb 1a                	jmp    8007c1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b4:	83 eb 01             	sub    $0x1,%ebx
  8007b7:	eb 08                	jmp    8007c1 <vprintfmt+0x283>
  8007b9:	89 fb                	mov    %edi,%ebx
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007c1:	85 db                	test   %ebx,%ebx
  8007c3:	7f e2                	jg     8007a7 <vprintfmt+0x269>
  8007c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007cb:	e9 93 fd ff ff       	jmp    800563 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d0:	83 fa 01             	cmp    $0x1,%edx
  8007d3:	7e 16                	jle    8007eb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 08             	lea    0x8(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 50 04             	mov    0x4(%eax),%edx
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007e9:	eb 32                	jmp    80081d <vprintfmt+0x2df>
	else if (lflag)
  8007eb:	85 d2                	test   %edx,%edx
  8007ed:	74 18                	je     800807 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 30                	mov    (%eax),%esi
  8007fa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	c1 f8 1f             	sar    $0x1f,%eax
  800802:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800805:	eb 16                	jmp    80081d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 30                	mov    (%eax),%esi
  800812:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800815:	89 f0                	mov    %esi,%eax
  800817:	c1 f8 1f             	sar    $0x1f,%eax
  80081a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800823:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800828:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80082c:	0f 89 80 00 00 00    	jns    8008b2 <vprintfmt+0x374>
				putch('-', putdat);
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800843:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800846:	f7 d8                	neg    %eax
  800848:	83 d2 00             	adc    $0x0,%edx
  80084b:	f7 da                	neg    %edx
			}
			base = 10;
  80084d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800852:	eb 5e                	jmp    8008b2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
  800857:	e8 63 fc ff ff       	call   8004bf <getuint>
			base = 10;
  80085c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800861:	eb 4f                	jmp    8008b2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 54 fc ff ff       	call   8004bf <getuint>
			base = 8;
  80086b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800870:	eb 40                	jmp    8008b2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800876:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800880:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800884:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8d 50 04             	lea    0x4(%eax),%edx
  800894:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800897:	8b 00                	mov    (%eax),%eax
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008a3:	eb 0d                	jmp    8008b2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a8:	e8 12 fc ff ff       	call   8004bf <getuint>
			base = 16;
  8008ad:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8008b6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008ba:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008cc:	89 fa                	mov    %edi,%edx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	e8 fa fa ff ff       	call   8003d0 <printnum>
			break;
  8008d6:	e9 88 fc ff ff       	jmp    800563 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008e5:	e9 79 fc ff ff       	jmp    800563 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f8:	89 f3                	mov    %esi,%ebx
  8008fa:	eb 03                	jmp    8008ff <vprintfmt+0x3c1>
  8008fc:	83 eb 01             	sub    $0x1,%ebx
  8008ff:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800903:	75 f7                	jne    8008fc <vprintfmt+0x3be>
  800905:	e9 59 fc ff ff       	jmp    800563 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80090a:	83 c4 3c             	add    $0x3c,%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 28             	sub    $0x28,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800921:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800925:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 30                	je     800963 <vsnprintf+0x51>
  800933:	85 d2                	test   %edx,%edx
  800935:	7e 2c                	jle    800963 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
  800941:	89 44 24 08          	mov    %eax,0x8(%esp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 f9 04 80 00 	movl   $0x8004f9,(%esp)
  800953:	e8 e6 fb ff ff       	call   80053e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	eb 05                	jmp    800968 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800973:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800977:	8b 45 10             	mov    0x10(%ebp),%eax
  80097a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	89 44 24 04          	mov    %eax,0x4(%esp)
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	e8 82 ff ff ff       	call   800912 <vsnprintf>
	va_end(ap);

	return rc;
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    
  800992:	66 90                	xchg   %ax,%ax
  800994:	66 90                	xchg   %ax,%ax
  800996:	66 90                	xchg   %ax,%ax
  800998:	66 90                	xchg   %ax,%ax
  80099a:	66 90                	xchg   %ax,%ax
  80099c:	66 90                	xchg   %ax,%ax
  80099e:	66 90                	xchg   %ax,%ax

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	eb 03                	jmp    8009b0 <strlen+0x10>
		n++;
  8009ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b4:	75 f7                	jne    8009ad <strlen+0xd>
		n++;
	return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 03                	jmp    8009cb <strnlen+0x13>
		n++;
  8009c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	39 d0                	cmp    %edx,%eax
  8009cd:	74 06                	je     8009d5 <strnlen+0x1d>
  8009cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d3:	75 f3                	jne    8009c8 <strnlen+0x10>
		n++;
	return n;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	75 ef                	jne    8009e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 08             	sub    $0x8,%esp
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a01:	89 1c 24             	mov    %ebx,(%esp)
  800a04:	e8 97 ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a10:	01 d8                	add    %ebx,%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 bd ff ff ff       	call   8009d7 <strcpy>
	return dst;
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	83 c4 08             	add    $0x8,%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	eb 0f                	jmp    800a45 <strncpy+0x23>
		*dst++ = *src;
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a42:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	75 ed                	jne    800a36 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a49:	89 f0                	mov    %esi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a5d:	89 f0                	mov    %esi,%eax
  800a5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	75 0b                	jne    800a72 <strlcpy+0x23>
  800a67:	eb 1d                	jmp    800a86 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 0b                	je     800a81 <strlcpy+0x32>
  800a76:	0f b6 0a             	movzbl (%edx),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	75 ec                	jne    800a69 <strlcpy+0x1a>
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	eb 02                	jmp    800a83 <strlcpy+0x34>
  800a81:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a83:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a95:	eb 06                	jmp    800a9d <strcmp+0x11>
		p++, q++;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strcmp+0x1c>
  800aa4:	3a 02                	cmp    (%edx),%al
  800aa6:	74 ef                	je     800a97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac1:	eb 06                	jmp    800ac9 <strncmp+0x17>
		n--, p++, q++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 15                	je     800ae2 <strncmp+0x30>
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	74 04                	je     800ad8 <strncmp+0x26>
  800ad4:	3a 0a                	cmp    (%edx),%cl
  800ad6:	74 eb                	je     800ac3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	0f b6 00             	movzbl (%eax),%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
  800ae0:	eb 05                	jmp    800ae7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	eb 07                	jmp    800afd <strchr+0x13>
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 0f                	je     800b09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 f2                	jne    800af6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b15:	eb 07                	jmp    800b1e <strfind+0x13>
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	74 0a                	je     800b25 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1b:	83 c0 01             	add    $0x1,%eax
  800b1e:	0f b6 10             	movzbl (%eax),%edx
  800b21:	84 d2                	test   %dl,%dl
  800b23:	75 f2                	jne    800b17 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 36                	je     800b6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3d:	75 28                	jne    800b67 <memset+0x40>
  800b3f:	f6 c1 03             	test   $0x3,%cl
  800b42:	75 23                	jne    800b67 <memset+0x40>
		c &= 0xFF;
  800b44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	c1 e3 08             	shl    $0x8,%ebx
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 18             	shl    $0x18,%esi
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e0 10             	shl    $0x10,%eax
  800b57:	09 f0                	or     %esi,%eax
  800b59:	09 c2                	or     %eax,%edx
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b62:	fc                   	cld    
  800b63:	f3 ab                	rep stos %eax,%es:(%edi)
  800b65:	eb 06                	jmp    800b6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 35                	jae    800bbb <memmove+0x47>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 d0                	cmp    %edx,%eax
  800b8b:	73 2e                	jae    800bbb <memmove+0x47>
		s += n;
		d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9a:	75 13                	jne    800baf <memmove+0x3b>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 0e                	jne    800baf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba1:	83 ef 04             	sub    $0x4,%edi
  800ba4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800baa:	fd                   	std    
  800bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bad:	eb 09                	jmp    800bb8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800baf:	83 ef 01             	sub    $0x1,%edi
  800bb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb5:	fd                   	std    
  800bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb8:	fc                   	cld    
  800bb9:	eb 1d                	jmp    800bd8 <memmove+0x64>
  800bbb:	89 f2                	mov    %esi,%edx
  800bbd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 0f                	jne    800bd3 <memmove+0x5f>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 0a                	jne    800bd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd1:	eb 05                	jmp    800bd8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	fc                   	cld    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	89 04 24             	mov    %eax,(%esp)
  800bf6:	e8 79 ff ff ff       	call   800b74 <memmove>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0d:	eb 1a                	jmp    800c29 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0f:	0f b6 02             	movzbl (%edx),%eax
  800c12:	0f b6 19             	movzbl (%ecx),%ebx
  800c15:	38 d8                	cmp    %bl,%al
  800c17:	74 0a                	je     800c23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c19:	0f b6 c0             	movzbl %al,%eax
  800c1c:	0f b6 db             	movzbl %bl,%ebx
  800c1f:	29 d8                	sub    %ebx,%eax
  800c21:	eb 0f                	jmp    800c32 <memcmp+0x35>
		s1++, s2++;
  800c23:	83 c2 01             	add    $0x1,%edx
  800c26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c29:	39 f2                	cmp    %esi,%edx
  800c2b:	75 e2                	jne    800c0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c44:	eb 07                	jmp    800c4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c46:	38 08                	cmp    %cl,(%eax)
  800c48:	74 07                	je     800c51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	39 d0                	cmp    %edx,%eax
  800c4f:	72 f5                	jb     800c46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5f:	eb 03                	jmp    800c64 <strtol+0x11>
		s++;
  800c61:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c64:	0f b6 0a             	movzbl (%edx),%ecx
  800c67:	80 f9 09             	cmp    $0x9,%cl
  800c6a:	74 f5                	je     800c61 <strtol+0xe>
  800c6c:	80 f9 20             	cmp    $0x20,%cl
  800c6f:	74 f0                	je     800c61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c71:	80 f9 2b             	cmp    $0x2b,%cl
  800c74:	75 0a                	jne    800c80 <strtol+0x2d>
		s++;
  800c76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c79:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7e:	eb 11                	jmp    800c91 <strtol+0x3e>
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c85:	80 f9 2d             	cmp    $0x2d,%cl
  800c88:	75 07                	jne    800c91 <strtol+0x3e>
		s++, neg = 1;
  800c8a:	8d 52 01             	lea    0x1(%edx),%edx
  800c8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c96:	75 15                	jne    800cad <strtol+0x5a>
  800c98:	80 3a 30             	cmpb   $0x30,(%edx)
  800c9b:	75 10                	jne    800cad <strtol+0x5a>
  800c9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca1:	75 0a                	jne    800cad <strtol+0x5a>
		s += 2, base = 16;
  800ca3:	83 c2 02             	add    $0x2,%edx
  800ca6:	b8 10 00 00 00       	mov    $0x10,%eax
  800cab:	eb 10                	jmp    800cbd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800cad:	85 c0                	test   %eax,%eax
  800caf:	75 0c                	jne    800cbd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb6:	75 05                	jne    800cbd <strtol+0x6a>
		s++, base = 8;
  800cb8:	83 c2 01             	add    $0x1,%edx
  800cbb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc5:	0f b6 0a             	movzbl (%edx),%ecx
  800cc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	3c 09                	cmp    $0x9,%al
  800ccf:	77 08                	ja     800cd9 <strtol+0x86>
			dig = *s - '0';
  800cd1:	0f be c9             	movsbl %cl,%ecx
  800cd4:	83 e9 30             	sub    $0x30,%ecx
  800cd7:	eb 20                	jmp    800cf9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800cd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	3c 19                	cmp    $0x19,%al
  800ce0:	77 08                	ja     800cea <strtol+0x97>
			dig = *s - 'a' + 10;
  800ce2:	0f be c9             	movsbl %cl,%ecx
  800ce5:	83 e9 57             	sub    $0x57,%ecx
  800ce8:	eb 0f                	jmp    800cf9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	3c 19                	cmp    $0x19,%al
  800cf1:	77 16                	ja     800d09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cf3:	0f be c9             	movsbl %cl,%ecx
  800cf6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cf9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cfc:	7d 0f                	jge    800d0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cfe:	83 c2 01             	add    $0x1,%edx
  800d01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d07:	eb bc                	jmp    800cc5 <strtol+0x72>
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 02                	jmp    800d0f <strtol+0xbc>
  800d0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d13:	74 05                	je     800d1a <strtol+0xc7>
		*endptr = (char *) s;
  800d15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d1a:	f7 d8                	neg    %eax
  800d1c:	85 ff                	test   %edi,%edi
  800d1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 c3                	mov    %eax,%ebx
  800d39:	89 c7                	mov    %eax,%edi
  800d3b:	89 c6                	mov    %eax,%esi
  800d3d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_cgetc>:

int
sys_cgetc(void)
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
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 03 00 00 00       	mov    $0x3,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800da8:	e8 02 f5 ff ff       	call   8002af <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_yield>:

void
sys_yield(void)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de4:	89 d1                	mov    %edx,%ecx
  800de6:	89 d3                	mov    %edx,%ebx
  800de8:	89 d7                	mov    %edx,%edi
  800dea:	89 d6                	mov    %edx,%esi
  800dec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 04 00 00 00       	mov    $0x4,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	89 f7                	mov    %esi,%edi
  800e11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e3a:	e8 70 f4 ff ff       	call   8002af <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3f:	83 c4 2c             	add    $0x2c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b8 05 00 00 00       	mov    $0x5,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	8b 75 18             	mov    0x18(%ebp),%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e8d:	e8 1d f4 ff ff       	call   8002af <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800ee0:	e8 ca f3 ff ff       	call   8002af <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 08 00 00 00       	mov    $0x8,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f33:	e8 77 f3 ff ff       	call   8002af <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f86:	e8 24 f3 ff ff       	call   8002af <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f8b:	83 c4 2c             	add    $0x2c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fd9:	e8 d1 f2 ff ff       	call   8002af <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fde:	83 c4 2c             	add    $0x2c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801002:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801012:	b9 00 00 00 00       	mov    $0x0,%ecx
  801017:	b8 0d 00 00 00       	mov    $0xd,%eax
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	89 cb                	mov    %ecx,%ebx
  801021:	89 cf                	mov    %ecx,%edi
  801023:	89 ce                	mov    %ecx,%esi
  801025:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	7e 28                	jle    801053 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801036:	00 
  801037:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801046:	00 
  801047:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80104e:	e8 5c f2 ff ff       	call   8002af <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801053:	83 c4 2c             	add    $0x2c,%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	ba 00 00 00 00       	mov    $0x0,%edx
  801066:	b8 0e 00 00 00       	mov    $0xe,%eax
  80106b:	89 d1                	mov    %edx,%ecx
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 d7                	mov    %edx,%edi
  801071:	89 d6                	mov    %edx,%esi
  801073:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801090:	8b 55 08             	mov    0x8(%ebp),%edx
  801093:	89 df                	mov    %ebx,%edi
  801095:	89 de                	mov    %ebx,%esi
  801097:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	7e 28                	jle    8010c5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  8010b0:	00 
  8010b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b8:	00 
  8010b9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  8010c0:	e8 ea f1 ff ff       	call   8002af <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  8010c5:	83 c4 2c             	add    $0x2c,%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010db:	b8 10 00 00 00       	mov    $0x10,%eax
  8010e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e6:	89 df                	mov    %ebx,%edi
  8010e8:	89 de                	mov    %ebx,%esi
  8010ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	7e 28                	jle    801118 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801103:	00 
  801104:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80110b:	00 
  80110c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801113:	e8 97 f1 ff ff       	call   8002af <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801118:	83 c4 2c             	add    $0x2c,%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	05 00 00 00 30       	add    $0x30000000,%eax
  80112b:	c1 e8 0c             	shr    $0xc,%eax
}
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80113b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801140:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801152:	89 c2                	mov    %eax,%edx
  801154:	c1 ea 16             	shr    $0x16,%edx
  801157:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115e:	f6 c2 01             	test   $0x1,%dl
  801161:	74 11                	je     801174 <fd_alloc+0x2d>
  801163:	89 c2                	mov    %eax,%edx
  801165:	c1 ea 0c             	shr    $0xc,%edx
  801168:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116f:	f6 c2 01             	test   $0x1,%dl
  801172:	75 09                	jne    80117d <fd_alloc+0x36>
			*fd_store = fd;
  801174:	89 01                	mov    %eax,(%ecx)
			return 0;
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
  80117b:	eb 17                	jmp    801194 <fd_alloc+0x4d>
  80117d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801182:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801187:	75 c9                	jne    801152 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801189:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80118f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80119c:	83 f8 1f             	cmp    $0x1f,%eax
  80119f:	77 36                	ja     8011d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a1:	c1 e0 0c             	shl    $0xc,%eax
  8011a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 16             	shr    $0x16,%edx
  8011ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	74 24                	je     8011de <fd_lookup+0x48>
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 ea 0c             	shr    $0xc,%edx
  8011bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	74 1a                	je     8011e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	eb 13                	jmp    8011ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dc:	eb 0c                	jmp    8011ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e3:	eb 05                	jmp    8011ea <fd_lookup+0x54>
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 18             	sub    $0x18,%esp
  8011f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fa:	eb 13                	jmp    80120f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8011fc:	39 08                	cmp    %ecx,(%eax)
  8011fe:	75 0c                	jne    80120c <dev_lookup+0x20>
			*dev = devtab[i];
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	89 01                	mov    %eax,(%ecx)
			return 0;
  801205:	b8 00 00 00 00       	mov    $0x0,%eax
  80120a:	eb 38                	jmp    801244 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80120c:	83 c2 01             	add    $0x1,%edx
  80120f:	8b 04 95 48 2c 80 00 	mov    0x802c48(,%edx,4),%eax
  801216:	85 c0                	test   %eax,%eax
  801218:	75 e2                	jne    8011fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80121a:	a1 08 40 80 00       	mov    0x804008,%eax
  80121f:	8b 40 48             	mov    0x48(%eax),%eax
  801222:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  801231:	e8 72 f1 ff ff       	call   8003a8 <cprintf>
	*dev = 0;
  801236:	8b 45 0c             	mov    0xc(%ebp),%eax
  801239:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80123f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 20             	sub    $0x20,%esp
  80124e:	8b 75 08             	mov    0x8(%ebp),%esi
  801251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801261:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 2a ff ff ff       	call   801196 <fd_lookup>
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 05                	js     801275 <fd_close+0x2f>
	    || fd != fd2)
  801270:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801273:	74 0c                	je     801281 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801275:	84 db                	test   %bl,%bl
  801277:	ba 00 00 00 00       	mov    $0x0,%edx
  80127c:	0f 44 c2             	cmove  %edx,%eax
  80127f:	eb 3f                	jmp    8012c0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	89 44 24 04          	mov    %eax,0x4(%esp)
  801288:	8b 06                	mov    (%esi),%eax
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	e8 5a ff ff ff       	call   8011ec <dev_lookup>
  801292:	89 c3                	mov    %eax,%ebx
  801294:	85 c0                	test   %eax,%eax
  801296:	78 16                	js     8012ae <fd_close+0x68>
		if (dev->dev_close)
  801298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80129e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 07                	je     8012ae <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8012a7:	89 34 24             	mov    %esi,(%esp)
  8012aa:	ff d0                	call   *%eax
  8012ac:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b9:	e8 dc fb ff ff       	call   800e9a <sys_page_unmap>
	return r;
  8012be:	89 d8                	mov    %ebx,%eax
}
  8012c0:	83 c4 20             	add    $0x20,%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	e8 b7 fe ff ff       	call   801196 <fd_lookup>
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	78 13                	js     8012f8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8012e5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012ec:	00 
  8012ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f0:	89 04 24             	mov    %eax,(%esp)
  8012f3:	e8 4e ff ff ff       	call   801246 <fd_close>
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <close_all>:

void
close_all(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	e8 b9 ff ff ff       	call   8012c7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130e:	83 c3 01             	add    $0x1,%ebx
  801311:	83 fb 20             	cmp    $0x20,%ebx
  801314:	75 f0                	jne    801306 <close_all+0xc>
		close(i);
}
  801316:	83 c4 14             	add    $0x14,%esp
  801319:	5b                   	pop    %ebx
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801325:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 5f fe ff ff       	call   801196 <fd_lookup>
  801337:	89 c2                	mov    %eax,%edx
  801339:	85 d2                	test   %edx,%edx
  80133b:	0f 88 e1 00 00 00    	js     801422 <dup+0x106>
		return r;
	close(newfdnum);
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	e8 7b ff ff ff       	call   8012c7 <close>

	newfd = INDEX2FD(newfdnum);
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80134f:	c1 e3 0c             	shl    $0xc,%ebx
  801352:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 cd fd ff ff       	call   801130 <fd2data>
  801363:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801365:	89 1c 24             	mov    %ebx,(%esp)
  801368:	e8 c3 fd ff ff       	call   801130 <fd2data>
  80136d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80136f:	89 f0                	mov    %esi,%eax
  801371:	c1 e8 16             	shr    $0x16,%eax
  801374:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137b:	a8 01                	test   $0x1,%al
  80137d:	74 43                	je     8013c2 <dup+0xa6>
  80137f:	89 f0                	mov    %esi,%eax
  801381:	c1 e8 0c             	shr    $0xc,%eax
  801384:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138b:	f6 c2 01             	test   $0x1,%dl
  80138e:	74 32                	je     8013c2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801390:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801397:	25 07 0e 00 00       	and    $0xe07,%eax
  80139c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013ab:	00 
  8013ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b7:	e8 8b fa ff ff       	call   800e47 <sys_page_map>
  8013bc:	89 c6                	mov    %eax,%esi
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 3e                	js     801400 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	c1 ea 0c             	shr    $0xc,%edx
  8013ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013e6:	00 
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f2:	e8 50 fa ff ff       	call   800e47 <sys_page_map>
  8013f7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fc:	85 f6                	test   %esi,%esi
  8013fe:	79 22                	jns    801422 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801400:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801404:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140b:	e8 8a fa ff ff       	call   800e9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801410:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141b:	e8 7a fa ff ff       	call   800e9a <sys_page_unmap>
	return r;
  801420:	89 f0                	mov    %esi,%eax
}
  801422:	83 c4 3c             	add    $0x3c,%esp
  801425:	5b                   	pop    %ebx
  801426:	5e                   	pop    %esi
  801427:	5f                   	pop    %edi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 24             	sub    $0x24,%esp
  801431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801434:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	89 1c 24             	mov    %ebx,(%esp)
  80143e:	e8 53 fd ff ff       	call   801196 <fd_lookup>
  801443:	89 c2                	mov    %eax,%edx
  801445:	85 d2                	test   %edx,%edx
  801447:	78 6d                	js     8014b6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	8b 00                	mov    (%eax),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 8f fd ff ff       	call   8011ec <dev_lookup>
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 55                	js     8014b6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	8b 50 08             	mov    0x8(%eax),%edx
  801467:	83 e2 03             	and    $0x3,%edx
  80146a:	83 fa 01             	cmp    $0x1,%edx
  80146d:	75 23                	jne    801492 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146f:	a1 08 40 80 00       	mov    0x804008,%eax
  801474:	8b 40 48             	mov    0x48(%eax),%eax
  801477:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  801486:	e8 1d ef ff ff       	call   8003a8 <cprintf>
		return -E_INVAL;
  80148b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801490:	eb 24                	jmp    8014b6 <read+0x8c>
	}
	if (!dev->dev_read)
  801492:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801495:	8b 52 08             	mov    0x8(%edx),%edx
  801498:	85 d2                	test   %edx,%edx
  80149a:	74 15                	je     8014b1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80149f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014aa:	89 04 24             	mov    %eax,(%esp)
  8014ad:	ff d2                	call   *%edx
  8014af:	eb 05                	jmp    8014b6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014b6:	83 c4 24             	add    $0x24,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 1c             	sub    $0x1c,%esp
  8014c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d0:	eb 23                	jmp    8014f5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d2:	89 f0                	mov    %esi,%eax
  8014d4:	29 d8                	sub    %ebx,%eax
  8014d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014da:	89 d8                	mov    %ebx,%eax
  8014dc:	03 45 0c             	add    0xc(%ebp),%eax
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	89 3c 24             	mov    %edi,(%esp)
  8014e6:	e8 3f ff ff ff       	call   80142a <read>
		if (m < 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 10                	js     8014ff <readn+0x43>
			return m;
		if (m == 0)
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	74 0a                	je     8014fd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f3:	01 c3                	add    %eax,%ebx
  8014f5:	39 f3                	cmp    %esi,%ebx
  8014f7:	72 d9                	jb     8014d2 <readn+0x16>
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	eb 02                	jmp    8014ff <readn+0x43>
  8014fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ff:	83 c4 1c             	add    $0x1c,%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5f                   	pop    %edi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 24             	sub    $0x24,%esp
  80150e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801511:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	89 1c 24             	mov    %ebx,(%esp)
  80151b:	e8 76 fc ff ff       	call   801196 <fd_lookup>
  801520:	89 c2                	mov    %eax,%edx
  801522:	85 d2                	test   %edx,%edx
  801524:	78 68                	js     80158e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	8b 00                	mov    (%eax),%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 b2 fc ff ff       	call   8011ec <dev_lookup>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 50                	js     80158e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801541:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801545:	75 23                	jne    80156a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801547:	a1 08 40 80 00       	mov    0x804008,%eax
  80154c:	8b 40 48             	mov    0x48(%eax),%eax
  80154f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	c7 04 24 29 2c 80 00 	movl   $0x802c29,(%esp)
  80155e:	e8 45 ee ff ff       	call   8003a8 <cprintf>
		return -E_INVAL;
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801568:	eb 24                	jmp    80158e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156d:	8b 52 0c             	mov    0xc(%edx),%edx
  801570:	85 d2                	test   %edx,%edx
  801572:	74 15                	je     801589 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801574:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801577:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	ff d2                	call   *%edx
  801587:	eb 05                	jmp    80158e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801589:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80158e:	83 c4 24             	add    $0x24,%esp
  801591:	5b                   	pop    %ebx
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <seek>:

int
seek(int fdnum, off_t offset)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a4:	89 04 24             	mov    %eax,(%esp)
  8015a7:	e8 ea fb ff ff       	call   801196 <fd_lookup>
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 0e                	js     8015be <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 24             	sub    $0x24,%esp
  8015c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d1:	89 1c 24             	mov    %ebx,(%esp)
  8015d4:	e8 bd fb ff ff       	call   801196 <fd_lookup>
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	78 61                	js     801640 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e9:	8b 00                	mov    (%eax),%eax
  8015eb:	89 04 24             	mov    %eax,(%esp)
  8015ee:	e8 f9 fb ff ff       	call   8011ec <dev_lookup>
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 49                	js     801640 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fe:	75 23                	jne    801623 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801600:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801605:	8b 40 48             	mov    0x48(%eax),%eax
  801608:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801610:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  801617:	e8 8c ed ff ff       	call   8003a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801621:	eb 1d                	jmp    801640 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801623:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801626:	8b 52 18             	mov    0x18(%edx),%edx
  801629:	85 d2                	test   %edx,%edx
  80162b:	74 0e                	je     80163b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80162d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801630:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	ff d2                	call   *%edx
  801639:	eb 05                	jmp    801640 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801640:	83 c4 24             	add    $0x24,%esp
  801643:	5b                   	pop    %ebx
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 24             	sub    $0x24,%esp
  80164d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	89 44 24 04          	mov    %eax,0x4(%esp)
  801657:	8b 45 08             	mov    0x8(%ebp),%eax
  80165a:	89 04 24             	mov    %eax,(%esp)
  80165d:	e8 34 fb ff ff       	call   801196 <fd_lookup>
  801662:	89 c2                	mov    %eax,%edx
  801664:	85 d2                	test   %edx,%edx
  801666:	78 52                	js     8016ba <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	8b 00                	mov    (%eax),%eax
  801674:	89 04 24             	mov    %eax,(%esp)
  801677:	e8 70 fb ff ff       	call   8011ec <dev_lookup>
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 3a                	js     8016ba <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801687:	74 2c                	je     8016b5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801689:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801693:	00 00 00 
	stat->st_isdir = 0;
  801696:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169d:	00 00 00 
	stat->st_dev = dev;
  8016a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ad:	89 14 24             	mov    %edx,(%esp)
  8016b0:	ff 50 14             	call   *0x14(%eax)
  8016b3:	eb 05                	jmp    8016ba <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ba:	83 c4 24             	add    $0x24,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016cf:	00 
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	89 04 24             	mov    %eax,(%esp)
  8016d6:	e8 28 02 00 00       	call   801903 <open>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	85 db                	test   %ebx,%ebx
  8016df:	78 1b                	js     8016fc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 56 ff ff ff       	call   801646 <fstat>
  8016f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f2:	89 1c 24             	mov    %ebx,(%esp)
  8016f5:	e8 cd fb ff ff       	call   8012c7 <close>
	return r;
  8016fa:	89 f0                	mov    %esi,%eax
}
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 10             	sub    $0x10,%esp
  80170b:	89 c6                	mov    %eax,%esi
  80170d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801716:	75 11                	jne    801729 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801718:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80171f:	e8 a1 0d 00 00       	call   8024c5 <ipc_find_env>
  801724:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801729:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801730:	00 
  801731:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801738:	00 
  801739:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173d:	a1 00 40 80 00       	mov    0x804000,%eax
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	e8 10 0d 00 00       	call   80245a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80174a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801751:	00 
  801752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175d:	e8 7e 0c 00 00       	call   8023e0 <ipc_recv>
}
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 02 00 00 00       	mov    $0x2,%eax
  80178c:	e8 72 ff ff ff       	call   801703 <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ae:	e8 50 ff ff ff       	call   801703 <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 14             	sub    $0x14,%esp
  8017bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d4:	e8 2a ff ff ff       	call   801703 <fsipc>
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	85 d2                	test   %edx,%edx
  8017dd:	78 2b                	js     80180a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017df:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017e6:	00 
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 e8 f1 ff ff       	call   8009d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180a:	83 c4 14             	add    $0x14,%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 18             	sub    $0x18,%esp
  801816:	8b 45 10             	mov    0x10(%ebp),%eax
  801819:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80181e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801823:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801826:	8b 55 08             	mov    0x8(%ebp),%edx
  801829:	8b 52 0c             	mov    0xc(%edx),%edx
  80182c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801832:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801849:	e8 26 f3 ff ff       	call   800b74 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 04 00 00 00       	mov    $0x4,%eax
  801858:	e8 a6 fe ff ff       	call   801703 <fsipc>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 10             	sub    $0x10,%esp
  801867:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801875:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 03 00 00 00       	mov    $0x3,%eax
  801885:	e8 79 fe ff ff       	call   801703 <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 6a                	js     8018fa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801890:	39 c6                	cmp    %eax,%esi
  801892:	73 24                	jae    8018b8 <devfile_read+0x59>
  801894:	c7 44 24 0c 5c 2c 80 	movl   $0x802c5c,0xc(%esp)
  80189b:	00 
  80189c:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  8018a3:	00 
  8018a4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018ab:	00 
  8018ac:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8018b3:	e8 f7 e9 ff ff       	call   8002af <_panic>
	assert(r <= PGSIZE);
  8018b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018bd:	7e 24                	jle    8018e3 <devfile_read+0x84>
  8018bf:	c7 44 24 0c 83 2c 80 	movl   $0x802c83,0xc(%esp)
  8018c6:	00 
  8018c7:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  8018ce:	00 
  8018cf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018d6:	00 
  8018d7:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8018de:	e8 cc e9 ff ff       	call   8002af <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018ee:	00 
  8018ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 7a f2 ff ff       	call   800b74 <memmove>
	return r;
}
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 24             	sub    $0x24,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 8b f0 ff ff       	call   8009a0 <strlen>
  801915:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191a:	7f 60                	jg     80197c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	e8 20 f8 ff ff       	call   801147 <fd_alloc>
  801927:	89 c2                	mov    %eax,%edx
  801929:	85 d2                	test   %edx,%edx
  80192b:	78 54                	js     801981 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80192d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801931:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801938:	e8 9a f0 ff ff       	call   8009d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801940:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801945:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801948:	b8 01 00 00 00       	mov    $0x1,%eax
  80194d:	e8 b1 fd ff ff       	call   801703 <fsipc>
  801952:	89 c3                	mov    %eax,%ebx
  801954:	85 c0                	test   %eax,%eax
  801956:	79 17                	jns    80196f <open+0x6c>
		fd_close(fd, 0);
  801958:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80195f:	00 
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	89 04 24             	mov    %eax,(%esp)
  801966:	e8 db f8 ff ff       	call   801246 <fd_close>
		return r;
  80196b:	89 d8                	mov    %ebx,%eax
  80196d:	eb 12                	jmp    801981 <open+0x7e>
	}

	return fd2num(fd);
  80196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 a6 f7 ff ff       	call   801120 <fd2num>
  80197a:	eb 05                	jmp    801981 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801981:	83 c4 24             	add    $0x24,%esp
  801984:	5b                   	pop    %ebx
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 08 00 00 00       	mov    $0x8,%eax
  801997:	e8 67 fd ff ff       	call   801703 <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    
  80199e:	66 90                	xchg   %ax,%ax

008019a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8019a6:	c7 44 24 04 8f 2c 80 	movl   $0x802c8f,0x4(%esp)
  8019ad:	00 
  8019ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b1:	89 04 24             	mov    %eax,(%esp)
  8019b4:	e8 1e f0 ff ff       	call   8009d7 <strcpy>
	return 0;
}
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 14             	sub    $0x14,%esp
  8019c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ca:	89 1c 24             	mov    %ebx,(%esp)
  8019cd:	e8 2b 0b 00 00       	call   8024fd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019d7:	83 f8 01             	cmp    $0x1,%eax
  8019da:	75 0d                	jne    8019e9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8019dc:	8b 43 0c             	mov    0xc(%ebx),%eax
  8019df:	89 04 24             	mov    %eax,(%esp)
  8019e2:	e8 29 03 00 00       	call   801d10 <nsipc_close>
  8019e7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8019e9:	89 d0                	mov    %edx,%eax
  8019eb:	83 c4 14             	add    $0x14,%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019fe:	00 
  8019ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801a02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	8b 40 0c             	mov    0xc(%eax),%eax
  801a13:	89 04 24             	mov    %eax,(%esp)
  801a16:	e8 f0 03 00 00       	call   801e0b <nsipc_send>
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a23:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a2a:	00 
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	e8 44 03 00 00       	call   801d8b <nsipc_recv>
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a4f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a52:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 38 f7 ff ff       	call   801196 <fd_lookup>
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 17                	js     801a79 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a6b:	39 08                	cmp    %ecx,(%eax)
  801a6d:	75 05                	jne    801a74 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a72:	eb 05                	jmp    801a79 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a74:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 20             	sub    $0x20,%esp
  801a83:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a88:	89 04 24             	mov    %eax,(%esp)
  801a8b:	e8 b7 f6 ff ff       	call   801147 <fd_alloc>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 21                	js     801ab7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a96:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a9d:	00 
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aac:	e8 42 f3 ff ff       	call   800df3 <sys_page_alloc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 0c                	jns    801ac3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801ab7:	89 34 24             	mov    %esi,(%esp)
  801aba:	e8 51 02 00 00       	call   801d10 <nsipc_close>
		return r;
  801abf:	89 d8                	mov    %ebx,%eax
  801ac1:	eb 20                	jmp    801ae3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ac3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801ad8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801adb:	89 14 24             	mov    %edx,(%esp)
  801ade:	e8 3d f6 ff ff       	call   801120 <fd2num>
}
  801ae3:	83 c4 20             	add    $0x20,%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 51 ff ff ff       	call   801a49 <fd2sockid>
		return r;
  801af8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 23                	js     801b21 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801afe:	8b 55 10             	mov    0x10(%ebp),%edx
  801b01:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b08:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 45 01 00 00       	call   801c59 <nsipc_accept>
		return r;
  801b14:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 07                	js     801b21 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801b1a:	e8 5c ff ff ff       	call   801a7b <alloc_sockfd>
  801b1f:	89 c1                	mov    %eax,%ecx
}
  801b21:	89 c8                	mov    %ecx,%eax
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	e8 16 ff ff ff       	call   801a49 <fd2sockid>
  801b33:	89 c2                	mov    %eax,%edx
  801b35:	85 d2                	test   %edx,%edx
  801b37:	78 16                	js     801b4f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801b39:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	89 14 24             	mov    %edx,(%esp)
  801b4a:	e8 60 01 00 00       	call   801caf <nsipc_bind>
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <shutdown>:

int
shutdown(int s, int how)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	e8 ea fe ff ff       	call   801a49 <fd2sockid>
  801b5f:	89 c2                	mov    %eax,%edx
  801b61:	85 d2                	test   %edx,%edx
  801b63:	78 0f                	js     801b74 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6c:	89 14 24             	mov    %edx,(%esp)
  801b6f:	e8 7a 01 00 00       	call   801cee <nsipc_shutdown>
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	e8 c5 fe ff ff       	call   801a49 <fd2sockid>
  801b84:	89 c2                	mov    %eax,%edx
  801b86:	85 d2                	test   %edx,%edx
  801b88:	78 16                	js     801ba0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801b8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b98:	89 14 24             	mov    %edx,(%esp)
  801b9b:	e8 8a 01 00 00       	call   801d2a <nsipc_connect>
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <listen>:

int
listen(int s, int backlog)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bab:	e8 99 fe ff ff       	call   801a49 <fd2sockid>
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	85 d2                	test   %edx,%edx
  801bb4:	78 0f                	js     801bc5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbd:	89 14 24             	mov    %edx,(%esp)
  801bc0:	e8 a4 01 00 00       	call   801d69 <nsipc_listen>
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bcd:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 98 02 00 00       	call   801e7e <nsipc_socket>
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	85 d2                	test   %edx,%edx
  801bea:	78 05                	js     801bf1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801bec:	e8 8a fe ff ff       	call   801a7b <alloc_sockfd>
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 14             	sub    $0x14,%esp
  801bfa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bfc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c03:	75 11                	jne    801c16 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c0c:	e8 b4 08 00 00       	call   8024c5 <ipc_find_env>
  801c11:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c1d:	00 
  801c1e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c25:	00 
  801c26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 23 08 00 00       	call   80245a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3e:	00 
  801c3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c46:	00 
  801c47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4e:	e8 8d 07 00 00       	call   8023e0 <ipc_recv>
}
  801c53:	83 c4 14             	add    $0x14,%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 10             	sub    $0x10,%esp
  801c61:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c6c:	8b 06                	mov    (%esi),%eax
  801c6e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c73:	b8 01 00 00 00       	mov    $0x1,%eax
  801c78:	e8 76 ff ff ff       	call   801bf3 <nsipc>
  801c7d:	89 c3                	mov    %eax,%ebx
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	78 23                	js     801ca6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c83:	a1 10 60 80 00       	mov    0x806010,%eax
  801c88:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c93:	00 
  801c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c97:	89 04 24             	mov    %eax,(%esp)
  801c9a:	e8 d5 ee ff ff       	call   800b74 <memmove>
		*addrlen = ret->ret_addrlen;
  801c9f:	a1 10 60 80 00       	mov    0x806010,%eax
  801ca4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	53                   	push   %ebx
  801cb3:	83 ec 14             	sub    $0x14,%esp
  801cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cc1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801cd3:	e8 9c ee ff ff       	call   800b74 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cd8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cde:	b8 02 00 00 00       	mov    $0x2,%eax
  801ce3:	e8 0b ff ff ff       	call   801bf3 <nsipc>
}
  801ce8:	83 c4 14             	add    $0x14,%esp
  801ceb:	5b                   	pop    %ebx
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cff:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d04:	b8 03 00 00 00       	mov    $0x3,%eax
  801d09:	e8 e5 fe ff ff       	call   801bf3 <nsipc>
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <nsipc_close>:

int
nsipc_close(int s)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d1e:	b8 04 00 00 00       	mov    $0x4,%eax
  801d23:	e8 cb fe ff ff       	call   801bf3 <nsipc>
}
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 14             	sub    $0x14,%esp
  801d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d3c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d47:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d4e:	e8 21 ee ff ff       	call   800b74 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d53:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d59:	b8 05 00 00 00       	mov    $0x5,%eax
  801d5e:	e8 90 fe ff ff       	call   801bf3 <nsipc>
}
  801d63:	83 c4 14             	add    $0x14,%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d7f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d84:	e8 6a fe ff ff       	call   801bf3 <nsipc>
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 10             	sub    $0x10,%esp
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d9e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801da4:	8b 45 14             	mov    0x14(%ebp),%eax
  801da7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dac:	b8 07 00 00 00       	mov    $0x7,%eax
  801db1:	e8 3d fe ff ff       	call   801bf3 <nsipc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 46                	js     801e02 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801dbc:	39 f0                	cmp    %esi,%eax
  801dbe:	7f 07                	jg     801dc7 <nsipc_recv+0x3c>
  801dc0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dc5:	7e 24                	jle    801deb <nsipc_recv+0x60>
  801dc7:	c7 44 24 0c 9b 2c 80 	movl   $0x802c9b,0xc(%esp)
  801dce:	00 
  801dcf:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  801dd6:	00 
  801dd7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801dde:	00 
  801ddf:	c7 04 24 b0 2c 80 00 	movl   $0x802cb0,(%esp)
  801de6:	e8 c4 e4 ff ff       	call   8002af <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801def:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801df6:	00 
  801df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfa:	89 04 24             	mov    %eax,(%esp)
  801dfd:	e8 72 ed ff ff       	call   800b74 <memmove>
	}

	return r;
}
  801e02:	89 d8                	mov    %ebx,%eax
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 14             	sub    $0x14,%esp
  801e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e1d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e23:	7e 24                	jle    801e49 <nsipc_send+0x3e>
  801e25:	c7 44 24 0c bc 2c 80 	movl   $0x802cbc,0xc(%esp)
  801e2c:	00 
  801e2d:	c7 44 24 08 63 2c 80 	movl   $0x802c63,0x8(%esp)
  801e34:	00 
  801e35:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801e3c:	00 
  801e3d:	c7 04 24 b0 2c 80 00 	movl   $0x802cb0,(%esp)
  801e44:	e8 66 e4 ff ff       	call   8002af <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e54:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e5b:	e8 14 ed ff ff       	call   800b74 <memmove>
	nsipcbuf.send.req_size = size;
  801e60:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e66:	8b 45 14             	mov    0x14(%ebp),%eax
  801e69:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e6e:	b8 08 00 00 00       	mov    $0x8,%eax
  801e73:	e8 7b fd ff ff       	call   801bf3 <nsipc>
}
  801e78:	83 c4 14             	add    $0x14,%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e84:	8b 45 08             	mov    0x8(%ebp),%eax
  801e87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e94:	8b 45 10             	mov    0x10(%ebp),%eax
  801e97:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  801ea1:	e8 4d fd ff ff       	call   801bf3 <nsipc>
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	56                   	push   %esi
  801eac:	53                   	push   %ebx
  801ead:	83 ec 10             	sub    $0x10,%esp
  801eb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 72 f2 ff ff       	call   801130 <fd2data>
  801ebe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ec0:	c7 44 24 04 c8 2c 80 	movl   $0x802cc8,0x4(%esp)
  801ec7:	00 
  801ec8:	89 1c 24             	mov    %ebx,(%esp)
  801ecb:	e8 07 eb ff ff       	call   8009d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ed0:	8b 46 04             	mov    0x4(%esi),%eax
  801ed3:	2b 06                	sub    (%esi),%eax
  801ed5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801edb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ee2:	00 00 00 
	stat->st_dev = &devpipe;
  801ee5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801eec:	30 80 00 
	return 0;
}
  801eef:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	53                   	push   %ebx
  801eff:	83 ec 14             	sub    $0x14,%esp
  801f02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 85 ef ff ff       	call   800e9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f15:	89 1c 24             	mov    %ebx,(%esp)
  801f18:	e8 13 f2 ff ff       	call   801130 <fd2data>
  801f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f28:	e8 6d ef ff ff       	call   800e9a <sys_page_unmap>
}
  801f2d:	83 c4 14             	add    $0x14,%esp
  801f30:	5b                   	pop    %ebx
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 2c             	sub    $0x2c,%esp
  801f3c:	89 c6                	mov    %eax,%esi
  801f3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f41:	a1 08 40 80 00       	mov    0x804008,%eax
  801f46:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f49:	89 34 24             	mov    %esi,(%esp)
  801f4c:	e8 ac 05 00 00       	call   8024fd <pageref>
  801f51:	89 c7                	mov    %eax,%edi
  801f53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f56:	89 04 24             	mov    %eax,(%esp)
  801f59:	e8 9f 05 00 00       	call   8024fd <pageref>
  801f5e:	39 c7                	cmp    %eax,%edi
  801f60:	0f 94 c2             	sete   %dl
  801f63:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f66:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801f6c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f6f:	39 fb                	cmp    %edi,%ebx
  801f71:	74 21                	je     801f94 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f73:	84 d2                	test   %dl,%dl
  801f75:	74 ca                	je     801f41 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f77:	8b 51 58             	mov    0x58(%ecx),%edx
  801f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f7e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f86:	c7 04 24 cf 2c 80 00 	movl   $0x802ccf,(%esp)
  801f8d:	e8 16 e4 ff ff       	call   8003a8 <cprintf>
  801f92:	eb ad                	jmp    801f41 <_pipeisclosed+0xe>
	}
}
  801f94:	83 c4 2c             	add    $0x2c,%esp
  801f97:	5b                   	pop    %ebx
  801f98:	5e                   	pop    %esi
  801f99:	5f                   	pop    %edi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	57                   	push   %edi
  801fa0:	56                   	push   %esi
  801fa1:	53                   	push   %ebx
  801fa2:	83 ec 1c             	sub    $0x1c,%esp
  801fa5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fa8:	89 34 24             	mov    %esi,(%esp)
  801fab:	e8 80 f1 ff ff       	call   801130 <fd2data>
  801fb0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fb7:	eb 45                	jmp    801ffe <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fb9:	89 da                	mov    %ebx,%edx
  801fbb:	89 f0                	mov    %esi,%eax
  801fbd:	e8 71 ff ff ff       	call   801f33 <_pipeisclosed>
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	75 41                	jne    802007 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fc6:	e8 09 ee ff ff       	call   800dd4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcb:	8b 43 04             	mov    0x4(%ebx),%eax
  801fce:	8b 0b                	mov    (%ebx),%ecx
  801fd0:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd3:	39 d0                	cmp    %edx,%eax
  801fd5:	73 e2                	jae    801fb9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fda:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fde:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe1:	99                   	cltd   
  801fe2:	c1 ea 1b             	shr    $0x1b,%edx
  801fe5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801fe8:	83 e1 1f             	and    $0x1f,%ecx
  801feb:	29 d1                	sub    %edx,%ecx
  801fed:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ff1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ff5:	83 c0 01             	add    $0x1,%eax
  801ff8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffb:	83 c7 01             	add    $0x1,%edi
  801ffe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802001:	75 c8                	jne    801fcb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802003:	89 f8                	mov    %edi,%eax
  802005:	eb 05                	jmp    80200c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80200c:	83 c4 1c             	add    $0x1c,%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	57                   	push   %edi
  802018:	56                   	push   %esi
  802019:	53                   	push   %ebx
  80201a:	83 ec 1c             	sub    $0x1c,%esp
  80201d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802020:	89 3c 24             	mov    %edi,(%esp)
  802023:	e8 08 f1 ff ff       	call   801130 <fd2data>
  802028:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202a:	be 00 00 00 00       	mov    $0x0,%esi
  80202f:	eb 3d                	jmp    80206e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802031:	85 f6                	test   %esi,%esi
  802033:	74 04                	je     802039 <devpipe_read+0x25>
				return i;
  802035:	89 f0                	mov    %esi,%eax
  802037:	eb 43                	jmp    80207c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802039:	89 da                	mov    %ebx,%edx
  80203b:	89 f8                	mov    %edi,%eax
  80203d:	e8 f1 fe ff ff       	call   801f33 <_pipeisclosed>
  802042:	85 c0                	test   %eax,%eax
  802044:	75 31                	jne    802077 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802046:	e8 89 ed ff ff       	call   800dd4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80204b:	8b 03                	mov    (%ebx),%eax
  80204d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802050:	74 df                	je     802031 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802052:	99                   	cltd   
  802053:	c1 ea 1b             	shr    $0x1b,%edx
  802056:	01 d0                	add    %edx,%eax
  802058:	83 e0 1f             	and    $0x1f,%eax
  80205b:	29 d0                	sub    %edx,%eax
  80205d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802065:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802068:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206b:	83 c6 01             	add    $0x1,%esi
  80206e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802071:	75 d8                	jne    80204b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802073:	89 f0                	mov    %esi,%eax
  802075:	eb 05                	jmp    80207c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	89 04 24             	mov    %eax,(%esp)
  802092:	e8 b0 f0 ff ff       	call   801147 <fd_alloc>
  802097:	89 c2                	mov    %eax,%edx
  802099:	85 d2                	test   %edx,%edx
  80209b:	0f 88 4d 01 00 00    	js     8021ee <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020a8:	00 
  8020a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b7:	e8 37 ed ff ff       	call   800df3 <sys_page_alloc>
  8020bc:	89 c2                	mov    %eax,%edx
  8020be:	85 d2                	test   %edx,%edx
  8020c0:	0f 88 28 01 00 00    	js     8021ee <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020c9:	89 04 24             	mov    %eax,(%esp)
  8020cc:	e8 76 f0 ff ff       	call   801147 <fd_alloc>
  8020d1:	89 c3                	mov    %eax,%ebx
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	0f 88 fe 00 00 00    	js     8021d9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020db:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e2:	00 
  8020e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f1:	e8 fd ec ff ff       	call   800df3 <sys_page_alloc>
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	0f 88 d9 00 00 00    	js     8021d9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802103:	89 04 24             	mov    %eax,(%esp)
  802106:	e8 25 f0 ff ff       	call   801130 <fd2data>
  80210b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802114:	00 
  802115:	89 44 24 04          	mov    %eax,0x4(%esp)
  802119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802120:	e8 ce ec ff ff       	call   800df3 <sys_page_alloc>
  802125:	89 c3                	mov    %eax,%ebx
  802127:	85 c0                	test   %eax,%eax
  802129:	0f 88 97 00 00 00    	js     8021c6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802132:	89 04 24             	mov    %eax,(%esp)
  802135:	e8 f6 ef ff ff       	call   801130 <fd2data>
  80213a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802141:	00 
  802142:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802146:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80214d:	00 
  80214e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802159:	e8 e9 ec ff ff       	call   800e47 <sys_page_map>
  80215e:	89 c3                	mov    %eax,%ebx
  802160:	85 c0                	test   %eax,%eax
  802162:	78 52                	js     8021b6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802164:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80216a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80216f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802172:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802179:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80217f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802182:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802187:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80218e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802191:	89 04 24             	mov    %eax,(%esp)
  802194:	e8 87 ef ff ff       	call   801120 <fd2num>
  802199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80219e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a1:	89 04 24             	mov    %eax,(%esp)
  8021a4:	e8 77 ef ff ff       	call   801120 <fd2num>
  8021a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b4:	eb 38                	jmp    8021ee <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c1:	e8 d4 ec ff ff       	call   800e9a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8021c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d4:	e8 c1 ec ff ff       	call   800e9a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e7:	e8 ae ec ff ff       	call   800e9a <sys_page_unmap>
  8021ec:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8021ee:	83 c4 30             	add    $0x30,%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802202:	8b 45 08             	mov    0x8(%ebp),%eax
  802205:	89 04 24             	mov    %eax,(%esp)
  802208:	e8 89 ef ff ff       	call   801196 <fd_lookup>
  80220d:	89 c2                	mov    %eax,%edx
  80220f:	85 d2                	test   %edx,%edx
  802211:	78 15                	js     802228 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802216:	89 04 24             	mov    %eax,(%esp)
  802219:	e8 12 ef ff ff       	call   801130 <fd2data>
	return _pipeisclosed(fd, p);
  80221e:	89 c2                	mov    %eax,%edx
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	e8 0b fd ff ff       	call   801f33 <_pipeisclosed>
}
  802228:	c9                   	leave  
  802229:	c3                   	ret    
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802233:	b8 00 00 00 00       	mov    $0x0,%eax
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802240:	c7 44 24 04 e7 2c 80 	movl   $0x802ce7,0x4(%esp)
  802247:	00 
  802248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224b:	89 04 24             	mov    %eax,(%esp)
  80224e:	e8 84 e7 ff ff       	call   8009d7 <strcpy>
	return 0;
}
  802253:	b8 00 00 00 00       	mov    $0x0,%eax
  802258:	c9                   	leave  
  802259:	c3                   	ret    

0080225a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	57                   	push   %edi
  80225e:	56                   	push   %esi
  80225f:	53                   	push   %ebx
  802260:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802266:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80226b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802271:	eb 31                	jmp    8022a4 <devcons_write+0x4a>
		m = n - tot;
  802273:	8b 75 10             	mov    0x10(%ebp),%esi
  802276:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802278:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80227b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802280:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802283:	89 74 24 08          	mov    %esi,0x8(%esp)
  802287:	03 45 0c             	add    0xc(%ebp),%eax
  80228a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228e:	89 3c 24             	mov    %edi,(%esp)
  802291:	e8 de e8 ff ff       	call   800b74 <memmove>
		sys_cputs(buf, m);
  802296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80229a:	89 3c 24             	mov    %edi,(%esp)
  80229d:	e8 84 ea ff ff       	call   800d26 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a2:	01 f3                	add    %esi,%ebx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022a9:	72 c8                	jb     802273 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022ab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5f                   	pop    %edi
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    

008022b6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8022bc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8022c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022c5:	75 07                	jne    8022ce <devcons_read+0x18>
  8022c7:	eb 2a                	jmp    8022f3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022c9:	e8 06 eb ff ff       	call   800dd4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022ce:	66 90                	xchg   %ax,%ax
  8022d0:	e8 6f ea ff ff       	call   800d44 <sys_cgetc>
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	74 f0                	je     8022c9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 16                	js     8022f3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022dd:	83 f8 04             	cmp    $0x4,%eax
  8022e0:	74 0c                	je     8022ee <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8022e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022e5:	88 02                	mov    %al,(%edx)
	return 1;
  8022e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ec:	eb 05                	jmp    8022f3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022ee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8022fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802308:	00 
  802309:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80230c:	89 04 24             	mov    %eax,(%esp)
  80230f:	e8 12 ea ff ff       	call   800d26 <sys_cputs>
}
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <getchar>:

int
getchar(void)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80231c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802323:	00 
  802324:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802332:	e8 f3 f0 ff ff       	call   80142a <read>
	if (r < 0)
  802337:	85 c0                	test   %eax,%eax
  802339:	78 0f                	js     80234a <getchar+0x34>
		return r;
	if (r < 1)
  80233b:	85 c0                	test   %eax,%eax
  80233d:	7e 06                	jle    802345 <getchar+0x2f>
		return -E_EOF;
	return c;
  80233f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802343:	eb 05                	jmp    80234a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802345:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    

0080234c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802355:	89 44 24 04          	mov    %eax,0x4(%esp)
  802359:	8b 45 08             	mov    0x8(%ebp),%eax
  80235c:	89 04 24             	mov    %eax,(%esp)
  80235f:	e8 32 ee ff ff       	call   801196 <fd_lookup>
  802364:	85 c0                	test   %eax,%eax
  802366:	78 11                	js     802379 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802371:	39 10                	cmp    %edx,(%eax)
  802373:	0f 94 c0             	sete   %al
  802376:	0f b6 c0             	movzbl %al,%eax
}
  802379:	c9                   	leave  
  80237a:	c3                   	ret    

0080237b <opencons>:

int
opencons(void)
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802384:	89 04 24             	mov    %eax,(%esp)
  802387:	e8 bb ed ff ff       	call   801147 <fd_alloc>
		return r;
  80238c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 40                	js     8023d2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802392:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802399:	00 
  80239a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a8:	e8 46 ea ff ff       	call   800df3 <sys_page_alloc>
		return r;
  8023ad:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 1f                	js     8023d2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023b3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023c8:	89 04 24             	mov    %eax,(%esp)
  8023cb:	e8 50 ed ff ff       	call   801120 <fd2num>
  8023d0:	89 c2                	mov    %eax,%edx
}
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    
  8023d6:	66 90                	xchg   %ax,%ax
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	56                   	push   %esi
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 10             	sub    $0x10,%esp
  8023e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8023eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023f8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8023fb:	89 04 24             	mov    %eax,(%esp)
  8023fe:	e8 06 ec ff ff       	call   801009 <sys_ipc_recv>

	if(ret < 0) {
  802403:	85 c0                	test   %eax,%eax
  802405:	79 16                	jns    80241d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802407:	85 f6                	test   %esi,%esi
  802409:	74 06                	je     802411 <ipc_recv+0x31>
  80240b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802411:	85 db                	test   %ebx,%ebx
  802413:	74 3e                	je     802453 <ipc_recv+0x73>
  802415:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80241b:	eb 36                	jmp    802453 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80241d:	e8 93 e9 ff ff       	call   800db5 <sys_getenvid>
  802422:	25 ff 03 00 00       	and    $0x3ff,%eax
  802427:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80242a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80242f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802434:	85 f6                	test   %esi,%esi
  802436:	74 05                	je     80243d <ipc_recv+0x5d>
  802438:	8b 40 74             	mov    0x74(%eax),%eax
  80243b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80243d:	85 db                	test   %ebx,%ebx
  80243f:	74 0a                	je     80244b <ipc_recv+0x6b>
  802441:	a1 08 40 80 00       	mov    0x804008,%eax
  802446:	8b 40 78             	mov    0x78(%eax),%eax
  802449:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80244b:	a1 08 40 80 00       	mov    0x804008,%eax
  802450:	8b 40 70             	mov    0x70(%eax),%eax
}
  802453:	83 c4 10             	add    $0x10,%esp
  802456:	5b                   	pop    %ebx
  802457:	5e                   	pop    %esi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    

0080245a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	57                   	push   %edi
  80245e:	56                   	push   %esi
  80245f:	53                   	push   %ebx
  802460:	83 ec 1c             	sub    $0x1c,%esp
  802463:	8b 7d 08             	mov    0x8(%ebp),%edi
  802466:	8b 75 0c             	mov    0xc(%ebp),%esi
  802469:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80246c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80246e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802473:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802476:	8b 45 14             	mov    0x14(%ebp),%eax
  802479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80247d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802481:	89 74 24 04          	mov    %esi,0x4(%esp)
  802485:	89 3c 24             	mov    %edi,(%esp)
  802488:	e8 59 eb ff ff       	call   800fe6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80248d:	85 c0                	test   %eax,%eax
  80248f:	79 2c                	jns    8024bd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802491:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802494:	74 20                	je     8024b6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249a:	c7 44 24 08 f4 2c 80 	movl   $0x802cf4,0x8(%esp)
  8024a1:	00 
  8024a2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024a9:	00 
  8024aa:	c7 04 24 24 2d 80 00 	movl   $0x802d24,(%esp)
  8024b1:	e8 f9 dd ff ff       	call   8002af <_panic>
		}
		sys_yield();
  8024b6:	e8 19 e9 ff ff       	call   800dd4 <sys_yield>
	}
  8024bb:	eb b9                	jmp    802476 <ipc_send+0x1c>
}
  8024bd:	83 c4 1c             	add    $0x1c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024cb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024d0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024d9:	8b 52 50             	mov    0x50(%edx),%edx
  8024dc:	39 ca                	cmp    %ecx,%edx
  8024de:	75 0d                	jne    8024ed <ipc_find_env+0x28>
			return envs[i].env_id;
  8024e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024e3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8024e8:	8b 40 40             	mov    0x40(%eax),%eax
  8024eb:	eb 0e                	jmp    8024fb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024ed:	83 c0 01             	add    $0x1,%eax
  8024f0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024f5:	75 d9                	jne    8024d0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024f7:	66 b8 00 00          	mov    $0x0,%ax
}
  8024fb:	5d                   	pop    %ebp
  8024fc:	c3                   	ret    

008024fd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802503:	89 d0                	mov    %edx,%eax
  802505:	c1 e8 16             	shr    $0x16,%eax
  802508:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80250f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802514:	f6 c1 01             	test   $0x1,%cl
  802517:	74 1d                	je     802536 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802519:	c1 ea 0c             	shr    $0xc,%edx
  80251c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802523:	f6 c2 01             	test   $0x1,%dl
  802526:	74 0e                	je     802536 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802528:	c1 ea 0c             	shr    $0xc,%edx
  80252b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802532:	ef 
  802533:	0f b7 c0             	movzwl %ax,%eax
}
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	83 ec 0c             	sub    $0xc,%esp
  802546:	8b 44 24 28          	mov    0x28(%esp),%eax
  80254a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80254e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802552:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802556:	85 c0                	test   %eax,%eax
  802558:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80255c:	89 ea                	mov    %ebp,%edx
  80255e:	89 0c 24             	mov    %ecx,(%esp)
  802561:	75 2d                	jne    802590 <__udivdi3+0x50>
  802563:	39 e9                	cmp    %ebp,%ecx
  802565:	77 61                	ja     8025c8 <__udivdi3+0x88>
  802567:	85 c9                	test   %ecx,%ecx
  802569:	89 ce                	mov    %ecx,%esi
  80256b:	75 0b                	jne    802578 <__udivdi3+0x38>
  80256d:	b8 01 00 00 00       	mov    $0x1,%eax
  802572:	31 d2                	xor    %edx,%edx
  802574:	f7 f1                	div    %ecx
  802576:	89 c6                	mov    %eax,%esi
  802578:	31 d2                	xor    %edx,%edx
  80257a:	89 e8                	mov    %ebp,%eax
  80257c:	f7 f6                	div    %esi
  80257e:	89 c5                	mov    %eax,%ebp
  802580:	89 f8                	mov    %edi,%eax
  802582:	f7 f6                	div    %esi
  802584:	89 ea                	mov    %ebp,%edx
  802586:	83 c4 0c             	add    $0xc,%esp
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    
  80258d:	8d 76 00             	lea    0x0(%esi),%esi
  802590:	39 e8                	cmp    %ebp,%eax
  802592:	77 24                	ja     8025b8 <__udivdi3+0x78>
  802594:	0f bd e8             	bsr    %eax,%ebp
  802597:	83 f5 1f             	xor    $0x1f,%ebp
  80259a:	75 3c                	jne    8025d8 <__udivdi3+0x98>
  80259c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025a0:	39 34 24             	cmp    %esi,(%esp)
  8025a3:	0f 86 9f 00 00 00    	jbe    802648 <__udivdi3+0x108>
  8025a9:	39 d0                	cmp    %edx,%eax
  8025ab:	0f 82 97 00 00 00    	jb     802648 <__udivdi3+0x108>
  8025b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	31 c0                	xor    %eax,%eax
  8025bc:	83 c4 0c             	add    $0xc,%esp
  8025bf:	5e                   	pop    %esi
  8025c0:	5f                   	pop    %edi
  8025c1:	5d                   	pop    %ebp
  8025c2:	c3                   	ret    
  8025c3:	90                   	nop
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	89 f8                	mov    %edi,%eax
  8025ca:	f7 f1                	div    %ecx
  8025cc:	31 d2                	xor    %edx,%edx
  8025ce:	83 c4 0c             	add    $0xc,%esp
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	8d 76 00             	lea    0x0(%esi),%esi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	8b 3c 24             	mov    (%esp),%edi
  8025dd:	d3 e0                	shl    %cl,%eax
  8025df:	89 c6                	mov    %eax,%esi
  8025e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8025e6:	29 e8                	sub    %ebp,%eax
  8025e8:	89 c1                	mov    %eax,%ecx
  8025ea:	d3 ef                	shr    %cl,%edi
  8025ec:	89 e9                	mov    %ebp,%ecx
  8025ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8025f2:	8b 3c 24             	mov    (%esp),%edi
  8025f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8025f9:	89 d6                	mov    %edx,%esi
  8025fb:	d3 e7                	shl    %cl,%edi
  8025fd:	89 c1                	mov    %eax,%ecx
  8025ff:	89 3c 24             	mov    %edi,(%esp)
  802602:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802606:	d3 ee                	shr    %cl,%esi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	d3 e2                	shl    %cl,%edx
  80260c:	89 c1                	mov    %eax,%ecx
  80260e:	d3 ef                	shr    %cl,%edi
  802610:	09 d7                	or     %edx,%edi
  802612:	89 f2                	mov    %esi,%edx
  802614:	89 f8                	mov    %edi,%eax
  802616:	f7 74 24 08          	divl   0x8(%esp)
  80261a:	89 d6                	mov    %edx,%esi
  80261c:	89 c7                	mov    %eax,%edi
  80261e:	f7 24 24             	mull   (%esp)
  802621:	39 d6                	cmp    %edx,%esi
  802623:	89 14 24             	mov    %edx,(%esp)
  802626:	72 30                	jb     802658 <__udivdi3+0x118>
  802628:	8b 54 24 04          	mov    0x4(%esp),%edx
  80262c:	89 e9                	mov    %ebp,%ecx
  80262e:	d3 e2                	shl    %cl,%edx
  802630:	39 c2                	cmp    %eax,%edx
  802632:	73 05                	jae    802639 <__udivdi3+0xf9>
  802634:	3b 34 24             	cmp    (%esp),%esi
  802637:	74 1f                	je     802658 <__udivdi3+0x118>
  802639:	89 f8                	mov    %edi,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	e9 7a ff ff ff       	jmp    8025bc <__udivdi3+0x7c>
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	31 d2                	xor    %edx,%edx
  80264a:	b8 01 00 00 00       	mov    $0x1,%eax
  80264f:	e9 68 ff ff ff       	jmp    8025bc <__udivdi3+0x7c>
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	8d 47 ff             	lea    -0x1(%edi),%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	83 c4 0c             	add    $0xc,%esp
  802660:	5e                   	pop    %esi
  802661:	5f                   	pop    %edi
  802662:	5d                   	pop    %ebp
  802663:	c3                   	ret    
  802664:	66 90                	xchg   %ax,%ax
  802666:	66 90                	xchg   %ax,%ax
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	83 ec 14             	sub    $0x14,%esp
  802676:	8b 44 24 28          	mov    0x28(%esp),%eax
  80267a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80267e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802682:	89 c7                	mov    %eax,%edi
  802684:	89 44 24 04          	mov    %eax,0x4(%esp)
  802688:	8b 44 24 30          	mov    0x30(%esp),%eax
  80268c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802690:	89 34 24             	mov    %esi,(%esp)
  802693:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802697:	85 c0                	test   %eax,%eax
  802699:	89 c2                	mov    %eax,%edx
  80269b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80269f:	75 17                	jne    8026b8 <__umoddi3+0x48>
  8026a1:	39 fe                	cmp    %edi,%esi
  8026a3:	76 4b                	jbe    8026f0 <__umoddi3+0x80>
  8026a5:	89 c8                	mov    %ecx,%eax
  8026a7:	89 fa                	mov    %edi,%edx
  8026a9:	f7 f6                	div    %esi
  8026ab:	89 d0                	mov    %edx,%eax
  8026ad:	31 d2                	xor    %edx,%edx
  8026af:	83 c4 14             	add    $0x14,%esp
  8026b2:	5e                   	pop    %esi
  8026b3:	5f                   	pop    %edi
  8026b4:	5d                   	pop    %ebp
  8026b5:	c3                   	ret    
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	39 f8                	cmp    %edi,%eax
  8026ba:	77 54                	ja     802710 <__umoddi3+0xa0>
  8026bc:	0f bd e8             	bsr    %eax,%ebp
  8026bf:	83 f5 1f             	xor    $0x1f,%ebp
  8026c2:	75 5c                	jne    802720 <__umoddi3+0xb0>
  8026c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8026c8:	39 3c 24             	cmp    %edi,(%esp)
  8026cb:	0f 87 e7 00 00 00    	ja     8027b8 <__umoddi3+0x148>
  8026d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026d5:	29 f1                	sub    %esi,%ecx
  8026d7:	19 c7                	sbb    %eax,%edi
  8026d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026e9:	83 c4 14             	add    $0x14,%esp
  8026ec:	5e                   	pop    %esi
  8026ed:	5f                   	pop    %edi
  8026ee:	5d                   	pop    %ebp
  8026ef:	c3                   	ret    
  8026f0:	85 f6                	test   %esi,%esi
  8026f2:	89 f5                	mov    %esi,%ebp
  8026f4:	75 0b                	jne    802701 <__umoddi3+0x91>
  8026f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	f7 f6                	div    %esi
  8026ff:	89 c5                	mov    %eax,%ebp
  802701:	8b 44 24 04          	mov    0x4(%esp),%eax
  802705:	31 d2                	xor    %edx,%edx
  802707:	f7 f5                	div    %ebp
  802709:	89 c8                	mov    %ecx,%eax
  80270b:	f7 f5                	div    %ebp
  80270d:	eb 9c                	jmp    8026ab <__umoddi3+0x3b>
  80270f:	90                   	nop
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 fa                	mov    %edi,%edx
  802714:	83 c4 14             	add    $0x14,%esp
  802717:	5e                   	pop    %esi
  802718:	5f                   	pop    %edi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    
  80271b:	90                   	nop
  80271c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802720:	8b 04 24             	mov    (%esp),%eax
  802723:	be 20 00 00 00       	mov    $0x20,%esi
  802728:	89 e9                	mov    %ebp,%ecx
  80272a:	29 ee                	sub    %ebp,%esi
  80272c:	d3 e2                	shl    %cl,%edx
  80272e:	89 f1                	mov    %esi,%ecx
  802730:	d3 e8                	shr    %cl,%eax
  802732:	89 e9                	mov    %ebp,%ecx
  802734:	89 44 24 04          	mov    %eax,0x4(%esp)
  802738:	8b 04 24             	mov    (%esp),%eax
  80273b:	09 54 24 04          	or     %edx,0x4(%esp)
  80273f:	89 fa                	mov    %edi,%edx
  802741:	d3 e0                	shl    %cl,%eax
  802743:	89 f1                	mov    %esi,%ecx
  802745:	89 44 24 08          	mov    %eax,0x8(%esp)
  802749:	8b 44 24 10          	mov    0x10(%esp),%eax
  80274d:	d3 ea                	shr    %cl,%edx
  80274f:	89 e9                	mov    %ebp,%ecx
  802751:	d3 e7                	shl    %cl,%edi
  802753:	89 f1                	mov    %esi,%ecx
  802755:	d3 e8                	shr    %cl,%eax
  802757:	89 e9                	mov    %ebp,%ecx
  802759:	09 f8                	or     %edi,%eax
  80275b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80275f:	f7 74 24 04          	divl   0x4(%esp)
  802763:	d3 e7                	shl    %cl,%edi
  802765:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802769:	89 d7                	mov    %edx,%edi
  80276b:	f7 64 24 08          	mull   0x8(%esp)
  80276f:	39 d7                	cmp    %edx,%edi
  802771:	89 c1                	mov    %eax,%ecx
  802773:	89 14 24             	mov    %edx,(%esp)
  802776:	72 2c                	jb     8027a4 <__umoddi3+0x134>
  802778:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80277c:	72 22                	jb     8027a0 <__umoddi3+0x130>
  80277e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802782:	29 c8                	sub    %ecx,%eax
  802784:	19 d7                	sbb    %edx,%edi
  802786:	89 e9                	mov    %ebp,%ecx
  802788:	89 fa                	mov    %edi,%edx
  80278a:	d3 e8                	shr    %cl,%eax
  80278c:	89 f1                	mov    %esi,%ecx
  80278e:	d3 e2                	shl    %cl,%edx
  802790:	89 e9                	mov    %ebp,%ecx
  802792:	d3 ef                	shr    %cl,%edi
  802794:	09 d0                	or     %edx,%eax
  802796:	89 fa                	mov    %edi,%edx
  802798:	83 c4 14             	add    $0x14,%esp
  80279b:	5e                   	pop    %esi
  80279c:	5f                   	pop    %edi
  80279d:	5d                   	pop    %ebp
  80279e:	c3                   	ret    
  80279f:	90                   	nop
  8027a0:	39 d7                	cmp    %edx,%edi
  8027a2:	75 da                	jne    80277e <__umoddi3+0x10e>
  8027a4:	8b 14 24             	mov    (%esp),%edx
  8027a7:	89 c1                	mov    %eax,%ecx
  8027a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8027ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8027b1:	eb cb                	jmp    80277e <__umoddi3+0x10e>
  8027b3:	90                   	nop
  8027b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8027bc:	0f 82 0f ff ff ff    	jb     8026d1 <__umoddi3+0x61>
  8027c2:	e9 1a ff ff ff       	jmp    8026e1 <__umoddi3+0x71>
