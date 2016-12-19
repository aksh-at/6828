
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 d5 03 00 00       	call   800406 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80004b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	eb 0c                	jmp    800063 <sum+0x23>
		tot ^= i * s[i];
  800057:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80005b:	0f af ca             	imul   %edx,%ecx
  80005e:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800060:	83 c2 01             	add    $0x1,%edx
  800063:	39 da                	cmp    %ebx,%edx
  800065:	7c f0                	jl     800057 <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800067:	5b                   	pop    %ebx
  800068:	5e                   	pop    %esi
  800069:	5d                   	pop    %ebp
  80006a:	c3                   	ret    

0080006b <umain>:

void
umain(int argc, char **argv)
{
  80006b:	55                   	push   %ebp
  80006c:	89 e5                	mov    %esp,%ebp
  80006e:	57                   	push   %edi
  80006f:	56                   	push   %esi
  800070:	53                   	push   %ebx
  800071:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800077:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80007a:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800081:	e8 da 04 00 00       	call   800560 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800086:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008d:	00 
  80008e:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  800095:	e8 a6 ff ff ff       	call   800040 <sum>
  80009a:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009f:	74 1a                	je     8000bb <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a1:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a8:	00 
  8000a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ad:	c7 04 24 48 2f 80 00 	movl   $0x802f48,(%esp)
  8000b4:	e8 a7 04 00 00       	call   800560 <cprintf>
  8000b9:	eb 0c                	jmp    8000c7 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000bb:	c7 04 24 8f 2e 80 00 	movl   $0x802e8f,(%esp)
  8000c2:	e8 99 04 00 00       	call   800560 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c7:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000ce:	00 
  8000cf:	c7 04 24 20 60 80 00 	movl   $0x806020,(%esp)
  8000d6:	e8 65 ff ff ff       	call   800040 <sum>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	74 12                	je     8000f1 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e3:	c7 04 24 84 2f 80 00 	movl   $0x802f84,(%esp)
  8000ea:	e8 71 04 00 00       	call   800560 <cprintf>
  8000ef:	eb 0c                	jmp    8000fd <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000f1:	c7 04 24 a6 2e 80 00 	movl   $0x802ea6,(%esp)
  8000f8:	e8 63 04 00 00       	call   800560 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000fd:	c7 44 24 04 bc 2e 80 	movl   $0x802ebc,0x4(%esp)
  800104:	00 
  800105:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010b:	89 04 24             	mov    %eax,(%esp)
  80010e:	e8 94 0a 00 00       	call   800ba7 <strcat>
	for (i = 0; i < argc; i++) {
  800113:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800118:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80011e:	eb 32                	jmp    800152 <umain+0xe7>
		strcat(args, " '");
  800120:	c7 44 24 04 c8 2e 80 	movl   $0x802ec8,0x4(%esp)
  800127:	00 
  800128:	89 34 24             	mov    %esi,(%esp)
  80012b:	e8 77 0a 00 00       	call   800ba7 <strcat>
		strcat(args, argv[i]);
  800130:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	89 34 24             	mov    %esi,(%esp)
  80013a:	e8 68 0a 00 00       	call   800ba7 <strcat>
		strcat(args, "'");
  80013f:	c7 44 24 04 c9 2e 80 	movl   $0x802ec9,0x4(%esp)
  800146:	00 
  800147:	89 34 24             	mov    %esi,(%esp)
  80014a:	e8 58 0a 00 00       	call   800ba7 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80014f:	83 c3 01             	add    $0x1,%ebx
  800152:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800155:	7c c9                	jl     800120 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800157:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 cb 2e 80 00 	movl   $0x802ecb,(%esp)
  800168:	e8 f3 03 00 00       	call   800560 <cprintf>

	cprintf("init: running sh\n");
  80016d:	c7 04 24 cf 2e 80 00 	movl   $0x802ecf,(%esp)
  800174:	e8 e7 03 00 00       	call   800560 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800180:	e8 f2 12 00 00       	call   801477 <close>
	if ((r = opencons()) < 0)
  800185:	e8 21 02 00 00       	call   8003ab <opencons>
  80018a:	85 c0                	test   %eax,%eax
  80018c:	79 20                	jns    8001ae <umain+0x143>
		panic("opencons: %e", r);
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	c7 44 24 08 e1 2e 80 	movl   $0x802ee1,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 ee 2e 80 00 	movl   $0x802eee,(%esp)
  8001a9:	e8 b9 02 00 00       	call   800467 <_panic>
	if (r != 0)
  8001ae:	85 c0                	test   %eax,%eax
  8001b0:	74 20                	je     8001d2 <umain+0x167>
		panic("first opencons used fd %d", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 fa 2e 80 	movl   $0x802efa,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 ee 2e 80 00 	movl   $0x802eee,(%esp)
  8001cd:	e8 95 02 00 00       	call   800467 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e1:	e8 e6 12 00 00       	call   8014cc <dup>
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	79 20                	jns    80020a <umain+0x19f>
		panic("dup: %e", r);
  8001ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ee:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 ee 2e 80 00 	movl   $0x802eee,(%esp)
  800205:	e8 5d 02 00 00       	call   800467 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  80020a:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800211:	e8 4a 03 00 00       	call   800560 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800216:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80021d:	00 
  80021e:	c7 44 24 04 30 2f 80 	movl   $0x802f30,0x4(%esp)
  800225:	00 
  800226:	c7 04 24 2f 2f 80 00 	movl   $0x802f2f,(%esp)
  80022d:	e8 f5 1e 00 00       	call   802127 <spawnl>
		if (r < 0) {
  800232:	85 c0                	test   %eax,%eax
  800234:	79 12                	jns    800248 <umain+0x1dd>
			cprintf("init: spawn sh: %e\n", r);
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  800241:	e8 1a 03 00 00       	call   800560 <cprintf>
			continue;
  800246:	eb c2                	jmp    80020a <umain+0x19f>
		}
		wait(r);
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 da 27 00 00       	call   802a2a <wait>
  800250:	eb b8                	jmp    80020a <umain+0x19f>
  800252:	66 90                	xchg   %ax,%ax
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800270:	c7 44 24 04 b3 2f 80 	movl   $0x802fb3,0x4(%esp)
  800277:	00 
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 04 09 00 00       	call   800b87 <strcpy>
	return 0;
}
  800283:	b8 00 00 00 00       	mov    $0x0,%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80029b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002a1:	eb 31                	jmp    8002d4 <devcons_write+0x4a>
		m = n - tot;
  8002a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8002a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8002a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8002ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8002b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8002b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002b7:	03 45 0c             	add    0xc(%ebp),%eax
  8002ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002be:	89 3c 24             	mov    %edi,(%esp)
  8002c1:	e8 5e 0a 00 00       	call   800d24 <memmove>
		sys_cputs(buf, m);
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	89 3c 24             	mov    %edi,(%esp)
  8002cd:	e8 04 0c 00 00       	call   800ed6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002d2:	01 f3                	add    %esi,%ebx
  8002d4:	89 d8                	mov    %ebx,%eax
  8002d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002d9:	72 c8                	jb     8002a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8002f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002f5:	75 07                	jne    8002fe <devcons_read+0x18>
  8002f7:	eb 2a                	jmp    800323 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002f9:	e8 86 0c 00 00       	call   800f84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002fe:	66 90                	xchg   %ax,%ax
  800300:	e8 ef 0b 00 00       	call   800ef4 <sys_cgetc>
  800305:	85 c0                	test   %eax,%eax
  800307:	74 f0                	je     8002f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800309:	85 c0                	test   %eax,%eax
  80030b:	78 16                	js     800323 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80030d:	83 f8 04             	cmp    $0x4,%eax
  800310:	74 0c                	je     80031e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800312:	8b 55 0c             	mov    0xc(%ebp),%edx
  800315:	88 02                	mov    %al,(%edx)
	return 1;
  800317:	b8 01 00 00 00       	mov    $0x1,%eax
  80031c:	eb 05                	jmp    800323 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800331:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 92 0b 00 00       	call   800ed6 <sys_cputs>
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <getchar>:

int
getchar(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80034c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800353:	00 
  800354:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800362:	e8 73 12 00 00       	call   8015da <read>
	if (r < 0)
  800367:	85 c0                	test   %eax,%eax
  800369:	78 0f                	js     80037a <getchar+0x34>
		return r;
	if (r < 1)
  80036b:	85 c0                	test   %eax,%eax
  80036d:	7e 06                	jle    800375 <getchar+0x2f>
		return -E_EOF;
	return c;
  80036f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800373:	eb 05                	jmp    80037a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800375:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 b2 0f 00 00       	call   801346 <fd_lookup>
  800394:	85 c0                	test   %eax,%eax
  800396:	78 11                	js     8003a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80039b:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003a1:	39 10                	cmp    %edx,(%eax)
  8003a3:	0f 94 c0             	sete   %al
  8003a6:	0f b6 c0             	movzbl %al,%eax
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <opencons>:

int
opencons(void)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 3b 0f 00 00       	call   8012f7 <fd_alloc>
		return r;
  8003bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	78 40                	js     800402 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003c9:	00 
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003d8:	e8 c6 0b 00 00       	call   800fa3 <sys_page_alloc>
		return r;
  8003dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	78 1f                	js     800402 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003e3:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 d0 0e 00 00       	call   8012d0 <fd2num>
  800400:	89 c2                	mov    %eax,%edx
}
  800402:	89 d0                	mov    %edx,%eax
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 10             	sub    $0x10,%esp
  80040e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800411:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800414:	e8 4c 0b 00 00       	call   800f65 <sys_getenvid>
  800419:	25 ff 03 00 00       	and    $0x3ff,%eax
  80041e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800421:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800426:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	7e 07                	jle    800436 <libmain+0x30>
		binaryname = argv[0];
  80042f:	8b 06                	mov    (%esi),%eax
  800431:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  800436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043a:	89 1c 24             	mov    %ebx,(%esp)
  80043d:	e8 29 fc ff ff       	call   80006b <umain>

	// exit gracefully
	exit();
  800442:	e8 07 00 00 00       	call   80044e <exit>
}
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800454:	e8 51 10 00 00       	call   8014aa <close_all>
	sys_env_destroy(0);
  800459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800460:	e8 ae 0a 00 00       	call   800f13 <sys_env_destroy>
}
  800465:	c9                   	leave  
  800466:	c3                   	ret    

00800467 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80046f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800472:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  800478:	e8 e8 0a 00 00       	call   800f65 <sys_getenvid>
  80047d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800480:	89 54 24 10          	mov    %edx,0x10(%esp)
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800493:	c7 04 24 cc 2f 80 00 	movl   $0x802fcc,(%esp)
  80049a:	e8 c1 00 00 00       	call   800560 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 51 00 00 00       	call   8004ff <vcprintf>
	cprintf("\n");
  8004ae:	c7 04 24 07 35 80 00 	movl   $0x803507,(%esp)
  8004b5:	e8 a6 00 00 00       	call   800560 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ba:	cc                   	int3   
  8004bb:	eb fd                	jmp    8004ba <_panic+0x53>

008004bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	53                   	push   %ebx
  8004c1:	83 ec 14             	sub    $0x14,%esp
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c7:	8b 13                	mov    (%ebx),%edx
  8004c9:	8d 42 01             	lea    0x1(%edx),%eax
  8004cc:	89 03                	mov    %eax,(%ebx)
  8004ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004da:	75 19                	jne    8004f5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004dc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e3:	00 
  8004e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	e8 e7 09 00 00       	call   800ed6 <sys_cputs>
		b->idx = 0;
  8004ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f9:	83 c4 14             	add    $0x14,%esp
  8004fc:	5b                   	pop    %ebx
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800508:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050f:	00 00 00 
	b.cnt = 0;
  800512:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800519:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	c7 04 24 bd 04 80 00 	movl   $0x8004bd,(%esp)
  80053b:	e8 ae 01 00 00       	call   8006ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800540:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800546:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 7e 09 00 00       	call   800ed6 <sys_cputs>

	return b.cnt;
}
  800558:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800566:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 87 ff ff ff       	call   8004ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800578:	c9                   	leave  
  800579:	c3                   	ret    
  80057a:	66 90                	xchg   %ax,%ax
  80057c:	66 90                	xchg   %ax,%ax
  80057e:	66 90                	xchg   %ax,%ax

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 3c             	sub    $0x3c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d7                	mov    %edx,%edi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 c3                	mov    %eax,%ebx
  800599:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80059c:	8b 45 10             	mov    0x10(%ebp),%eax
  80059f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ad:	39 d9                	cmp    %ebx,%ecx
  8005af:	72 05                	jb     8005b6 <printnum+0x36>
  8005b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005b4:	77 69                	ja     80061f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005bd:	83 ee 01             	sub    $0x1,%esi
  8005c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005d0:	89 c3                	mov    %eax,%ebx
  8005d2:	89 d6                	mov    %edx,%esi
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	e8 fc 25 00 00       	call   802bf0 <__udivdi3>
  8005f4:	89 d9                	mov    %ebx,%ecx
  8005f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	89 fa                	mov    %edi,%edx
  800607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060a:	e8 71 ff ff ff       	call   800580 <printnum>
  80060f:	eb 1b                	jmp    80062c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	8b 45 18             	mov    0x18(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff d3                	call   *%ebx
  80061d:	eb 03                	jmp    800622 <printnum+0xa2>
  80061f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800622:	83 ee 01             	sub    $0x1,%esi
  800625:	85 f6                	test   %esi,%esi
  800627:	7f e8                	jg     800611 <printnum+0x91>
  800629:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80062c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800630:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800642:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	e8 cc 26 00 00       	call   802d20 <__umoddi3>
  800654:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800658:	0f be 80 ef 2f 80 00 	movsbl 0x802fef(%eax),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800665:	ff d0                	call   *%eax
}
  800667:	83 c4 3c             	add    $0x3c,%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800672:	83 fa 01             	cmp    $0x1,%edx
  800675:	7e 0e                	jle    800685 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800677:	8b 10                	mov    (%eax),%edx
  800679:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067c:	89 08                	mov    %ecx,(%eax)
  80067e:	8b 02                	mov    (%edx),%eax
  800680:	8b 52 04             	mov    0x4(%edx),%edx
  800683:	eb 22                	jmp    8006a7 <getuint+0x38>
	else if (lflag)
  800685:	85 d2                	test   %edx,%edx
  800687:	74 10                	je     800699 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068e:	89 08                	mov    %ecx,(%eax)
  800690:	8b 02                	mov    (%edx),%eax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
  800697:	eb 0e                	jmp    8006a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069e:	89 08                	mov    %ecx,(%eax)
  8006a0:	8b 02                	mov    (%edx),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b8:	73 0a                	jae    8006c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006bd:	89 08                	mov    %ecx,(%eax)
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	88 02                	mov    %al,(%edx)
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 02 00 00 00       	call   8006ee <vprintfmt>
	va_end(ap);
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	57                   	push   %edi
  8006f2:	56                   	push   %esi
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 3c             	sub    $0x3c,%esp
  8006f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006fd:	eb 14                	jmp    800713 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 b3 03 00 00    	je     800aba <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800707:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800711:	89 f3                	mov    %esi,%ebx
  800713:	8d 73 01             	lea    0x1(%ebx),%esi
  800716:	0f b6 03             	movzbl (%ebx),%eax
  800719:	83 f8 25             	cmp    $0x25,%eax
  80071c:	75 e1                	jne    8006ff <vprintfmt+0x11>
  80071e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800722:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800729:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800730:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	eb 1d                	jmp    80075b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800740:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800744:	eb 15                	jmp    80075b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800748:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80074c:	eb 0d                	jmp    80075b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80074e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800751:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800754:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80075e:	0f b6 0e             	movzbl (%esi),%ecx
  800761:	0f b6 c1             	movzbl %cl,%eax
  800764:	83 e9 23             	sub    $0x23,%ecx
  800767:	80 f9 55             	cmp    $0x55,%cl
  80076a:	0f 87 2a 03 00 00    	ja     800a9a <vprintfmt+0x3ac>
  800770:	0f b6 c9             	movzbl %cl,%ecx
  800773:	ff 24 8d 40 31 80 00 	jmp    *0x803140(,%ecx,4)
  80077a:	89 de                	mov    %ebx,%esi
  80077c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800781:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800784:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800788:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80078b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80078e:	83 fb 09             	cmp    $0x9,%ebx
  800791:	77 36                	ja     8007c9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800793:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800796:	eb e9                	jmp    800781 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 48 04             	lea    0x4(%eax),%ecx
  80079e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a8:	eb 22                	jmp    8007cc <vprintfmt+0xde>
  8007aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ad:	85 c9                	test   %ecx,%ecx
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	0f 49 c1             	cmovns %ecx,%eax
  8007b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	89 de                	mov    %ebx,%esi
  8007bc:	eb 9d                	jmp    80075b <vprintfmt+0x6d>
  8007be:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007c7:	eb 92                	jmp    80075b <vprintfmt+0x6d>
  8007c9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d0:	79 89                	jns    80075b <vprintfmt+0x6d>
  8007d2:	e9 77 ff ff ff       	jmp    80074e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007da:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007dc:	e9 7a ff ff ff       	jmp    80075b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f6:	e9 18 ff ff ff       	jmp    800713 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 50 04             	lea    0x4(%eax),%edx
  800801:	89 55 14             	mov    %edx,0x14(%ebp)
  800804:	8b 00                	mov    (%eax),%eax
  800806:	99                   	cltd   
  800807:	31 d0                	xor    %edx,%eax
  800809:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80080b:	83 f8 0f             	cmp    $0xf,%eax
  80080e:	7f 0b                	jg     80081b <vprintfmt+0x12d>
  800810:	8b 14 85 a0 32 80 00 	mov    0x8032a0(,%eax,4),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	75 20                	jne    80083b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80081b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081f:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800826:	00 
  800827:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 90 fe ff ff       	call   8006c6 <printfmt>
  800836:	e9 d8 fe ff ff       	jmp    800713 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80083b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80083f:	c7 44 24 08 d5 33 80 	movl   $0x8033d5,0x8(%esp)
  800846:	00 
  800847:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 70 fe ff ff       	call   8006c6 <printfmt>
  800856:	e9 b8 fe ff ff       	jmp    800713 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80085e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800861:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8d 50 04             	lea    0x4(%eax),%edx
  80086a:	89 55 14             	mov    %edx,0x14(%ebp)
  80086d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80086f:	85 f6                	test   %esi,%esi
  800871:	b8 00 30 80 00       	mov    $0x803000,%eax
  800876:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800879:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80087d:	0f 84 97 00 00 00    	je     80091a <vprintfmt+0x22c>
  800883:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800887:	0f 8e 9b 00 00 00    	jle    800928 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800891:	89 34 24             	mov    %esi,(%esp)
  800894:	e8 cf 02 00 00       	call   800b68 <strnlen>
  800899:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80089c:	29 c2                	sub    %eax,%edx
  80089e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008b1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b3:	eb 0f                	jmp    8008c4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c1:	83 eb 01             	sub    $0x1,%ebx
  8008c4:	85 db                	test   %ebx,%ebx
  8008c6:	7f ed                	jg     8008b5 <vprintfmt+0x1c7>
  8008c8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	0f 49 c2             	cmovns %edx,%eax
  8008d8:	29 c2                	sub    %eax,%edx
  8008da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8008dd:	89 d7                	mov    %edx,%edi
  8008df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008e2:	eb 50                	jmp    800934 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e8:	74 1e                	je     800908 <vprintfmt+0x21a>
  8008ea:	0f be d2             	movsbl %dl,%edx
  8008ed:	83 ea 20             	sub    $0x20,%edx
  8008f0:	83 fa 5e             	cmp    $0x5e,%edx
  8008f3:	76 13                	jbe    800908 <vprintfmt+0x21a>
					putch('?', putdat);
  8008f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800903:	ff 55 08             	call   *0x8(%ebp)
  800906:	eb 0d                	jmp    800915 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	eb 1a                	jmp    800934 <vprintfmt+0x246>
  80091a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80091d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800920:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800923:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800926:	eb 0c                	jmp    800934 <vprintfmt+0x246>
  800928:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80092b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80092e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800931:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800934:	83 c6 01             	add    $0x1,%esi
  800937:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80093b:	0f be c2             	movsbl %dl,%eax
  80093e:	85 c0                	test   %eax,%eax
  800940:	74 27                	je     800969 <vprintfmt+0x27b>
  800942:	85 db                	test   %ebx,%ebx
  800944:	78 9e                	js     8008e4 <vprintfmt+0x1f6>
  800946:	83 eb 01             	sub    $0x1,%ebx
  800949:	79 99                	jns    8008e4 <vprintfmt+0x1f6>
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	89 c3                	mov    %eax,%ebx
  800955:	eb 1a                	jmp    800971 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800957:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800962:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800964:	83 eb 01             	sub    $0x1,%ebx
  800967:	eb 08                	jmp    800971 <vprintfmt+0x283>
  800969:	89 fb                	mov    %edi,%ebx
  80096b:	8b 75 08             	mov    0x8(%ebp),%esi
  80096e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800971:	85 db                	test   %ebx,%ebx
  800973:	7f e2                	jg     800957 <vprintfmt+0x269>
  800975:	89 75 08             	mov    %esi,0x8(%ebp)
  800978:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80097b:	e9 93 fd ff ff       	jmp    800713 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800980:	83 fa 01             	cmp    $0x1,%edx
  800983:	7e 16                	jle    80099b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8d 50 08             	lea    0x8(%eax),%edx
  80098b:	89 55 14             	mov    %edx,0x14(%ebp)
  80098e:	8b 50 04             	mov    0x4(%eax),%edx
  800991:	8b 00                	mov    (%eax),%eax
  800993:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800996:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800999:	eb 32                	jmp    8009cd <vprintfmt+0x2df>
	else if (lflag)
  80099b:	85 d2                	test   %edx,%edx
  80099d:	74 18                	je     8009b7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8d 50 04             	lea    0x4(%eax),%edx
  8009a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a8:	8b 30                	mov    (%eax),%esi
  8009aa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009ad:	89 f0                	mov    %esi,%eax
  8009af:	c1 f8 1f             	sar    $0x1f,%eax
  8009b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b5:	eb 16                	jmp    8009cd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	8d 50 04             	lea    0x4(%eax),%edx
  8009bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c0:	8b 30                	mov    (%eax),%esi
  8009c2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009c5:	89 f0                	mov    %esi,%eax
  8009c7:	c1 f8 1f             	sar    $0x1f,%eax
  8009ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009dc:	0f 89 80 00 00 00    	jns    800a62 <vprintfmt+0x374>
				putch('-', putdat);
  8009e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f6:	f7 d8                	neg    %eax
  8009f8:	83 d2 00             	adc    $0x0,%edx
  8009fb:	f7 da                	neg    %edx
			}
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a02:	eb 5e                	jmp    800a62 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 63 fc ff ff       	call   80066f <getuint>
			base = 10;
  800a0c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a11:	eb 4f                	jmp    800a62 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a13:	8d 45 14             	lea    0x14(%ebp),%eax
  800a16:	e8 54 fc ff ff       	call   80066f <getuint>
			base = 8;
  800a1b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a20:	eb 40                	jmp    800a62 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a22:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a26:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a2d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a30:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a34:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8d 50 04             	lea    0x4(%eax),%edx
  800a44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a47:	8b 00                	mov    (%eax),%eax
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a53:	eb 0d                	jmp    800a62 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	e8 12 fc ff ff       	call   80066f <getuint>
			base = 16;
  800a5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a62:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800a66:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a6a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a6d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a71:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a7c:	89 fa                	mov    %edi,%edx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	e8 fa fa ff ff       	call   800580 <printnum>
			break;
  800a86:	e9 88 fc ff ff       	jmp    800713 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8f:	89 04 24             	mov    %eax,(%esp)
  800a92:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a95:	e9 79 fc ff ff       	jmp    800713 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	eb 03                	jmp    800aaf <vprintfmt+0x3c1>
  800aac:	83 eb 01             	sub    $0x1,%ebx
  800aaf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ab3:	75 f7                	jne    800aac <vprintfmt+0x3be>
  800ab5:	e9 59 fc ff ff       	jmp    800713 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800aba:	83 c4 3c             	add    $0x3c,%esp
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	83 ec 28             	sub    $0x28,%esp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ace:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	74 30                	je     800b13 <vsnprintf+0x51>
  800ae3:	85 d2                	test   %edx,%edx
  800ae5:	7e 2c                	jle    800b13 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aee:	8b 45 10             	mov    0x10(%ebp),%eax
  800af1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afc:	c7 04 24 a9 06 80 00 	movl   $0x8006a9,(%esp)
  800b03:	e8 e6 fb ff ff       	call   8006ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b11:	eb 05                	jmp    800b18 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b20:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	e8 82 ff ff ff       	call   800ac2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    
  800b42:	66 90                	xchg   %ax,%ax
  800b44:	66 90                	xchg   %ax,%ax
  800b46:	66 90                	xchg   %ax,%ax
  800b48:	66 90                	xchg   %ax,%ax
  800b4a:	66 90                	xchg   %ax,%ax
  800b4c:	66 90                	xchg   %ax,%ax
  800b4e:	66 90                	xchg   %ax,%ax

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	eb 03                	jmp    800b60 <strlen+0x10>
		n++;
  800b5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b64:	75 f7                	jne    800b5d <strlen+0xd>
		n++;
	return n;
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb 03                	jmp    800b7b <strnlen+0x13>
		n++;
  800b78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7b:	39 d0                	cmp    %edx,%eax
  800b7d:	74 06                	je     800b85 <strnlen+0x1d>
  800b7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b83:	75 f3                	jne    800b78 <strnlen+0x10>
		n++;
	return n;
}
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	53                   	push   %ebx
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
  800b99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	75 ef                	jne    800b93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 97 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc0:	01 d8                	add    %ebx,%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 bd ff ff ff       	call   800b87 <strcpy>
	return dst;
}
  800bca:	89 d8                	mov    %ebx,%eax
  800bcc:	83 c4 08             	add    $0x8,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be2:	89 f2                	mov    %esi,%edx
  800be4:	eb 0f                	jmp    800bf5 <strncpy+0x23>
		*dst++ = *src;
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bef:	80 39 01             	cmpb   $0x1,(%ecx)
  800bf2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf5:	39 da                	cmp    %ebx,%edx
  800bf7:	75 ed                	jne    800be6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 75 08             	mov    0x8(%ebp),%esi
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c13:	85 c9                	test   %ecx,%ecx
  800c15:	75 0b                	jne    800c22 <strlcpy+0x23>
  800c17:	eb 1d                	jmp    800c36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c22:	39 d8                	cmp    %ebx,%eax
  800c24:	74 0b                	je     800c31 <strlcpy+0x32>
  800c26:	0f b6 0a             	movzbl (%edx),%ecx
  800c29:	84 c9                	test   %cl,%cl
  800c2b:	75 ec                	jne    800c19 <strlcpy+0x1a>
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	eb 02                	jmp    800c33 <strlcpy+0x34>
  800c31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c36:	29 f0                	sub    %esi,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c45:	eb 06                	jmp    800c4d <strcmp+0x11>
		p++, q++;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c4d:	0f b6 01             	movzbl (%ecx),%eax
  800c50:	84 c0                	test   %al,%al
  800c52:	74 04                	je     800c58 <strcmp+0x1c>
  800c54:	3a 02                	cmp    (%edx),%al
  800c56:	74 ef                	je     800c47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	0f b6 12             	movzbl (%edx),%edx
  800c5e:	29 d0                	sub    %edx,%eax
}
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	53                   	push   %ebx
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c71:	eb 06                	jmp    800c79 <strncmp+0x17>
		n--, p++, q++;
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c79:	39 d8                	cmp    %ebx,%eax
  800c7b:	74 15                	je     800c92 <strncmp+0x30>
  800c7d:	0f b6 08             	movzbl (%eax),%ecx
  800c80:	84 c9                	test   %cl,%cl
  800c82:	74 04                	je     800c88 <strncmp+0x26>
  800c84:	3a 0a                	cmp    (%edx),%cl
  800c86:	74 eb                	je     800c73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	0f b6 12             	movzbl (%edx),%edx
  800c8e:	29 d0                	sub    %edx,%eax
  800c90:	eb 05                	jmp    800c97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca4:	eb 07                	jmp    800cad <strchr+0x13>
		if (*s == c)
  800ca6:	38 ca                	cmp    %cl,%dl
  800ca8:	74 0f                	je     800cb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	0f b6 10             	movzbl (%eax),%edx
  800cb0:	84 d2                	test   %dl,%dl
  800cb2:	75 f2                	jne    800ca6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc5:	eb 07                	jmp    800cce <strfind+0x13>
		if (*s == c)
  800cc7:	38 ca                	cmp    %cl,%dl
  800cc9:	74 0a                	je     800cd5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ccb:	83 c0 01             	add    $0x1,%eax
  800cce:	0f b6 10             	movzbl (%eax),%edx
  800cd1:	84 d2                	test   %dl,%dl
  800cd3:	75 f2                	jne    800cc7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ce3:	85 c9                	test   %ecx,%ecx
  800ce5:	74 36                	je     800d1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ce7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ced:	75 28                	jne    800d17 <memset+0x40>
  800cef:	f6 c1 03             	test   $0x3,%cl
  800cf2:	75 23                	jne    800d17 <memset+0x40>
		c &= 0xFF;
  800cf4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	c1 e3 08             	shl    $0x8,%ebx
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	c1 e6 18             	shl    $0x18,%esi
  800d02:	89 d0                	mov    %edx,%eax
  800d04:	c1 e0 10             	shl    $0x10,%eax
  800d07:	09 f0                	or     %esi,%eax
  800d09:	09 c2                	or     %eax,%edx
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d12:	fc                   	cld    
  800d13:	f3 ab                	rep stos %eax,%es:(%edi)
  800d15:	eb 06                	jmp    800d1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	fc                   	cld    
  800d1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d1d:	89 f8                	mov    %edi,%eax
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d32:	39 c6                	cmp    %eax,%esi
  800d34:	73 35                	jae    800d6b <memmove+0x47>
  800d36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d39:	39 d0                	cmp    %edx,%eax
  800d3b:	73 2e                	jae    800d6b <memmove+0x47>
		s += n;
		d += n;
  800d3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4a:	75 13                	jne    800d5f <memmove+0x3b>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	75 0e                	jne    800d5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d51:	83 ef 04             	sub    $0x4,%edi
  800d54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d5a:	fd                   	std    
  800d5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d5d:	eb 09                	jmp    800d68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d5f:	83 ef 01             	sub    $0x1,%edi
  800d62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d65:	fd                   	std    
  800d66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d68:	fc                   	cld    
  800d69:	eb 1d                	jmp    800d88 <memmove+0x64>
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	f6 c2 03             	test   $0x3,%dl
  800d72:	75 0f                	jne    800d83 <memmove+0x5f>
  800d74:	f6 c1 03             	test   $0x3,%cl
  800d77:	75 0a                	jne    800d83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	fc                   	cld    
  800d7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d81:	eb 05                	jmp    800d88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	fc                   	cld    
  800d86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d92:	8b 45 10             	mov    0x10(%ebp),%eax
  800d95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	89 04 24             	mov    %eax,(%esp)
  800da6:	e8 79 ff ff ff       	call   800d24 <memmove>
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	eb 1a                	jmp    800dd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800dbf:	0f b6 02             	movzbl (%edx),%eax
  800dc2:	0f b6 19             	movzbl (%ecx),%ebx
  800dc5:	38 d8                	cmp    %bl,%al
  800dc7:	74 0a                	je     800dd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dc9:	0f b6 c0             	movzbl %al,%eax
  800dcc:	0f b6 db             	movzbl %bl,%ebx
  800dcf:	29 d8                	sub    %ebx,%eax
  800dd1:	eb 0f                	jmp    800de2 <memcmp+0x35>
		s1++, s2++;
  800dd3:	83 c2 01             	add    $0x1,%edx
  800dd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd9:	39 f2                	cmp    %esi,%edx
  800ddb:	75 e2                	jne    800dbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800def:	89 c2                	mov    %eax,%edx
  800df1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df4:	eb 07                	jmp    800dfd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df6:	38 08                	cmp    %cl,(%eax)
  800df8:	74 07                	je     800e01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	39 d0                	cmp    %edx,%eax
  800dff:	72 f5                	jb     800df6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0f:	eb 03                	jmp    800e14 <strtol+0x11>
		s++;
  800e11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e14:	0f b6 0a             	movzbl (%edx),%ecx
  800e17:	80 f9 09             	cmp    $0x9,%cl
  800e1a:	74 f5                	je     800e11 <strtol+0xe>
  800e1c:	80 f9 20             	cmp    $0x20,%cl
  800e1f:	74 f0                	je     800e11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e21:	80 f9 2b             	cmp    $0x2b,%cl
  800e24:	75 0a                	jne    800e30 <strtol+0x2d>
		s++;
  800e26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e29:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2e:	eb 11                	jmp    800e41 <strtol+0x3e>
  800e30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e35:	80 f9 2d             	cmp    $0x2d,%cl
  800e38:	75 07                	jne    800e41 <strtol+0x3e>
		s++, neg = 1;
  800e3a:	8d 52 01             	lea    0x1(%edx),%edx
  800e3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e46:	75 15                	jne    800e5d <strtol+0x5a>
  800e48:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4b:	75 10                	jne    800e5d <strtol+0x5a>
  800e4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e51:	75 0a                	jne    800e5d <strtol+0x5a>
		s += 2, base = 16;
  800e53:	83 c2 02             	add    $0x2,%edx
  800e56:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5b:	eb 10                	jmp    800e6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	75 0c                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e63:	80 3a 30             	cmpb   $0x30,(%edx)
  800e66:	75 05                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
  800e68:	83 c2 01             	add    $0x1,%edx
  800e6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e75:	0f b6 0a             	movzbl (%edx),%ecx
  800e78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e7b:	89 f0                	mov    %esi,%eax
  800e7d:	3c 09                	cmp    $0x9,%al
  800e7f:	77 08                	ja     800e89 <strtol+0x86>
			dig = *s - '0';
  800e81:	0f be c9             	movsbl %cl,%ecx
  800e84:	83 e9 30             	sub    $0x30,%ecx
  800e87:	eb 20                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e8c:	89 f0                	mov    %esi,%eax
  800e8e:	3c 19                	cmp    $0x19,%al
  800e90:	77 08                	ja     800e9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e92:	0f be c9             	movsbl %cl,%ecx
  800e95:	83 e9 57             	sub    $0x57,%ecx
  800e98:	eb 0f                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e9d:	89 f0                	mov    %esi,%eax
  800e9f:	3c 19                	cmp    $0x19,%al
  800ea1:	77 16                	ja     800eb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ea3:	0f be c9             	movsbl %cl,%ecx
  800ea6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ea9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800eac:	7d 0f                	jge    800ebd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800eae:	83 c2 01             	add    $0x1,%edx
  800eb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800eb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800eb7:	eb bc                	jmp    800e75 <strtol+0x72>
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	eb 02                	jmp    800ebf <strtol+0xbc>
  800ebd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec3:	74 05                	je     800eca <strtol+0xc7>
		*endptr = (char *) s;
  800ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800eca:	f7 d8                	neg    %eax
  800ecc:	85 ff                	test   %edi,%edi
  800ece:	0f 44 c3             	cmove  %ebx,%eax
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	89 c7                	mov    %eax,%edi
  800eeb:	89 c6                	mov    %eax,%esi
  800eed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 01 00 00 00       	mov    $0x1,%eax
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 d3                	mov    %edx,%ebx
  800f08:	89 d7                	mov    %edx,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f21:	b8 03 00 00 00       	mov    $0x3,%eax
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 cb                	mov    %ecx,%ebx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	89 ce                	mov    %ecx,%esi
  800f2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  800f58:	e8 0a f5 ff ff       	call   800467 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f5d:	83 c4 2c             	add    $0x2c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 02 00 00 00       	mov    $0x2,%eax
  800f75:	89 d1                	mov    %edx,%ecx
  800f77:	89 d3                	mov    %edx,%ebx
  800f79:	89 d7                	mov    %edx,%edi
  800f7b:	89 d6                	mov    %edx,%esi
  800f7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_yield>:

void
sys_yield(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 d3                	mov    %edx,%ebx
  800f98:	89 d7                	mov    %edx,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	89 f7                	mov    %esi,%edi
  800fc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  800fea:	e8 78 f4 ff ff       	call   800467 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fef:	83 c4 2c             	add    $0x2c,%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801000:	b8 05 00 00 00       	mov    $0x5,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	8b 75 18             	mov    0x18(%ebp),%esi
  801014:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7e 28                	jle    801042 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801025:	00 
  801026:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  80103d:	e8 25 f4 ff ff       	call   800467 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801042:	83 c4 2c             	add    $0x2c,%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	b8 06 00 00 00       	mov    $0x6,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 df                	mov    %ebx,%edi
  801065:	89 de                	mov    %ebx,%esi
  801067:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  801090:	e8 d2 f3 ff ff       	call   800467 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801095:	83 c4 2c             	add    $0x2c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  8010e3:	e8 7f f3 ff ff       	call   800467 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e8:	83 c4 2c             	add    $0x2c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 df                	mov    %ebx,%edi
  80110b:	89 de                	mov    %ebx,%esi
  80110d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	7e 28                	jle    80113b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801113:	89 44 24 10          	mov    %eax,0x10(%esp)
  801117:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80111e:	00 
  80111f:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  801136:	e8 2c f3 ff ff       	call   800467 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80113b:	83 c4 2c             	add    $0x2c,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 0a 00 00 00       	mov    $0xa,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	89 de                	mov    %ebx,%esi
  801160:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 28                	jle    80118e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801171:	00 
  801172:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  801189:	e8 d9 f2 ff ff       	call   800467 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80118e:	83 c4 2c             	add    $0x2c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119c:	be 00 00 00 00       	mov    $0x0,%esi
  8011a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	89 cb                	mov    %ecx,%ebx
  8011d1:	89 cf                	mov    %ecx,%edi
  8011d3:	89 ce                	mov    %ecx,%esi
  8011d5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7e 28                	jle    801203 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f6:	00 
  8011f7:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  8011fe:	e8 64 f2 ff ff       	call   800467 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801203:	83 c4 2c             	add    $0x2c,%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	ba 00 00 00 00       	mov    $0x0,%edx
  801216:	b8 0e 00 00 00       	mov    $0xe,%eax
  80121b:	89 d1                	mov    %edx,%ecx
  80121d:	89 d3                	mov    %edx,%ebx
  80121f:	89 d7                	mov    %edx,%edi
  801221:	89 d6                	mov    %edx,%esi
  801223:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
  801238:	b8 0f 00 00 00       	mov    $0xf,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 df                	mov    %ebx,%edi
  801245:	89 de                	mov    %ebx,%esi
  801247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	7e 28                	jle    801275 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801251:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801258:	00 
  801259:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  801270:	e8 f2 f1 ff ff       	call   800467 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801275:	83 c4 2c             	add    $0x2c,%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
  801283:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	b8 10 00 00 00       	mov    $0x10,%eax
  801290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	89 df                	mov    %ebx,%edi
  801298:	89 de                	mov    %ebx,%esi
  80129a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80129c:	85 c0                	test   %eax,%eax
  80129e:	7e 28                	jle    8012c8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 08 ff 32 80 	movl   $0x8032ff,0x8(%esp)
  8012b3:	00 
  8012b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bb:	00 
  8012bc:	c7 04 24 1c 33 80 00 	movl   $0x80331c,(%esp)
  8012c3:	e8 9f f1 ff ff       	call   800467 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8012c8:	83 c4 2c             	add    $0x2c,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801302:	89 c2                	mov    %eax,%edx
  801304:	c1 ea 16             	shr    $0x16,%edx
  801307:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130e:	f6 c2 01             	test   $0x1,%dl
  801311:	74 11                	je     801324 <fd_alloc+0x2d>
  801313:	89 c2                	mov    %eax,%edx
  801315:	c1 ea 0c             	shr    $0xc,%edx
  801318:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131f:	f6 c2 01             	test   $0x1,%dl
  801322:	75 09                	jne    80132d <fd_alloc+0x36>
			*fd_store = fd;
  801324:	89 01                	mov    %eax,(%ecx)
			return 0;
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	eb 17                	jmp    801344 <fd_alloc+0x4d>
  80132d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801332:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801337:	75 c9                	jne    801302 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801339:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134c:	83 f8 1f             	cmp    $0x1f,%eax
  80134f:	77 36                	ja     801387 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801351:	c1 e0 0c             	shl    $0xc,%eax
  801354:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801359:	89 c2                	mov    %eax,%edx
  80135b:	c1 ea 16             	shr    $0x16,%edx
  80135e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801365:	f6 c2 01             	test   $0x1,%dl
  801368:	74 24                	je     80138e <fd_lookup+0x48>
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	c1 ea 0c             	shr    $0xc,%edx
  80136f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801376:	f6 c2 01             	test   $0x1,%dl
  801379:	74 1a                	je     801395 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 02                	mov    %eax,(%edx)
	return 0;
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	eb 13                	jmp    80139a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138c:	eb 0c                	jmp    80139a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801393:	eb 05                	jmp    80139a <fd_lookup+0x54>
  801395:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 18             	sub    $0x18,%esp
  8013a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013aa:	eb 13                	jmp    8013bf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8013ac:	39 08                	cmp    %ecx,(%eax)
  8013ae:	75 0c                	jne    8013bc <dev_lookup+0x20>
			*dev = devtab[i];
  8013b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ba:	eb 38                	jmp    8013f4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013bc:	83 c2 01             	add    $0x1,%edx
  8013bf:	8b 04 95 a8 33 80 00 	mov    0x8033a8(,%edx,4),%eax
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	75 e2                	jne    8013ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ca:	a1 90 77 80 00       	mov    0x807790,%eax
  8013cf:	8b 40 48             	mov    0x48(%eax),%eax
  8013d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	c7 04 24 2c 33 80 00 	movl   $0x80332c,(%esp)
  8013e1:	e8 7a f1 ff ff       	call   800560 <cprintf>
	*dev = 0;
  8013e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 20             	sub    $0x20,%esp
  8013fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 2a ff ff ff       	call   801346 <fd_lookup>
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 05                	js     801425 <fd_close+0x2f>
	    || fd != fd2)
  801420:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801423:	74 0c                	je     801431 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801425:	84 db                	test   %bl,%bl
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	0f 44 c2             	cmove  %edx,%eax
  80142f:	eb 3f                	jmp    801470 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	8b 06                	mov    (%esi),%eax
  80143a:	89 04 24             	mov    %eax,(%esp)
  80143d:	e8 5a ff ff ff       	call   80139c <dev_lookup>
  801442:	89 c3                	mov    %eax,%ebx
  801444:	85 c0                	test   %eax,%eax
  801446:	78 16                	js     80145e <fd_close+0x68>
		if (dev->dev_close)
  801448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80144e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801453:	85 c0                	test   %eax,%eax
  801455:	74 07                	je     80145e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801457:	89 34 24             	mov    %esi,(%esp)
  80145a:	ff d0                	call   *%eax
  80145c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801462:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801469:	e8 dc fb ff ff       	call   80104a <sys_page_unmap>
	return r;
  80146e:	89 d8                	mov    %ebx,%eax
}
  801470:	83 c4 20             	add    $0x20,%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	89 44 24 04          	mov    %eax,0x4(%esp)
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 b7 fe ff ff       	call   801346 <fd_lookup>
  80148f:	89 c2                	mov    %eax,%edx
  801491:	85 d2                	test   %edx,%edx
  801493:	78 13                	js     8014a8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801495:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80149c:	00 
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	89 04 24             	mov    %eax,(%esp)
  8014a3:	e8 4e ff ff ff       	call   8013f6 <fd_close>
}
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <close_all>:

void
close_all(void)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b6:	89 1c 24             	mov    %ebx,(%esp)
  8014b9:	e8 b9 ff ff ff       	call   801477 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014be:	83 c3 01             	add    $0x1,%ebx
  8014c1:	83 fb 20             	cmp    $0x20,%ebx
  8014c4:	75 f0                	jne    8014b6 <close_all+0xc>
		close(i);
}
  8014c6:	83 c4 14             	add    $0x14,%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	57                   	push   %edi
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 5f fe ff ff       	call   801346 <fd_lookup>
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	85 d2                	test   %edx,%edx
  8014eb:	0f 88 e1 00 00 00    	js     8015d2 <dup+0x106>
		return r;
	close(newfdnum);
  8014f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f4:	89 04 24             	mov    %eax,(%esp)
  8014f7:	e8 7b ff ff ff       	call   801477 <close>

	newfd = INDEX2FD(newfdnum);
  8014fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ff:	c1 e3 0c             	shl    $0xc,%ebx
  801502:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 cd fd ff ff       	call   8012e0 <fd2data>
  801513:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801515:	89 1c 24             	mov    %ebx,(%esp)
  801518:	e8 c3 fd ff ff       	call   8012e0 <fd2data>
  80151d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151f:	89 f0                	mov    %esi,%eax
  801521:	c1 e8 16             	shr    $0x16,%eax
  801524:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80152b:	a8 01                	test   $0x1,%al
  80152d:	74 43                	je     801572 <dup+0xa6>
  80152f:	89 f0                	mov    %esi,%eax
  801531:	c1 e8 0c             	shr    $0xc,%eax
  801534:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80153b:	f6 c2 01             	test   $0x1,%dl
  80153e:	74 32                	je     801572 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801540:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801547:	25 07 0e 00 00       	and    $0xe07,%eax
  80154c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801550:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801554:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80155b:	00 
  80155c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801560:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801567:	e8 8b fa ff ff       	call   800ff7 <sys_page_map>
  80156c:	89 c6                	mov    %eax,%esi
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 3e                	js     8015b0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801575:	89 c2                	mov    %eax,%edx
  801577:	c1 ea 0c             	shr    $0xc,%edx
  80157a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801581:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801587:	89 54 24 10          	mov    %edx,0x10(%esp)
  80158b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80158f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801596:	00 
  801597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a2:	e8 50 fa ff ff       	call   800ff7 <sys_page_map>
  8015a7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ac:	85 f6                	test   %esi,%esi
  8015ae:	79 22                	jns    8015d2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015bb:	e8 8a fa ff ff       	call   80104a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015cb:	e8 7a fa ff ff       	call   80104a <sys_page_unmap>
	return r;
  8015d0:	89 f0                	mov    %esi,%eax
}
  8015d2:	83 c4 3c             	add    $0x3c,%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 24             	sub    $0x24,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 53 fd ff ff       	call   801346 <fd_lookup>
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	78 6d                	js     801666 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	8b 00                	mov    (%eax),%eax
  801605:	89 04 24             	mov    %eax,(%esp)
  801608:	e8 8f fd ff ff       	call   80139c <dev_lookup>
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 55                	js     801666 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801614:	8b 50 08             	mov    0x8(%eax),%edx
  801617:	83 e2 03             	and    $0x3,%edx
  80161a:	83 fa 01             	cmp    $0x1,%edx
  80161d:	75 23                	jne    801642 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161f:	a1 90 77 80 00       	mov    0x807790,%eax
  801624:	8b 40 48             	mov    0x48(%eax),%eax
  801627:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80162b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162f:	c7 04 24 6d 33 80 00 	movl   $0x80336d,(%esp)
  801636:	e8 25 ef ff ff       	call   800560 <cprintf>
		return -E_INVAL;
  80163b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801640:	eb 24                	jmp    801666 <read+0x8c>
	}
	if (!dev->dev_read)
  801642:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801645:	8b 52 08             	mov    0x8(%edx),%edx
  801648:	85 d2                	test   %edx,%edx
  80164a:	74 15                	je     801661 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80164c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80164f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801653:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801656:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80165a:	89 04 24             	mov    %eax,(%esp)
  80165d:	ff d2                	call   *%edx
  80165f:	eb 05                	jmp    801666 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801661:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801666:	83 c4 24             	add    $0x24,%esp
  801669:	5b                   	pop    %ebx
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 1c             	sub    $0x1c,%esp
  801675:	8b 7d 08             	mov    0x8(%ebp),%edi
  801678:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	eb 23                	jmp    8016a5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801682:	89 f0                	mov    %esi,%eax
  801684:	29 d8                	sub    %ebx,%eax
  801686:	89 44 24 08          	mov    %eax,0x8(%esp)
  80168a:	89 d8                	mov    %ebx,%eax
  80168c:	03 45 0c             	add    0xc(%ebp),%eax
  80168f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801693:	89 3c 24             	mov    %edi,(%esp)
  801696:	e8 3f ff ff ff       	call   8015da <read>
		if (m < 0)
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 10                	js     8016af <readn+0x43>
			return m;
		if (m == 0)
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	74 0a                	je     8016ad <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a3:	01 c3                	add    %eax,%ebx
  8016a5:	39 f3                	cmp    %esi,%ebx
  8016a7:	72 d9                	jb     801682 <readn+0x16>
  8016a9:	89 d8                	mov    %ebx,%eax
  8016ab:	eb 02                	jmp    8016af <readn+0x43>
  8016ad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016af:	83 c4 1c             	add    $0x1c,%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5f                   	pop    %edi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 24             	sub    $0x24,%esp
  8016be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	89 1c 24             	mov    %ebx,(%esp)
  8016cb:	e8 76 fc ff ff       	call   801346 <fd_lookup>
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	85 d2                	test   %edx,%edx
  8016d4:	78 68                	js     80173e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	8b 00                	mov    (%eax),%eax
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	e8 b2 fc ff ff       	call   80139c <dev_lookup>
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 50                	js     80173e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f5:	75 23                	jne    80171a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f7:	a1 90 77 80 00       	mov    0x807790,%eax
  8016fc:	8b 40 48             	mov    0x48(%eax),%eax
  8016ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801703:	89 44 24 04          	mov    %eax,0x4(%esp)
  801707:	c7 04 24 89 33 80 00 	movl   $0x803389,(%esp)
  80170e:	e8 4d ee ff ff       	call   800560 <cprintf>
		return -E_INVAL;
  801713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801718:	eb 24                	jmp    80173e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80171a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171d:	8b 52 0c             	mov    0xc(%edx),%edx
  801720:	85 d2                	test   %edx,%edx
  801722:	74 15                	je     801739 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801724:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801727:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801732:	89 04 24             	mov    %eax,(%esp)
  801735:	ff d2                	call   *%edx
  801737:	eb 05                	jmp    80173e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801739:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80173e:	83 c4 24             	add    $0x24,%esp
  801741:	5b                   	pop    %ebx
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <seek>:

int
seek(int fdnum, off_t offset)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 ea fb ff ff       	call   801346 <fd_lookup>
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 0e                	js     80176e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801760:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801763:	8b 55 0c             	mov    0xc(%ebp),%edx
  801766:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 24             	sub    $0x24,%esp
  801777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	89 1c 24             	mov    %ebx,(%esp)
  801784:	e8 bd fb ff ff       	call   801346 <fd_lookup>
  801789:	89 c2                	mov    %eax,%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	78 61                	js     8017f0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801799:	8b 00                	mov    (%eax),%eax
  80179b:	89 04 24             	mov    %eax,(%esp)
  80179e:	e8 f9 fb ff ff       	call   80139c <dev_lookup>
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 49                	js     8017f0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ae:	75 23                	jne    8017d3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b0:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b5:	8b 40 48             	mov    0x48(%eax),%eax
  8017b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	c7 04 24 4c 33 80 00 	movl   $0x80334c,(%esp)
  8017c7:	e8 94 ed ff ff       	call   800560 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d1:	eb 1d                	jmp    8017f0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8017d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d6:	8b 52 18             	mov    0x18(%edx),%edx
  8017d9:	85 d2                	test   %edx,%edx
  8017db:	74 0e                	je     8017eb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e4:	89 04 24             	mov    %eax,(%esp)
  8017e7:	ff d2                	call   *%edx
  8017e9:	eb 05                	jmp    8017f0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f0:	83 c4 24             	add    $0x24,%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 24             	sub    $0x24,%esp
  8017fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 34 fb ff ff       	call   801346 <fd_lookup>
  801812:	89 c2                	mov    %eax,%edx
  801814:	85 d2                	test   %edx,%edx
  801816:	78 52                	js     80186a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801822:	8b 00                	mov    (%eax),%eax
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	e8 70 fb ff ff       	call   80139c <dev_lookup>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 3a                	js     80186a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801830:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801833:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801837:	74 2c                	je     801865 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801839:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801843:	00 00 00 
	stat->st_isdir = 0;
  801846:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184d:	00 00 00 
	stat->st_dev = dev;
  801850:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801856:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80185d:	89 14 24             	mov    %edx,(%esp)
  801860:	ff 50 14             	call   *0x14(%eax)
  801863:	eb 05                	jmp    80186a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801865:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80186a:	83 c4 24             	add    $0x24,%esp
  80186d:	5b                   	pop    %ebx
  80186e:	5d                   	pop    %ebp
  80186f:	c3                   	ret    

00801870 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801878:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80187f:	00 
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 28 02 00 00       	call   801ab3 <open>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	85 db                	test   %ebx,%ebx
  80188f:	78 1b                	js     8018ac <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801891:	8b 45 0c             	mov    0xc(%ebp),%eax
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 56 ff ff ff       	call   8017f6 <fstat>
  8018a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a2:	89 1c 24             	mov    %ebx,(%esp)
  8018a5:	e8 cd fb ff ff       	call   801477 <close>
	return r;
  8018aa:	89 f0                	mov    %esi,%eax
}
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 10             	sub    $0x10,%esp
  8018bb:	89 c6                	mov    %eax,%esi
  8018bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018bf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8018c6:	75 11                	jne    8018d9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018cf:	e8 a1 12 00 00       	call   802b75 <ipc_find_env>
  8018d4:	a3 00 60 80 00       	mov    %eax,0x806000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018e0:	00 
  8018e1:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  8018e8:	00 
  8018e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018ed:	a1 00 60 80 00       	mov    0x806000,%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 10 12 00 00       	call   802b0a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801901:	00 
  801902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801906:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190d:	e8 7e 11 00 00       	call   802a90 <ipc_recv>
}
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	8b 40 0c             	mov    0xc(%eax),%eax
  801925:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80192a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192d:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801932:	ba 00 00 00 00       	mov    $0x0,%edx
  801937:	b8 02 00 00 00       	mov    $0x2,%eax
  80193c:	e8 72 ff ff ff       	call   8018b3 <fsipc>
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 40 0c             	mov    0xc(%eax),%eax
  80194f:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801954:	ba 00 00 00 00       	mov    $0x0,%edx
  801959:	b8 06 00 00 00       	mov    $0x6,%eax
  80195e:	e8 50 ff ff ff       	call   8018b3 <fsipc>
}
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	53                   	push   %ebx
  801969:	83 ec 14             	sub    $0x14,%esp
  80196c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	8b 40 0c             	mov    0xc(%eax),%eax
  801975:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
  80197f:	b8 05 00 00 00       	mov    $0x5,%eax
  801984:	e8 2a ff ff ff       	call   8018b3 <fsipc>
  801989:	89 c2                	mov    %eax,%edx
  80198b:	85 d2                	test   %edx,%edx
  80198d:	78 2b                	js     8019ba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198f:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801996:	00 
  801997:	89 1c 24             	mov    %ebx,(%esp)
  80199a:	e8 e8 f1 ff ff       	call   800b87 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199f:	a1 80 80 80 00       	mov    0x808080,%eax
  8019a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019aa:	a1 84 80 80 00       	mov    0x808084,%eax
  8019af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ba:	83 c4 14             	add    $0x14,%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 18             	sub    $0x18,%esp
  8019c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019ce:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8019dc:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  8019e2:	a3 04 80 80 00       	mov    %eax,0x808004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8019e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f2:	c7 04 24 08 80 80 00 	movl   $0x808008,(%esp)
  8019f9:	e8 26 f3 ff ff       	call   800d24 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  8019fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801a03:	b8 04 00 00 00       	mov    $0x4,%eax
  801a08:	e8 a6 fe ff ff       	call   8018b3 <fsipc>
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	83 ec 10             	sub    $0x10,%esp
  801a17:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a20:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801a25:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 03 00 00 00       	mov    $0x3,%eax
  801a35:	e8 79 fe ff ff       	call   8018b3 <fsipc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 6a                	js     801aaa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a40:	39 c6                	cmp    %eax,%esi
  801a42:	73 24                	jae    801a68 <devfile_read+0x59>
  801a44:	c7 44 24 0c bc 33 80 	movl   $0x8033bc,0xc(%esp)
  801a4b:	00 
  801a4c:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  801a53:	00 
  801a54:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a5b:	00 
  801a5c:	c7 04 24 d8 33 80 00 	movl   $0x8033d8,(%esp)
  801a63:	e8 ff e9 ff ff       	call   800467 <_panic>
	assert(r <= PGSIZE);
  801a68:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a6d:	7e 24                	jle    801a93 <devfile_read+0x84>
  801a6f:	c7 44 24 0c e3 33 80 	movl   $0x8033e3,0xc(%esp)
  801a76:	00 
  801a77:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  801a7e:	00 
  801a7f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a86:	00 
  801a87:	c7 04 24 d8 33 80 00 	movl   $0x8033d8,(%esp)
  801a8e:	e8 d4 e9 ff ff       	call   800467 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a97:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801a9e:	00 
  801a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 7a f2 ff ff       	call   800d24 <memmove>
	return r;
}
  801aaa:	89 d8                	mov    %ebx,%eax
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 24             	sub    $0x24,%esp
  801aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801abd:	89 1c 24             	mov    %ebx,(%esp)
  801ac0:	e8 8b f0 ff ff       	call   800b50 <strlen>
  801ac5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aca:	7f 60                	jg     801b2c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 20 f8 ff ff       	call   8012f7 <fd_alloc>
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	85 d2                	test   %edx,%edx
  801adb:	78 54                	js     801b31 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801add:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae1:	c7 04 24 00 80 80 00 	movl   $0x808000,(%esp)
  801ae8:	e8 9a f0 ff ff       	call   800b87 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af0:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af8:	b8 01 00 00 00       	mov    $0x1,%eax
  801afd:	e8 b1 fd ff ff       	call   8018b3 <fsipc>
  801b02:	89 c3                	mov    %eax,%ebx
  801b04:	85 c0                	test   %eax,%eax
  801b06:	79 17                	jns    801b1f <open+0x6c>
		fd_close(fd, 0);
  801b08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b0f:	00 
  801b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b13:	89 04 24             	mov    %eax,(%esp)
  801b16:	e8 db f8 ff ff       	call   8013f6 <fd_close>
		return r;
  801b1b:	89 d8                	mov    %ebx,%eax
  801b1d:	eb 12                	jmp    801b31 <open+0x7e>
	}

	return fd2num(fd);
  801b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b22:	89 04 24             	mov    %eax,(%esp)
  801b25:	e8 a6 f7 ff ff       	call   8012d0 <fd2num>
  801b2a:	eb 05                	jmp    801b31 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b2c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b31:	83 c4 24             	add    $0x24,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b42:	b8 08 00 00 00       	mov    $0x8,%eax
  801b47:	e8 67 fd ff ff       	call   8018b3 <fsipc>
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b63:	00 
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	89 04 24             	mov    %eax,(%esp)
  801b6a:	e8 44 ff ff ff       	call   801ab3 <open>
  801b6f:	89 c2                	mov    %eax,%edx
  801b71:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 3e 05 00 00    	js     8020bd <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b7f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801b86:	00 
  801b87:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b91:	89 14 24             	mov    %edx,(%esp)
  801b94:	e8 d3 fa ff ff       	call   80166c <readn>
  801b99:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b9e:	75 0c                	jne    801bac <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801ba0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ba7:	45 4c 46 
  801baa:	74 36                	je     801be2 <spawn+0x92>
		close(fd);
  801bac:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bb2:	89 04 24             	mov    %eax,(%esp)
  801bb5:	e8 bd f8 ff ff       	call   801477 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801bba:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801bc1:	46 
  801bc2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcc:	c7 04 24 ef 33 80 00 	movl   $0x8033ef,(%esp)
  801bd3:	e8 88 e9 ff ff       	call   800560 <cprintf>
		return -E_NOT_EXEC;
  801bd8:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801bdd:	e9 3a 05 00 00       	jmp    80211c <spawn+0x5cc>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801be2:	b8 07 00 00 00       	mov    $0x7,%eax
  801be7:	cd 30                	int    $0x30
  801be9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801bef:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 c8 04 00 00    	js     8020c5 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801bfd:	89 c6                	mov    %eax,%esi
  801bff:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c05:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801c08:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801c0e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c14:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c1b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c21:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c27:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c2c:	be 00 00 00 00       	mov    $0x0,%esi
  801c31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c34:	eb 0f                	jmp    801c45 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c36:	89 04 24             	mov    %eax,(%esp)
  801c39:	e8 12 ef ff ff       	call   800b50 <strlen>
  801c3e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c42:	83 c3 01             	add    $0x1,%ebx
  801c45:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801c4c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	75 e3                	jne    801c36 <spawn+0xe6>
  801c53:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801c59:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c5f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c64:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c66:	89 fa                	mov    %edi,%edx
  801c68:	83 e2 fc             	and    $0xfffffffc,%edx
  801c6b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c72:	29 c2                	sub    %eax,%edx
  801c74:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801c7a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801c7d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c82:	0f 86 4d 04 00 00    	jbe    8020d5 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c88:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c8f:	00 
  801c90:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c97:	00 
  801c98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9f:	e8 ff f2 ff ff       	call   800fa3 <sys_page_alloc>
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 70 04 00 00    	js     80211c <spawn+0x5cc>
  801cac:	be 00 00 00 00       	mov    $0x0,%esi
  801cb1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801cb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cba:	eb 30                	jmp    801cec <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801cbc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801cc2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801cc8:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801ccb:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd2:	89 3c 24             	mov    %edi,(%esp)
  801cd5:	e8 ad ee ff ff       	call   800b87 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801cda:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 6b ee ff ff       	call   800b50 <strlen>
  801ce5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ce9:	83 c6 01             	add    $0x1,%esi
  801cec:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801cf2:	7f c8                	jg     801cbc <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801cf4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801cfa:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d00:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d07:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d0d:	74 24                	je     801d33 <spawn+0x1e3>
  801d0f:	c7 44 24 0c 64 34 80 	movl   $0x803464,0xc(%esp)
  801d16:	00 
  801d17:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  801d1e:	00 
  801d1f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801d26:	00 
  801d27:	c7 04 24 09 34 80 00 	movl   $0x803409,(%esp)
  801d2e:	e8 34 e7 ff ff       	call   800467 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d33:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d39:	89 c8                	mov    %ecx,%eax
  801d3b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d40:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801d43:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d49:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d4c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801d52:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d58:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801d5f:	00 
  801d60:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801d67:	ee 
  801d68:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d72:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d79:	00 
  801d7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d81:	e8 71 f2 ff ff       	call   800ff7 <sys_page_map>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	0f 88 76 03 00 00    	js     802106 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d90:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d97:	00 
  801d98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9f:	e8 a6 f2 ff ff       	call   80104a <sys_page_unmap>
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	85 c0                	test   %eax,%eax
  801da8:	0f 88 58 03 00 00    	js     802106 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801dae:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801db4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801dbb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dc1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801dc8:	00 00 00 
  801dcb:	e9 b6 01 00 00       	jmp    801f86 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801dd0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801dd6:	83 38 01             	cmpl   $0x1,(%eax)
  801dd9:	0f 85 99 01 00 00    	jne    801f78 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ddf:	89 c2                	mov    %eax,%edx
  801de1:	8b 40 18             	mov    0x18(%eax),%eax
  801de4:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801de7:	83 f8 01             	cmp    $0x1,%eax
  801dea:	19 c0                	sbb    %eax,%eax
  801dec:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801df2:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801df9:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e00:	89 d0                	mov    %edx,%eax
  801e02:	8b 52 04             	mov    0x4(%edx),%edx
  801e05:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801e0b:	8b 50 10             	mov    0x10(%eax),%edx
  801e0e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801e14:	8b 48 14             	mov    0x14(%eax),%ecx
  801e17:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801e1d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e27:	74 14                	je     801e3d <spawn+0x2ed>
		va -= i;
  801e29:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e2b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801e31:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801e37:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e42:	e9 23 01 00 00       	jmp    801f6a <spawn+0x41a>
		if (i >= filesz) {
  801e47:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801e4d:	77 2b                	ja     801e7a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e4f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e5d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e63:	89 04 24             	mov    %eax,(%esp)
  801e66:	e8 38 f1 ff ff       	call   800fa3 <sys_page_alloc>
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	0f 89 eb 00 00 00    	jns    801f5e <spawn+0x40e>
  801e73:	89 c3                	mov    %eax,%ebx
  801e75:	e9 6c 02 00 00       	jmp    8020e6 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e7a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e81:	00 
  801e82:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e89:	00 
  801e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e91:	e8 0d f1 ff ff       	call   800fa3 <sys_page_alloc>
  801e96:	85 c0                	test   %eax,%eax
  801e98:	0f 88 3e 02 00 00    	js     8020dc <spawn+0x58c>
  801e9e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ea4:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eaa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eb0:	89 04 24             	mov    %eax,(%esp)
  801eb3:	e8 8c f8 ff ff       	call   801744 <seek>
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	0f 88 20 02 00 00    	js     8020e0 <spawn+0x590>
  801ec0:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ec6:	29 f9                	sub    %edi,%ecx
  801ec8:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801eca:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  801ed0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801ed5:	0f 47 c1             	cmova  %ecx,%eax
  801ed8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801edc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ee3:	00 
  801ee4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eea:	89 04 24             	mov    %eax,(%esp)
  801eed:	e8 7a f7 ff ff       	call   80166c <readn>
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 ea 01 00 00    	js     8020e4 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801efa:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f04:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f08:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f12:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f19:	00 
  801f1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f21:	e8 d1 f0 ff ff       	call   800ff7 <sys_page_map>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	79 20                	jns    801f4a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801f2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2e:	c7 44 24 08 15 34 80 	movl   $0x803415,0x8(%esp)
  801f35:	00 
  801f36:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801f3d:	00 
  801f3e:	c7 04 24 09 34 80 00 	movl   $0x803409,(%esp)
  801f45:	e8 1d e5 ff ff       	call   800467 <_panic>
			sys_page_unmap(0, UTEMP);
  801f4a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f51:	00 
  801f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f59:	e8 ec f0 ff ff       	call   80104a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f5e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f64:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f6a:	89 df                	mov    %ebx,%edi
  801f6c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801f72:	0f 87 cf fe ff ff    	ja     801e47 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f78:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f7f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f86:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f8d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f93:	0f 8c 37 fe ff ff    	jl     801dd0 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f99:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 d0 f4 ff ff       	call   801477 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  801fa7:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  801fac:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  801fb1:	89 d8                	mov    %ebx,%eax
  801fb3:	c1 e8 16             	shr    $0x16,%eax
  801fb6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	74 4e                	je     80200f <spawn+0x4bf>
  801fc1:	89 d8                	mov    %ebx,%eax
  801fc3:	c1 e8 0c             	shr    $0xc,%eax
  801fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fcd:	85 d2                	test   %edx,%edx
  801fcf:	74 3e                	je     80200f <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  801fd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fd8:	f6 c6 04             	test   $0x4,%dh
  801fdb:	74 32                	je     80200f <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801fdd:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  801fe4:	e8 7c ef ff ff       	call   800f65 <sys_getenvid>
  801fe9:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801fef:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801ff3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ff7:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801ffd:	89 54 24 08          	mov    %edx,0x8(%esp)
  802001:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 ea ef ff ff       	call   800ff7 <sys_page_map>
  80200d:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  80200f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802015:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80201b:	75 94                	jne    801fb1 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  80201d:	85 f6                	test   %esi,%esi
  80201f:	79 1c                	jns    80203d <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  802021:	c7 44 24 08 8c 34 80 	movl   $0x80348c,0x8(%esp)
  802028:	00 
  802029:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  802030:	00 
  802031:	c7 04 24 09 34 80 00 	movl   $0x803409,(%esp)
  802038:	e8 2a e4 ff ff       	call   800467 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80203d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802044:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802047:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802057:	89 04 24             	mov    %eax,(%esp)
  80205a:	e8 91 f0 ff ff       	call   8010f0 <sys_env_set_trapframe>
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 20                	jns    802083 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  802063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802067:	c7 44 24 08 32 34 80 	movl   $0x803432,0x8(%esp)
  80206e:	00 
  80206f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802076:	00 
  802077:	c7 04 24 09 34 80 00 	movl   $0x803409,(%esp)
  80207e:	e8 e4 e3 ff ff       	call   800467 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802083:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80208a:	00 
  80208b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802091:	89 04 24             	mov    %eax,(%esp)
  802094:	e8 04 f0 ff ff       	call   80109d <sys_env_set_status>
  802099:	85 c0                	test   %eax,%eax
  80209b:	79 30                	jns    8020cd <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  80209d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020a1:	c7 44 24 08 4c 34 80 	movl   $0x80344c,0x8(%esp)
  8020a8:	00 
  8020a9:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8020b0:	00 
  8020b1:	c7 04 24 09 34 80 00 	movl   $0x803409,(%esp)
  8020b8:	e8 aa e3 ff ff       	call   800467 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020bd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020c3:	eb 57                	jmp    80211c <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020c5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020cb:	eb 4f                	jmp    80211c <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020cd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020d3:	eb 47                	jmp    80211c <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8020d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8020da:	eb 40                	jmp    80211c <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	eb 06                	jmp    8020e6 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020e0:	89 c3                	mov    %eax,%ebx
  8020e2:	eb 02                	jmp    8020e6 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020e4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020e6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 1f ee ff ff       	call   800f13 <sys_env_destroy>
	close(fd);
  8020f4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020fa:	89 04 24             	mov    %eax,(%esp)
  8020fd:	e8 75 f3 ff ff       	call   801477 <close>
	return r;
  802102:	89 d8                	mov    %ebx,%eax
  802104:	eb 16                	jmp    80211c <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802106:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80210d:	00 
  80210e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802115:	e8 30 ef ff ff       	call   80104a <sys_page_unmap>
  80211a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80211c:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802122:	5b                   	pop    %ebx
  802123:	5e                   	pop    %esi
  802124:	5f                   	pop    %edi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80212f:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802132:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802137:	eb 03                	jmp    80213c <spawnl+0x15>
		argc++;
  802139:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80213c:	83 c0 04             	add    $0x4,%eax
  80213f:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802143:	75 f4                	jne    802139 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802145:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80214c:	83 e0 f0             	and    $0xfffffff0,%eax
  80214f:	29 c4                	sub    %eax,%esp
  802151:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802155:	c1 e8 02             	shr    $0x2,%eax
  802158:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80215f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802164:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80216b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802172:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
  802178:	eb 0a                	jmp    802184 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80217a:	83 c0 01             	add    $0x1,%eax
  80217d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802181:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802184:	39 d0                	cmp    %edx,%eax
  802186:	75 f2                	jne    80217a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218c:	8b 45 08             	mov    0x8(%ebp),%eax
  80218f:	89 04 24             	mov    %eax,(%esp)
  802192:	e8 b9 f9 ff ff       	call   801b50 <spawn>
}
  802197:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219a:	5b                   	pop    %ebx
  80219b:	5e                   	pop    %esi
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8021a6:	c7 44 24 04 b6 34 80 	movl   $0x8034b6,0x4(%esp)
  8021ad:	00 
  8021ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b1:	89 04 24             	mov    %eax,(%esp)
  8021b4:	e8 ce e9 ff ff       	call   800b87 <strcpy>
	return 0;
}
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 14             	sub    $0x14,%esp
  8021c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8021ca:	89 1c 24             	mov    %ebx,(%esp)
  8021cd:	e8 db 09 00 00       	call   802bad <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8021d2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8021d7:	83 f8 01             	cmp    $0x1,%eax
  8021da:	75 0d                	jne    8021e9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8021dc:	8b 43 0c             	mov    0xc(%ebx),%eax
  8021df:	89 04 24             	mov    %eax,(%esp)
  8021e2:	e8 29 03 00 00       	call   802510 <nsipc_close>
  8021e7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	83 c4 14             	add    $0x14,%esp
  8021ee:	5b                   	pop    %ebx
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8021f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021fe:	00 
  8021ff:	8b 45 10             	mov    0x10(%ebp),%eax
  802202:	89 44 24 08          	mov    %eax,0x8(%esp)
  802206:	8b 45 0c             	mov    0xc(%ebp),%eax
  802209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220d:	8b 45 08             	mov    0x8(%ebp),%eax
  802210:	8b 40 0c             	mov    0xc(%eax),%eax
  802213:	89 04 24             	mov    %eax,(%esp)
  802216:	e8 f0 03 00 00       	call   80260b <nsipc_send>
}
  80221b:	c9                   	leave  
  80221c:	c3                   	ret    

0080221d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80221d:	55                   	push   %ebp
  80221e:	89 e5                	mov    %esp,%ebp
  802220:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80222a:	00 
  80222b:	8b 45 10             	mov    0x10(%ebp),%eax
  80222e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802232:	8b 45 0c             	mov    0xc(%ebp),%eax
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	8b 40 0c             	mov    0xc(%eax),%eax
  80223f:	89 04 24             	mov    %eax,(%esp)
  802242:	e8 44 03 00 00       	call   80258b <nsipc_recv>
}
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80224f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802252:	89 54 24 04          	mov    %edx,0x4(%esp)
  802256:	89 04 24             	mov    %eax,(%esp)
  802259:	e8 e8 f0 ff ff       	call   801346 <fd_lookup>
  80225e:	85 c0                	test   %eax,%eax
  802260:	78 17                	js     802279 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  80226b:	39 08                	cmp    %ecx,(%eax)
  80226d:	75 05                	jne    802274 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80226f:	8b 40 0c             	mov    0xc(%eax),%eax
  802272:	eb 05                	jmp    802279 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802274:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	56                   	push   %esi
  80227f:	53                   	push   %ebx
  802280:	83 ec 20             	sub    $0x20,%esp
  802283:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802288:	89 04 24             	mov    %eax,(%esp)
  80228b:	e8 67 f0 ff ff       	call   8012f7 <fd_alloc>
  802290:	89 c3                	mov    %eax,%ebx
  802292:	85 c0                	test   %eax,%eax
  802294:	78 21                	js     8022b7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802296:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80229d:	00 
  80229e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ac:	e8 f2 ec ff ff       	call   800fa3 <sys_page_alloc>
  8022b1:	89 c3                	mov    %eax,%ebx
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	79 0c                	jns    8022c3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8022b7:	89 34 24             	mov    %esi,(%esp)
  8022ba:	e8 51 02 00 00       	call   802510 <nsipc_close>
		return r;
  8022bf:	89 d8                	mov    %ebx,%eax
  8022c1:	eb 20                	jmp    8022e3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022c3:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022d1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8022d8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8022db:	89 14 24             	mov    %edx,(%esp)
  8022de:	e8 ed ef ff ff       	call   8012d0 <fd2num>
}
  8022e3:	83 c4 20             	add    $0x20,%esp
  8022e6:	5b                   	pop    %ebx
  8022e7:	5e                   	pop    %esi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f3:	e8 51 ff ff ff       	call   802249 <fd2sockid>
		return r;
  8022f8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022fa:	85 c0                	test   %eax,%eax
  8022fc:	78 23                	js     802321 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022fe:	8b 55 10             	mov    0x10(%ebp),%edx
  802301:	89 54 24 08          	mov    %edx,0x8(%esp)
  802305:	8b 55 0c             	mov    0xc(%ebp),%edx
  802308:	89 54 24 04          	mov    %edx,0x4(%esp)
  80230c:	89 04 24             	mov    %eax,(%esp)
  80230f:	e8 45 01 00 00       	call   802459 <nsipc_accept>
		return r;
  802314:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802316:	85 c0                	test   %eax,%eax
  802318:	78 07                	js     802321 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80231a:	e8 5c ff ff ff       	call   80227b <alloc_sockfd>
  80231f:	89 c1                	mov    %eax,%ecx
}
  802321:	89 c8                	mov    %ecx,%eax
  802323:	c9                   	leave  
  802324:	c3                   	ret    

00802325 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80232b:	8b 45 08             	mov    0x8(%ebp),%eax
  80232e:	e8 16 ff ff ff       	call   802249 <fd2sockid>
  802333:	89 c2                	mov    %eax,%edx
  802335:	85 d2                	test   %edx,%edx
  802337:	78 16                	js     80234f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802339:	8b 45 10             	mov    0x10(%ebp),%eax
  80233c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802340:	8b 45 0c             	mov    0xc(%ebp),%eax
  802343:	89 44 24 04          	mov    %eax,0x4(%esp)
  802347:	89 14 24             	mov    %edx,(%esp)
  80234a:	e8 60 01 00 00       	call   8024af <nsipc_bind>
}
  80234f:	c9                   	leave  
  802350:	c3                   	ret    

00802351 <shutdown>:

int
shutdown(int s, int how)
{
  802351:	55                   	push   %ebp
  802352:	89 e5                	mov    %esp,%ebp
  802354:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802357:	8b 45 08             	mov    0x8(%ebp),%eax
  80235a:	e8 ea fe ff ff       	call   802249 <fd2sockid>
  80235f:	89 c2                	mov    %eax,%edx
  802361:	85 d2                	test   %edx,%edx
  802363:	78 0f                	js     802374 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802365:	8b 45 0c             	mov    0xc(%ebp),%eax
  802368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236c:	89 14 24             	mov    %edx,(%esp)
  80236f:	e8 7a 01 00 00       	call   8024ee <nsipc_shutdown>
}
  802374:	c9                   	leave  
  802375:	c3                   	ret    

00802376 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802376:	55                   	push   %ebp
  802377:	89 e5                	mov    %esp,%ebp
  802379:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80237c:	8b 45 08             	mov    0x8(%ebp),%eax
  80237f:	e8 c5 fe ff ff       	call   802249 <fd2sockid>
  802384:	89 c2                	mov    %eax,%edx
  802386:	85 d2                	test   %edx,%edx
  802388:	78 16                	js     8023a0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80238a:	8b 45 10             	mov    0x10(%ebp),%eax
  80238d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802391:	8b 45 0c             	mov    0xc(%ebp),%eax
  802394:	89 44 24 04          	mov    %eax,0x4(%esp)
  802398:	89 14 24             	mov    %edx,(%esp)
  80239b:	e8 8a 01 00 00       	call   80252a <nsipc_connect>
}
  8023a0:	c9                   	leave  
  8023a1:	c3                   	ret    

008023a2 <listen>:

int
listen(int s, int backlog)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ab:	e8 99 fe ff ff       	call   802249 <fd2sockid>
  8023b0:	89 c2                	mov    %eax,%edx
  8023b2:	85 d2                	test   %edx,%edx
  8023b4:	78 0f                	js     8023c5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8023b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bd:	89 14 24             	mov    %edx,(%esp)
  8023c0:	e8 a4 01 00 00       	call   802569 <nsipc_listen>
}
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8023c7:	55                   	push   %ebp
  8023c8:	89 e5                	mov    %esp,%ebp
  8023ca:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8023cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	89 04 24             	mov    %eax,(%esp)
  8023e1:	e8 98 02 00 00       	call   80267e <nsipc_socket>
  8023e6:	89 c2                	mov    %eax,%edx
  8023e8:	85 d2                	test   %edx,%edx
  8023ea:	78 05                	js     8023f1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  8023ec:	e8 8a fe ff ff       	call   80227b <alloc_sockfd>
}
  8023f1:	c9                   	leave  
  8023f2:	c3                   	ret    

008023f3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	53                   	push   %ebx
  8023f7:	83 ec 14             	sub    $0x14,%esp
  8023fa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023fc:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802403:	75 11                	jne    802416 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802405:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80240c:	e8 64 07 00 00       	call   802b75 <ipc_find_env>
  802411:	a3 04 60 80 00       	mov    %eax,0x806004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802416:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80241d:	00 
  80241e:	c7 44 24 08 00 90 80 	movl   $0x809000,0x8(%esp)
  802425:	00 
  802426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80242a:	a1 04 60 80 00       	mov    0x806004,%eax
  80242f:	89 04 24             	mov    %eax,(%esp)
  802432:	e8 d3 06 00 00       	call   802b0a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802437:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80243e:	00 
  80243f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802446:	00 
  802447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244e:	e8 3d 06 00 00       	call   802a90 <ipc_recv>
}
  802453:	83 c4 14             	add    $0x14,%esp
  802456:	5b                   	pop    %ebx
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    

00802459 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	56                   	push   %esi
  80245d:	53                   	push   %ebx
  80245e:	83 ec 10             	sub    $0x10,%esp
  802461:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802464:	8b 45 08             	mov    0x8(%ebp),%eax
  802467:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80246c:	8b 06                	mov    (%esi),%eax
  80246e:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802473:	b8 01 00 00 00       	mov    $0x1,%eax
  802478:	e8 76 ff ff ff       	call   8023f3 <nsipc>
  80247d:	89 c3                	mov    %eax,%ebx
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 23                	js     8024a6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802483:	a1 10 90 80 00       	mov    0x809010,%eax
  802488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80248c:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  802493:	00 
  802494:	8b 45 0c             	mov    0xc(%ebp),%eax
  802497:	89 04 24             	mov    %eax,(%esp)
  80249a:	e8 85 e8 ff ff       	call   800d24 <memmove>
		*addrlen = ret->ret_addrlen;
  80249f:	a1 10 90 80 00       	mov    0x809010,%eax
  8024a4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	83 c4 10             	add    $0x10,%esp
  8024ab:	5b                   	pop    %ebx
  8024ac:	5e                   	pop    %esi
  8024ad:	5d                   	pop    %ebp
  8024ae:	c3                   	ret    

008024af <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	53                   	push   %ebx
  8024b3:	83 ec 14             	sub    $0x14,%esp
  8024b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bc:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cc:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  8024d3:	e8 4c e8 ff ff       	call   800d24 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024d8:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8024de:	b8 02 00 00 00       	mov    $0x2,%eax
  8024e3:	e8 0b ff ff ff       	call   8023f3 <nsipc>
}
  8024e8:	83 c4 14             	add    $0x14,%esp
  8024eb:	5b                   	pop    %ebx
  8024ec:	5d                   	pop    %ebp
  8024ed:	c3                   	ret    

008024ee <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f7:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  8024fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ff:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802504:	b8 03 00 00 00       	mov    $0x3,%eax
  802509:	e8 e5 fe ff ff       	call   8023f3 <nsipc>
}
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <nsipc_close>:

int
nsipc_close(int s)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802516:	8b 45 08             	mov    0x8(%ebp),%eax
  802519:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  80251e:	b8 04 00 00 00       	mov    $0x4,%eax
  802523:	e8 cb fe ff ff       	call   8023f3 <nsipc>
}
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	53                   	push   %ebx
  80252e:	83 ec 14             	sub    $0x14,%esp
  802531:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802534:	8b 45 08             	mov    0x8(%ebp),%eax
  802537:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80253c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802540:	8b 45 0c             	mov    0xc(%ebp),%eax
  802543:	89 44 24 04          	mov    %eax,0x4(%esp)
  802547:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  80254e:	e8 d1 e7 ff ff       	call   800d24 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802553:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802559:	b8 05 00 00 00       	mov    $0x5,%eax
  80255e:	e8 90 fe ff ff       	call   8023f3 <nsipc>
}
  802563:	83 c4 14             	add    $0x14,%esp
  802566:	5b                   	pop    %ebx
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    

00802569 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802569:	55                   	push   %ebp
  80256a:	89 e5                	mov    %esp,%ebp
  80256c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80256f:	8b 45 08             	mov    0x8(%ebp),%eax
  802572:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257a:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  80257f:	b8 06 00 00 00       	mov    $0x6,%eax
  802584:	e8 6a fe ff ff       	call   8023f3 <nsipc>
}
  802589:	c9                   	leave  
  80258a:	c3                   	ret    

0080258b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	56                   	push   %esi
  80258f:	53                   	push   %ebx
  802590:	83 ec 10             	sub    $0x10,%esp
  802593:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802596:	8b 45 08             	mov    0x8(%ebp),%eax
  802599:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  80259e:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8025a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8025a7:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025ac:	b8 07 00 00 00       	mov    $0x7,%eax
  8025b1:	e8 3d fe ff ff       	call   8023f3 <nsipc>
  8025b6:	89 c3                	mov    %eax,%ebx
  8025b8:	85 c0                	test   %eax,%eax
  8025ba:	78 46                	js     802602 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8025bc:	39 f0                	cmp    %esi,%eax
  8025be:	7f 07                	jg     8025c7 <nsipc_recv+0x3c>
  8025c0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025c5:	7e 24                	jle    8025eb <nsipc_recv+0x60>
  8025c7:	c7 44 24 0c c2 34 80 	movl   $0x8034c2,0xc(%esp)
  8025ce:	00 
  8025cf:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  8025d6:	00 
  8025d7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8025de:	00 
  8025df:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  8025e6:	e8 7c de ff ff       	call   800467 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8025eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025ef:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  8025f6:	00 
  8025f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fa:	89 04 24             	mov    %eax,(%esp)
  8025fd:	e8 22 e7 ff ff       	call   800d24 <memmove>
	}

	return r;
}
  802602:	89 d8                	mov    %ebx,%eax
  802604:	83 c4 10             	add    $0x10,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    

0080260b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	53                   	push   %ebx
  80260f:	83 ec 14             	sub    $0x14,%esp
  802612:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802615:	8b 45 08             	mov    0x8(%ebp),%eax
  802618:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  80261d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802623:	7e 24                	jle    802649 <nsipc_send+0x3e>
  802625:	c7 44 24 0c e3 34 80 	movl   $0x8034e3,0xc(%esp)
  80262c:	00 
  80262d:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  802634:	00 
  802635:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80263c:	00 
  80263d:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  802644:	e8 1e de ff ff       	call   800467 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802649:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80264d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802650:	89 44 24 04          	mov    %eax,0x4(%esp)
  802654:	c7 04 24 0c 90 80 00 	movl   $0x80900c,(%esp)
  80265b:	e8 c4 e6 ff ff       	call   800d24 <memmove>
	nsipcbuf.send.req_size = size;
  802660:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802666:	8b 45 14             	mov    0x14(%ebp),%eax
  802669:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  80266e:	b8 08 00 00 00       	mov    $0x8,%eax
  802673:	e8 7b fd ff ff       	call   8023f3 <nsipc>
}
  802678:	83 c4 14             	add    $0x14,%esp
  80267b:	5b                   	pop    %ebx
  80267c:	5d                   	pop    %ebp
  80267d:	c3                   	ret    

0080267e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80267e:	55                   	push   %ebp
  80267f:	89 e5                	mov    %esp,%ebp
  802681:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802684:	8b 45 08             	mov    0x8(%ebp),%eax
  802687:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  80268c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80268f:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  802694:	8b 45 10             	mov    0x10(%ebp),%eax
  802697:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  80269c:	b8 09 00 00 00       	mov    $0x9,%eax
  8026a1:	e8 4d fd ff ff       	call   8023f3 <nsipc>
}
  8026a6:	c9                   	leave  
  8026a7:	c3                   	ret    

008026a8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026a8:	55                   	push   %ebp
  8026a9:	89 e5                	mov    %esp,%ebp
  8026ab:	56                   	push   %esi
  8026ac:	53                   	push   %ebx
  8026ad:	83 ec 10             	sub    $0x10,%esp
  8026b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b6:	89 04 24             	mov    %eax,(%esp)
  8026b9:	e8 22 ec ff ff       	call   8012e0 <fd2data>
  8026be:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8026c0:	c7 44 24 04 ef 34 80 	movl   $0x8034ef,0x4(%esp)
  8026c7:	00 
  8026c8:	89 1c 24             	mov    %ebx,(%esp)
  8026cb:	e8 b7 e4 ff ff       	call   800b87 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026d0:	8b 46 04             	mov    0x4(%esi),%eax
  8026d3:	2b 06                	sub    (%esi),%eax
  8026d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026e2:	00 00 00 
	stat->st_dev = &devpipe;
  8026e5:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  8026ec:	57 80 00 
	return 0;
}
  8026ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8026f4:	83 c4 10             	add    $0x10,%esp
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5d                   	pop    %ebp
  8026fa:	c3                   	ret    

008026fb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026fb:	55                   	push   %ebp
  8026fc:	89 e5                	mov    %esp,%ebp
  8026fe:	53                   	push   %ebx
  8026ff:	83 ec 14             	sub    $0x14,%esp
  802702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802705:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802710:	e8 35 e9 ff ff       	call   80104a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802715:	89 1c 24             	mov    %ebx,(%esp)
  802718:	e8 c3 eb ff ff       	call   8012e0 <fd2data>
  80271d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802728:	e8 1d e9 ff ff       	call   80104a <sys_page_unmap>
}
  80272d:	83 c4 14             	add    $0x14,%esp
  802730:	5b                   	pop    %ebx
  802731:	5d                   	pop    %ebp
  802732:	c3                   	ret    

00802733 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802733:	55                   	push   %ebp
  802734:	89 e5                	mov    %esp,%ebp
  802736:	57                   	push   %edi
  802737:	56                   	push   %esi
  802738:	53                   	push   %ebx
  802739:	83 ec 2c             	sub    $0x2c,%esp
  80273c:	89 c6                	mov    %eax,%esi
  80273e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802741:	a1 90 77 80 00       	mov    0x807790,%eax
  802746:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802749:	89 34 24             	mov    %esi,(%esp)
  80274c:	e8 5c 04 00 00       	call   802bad <pageref>
  802751:	89 c7                	mov    %eax,%edi
  802753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802756:	89 04 24             	mov    %eax,(%esp)
  802759:	e8 4f 04 00 00       	call   802bad <pageref>
  80275e:	39 c7                	cmp    %eax,%edi
  802760:	0f 94 c2             	sete   %dl
  802763:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802766:	8b 0d 90 77 80 00    	mov    0x807790,%ecx
  80276c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80276f:	39 fb                	cmp    %edi,%ebx
  802771:	74 21                	je     802794 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802773:	84 d2                	test   %dl,%dl
  802775:	74 ca                	je     802741 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802777:	8b 51 58             	mov    0x58(%ecx),%edx
  80277a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80277e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802782:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802786:	c7 04 24 f6 34 80 00 	movl   $0x8034f6,(%esp)
  80278d:	e8 ce dd ff ff       	call   800560 <cprintf>
  802792:	eb ad                	jmp    802741 <_pipeisclosed+0xe>
	}
}
  802794:	83 c4 2c             	add    $0x2c,%esp
  802797:	5b                   	pop    %ebx
  802798:	5e                   	pop    %esi
  802799:	5f                   	pop    %edi
  80279a:	5d                   	pop    %ebp
  80279b:	c3                   	ret    

0080279c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80279c:	55                   	push   %ebp
  80279d:	89 e5                	mov    %esp,%ebp
  80279f:	57                   	push   %edi
  8027a0:	56                   	push   %esi
  8027a1:	53                   	push   %ebx
  8027a2:	83 ec 1c             	sub    $0x1c,%esp
  8027a5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8027a8:	89 34 24             	mov    %esi,(%esp)
  8027ab:	e8 30 eb ff ff       	call   8012e0 <fd2data>
  8027b0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8027b7:	eb 45                	jmp    8027fe <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8027b9:	89 da                	mov    %ebx,%edx
  8027bb:	89 f0                	mov    %esi,%eax
  8027bd:	e8 71 ff ff ff       	call   802733 <_pipeisclosed>
  8027c2:	85 c0                	test   %eax,%eax
  8027c4:	75 41                	jne    802807 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8027c6:	e8 b9 e7 ff ff       	call   800f84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8027ce:	8b 0b                	mov    (%ebx),%ecx
  8027d0:	8d 51 20             	lea    0x20(%ecx),%edx
  8027d3:	39 d0                	cmp    %edx,%eax
  8027d5:	73 e2                	jae    8027b9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027da:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8027de:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8027e1:	99                   	cltd   
  8027e2:	c1 ea 1b             	shr    $0x1b,%edx
  8027e5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8027e8:	83 e1 1f             	and    $0x1f,%ecx
  8027eb:	29 d1                	sub    %edx,%ecx
  8027ed:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8027f1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8027f5:	83 c0 01             	add    $0x1,%eax
  8027f8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027fb:	83 c7 01             	add    $0x1,%edi
  8027fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802801:	75 c8                	jne    8027cb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802803:	89 f8                	mov    %edi,%eax
  802805:	eb 05                	jmp    80280c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802807:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80280c:	83 c4 1c             	add    $0x1c,%esp
  80280f:	5b                   	pop    %ebx
  802810:	5e                   	pop    %esi
  802811:	5f                   	pop    %edi
  802812:	5d                   	pop    %ebp
  802813:	c3                   	ret    

00802814 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802814:	55                   	push   %ebp
  802815:	89 e5                	mov    %esp,%ebp
  802817:	57                   	push   %edi
  802818:	56                   	push   %esi
  802819:	53                   	push   %ebx
  80281a:	83 ec 1c             	sub    $0x1c,%esp
  80281d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802820:	89 3c 24             	mov    %edi,(%esp)
  802823:	e8 b8 ea ff ff       	call   8012e0 <fd2data>
  802828:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80282a:	be 00 00 00 00       	mov    $0x0,%esi
  80282f:	eb 3d                	jmp    80286e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802831:	85 f6                	test   %esi,%esi
  802833:	74 04                	je     802839 <devpipe_read+0x25>
				return i;
  802835:	89 f0                	mov    %esi,%eax
  802837:	eb 43                	jmp    80287c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802839:	89 da                	mov    %ebx,%edx
  80283b:	89 f8                	mov    %edi,%eax
  80283d:	e8 f1 fe ff ff       	call   802733 <_pipeisclosed>
  802842:	85 c0                	test   %eax,%eax
  802844:	75 31                	jne    802877 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802846:	e8 39 e7 ff ff       	call   800f84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80284b:	8b 03                	mov    (%ebx),%eax
  80284d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802850:	74 df                	je     802831 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802852:	99                   	cltd   
  802853:	c1 ea 1b             	shr    $0x1b,%edx
  802856:	01 d0                	add    %edx,%eax
  802858:	83 e0 1f             	and    $0x1f,%eax
  80285b:	29 d0                	sub    %edx,%eax
  80285d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802865:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802868:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80286b:	83 c6 01             	add    $0x1,%esi
  80286e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802871:	75 d8                	jne    80284b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802873:	89 f0                	mov    %esi,%eax
  802875:	eb 05                	jmp    80287c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802877:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80287c:	83 c4 1c             	add    $0x1c,%esp
  80287f:	5b                   	pop    %ebx
  802880:	5e                   	pop    %esi
  802881:	5f                   	pop    %edi
  802882:	5d                   	pop    %ebp
  802883:	c3                   	ret    

00802884 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802884:	55                   	push   %ebp
  802885:	89 e5                	mov    %esp,%ebp
  802887:	56                   	push   %esi
  802888:	53                   	push   %ebx
  802889:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80288c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80288f:	89 04 24             	mov    %eax,(%esp)
  802892:	e8 60 ea ff ff       	call   8012f7 <fd_alloc>
  802897:	89 c2                	mov    %eax,%edx
  802899:	85 d2                	test   %edx,%edx
  80289b:	0f 88 4d 01 00 00    	js     8029ee <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028a8:	00 
  8028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028b7:	e8 e7 e6 ff ff       	call   800fa3 <sys_page_alloc>
  8028bc:	89 c2                	mov    %eax,%edx
  8028be:	85 d2                	test   %edx,%edx
  8028c0:	0f 88 28 01 00 00    	js     8029ee <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8028c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028c9:	89 04 24             	mov    %eax,(%esp)
  8028cc:	e8 26 ea ff ff       	call   8012f7 <fd_alloc>
  8028d1:	89 c3                	mov    %eax,%ebx
  8028d3:	85 c0                	test   %eax,%eax
  8028d5:	0f 88 fe 00 00 00    	js     8029d9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028db:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028e2:	00 
  8028e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f1:	e8 ad e6 ff ff       	call   800fa3 <sys_page_alloc>
  8028f6:	89 c3                	mov    %eax,%ebx
  8028f8:	85 c0                	test   %eax,%eax
  8028fa:	0f 88 d9 00 00 00    	js     8029d9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802903:	89 04 24             	mov    %eax,(%esp)
  802906:	e8 d5 e9 ff ff       	call   8012e0 <fd2data>
  80290b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80290d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802914:	00 
  802915:	89 44 24 04          	mov    %eax,0x4(%esp)
  802919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802920:	e8 7e e6 ff ff       	call   800fa3 <sys_page_alloc>
  802925:	89 c3                	mov    %eax,%ebx
  802927:	85 c0                	test   %eax,%eax
  802929:	0f 88 97 00 00 00    	js     8029c6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80292f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802932:	89 04 24             	mov    %eax,(%esp)
  802935:	e8 a6 e9 ff ff       	call   8012e0 <fd2data>
  80293a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802941:	00 
  802942:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802946:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80294d:	00 
  80294e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802959:	e8 99 e6 ff ff       	call   800ff7 <sys_page_map>
  80295e:	89 c3                	mov    %eax,%ebx
  802960:	85 c0                	test   %eax,%eax
  802962:	78 52                	js     8029b6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802964:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80296f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802972:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802979:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80297f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802982:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802984:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802987:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80298e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802991:	89 04 24             	mov    %eax,(%esp)
  802994:	e8 37 e9 ff ff       	call   8012d0 <fd2num>
  802999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80299c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80299e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029a1:	89 04 24             	mov    %eax,(%esp)
  8029a4:	e8 27 e9 ff ff       	call   8012d0 <fd2num>
  8029a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029ac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8029af:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b4:	eb 38                	jmp    8029ee <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8029b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029c1:	e8 84 e6 ff ff       	call   80104a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8029c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029d4:	e8 71 e6 ff ff       	call   80104a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029e7:	e8 5e e6 ff ff       	call   80104a <sys_page_unmap>
  8029ec:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8029ee:	83 c4 30             	add    $0x30,%esp
  8029f1:	5b                   	pop    %ebx
  8029f2:	5e                   	pop    %esi
  8029f3:	5d                   	pop    %ebp
  8029f4:	c3                   	ret    

008029f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8029f5:	55                   	push   %ebp
  8029f6:	89 e5                	mov    %esp,%ebp
  8029f8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a02:	8b 45 08             	mov    0x8(%ebp),%eax
  802a05:	89 04 24             	mov    %eax,(%esp)
  802a08:	e8 39 e9 ff ff       	call   801346 <fd_lookup>
  802a0d:	89 c2                	mov    %eax,%edx
  802a0f:	85 d2                	test   %edx,%edx
  802a11:	78 15                	js     802a28 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a16:	89 04 24             	mov    %eax,(%esp)
  802a19:	e8 c2 e8 ff ff       	call   8012e0 <fd2data>
	return _pipeisclosed(fd, p);
  802a1e:	89 c2                	mov    %eax,%edx
  802a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a23:	e8 0b fd ff ff       	call   802733 <_pipeisclosed>
}
  802a28:	c9                   	leave  
  802a29:	c3                   	ret    

00802a2a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a2a:	55                   	push   %ebp
  802a2b:	89 e5                	mov    %esp,%ebp
  802a2d:	56                   	push   %esi
  802a2e:	53                   	push   %ebx
  802a2f:	83 ec 10             	sub    $0x10,%esp
  802a32:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a35:	85 f6                	test   %esi,%esi
  802a37:	75 24                	jne    802a5d <wait+0x33>
  802a39:	c7 44 24 0c 0e 35 80 	movl   $0x80350e,0xc(%esp)
  802a40:	00 
  802a41:	c7 44 24 08 c3 33 80 	movl   $0x8033c3,0x8(%esp)
  802a48:	00 
  802a49:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802a50:	00 
  802a51:	c7 04 24 19 35 80 00 	movl   $0x803519,(%esp)
  802a58:	e8 0a da ff ff       	call   800467 <_panic>
	e = &envs[ENVX(envid)];
  802a5d:	89 f3                	mov    %esi,%ebx
  802a5f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802a65:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a68:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a6e:	eb 05                	jmp    802a75 <wait+0x4b>
		sys_yield();
  802a70:	e8 0f e5 ff ff       	call   800f84 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a75:	8b 43 48             	mov    0x48(%ebx),%eax
  802a78:	39 f0                	cmp    %esi,%eax
  802a7a:	75 07                	jne    802a83 <wait+0x59>
  802a7c:	8b 43 54             	mov    0x54(%ebx),%eax
  802a7f:	85 c0                	test   %eax,%eax
  802a81:	75 ed                	jne    802a70 <wait+0x46>
		sys_yield();
}
  802a83:	83 c4 10             	add    $0x10,%esp
  802a86:	5b                   	pop    %ebx
  802a87:	5e                   	pop    %esi
  802a88:	5d                   	pop    %ebp
  802a89:	c3                   	ret    
  802a8a:	66 90                	xchg   %ax,%ax
  802a8c:	66 90                	xchg   %ax,%ax
  802a8e:	66 90                	xchg   %ax,%ax

00802a90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a90:	55                   	push   %ebp
  802a91:	89 e5                	mov    %esp,%ebp
  802a93:	56                   	push   %esi
  802a94:	53                   	push   %ebx
  802a95:	83 ec 10             	sub    $0x10,%esp
  802a98:	8b 75 08             	mov    0x8(%ebp),%esi
  802a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802aa1:	85 c0                	test   %eax,%eax
  802aa3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802aa8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  802aab:	89 04 24             	mov    %eax,(%esp)
  802aae:	e8 06 e7 ff ff       	call   8011b9 <sys_ipc_recv>

	if(ret < 0) {
  802ab3:	85 c0                	test   %eax,%eax
  802ab5:	79 16                	jns    802acd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802ab7:	85 f6                	test   %esi,%esi
  802ab9:	74 06                	je     802ac1 <ipc_recv+0x31>
  802abb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802ac1:	85 db                	test   %ebx,%ebx
  802ac3:	74 3e                	je     802b03 <ipc_recv+0x73>
  802ac5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802acb:	eb 36                	jmp    802b03 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  802acd:	e8 93 e4 ff ff       	call   800f65 <sys_getenvid>
  802ad2:	25 ff 03 00 00       	and    $0x3ff,%eax
  802ad7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ada:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802adf:	a3 90 77 80 00       	mov    %eax,0x807790

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802ae4:	85 f6                	test   %esi,%esi
  802ae6:	74 05                	je     802aed <ipc_recv+0x5d>
  802ae8:	8b 40 74             	mov    0x74(%eax),%eax
  802aeb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802aed:	85 db                	test   %ebx,%ebx
  802aef:	74 0a                	je     802afb <ipc_recv+0x6b>
  802af1:	a1 90 77 80 00       	mov    0x807790,%eax
  802af6:	8b 40 78             	mov    0x78(%eax),%eax
  802af9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802afb:	a1 90 77 80 00       	mov    0x807790,%eax
  802b00:	8b 40 70             	mov    0x70(%eax),%eax
}
  802b03:	83 c4 10             	add    $0x10,%esp
  802b06:	5b                   	pop    %ebx
  802b07:	5e                   	pop    %esi
  802b08:	5d                   	pop    %ebp
  802b09:	c3                   	ret    

00802b0a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b0a:	55                   	push   %ebp
  802b0b:	89 e5                	mov    %esp,%ebp
  802b0d:	57                   	push   %edi
  802b0e:	56                   	push   %esi
  802b0f:	53                   	push   %ebx
  802b10:	83 ec 1c             	sub    $0x1c,%esp
  802b13:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b16:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  802b1c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  802b1e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b23:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802b26:	8b 45 14             	mov    0x14(%ebp),%eax
  802b29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b2d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b31:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b35:	89 3c 24             	mov    %edi,(%esp)
  802b38:	e8 59 e6 ff ff       	call   801196 <sys_ipc_try_send>

		if(ret >= 0) break;
  802b3d:	85 c0                	test   %eax,%eax
  802b3f:	79 2c                	jns    802b6d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802b41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b44:	74 20                	je     802b66 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b4a:	c7 44 24 08 24 35 80 	movl   $0x803524,0x8(%esp)
  802b51:	00 
  802b52:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802b59:	00 
  802b5a:	c7 04 24 54 35 80 00 	movl   $0x803554,(%esp)
  802b61:	e8 01 d9 ff ff       	call   800467 <_panic>
		}
		sys_yield();
  802b66:	e8 19 e4 ff ff       	call   800f84 <sys_yield>
	}
  802b6b:	eb b9                	jmp    802b26 <ipc_send+0x1c>
}
  802b6d:	83 c4 1c             	add    $0x1c,%esp
  802b70:	5b                   	pop    %ebx
  802b71:	5e                   	pop    %esi
  802b72:	5f                   	pop    %edi
  802b73:	5d                   	pop    %ebp
  802b74:	c3                   	ret    

00802b75 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b75:	55                   	push   %ebp
  802b76:	89 e5                	mov    %esp,%ebp
  802b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b7b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b80:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b83:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b89:	8b 52 50             	mov    0x50(%edx),%edx
  802b8c:	39 ca                	cmp    %ecx,%edx
  802b8e:	75 0d                	jne    802b9d <ipc_find_env+0x28>
			return envs[i].env_id;
  802b90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b93:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802b98:	8b 40 40             	mov    0x40(%eax),%eax
  802b9b:	eb 0e                	jmp    802bab <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b9d:	83 c0 01             	add    $0x1,%eax
  802ba0:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ba5:	75 d9                	jne    802b80 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ba7:	66 b8 00 00          	mov    $0x0,%ax
}
  802bab:	5d                   	pop    %ebp
  802bac:	c3                   	ret    

00802bad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802bad:	55                   	push   %ebp
  802bae:	89 e5                	mov    %esp,%ebp
  802bb0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bb3:	89 d0                	mov    %edx,%eax
  802bb5:	c1 e8 16             	shr    $0x16,%eax
  802bb8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802bbf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bc4:	f6 c1 01             	test   $0x1,%cl
  802bc7:	74 1d                	je     802be6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802bc9:	c1 ea 0c             	shr    $0xc,%edx
  802bcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802bd3:	f6 c2 01             	test   $0x1,%dl
  802bd6:	74 0e                	je     802be6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bd8:	c1 ea 0c             	shr    $0xc,%edx
  802bdb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802be2:	ef 
  802be3:	0f b7 c0             	movzwl %ax,%eax
}
  802be6:	5d                   	pop    %ebp
  802be7:	c3                   	ret    
  802be8:	66 90                	xchg   %ax,%ax
  802bea:	66 90                	xchg   %ax,%ax
  802bec:	66 90                	xchg   %ax,%ax
  802bee:	66 90                	xchg   %ax,%ax

00802bf0 <__udivdi3>:
  802bf0:	55                   	push   %ebp
  802bf1:	57                   	push   %edi
  802bf2:	56                   	push   %esi
  802bf3:	83 ec 0c             	sub    $0xc,%esp
  802bf6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802bfa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802bfe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802c02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802c06:	85 c0                	test   %eax,%eax
  802c08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c0c:	89 ea                	mov    %ebp,%edx
  802c0e:	89 0c 24             	mov    %ecx,(%esp)
  802c11:	75 2d                	jne    802c40 <__udivdi3+0x50>
  802c13:	39 e9                	cmp    %ebp,%ecx
  802c15:	77 61                	ja     802c78 <__udivdi3+0x88>
  802c17:	85 c9                	test   %ecx,%ecx
  802c19:	89 ce                	mov    %ecx,%esi
  802c1b:	75 0b                	jne    802c28 <__udivdi3+0x38>
  802c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  802c22:	31 d2                	xor    %edx,%edx
  802c24:	f7 f1                	div    %ecx
  802c26:	89 c6                	mov    %eax,%esi
  802c28:	31 d2                	xor    %edx,%edx
  802c2a:	89 e8                	mov    %ebp,%eax
  802c2c:	f7 f6                	div    %esi
  802c2e:	89 c5                	mov    %eax,%ebp
  802c30:	89 f8                	mov    %edi,%eax
  802c32:	f7 f6                	div    %esi
  802c34:	89 ea                	mov    %ebp,%edx
  802c36:	83 c4 0c             	add    $0xc,%esp
  802c39:	5e                   	pop    %esi
  802c3a:	5f                   	pop    %edi
  802c3b:	5d                   	pop    %ebp
  802c3c:	c3                   	ret    
  802c3d:	8d 76 00             	lea    0x0(%esi),%esi
  802c40:	39 e8                	cmp    %ebp,%eax
  802c42:	77 24                	ja     802c68 <__udivdi3+0x78>
  802c44:	0f bd e8             	bsr    %eax,%ebp
  802c47:	83 f5 1f             	xor    $0x1f,%ebp
  802c4a:	75 3c                	jne    802c88 <__udivdi3+0x98>
  802c4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802c50:	39 34 24             	cmp    %esi,(%esp)
  802c53:	0f 86 9f 00 00 00    	jbe    802cf8 <__udivdi3+0x108>
  802c59:	39 d0                	cmp    %edx,%eax
  802c5b:	0f 82 97 00 00 00    	jb     802cf8 <__udivdi3+0x108>
  802c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c68:	31 d2                	xor    %edx,%edx
  802c6a:	31 c0                	xor    %eax,%eax
  802c6c:	83 c4 0c             	add    $0xc,%esp
  802c6f:	5e                   	pop    %esi
  802c70:	5f                   	pop    %edi
  802c71:	5d                   	pop    %ebp
  802c72:	c3                   	ret    
  802c73:	90                   	nop
  802c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c78:	89 f8                	mov    %edi,%eax
  802c7a:	f7 f1                	div    %ecx
  802c7c:	31 d2                	xor    %edx,%edx
  802c7e:	83 c4 0c             	add    $0xc,%esp
  802c81:	5e                   	pop    %esi
  802c82:	5f                   	pop    %edi
  802c83:	5d                   	pop    %ebp
  802c84:	c3                   	ret    
  802c85:	8d 76 00             	lea    0x0(%esi),%esi
  802c88:	89 e9                	mov    %ebp,%ecx
  802c8a:	8b 3c 24             	mov    (%esp),%edi
  802c8d:	d3 e0                	shl    %cl,%eax
  802c8f:	89 c6                	mov    %eax,%esi
  802c91:	b8 20 00 00 00       	mov    $0x20,%eax
  802c96:	29 e8                	sub    %ebp,%eax
  802c98:	89 c1                	mov    %eax,%ecx
  802c9a:	d3 ef                	shr    %cl,%edi
  802c9c:	89 e9                	mov    %ebp,%ecx
  802c9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802ca2:	8b 3c 24             	mov    (%esp),%edi
  802ca5:	09 74 24 08          	or     %esi,0x8(%esp)
  802ca9:	89 d6                	mov    %edx,%esi
  802cab:	d3 e7                	shl    %cl,%edi
  802cad:	89 c1                	mov    %eax,%ecx
  802caf:	89 3c 24             	mov    %edi,(%esp)
  802cb2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802cb6:	d3 ee                	shr    %cl,%esi
  802cb8:	89 e9                	mov    %ebp,%ecx
  802cba:	d3 e2                	shl    %cl,%edx
  802cbc:	89 c1                	mov    %eax,%ecx
  802cbe:	d3 ef                	shr    %cl,%edi
  802cc0:	09 d7                	or     %edx,%edi
  802cc2:	89 f2                	mov    %esi,%edx
  802cc4:	89 f8                	mov    %edi,%eax
  802cc6:	f7 74 24 08          	divl   0x8(%esp)
  802cca:	89 d6                	mov    %edx,%esi
  802ccc:	89 c7                	mov    %eax,%edi
  802cce:	f7 24 24             	mull   (%esp)
  802cd1:	39 d6                	cmp    %edx,%esi
  802cd3:	89 14 24             	mov    %edx,(%esp)
  802cd6:	72 30                	jb     802d08 <__udivdi3+0x118>
  802cd8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802cdc:	89 e9                	mov    %ebp,%ecx
  802cde:	d3 e2                	shl    %cl,%edx
  802ce0:	39 c2                	cmp    %eax,%edx
  802ce2:	73 05                	jae    802ce9 <__udivdi3+0xf9>
  802ce4:	3b 34 24             	cmp    (%esp),%esi
  802ce7:	74 1f                	je     802d08 <__udivdi3+0x118>
  802ce9:	89 f8                	mov    %edi,%eax
  802ceb:	31 d2                	xor    %edx,%edx
  802ced:	e9 7a ff ff ff       	jmp    802c6c <__udivdi3+0x7c>
  802cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802cf8:	31 d2                	xor    %edx,%edx
  802cfa:	b8 01 00 00 00       	mov    $0x1,%eax
  802cff:	e9 68 ff ff ff       	jmp    802c6c <__udivdi3+0x7c>
  802d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d08:	8d 47 ff             	lea    -0x1(%edi),%eax
  802d0b:	31 d2                	xor    %edx,%edx
  802d0d:	83 c4 0c             	add    $0xc,%esp
  802d10:	5e                   	pop    %esi
  802d11:	5f                   	pop    %edi
  802d12:	5d                   	pop    %ebp
  802d13:	c3                   	ret    
  802d14:	66 90                	xchg   %ax,%ax
  802d16:	66 90                	xchg   %ax,%ax
  802d18:	66 90                	xchg   %ax,%ax
  802d1a:	66 90                	xchg   %ax,%ax
  802d1c:	66 90                	xchg   %ax,%ax
  802d1e:	66 90                	xchg   %ax,%ax

00802d20 <__umoddi3>:
  802d20:	55                   	push   %ebp
  802d21:	57                   	push   %edi
  802d22:	56                   	push   %esi
  802d23:	83 ec 14             	sub    $0x14,%esp
  802d26:	8b 44 24 28          	mov    0x28(%esp),%eax
  802d2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802d2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802d32:	89 c7                	mov    %eax,%edi
  802d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d38:	8b 44 24 30          	mov    0x30(%esp),%eax
  802d3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802d40:	89 34 24             	mov    %esi,(%esp)
  802d43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d47:	85 c0                	test   %eax,%eax
  802d49:	89 c2                	mov    %eax,%edx
  802d4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d4f:	75 17                	jne    802d68 <__umoddi3+0x48>
  802d51:	39 fe                	cmp    %edi,%esi
  802d53:	76 4b                	jbe    802da0 <__umoddi3+0x80>
  802d55:	89 c8                	mov    %ecx,%eax
  802d57:	89 fa                	mov    %edi,%edx
  802d59:	f7 f6                	div    %esi
  802d5b:	89 d0                	mov    %edx,%eax
  802d5d:	31 d2                	xor    %edx,%edx
  802d5f:	83 c4 14             	add    $0x14,%esp
  802d62:	5e                   	pop    %esi
  802d63:	5f                   	pop    %edi
  802d64:	5d                   	pop    %ebp
  802d65:	c3                   	ret    
  802d66:	66 90                	xchg   %ax,%ax
  802d68:	39 f8                	cmp    %edi,%eax
  802d6a:	77 54                	ja     802dc0 <__umoddi3+0xa0>
  802d6c:	0f bd e8             	bsr    %eax,%ebp
  802d6f:	83 f5 1f             	xor    $0x1f,%ebp
  802d72:	75 5c                	jne    802dd0 <__umoddi3+0xb0>
  802d74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d78:	39 3c 24             	cmp    %edi,(%esp)
  802d7b:	0f 87 e7 00 00 00    	ja     802e68 <__umoddi3+0x148>
  802d81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802d85:	29 f1                	sub    %esi,%ecx
  802d87:	19 c7                	sbb    %eax,%edi
  802d89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d91:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802d99:	83 c4 14             	add    $0x14,%esp
  802d9c:	5e                   	pop    %esi
  802d9d:	5f                   	pop    %edi
  802d9e:	5d                   	pop    %ebp
  802d9f:	c3                   	ret    
  802da0:	85 f6                	test   %esi,%esi
  802da2:	89 f5                	mov    %esi,%ebp
  802da4:	75 0b                	jne    802db1 <__umoddi3+0x91>
  802da6:	b8 01 00 00 00       	mov    $0x1,%eax
  802dab:	31 d2                	xor    %edx,%edx
  802dad:	f7 f6                	div    %esi
  802daf:	89 c5                	mov    %eax,%ebp
  802db1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802db5:	31 d2                	xor    %edx,%edx
  802db7:	f7 f5                	div    %ebp
  802db9:	89 c8                	mov    %ecx,%eax
  802dbb:	f7 f5                	div    %ebp
  802dbd:	eb 9c                	jmp    802d5b <__umoddi3+0x3b>
  802dbf:	90                   	nop
  802dc0:	89 c8                	mov    %ecx,%eax
  802dc2:	89 fa                	mov    %edi,%edx
  802dc4:	83 c4 14             	add    $0x14,%esp
  802dc7:	5e                   	pop    %esi
  802dc8:	5f                   	pop    %edi
  802dc9:	5d                   	pop    %ebp
  802dca:	c3                   	ret    
  802dcb:	90                   	nop
  802dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802dd0:	8b 04 24             	mov    (%esp),%eax
  802dd3:	be 20 00 00 00       	mov    $0x20,%esi
  802dd8:	89 e9                	mov    %ebp,%ecx
  802dda:	29 ee                	sub    %ebp,%esi
  802ddc:	d3 e2                	shl    %cl,%edx
  802dde:	89 f1                	mov    %esi,%ecx
  802de0:	d3 e8                	shr    %cl,%eax
  802de2:	89 e9                	mov    %ebp,%ecx
  802de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802de8:	8b 04 24             	mov    (%esp),%eax
  802deb:	09 54 24 04          	or     %edx,0x4(%esp)
  802def:	89 fa                	mov    %edi,%edx
  802df1:	d3 e0                	shl    %cl,%eax
  802df3:	89 f1                	mov    %esi,%ecx
  802df5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802df9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802dfd:	d3 ea                	shr    %cl,%edx
  802dff:	89 e9                	mov    %ebp,%ecx
  802e01:	d3 e7                	shl    %cl,%edi
  802e03:	89 f1                	mov    %esi,%ecx
  802e05:	d3 e8                	shr    %cl,%eax
  802e07:	89 e9                	mov    %ebp,%ecx
  802e09:	09 f8                	or     %edi,%eax
  802e0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802e0f:	f7 74 24 04          	divl   0x4(%esp)
  802e13:	d3 e7                	shl    %cl,%edi
  802e15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e19:	89 d7                	mov    %edx,%edi
  802e1b:	f7 64 24 08          	mull   0x8(%esp)
  802e1f:	39 d7                	cmp    %edx,%edi
  802e21:	89 c1                	mov    %eax,%ecx
  802e23:	89 14 24             	mov    %edx,(%esp)
  802e26:	72 2c                	jb     802e54 <__umoddi3+0x134>
  802e28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802e2c:	72 22                	jb     802e50 <__umoddi3+0x130>
  802e2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e32:	29 c8                	sub    %ecx,%eax
  802e34:	19 d7                	sbb    %edx,%edi
  802e36:	89 e9                	mov    %ebp,%ecx
  802e38:	89 fa                	mov    %edi,%edx
  802e3a:	d3 e8                	shr    %cl,%eax
  802e3c:	89 f1                	mov    %esi,%ecx
  802e3e:	d3 e2                	shl    %cl,%edx
  802e40:	89 e9                	mov    %ebp,%ecx
  802e42:	d3 ef                	shr    %cl,%edi
  802e44:	09 d0                	or     %edx,%eax
  802e46:	89 fa                	mov    %edi,%edx
  802e48:	83 c4 14             	add    $0x14,%esp
  802e4b:	5e                   	pop    %esi
  802e4c:	5f                   	pop    %edi
  802e4d:	5d                   	pop    %ebp
  802e4e:	c3                   	ret    
  802e4f:	90                   	nop
  802e50:	39 d7                	cmp    %edx,%edi
  802e52:	75 da                	jne    802e2e <__umoddi3+0x10e>
  802e54:	8b 14 24             	mov    (%esp),%edx
  802e57:	89 c1                	mov    %eax,%ecx
  802e59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802e5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802e61:	eb cb                	jmp    802e2e <__umoddi3+0x10e>
  802e63:	90                   	nop
  802e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802e6c:	0f 82 0f ff ff ff    	jb     802d81 <__umoddi3+0x61>
  802e72:	e9 1a ff ff ff       	jmp    802d91 <__umoddi3+0x71>
