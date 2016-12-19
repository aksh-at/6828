
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 fa 02 00 00       	call   80032b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80004e:	83 3d d0 51 80 00 00 	cmpl   $0x0,0x8051d0
  800055:	74 23                	je     80007a <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800057:	89 f0                	mov    %esi,%eax
  800059:	3c 01                	cmp    $0x1,%al
  80005b:	19 c0                	sbb    %eax,%eax
  80005d:	83 e0 c9             	and    $0xffffffc9,%eax
  800060:	83 c0 64             	add    $0x64,%eax
  800063:	89 44 24 08          	mov    %eax,0x8(%esp)
  800067:	8b 45 10             	mov    0x10(%ebp),%eax
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  800075:	e8 69 1c 00 00       	call   801ce3 <printf>
	if(prefix) {
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	74 38                	je     8000b6 <ls1+0x76>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80007e:	b8 a8 2b 80 00       	mov    $0x802ba8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800083:	80 3b 00             	cmpb   $0x0,(%ebx)
  800086:	74 1a                	je     8000a2 <ls1+0x62>
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 e0 09 00 00       	call   800a70 <strlen>
  800090:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
			sep = "/";
  800095:	b8 40 2b 80 00       	mov    $0x802b40,%eax
  80009a:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
  80009f:	0f 44 c2             	cmove  %edx,%eax
		else
			sep = "";
		printf("%s%s", prefix, sep);
  8000a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	c7 04 24 4b 2b 80 00 	movl   $0x802b4b,(%esp)
  8000b1:	e8 2d 1c 00 00       	call   801ce3 <printf>
	}
	printf("%s", name);
  8000b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 d5 2f 80 00 	movl   $0x802fd5,(%esp)
  8000c4:	e8 1a 1c 00 00       	call   801ce3 <printf>
	if(flag['F'] && isdir)
  8000c9:	83 3d 38 51 80 00 00 	cmpl   $0x0,0x805138
  8000d0:	74 12                	je     8000e4 <ls1+0xa4>
  8000d2:	89 f0                	mov    %esi,%eax
  8000d4:	84 c0                	test   %al,%al
  8000d6:	74 0c                	je     8000e4 <ls1+0xa4>
		printf("/");
  8000d8:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8000df:	e8 ff 1b 00 00       	call   801ce3 <printf>
	printf("\n");
  8000e4:	c7 04 24 a7 2b 80 00 	movl   $0x802ba7,(%esp)
  8000eb:	e8 f3 1b 00 00       	call   801ce3 <printf>
}
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  800103:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800106:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010d:	00 
  80010e:	89 3c 24             	mov    %edi,(%esp)
  800111:	e8 1d 1a 00 00       	call   801b33 <open>
  800116:	89 c3                	mov    %eax,%ebx
  800118:	85 c0                	test   %eax,%eax
  80011a:	78 08                	js     800124 <lsdir+0x2d>
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80011c:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800122:	eb 57                	jmp    80017b <lsdir+0x84>
{
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
  800124:	89 44 24 10          	mov    %eax,0x10(%esp)
  800128:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80012c:	c7 44 24 08 50 2b 80 	movl   $0x802b50,0x8(%esp)
  800133:	00 
  800134:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80013b:	00 
  80013c:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800143:	e8 44 02 00 00       	call   80038c <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800148:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80014f:	74 2a                	je     80017b <lsdir+0x84>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800151:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800155:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800166:	0f 94 c0             	sete   %al
  800169:	0f b6 c0             	movzbl %al,%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 c5 fe ff ff       	call   800040 <ls1>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80017b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  800182:	00 
  800183:	89 74 24 04          	mov    %esi,0x4(%esp)
  800187:	89 1c 24             	mov    %ebx,(%esp)
  80018a:	e8 5d 15 00 00       	call   8016ec <readn>
  80018f:	3d 00 01 00 00       	cmp    $0x100,%eax
  800194:	74 b2                	je     800148 <lsdir+0x51>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  800196:	85 c0                	test   %eax,%eax
  800198:	7e 20                	jle    8001ba <lsdir+0xc3>
		panic("short read in directory %s", path);
  80019a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80019e:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  8001a5:	00 
  8001a6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001ad:	00 
  8001ae:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  8001b5:	e8 d2 01 00 00       	call   80038c <_panic>
	if (n < 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	79 24                	jns    8001e2 <lsdir+0xeb>
		panic("error reading directory %s: %e", path, n);
  8001be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001c6:	c7 44 24 08 ac 2b 80 	movl   $0x802bac,0x8(%esp)
  8001cd:	00 
  8001ce:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d5:	00 
  8001d6:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  8001dd:	e8 aa 01 00 00       	call   80038c <_panic>
}
  8001e2:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	53                   	push   %ebx
  8001f1:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001fa:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	89 1c 24             	mov    %ebx,(%esp)
  800207:	e8 e4 16 00 00       	call   8018f0 <stat>
  80020c:	85 c0                	test   %eax,%eax
  80020e:	79 24                	jns    800234 <ls+0x47>
		panic("stat %s: %e", path, r);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800218:	c7 44 24 08 81 2b 80 	movl   $0x802b81,0x8(%esp)
  80021f:	00 
  800220:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800227:	00 
  800228:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  80022f:	e8 58 01 00 00       	call   80038c <_panic>
	if (st.st_isdir && !flag['d'])
  800234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800237:	85 c0                	test   %eax,%eax
  800239:	74 1a                	je     800255 <ls+0x68>
  80023b:	83 3d b0 51 80 00 00 	cmpl   $0x0,0x8051b0
  800242:	75 11                	jne    800255 <ls+0x68>
		lsdir(path, prefix);
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	89 1c 24             	mov    %ebx,(%esp)
  80024e:	e8 a4 fe ff ff       	call   8000f7 <lsdir>
  800253:	eb 23                	jmp    800278 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800260:	85 c0                	test   %eax,%eax
  800262:	0f 95 c0             	setne  %al
  800265:	0f b6 c0             	movzbl %al,%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800273:	e8 c8 fd ff ff       	call   800040 <ls1>
}
  800278:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <usage>:
	printf("\n");
}

void
usage(void)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800287:	c7 04 24 8d 2b 80 00 	movl   $0x802b8d,(%esp)
  80028e:	e8 50 1a 00 00       	call   801ce3 <printf>
	exit();
  800293:	e8 db 00 00 00       	call   800373 <exit>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <umain>:

void
umain(int argc, char **argv)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 20             	sub    $0x20,%esp
  8002a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a5:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 35 0f 00 00       	call   8011f0 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002bb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002be:	eb 1e                	jmp    8002de <umain+0x44>
		switch (i) {
  8002c0:	83 f8 64             	cmp    $0x64,%eax
  8002c3:	74 0a                	je     8002cf <umain+0x35>
  8002c5:	83 f8 6c             	cmp    $0x6c,%eax
  8002c8:	74 05                	je     8002cf <umain+0x35>
  8002ca:	83 f8 46             	cmp    $0x46,%eax
  8002cd:	75 0a                	jne    8002d9 <umain+0x3f>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002cf:	83 04 85 20 50 80 00 	addl   $0x1,0x805020(,%eax,4)
  8002d6:	01 
			break;
  8002d7:	eb 05                	jmp    8002de <umain+0x44>
		default:
			usage();
  8002d9:	e8 a3 ff ff ff       	call   800281 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002de:	89 1c 24             	mov    %ebx,(%esp)
  8002e1:	e8 42 0f 00 00       	call   801228 <argnext>
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	79 d6                	jns    8002c0 <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002ea:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ee:	74 07                	je     8002f7 <umain+0x5d>
  8002f0:	bb 01 00 00 00       	mov    $0x1,%ebx
  8002f5:	eb 28                	jmp    80031f <umain+0x85>
		ls("/", "");
  8002f7:	c7 44 24 04 a8 2b 80 	movl   $0x802ba8,0x4(%esp)
  8002fe:	00 
  8002ff:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  800306:	e8 e2 fe ff ff       	call   8001ed <ls>
  80030b:	eb 17                	jmp    800324 <umain+0x8a>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  80030d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 d1 fe ff ff       	call   8001ed <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031c:	83 c3 01             	add    $0x1,%ebx
  80031f:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800322:	7c e9                	jl     80030d <umain+0x73>
			ls(argv[i], argv[i]);
	}
}
  800324:	83 c4 20             	add    $0x20,%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 10             	sub    $0x10,%esp
  800333:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800336:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800339:	e8 47 0b 00 00       	call   800e85 <sys_getenvid>
  80033e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800343:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800346:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80034b:	a3 20 54 80 00       	mov    %eax,0x805420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800350:	85 db                	test   %ebx,%ebx
  800352:	7e 07                	jle    80035b <libmain+0x30>
		binaryname = argv[0];
  800354:	8b 06                	mov    (%esi),%eax
  800356:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80035b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035f:	89 1c 24             	mov    %ebx,(%esp)
  800362:	e8 33 ff ff ff       	call   80029a <umain>

	// exit gracefully
	exit();
  800367:	e8 07 00 00 00       	call   800373 <exit>
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800379:	e8 ac 11 00 00       	call   80152a <close_all>
	sys_env_destroy(0);
  80037e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800385:	e8 a9 0a 00 00       	call   800e33 <sys_env_destroy>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800397:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80039d:	e8 e3 0a 00 00       	call   800e85 <sys_getenvid>
  8003a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	c7 04 24 d8 2b 80 00 	movl   $0x802bd8,(%esp)
  8003bf:	e8 c1 00 00 00       	call   800485 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 51 00 00 00       	call   800424 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 a7 2b 80 00 	movl   $0x802ba7,(%esp)
  8003da:	e8 a6 00 00 00       	call   800485 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003df:	cc                   	int3   
  8003e0:	eb fd                	jmp    8003df <_panic+0x53>

008003e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 14             	sub    $0x14,%esp
  8003e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ec:	8b 13                	mov    (%ebx),%edx
  8003ee:	8d 42 01             	lea    0x1(%edx),%eax
  8003f1:	89 03                	mov    %eax,(%ebx)
  8003f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 19                	jne    80041a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800401:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800408:	00 
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 e2 09 00 00       	call   800df6 <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80041e:	83 c4 14             	add    $0x14,%esp
  800421:	5b                   	pop    %ebx
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800434:	00 00 00 
	b.cnt = 0;
  800437:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800441:	8b 45 0c             	mov    0xc(%ebp),%eax
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800455:	89 44 24 04          	mov    %eax,0x4(%esp)
  800459:	c7 04 24 e2 03 80 00 	movl   $0x8003e2,(%esp)
  800460:	e8 a9 01 00 00       	call   80060e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800465:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	e8 79 09 00 00       	call   800df6 <sys_cputs>

	return b.cnt;
}
  80047d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800492:	8b 45 08             	mov    0x8(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	e8 87 ff ff ff       	call   800424 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    
  80049f:	90                   	nop

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004cd:	39 d9                	cmp    %ebx,%ecx
  8004cf:	72 05                	jb     8004d6 <printnum+0x36>
  8004d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004d4:	77 69                	ja     80053f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 9c 23 00 00       	call   8028b0 <__udivdi3>
  800514:	89 d9                	mov    %ebx,%ecx
  800516:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80051a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	89 fa                	mov    %edi,%edx
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	e8 71 ff ff ff       	call   8004a0 <printnum>
  80052f:	eb 1b                	jmp    80054c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800531:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800535:	8b 45 18             	mov    0x18(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff d3                	call   *%ebx
  80053d:	eb 03                	jmp    800542 <printnum+0xa2>
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	7f e8                	jg     800531 <printnum+0x91>
  800549:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80054c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800550:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 6c 24 00 00       	call   8029e0 <__umoddi3>
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	0f be 80 fb 2b 80 00 	movsbl 0x802bfb(%eax),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800585:	ff d0                	call   *%eax
}
  800587:	83 c4 3c             	add    $0x3c,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800592:	83 fa 01             	cmp    $0x1,%edx
  800595:	7e 0e                	jle    8005a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800597:	8b 10                	mov    (%eax),%edx
  800599:	8d 4a 08             	lea    0x8(%edx),%ecx
  80059c:	89 08                	mov    %ecx,(%eax)
  80059e:	8b 02                	mov    (%edx),%eax
  8005a0:	8b 52 04             	mov    0x4(%edx),%edx
  8005a3:	eb 22                	jmp    8005c7 <getuint+0x38>
	else if (lflag)
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	74 10                	je     8005b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ae:	89 08                	mov    %ecx,(%eax)
  8005b0:	8b 02                	mov    (%edx),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b7:	eb 0e                	jmp    8005c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005be:	89 08                	mov    %ecx,(%eax)
  8005c0:	8b 02                	mov    (%edx),%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005c7:	5d                   	pop    %ebp
  8005c8:	c3                   	ret    

008005c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8005d8:	73 0a                	jae    8005e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	88 02                	mov    %al,(%edx)
}
  8005e4:	5d                   	pop    %ebp
  8005e5:	c3                   	ret    

008005e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	e8 02 00 00 00       	call   80060e <vprintfmt>
	va_end(ap);
}
  80060c:	c9                   	leave  
  80060d:	c3                   	ret    

0080060e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	57                   	push   %edi
  800612:	56                   	push   %esi
  800613:	53                   	push   %ebx
  800614:	83 ec 3c             	sub    $0x3c,%esp
  800617:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061d:	eb 14                	jmp    800633 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 84 b3 03 00 00    	je     8009da <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800627:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800631:	89 f3                	mov    %esi,%ebx
  800633:	8d 73 01             	lea    0x1(%ebx),%esi
  800636:	0f b6 03             	movzbl (%ebx),%eax
  800639:	83 f8 25             	cmp    $0x25,%eax
  80063c:	75 e1                	jne    80061f <vprintfmt+0x11>
  80063e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800642:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800649:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800650:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
  80065c:	eb 1d                	jmp    80067b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800660:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800664:	eb 15                	jmp    80067b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800668:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80066e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800671:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800674:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80067e:	0f b6 0e             	movzbl (%esi),%ecx
  800681:	0f b6 c1             	movzbl %cl,%eax
  800684:	83 e9 23             	sub    $0x23,%ecx
  800687:	80 f9 55             	cmp    $0x55,%cl
  80068a:	0f 87 2a 03 00 00    	ja     8009ba <vprintfmt+0x3ac>
  800690:	0f b6 c9             	movzbl %cl,%ecx
  800693:	ff 24 8d 40 2d 80 00 	jmp    *0x802d40(,%ecx,4)
  80069a:	89 de                	mov    %ebx,%esi
  80069c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006a1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006a4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006a8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006ab:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006ae:	83 fb 09             	cmp    $0x9,%ebx
  8006b1:	77 36                	ja     8006e9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006b3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b6:	eb e9                	jmp    8006a1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 48 04             	lea    0x4(%eax),%ecx
  8006be:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c8:	eb 22                	jmp    8006ec <vprintfmt+0xde>
  8006ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	89 de                	mov    %ebx,%esi
  8006dc:	eb 9d                	jmp    80067b <vprintfmt+0x6d>
  8006de:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8006e7:	eb 92                	jmp    80067b <vprintfmt+0x6d>
  8006e9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8006ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f0:	79 89                	jns    80067b <vprintfmt+0x6d>
  8006f2:	e9 77 ff ff ff       	jmp    80066e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006fc:	e9 7a ff ff ff       	jmp    80067b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			break;
  800716:	e9 18 ff ff ff       	jmp    800633 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8d 50 04             	lea    0x4(%eax),%edx
  800721:	89 55 14             	mov    %edx,0x14(%ebp)
  800724:	8b 00                	mov    (%eax),%eax
  800726:	99                   	cltd   
  800727:	31 d0                	xor    %edx,%eax
  800729:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80072b:	83 f8 0f             	cmp    $0xf,%eax
  80072e:	7f 0b                	jg     80073b <vprintfmt+0x12d>
  800730:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  800737:	85 d2                	test   %edx,%edx
  800739:	75 20                	jne    80075b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80073b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073f:	c7 44 24 08 13 2c 80 	movl   $0x802c13,0x8(%esp)
  800746:	00 
  800747:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	e8 90 fe ff ff       	call   8005e6 <printfmt>
  800756:	e9 d8 fe ff ff       	jmp    800633 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80075b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075f:	c7 44 24 08 d5 2f 80 	movl   $0x802fd5,0x8(%esp)
  800766:	00 
  800767:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	e8 70 fe ff ff       	call   8005e6 <printfmt>
  800776:	e9 b8 fe ff ff       	jmp    800633 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80077e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800781:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)
  80078d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80078f:	85 f6                	test   %esi,%esi
  800791:	b8 0c 2c 80 00       	mov    $0x802c0c,%eax
  800796:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800799:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80079d:	0f 84 97 00 00 00    	je     80083a <vprintfmt+0x22c>
  8007a3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007a7:	0f 8e 9b 00 00 00    	jle    800848 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b1:	89 34 24             	mov    %esi,(%esp)
  8007b4:	e8 cf 02 00 00       	call   800a88 <strnlen>
  8007b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007bc:	29 c2                	sub    %eax,%edx
  8007be:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007c1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007d1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d3:	eb 0f                	jmp    8007e4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8007d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e1:	83 eb 01             	sub    $0x1,%ebx
  8007e4:	85 db                	test   %ebx,%ebx
  8007e6:	7f ed                	jg     8007d5 <vprintfmt+0x1c7>
  8007e8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	0f 49 c2             	cmovns %edx,%eax
  8007f8:	29 c2                	sub    %eax,%edx
  8007fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007fd:	89 d7                	mov    %edx,%edi
  8007ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800802:	eb 50                	jmp    800854 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800804:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800808:	74 1e                	je     800828 <vprintfmt+0x21a>
  80080a:	0f be d2             	movsbl %dl,%edx
  80080d:	83 ea 20             	sub    $0x20,%edx
  800810:	83 fa 5e             	cmp    $0x5e,%edx
  800813:	76 13                	jbe    800828 <vprintfmt+0x21a>
					putch('?', putdat);
  800815:	8b 45 0c             	mov    0xc(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800823:	ff 55 08             	call   *0x8(%ebp)
  800826:	eb 0d                	jmp    800835 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800835:	83 ef 01             	sub    $0x1,%edi
  800838:	eb 1a                	jmp    800854 <vprintfmt+0x246>
  80083a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80083d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800840:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800843:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800846:	eb 0c                	jmp    800854 <vprintfmt+0x246>
  800848:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80084b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80084e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800851:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800854:	83 c6 01             	add    $0x1,%esi
  800857:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80085b:	0f be c2             	movsbl %dl,%eax
  80085e:	85 c0                	test   %eax,%eax
  800860:	74 27                	je     800889 <vprintfmt+0x27b>
  800862:	85 db                	test   %ebx,%ebx
  800864:	78 9e                	js     800804 <vprintfmt+0x1f6>
  800866:	83 eb 01             	sub    $0x1,%ebx
  800869:	79 99                	jns    800804 <vprintfmt+0x1f6>
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800870:	8b 75 08             	mov    0x8(%ebp),%esi
  800873:	89 c3                	mov    %eax,%ebx
  800875:	eb 1a                	jmp    800891 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800877:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800882:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800884:	83 eb 01             	sub    $0x1,%ebx
  800887:	eb 08                	jmp    800891 <vprintfmt+0x283>
  800889:	89 fb                	mov    %edi,%ebx
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800891:	85 db                	test   %ebx,%ebx
  800893:	7f e2                	jg     800877 <vprintfmt+0x269>
  800895:	89 75 08             	mov    %esi,0x8(%ebp)
  800898:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80089b:	e9 93 fd ff ff       	jmp    800633 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008a0:	83 fa 01             	cmp    $0x1,%edx
  8008a3:	7e 16                	jle    8008bb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8d 50 08             	lea    0x8(%eax),%edx
  8008ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ae:	8b 50 04             	mov    0x4(%eax),%edx
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008b9:	eb 32                	jmp    8008ed <vprintfmt+0x2df>
	else if (lflag)
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	74 18                	je     8008d7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8d 50 04             	lea    0x4(%eax),%edx
  8008c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c8:	8b 30                	mov    (%eax),%esi
  8008ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	c1 f8 1f             	sar    $0x1f,%eax
  8008d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d5:	eb 16                	jmp    8008ed <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 50 04             	lea    0x4(%eax),%edx
  8008dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e0:	8b 30                	mov    (%eax),%esi
  8008e2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008e5:	89 f0                	mov    %esi,%eax
  8008e7:	c1 f8 1f             	sar    $0x1f,%eax
  8008ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fc:	0f 89 80 00 00 00    	jns    800982 <vprintfmt+0x374>
				putch('-', putdat);
  800902:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800906:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80090d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800910:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800913:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800916:	f7 d8                	neg    %eax
  800918:	83 d2 00             	adc    $0x0,%edx
  80091b:	f7 da                	neg    %edx
			}
			base = 10;
  80091d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800922:	eb 5e                	jmp    800982 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800924:	8d 45 14             	lea    0x14(%ebp),%eax
  800927:	e8 63 fc ff ff       	call   80058f <getuint>
			base = 10;
  80092c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800931:	eb 4f                	jmp    800982 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
  800936:	e8 54 fc ff ff       	call   80058f <getuint>
			base = 8;
  80093b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800940:	eb 40                	jmp    800982 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800942:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800946:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80094d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800950:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800954:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80095b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80095e:	8b 45 14             	mov    0x14(%ebp),%eax
  800961:	8d 50 04             	lea    0x4(%eax),%edx
  800964:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800967:	8b 00                	mov    (%eax),%eax
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80096e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800973:	eb 0d                	jmp    800982 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800975:	8d 45 14             	lea    0x14(%ebp),%eax
  800978:	e8 12 fc ff ff       	call   80058f <getuint>
			base = 16;
  80097d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800982:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800986:	89 74 24 10          	mov    %esi,0x10(%esp)
  80098a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80098d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800991:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800995:	89 04 24             	mov    %eax,(%esp)
  800998:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099c:	89 fa                	mov    %edi,%edx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	e8 fa fa ff ff       	call   8004a0 <printnum>
			break;
  8009a6:	e9 88 fc ff ff       	jmp    800633 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009b5:	e9 79 fc ff ff       	jmp    800633 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c8:	89 f3                	mov    %esi,%ebx
  8009ca:	eb 03                	jmp    8009cf <vprintfmt+0x3c1>
  8009cc:	83 eb 01             	sub    $0x1,%ebx
  8009cf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009d3:	75 f7                	jne    8009cc <vprintfmt+0x3be>
  8009d5:	e9 59 fc ff ff       	jmp    800633 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009da:	83 c4 3c             	add    $0x3c,%esp
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	83 ec 28             	sub    $0x28,%esp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	74 30                	je     800a33 <vsnprintf+0x51>
  800a03:	85 d2                	test   %edx,%edx
  800a05:	7e 2c                	jle    800a33 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a07:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1c:	c7 04 24 c9 05 80 00 	movl   $0x8005c9,(%esp)
  800a23:	e8 e6 fb ff ff       	call   80060e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a31:	eb 05                	jmp    800a38 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a40:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a47:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	e8 82 ff ff ff       	call   8009e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    
  800a62:	66 90                	xchg   %ax,%ax
  800a64:	66 90                	xchg   %ax,%ax
  800a66:	66 90                	xchg   %ax,%ax
  800a68:	66 90                	xchg   %ax,%ax
  800a6a:	66 90                	xchg   %ax,%ax
  800a6c:	66 90                	xchg   %ax,%ax
  800a6e:	66 90                	xchg   %ax,%ax

00800a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	eb 03                	jmp    800a80 <strlen+0x10>
		n++;
  800a7d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a84:	75 f7                	jne    800a7d <strlen+0xd>
		n++;
	return n;
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	eb 03                	jmp    800a9b <strnlen+0x13>
		n++;
  800a98:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9b:	39 d0                	cmp    %edx,%eax
  800a9d:	74 06                	je     800aa5 <strnlen+0x1d>
  800a9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aa3:	75 f3                	jne    800a98 <strnlen+0x10>
		n++;
	return n;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800abd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ac0:	84 db                	test   %bl,%bl
  800ac2:	75 ef                	jne    800ab3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	83 ec 08             	sub    $0x8,%esp
  800ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad1:	89 1c 24             	mov    %ebx,(%esp)
  800ad4:	e8 97 ff ff ff       	call   800a70 <strlen>
	strcpy(dst + len, src);
  800ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae0:	01 d8                	add    %ebx,%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 bd ff ff ff       	call   800aa7 <strcpy>
	return dst;
}
  800aea:	89 d8                	mov    %ebx,%eax
  800aec:	83 c4 08             	add    $0x8,%esp
  800aef:	5b                   	pop    %ebx
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 75 08             	mov    0x8(%ebp),%esi
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	89 f3                	mov    %esi,%ebx
  800aff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b02:	89 f2                	mov    %esi,%edx
  800b04:	eb 0f                	jmp    800b15 <strncpy+0x23>
		*dst++ = *src;
  800b06:	83 c2 01             	add    $0x1,%edx
  800b09:	0f b6 01             	movzbl (%ecx),%eax
  800b0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b12:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b15:	39 da                	cmp    %ebx,%edx
  800b17:	75 ed                	jne    800b06 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b19:	89 f0                	mov    %esi,%eax
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 75 08             	mov    0x8(%ebp),%esi
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b2d:	89 f0                	mov    %esi,%eax
  800b2f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	75 0b                	jne    800b42 <strlcpy+0x23>
  800b37:	eb 1d                	jmp    800b56 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	83 c2 01             	add    $0x1,%edx
  800b3f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b42:	39 d8                	cmp    %ebx,%eax
  800b44:	74 0b                	je     800b51 <strlcpy+0x32>
  800b46:	0f b6 0a             	movzbl (%edx),%ecx
  800b49:	84 c9                	test   %cl,%cl
  800b4b:	75 ec                	jne    800b39 <strlcpy+0x1a>
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	eb 02                	jmp    800b53 <strlcpy+0x34>
  800b51:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b53:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b56:	29 f0                	sub    %esi,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b65:	eb 06                	jmp    800b6d <strcmp+0x11>
		p++, q++;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b6d:	0f b6 01             	movzbl (%ecx),%eax
  800b70:	84 c0                	test   %al,%al
  800b72:	74 04                	je     800b78 <strcmp+0x1c>
  800b74:	3a 02                	cmp    (%edx),%al
  800b76:	74 ef                	je     800b67 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b78:	0f b6 c0             	movzbl %al,%eax
  800b7b:	0f b6 12             	movzbl (%edx),%edx
  800b7e:	29 d0                	sub    %edx,%eax
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8c:	89 c3                	mov    %eax,%ebx
  800b8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b91:	eb 06                	jmp    800b99 <strncmp+0x17>
		n--, p++, q++;
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b99:	39 d8                	cmp    %ebx,%eax
  800b9b:	74 15                	je     800bb2 <strncmp+0x30>
  800b9d:	0f b6 08             	movzbl (%eax),%ecx
  800ba0:	84 c9                	test   %cl,%cl
  800ba2:	74 04                	je     800ba8 <strncmp+0x26>
  800ba4:	3a 0a                	cmp    (%edx),%cl
  800ba6:	74 eb                	je     800b93 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba8:	0f b6 00             	movzbl (%eax),%eax
  800bab:	0f b6 12             	movzbl (%edx),%edx
  800bae:	29 d0                	sub    %edx,%eax
  800bb0:	eb 05                	jmp    800bb7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc4:	eb 07                	jmp    800bcd <strchr+0x13>
		if (*s == c)
  800bc6:	38 ca                	cmp    %cl,%dl
  800bc8:	74 0f                	je     800bd9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	84 d2                	test   %dl,%dl
  800bd2:	75 f2                	jne    800bc6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be5:	eb 07                	jmp    800bee <strfind+0x13>
		if (*s == c)
  800be7:	38 ca                	cmp    %cl,%dl
  800be9:	74 0a                	je     800bf5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800beb:	83 c0 01             	add    $0x1,%eax
  800bee:	0f b6 10             	movzbl (%eax),%edx
  800bf1:	84 d2                	test   %dl,%dl
  800bf3:	75 f2                	jne    800be7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c03:	85 c9                	test   %ecx,%ecx
  800c05:	74 36                	je     800c3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0d:	75 28                	jne    800c37 <memset+0x40>
  800c0f:	f6 c1 03             	test   $0x3,%cl
  800c12:	75 23                	jne    800c37 <memset+0x40>
		c &= 0xFF;
  800c14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	c1 e3 08             	shl    $0x8,%ebx
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	c1 e6 18             	shl    $0x18,%esi
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	c1 e0 10             	shl    $0x10,%eax
  800c27:	09 f0                	or     %esi,%eax
  800c29:	09 c2                	or     %eax,%edx
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c2f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c32:	fc                   	cld    
  800c33:	f3 ab                	rep stos %eax,%es:(%edi)
  800c35:	eb 06                	jmp    800c3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	fc                   	cld    
  800c3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c3d:	89 f8                	mov    %edi,%eax
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c52:	39 c6                	cmp    %eax,%esi
  800c54:	73 35                	jae    800c8b <memmove+0x47>
  800c56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c59:	39 d0                	cmp    %edx,%eax
  800c5b:	73 2e                	jae    800c8b <memmove+0x47>
		s += n;
		d += n;
  800c5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6a:	75 13                	jne    800c7f <memmove+0x3b>
  800c6c:	f6 c1 03             	test   $0x3,%cl
  800c6f:	75 0e                	jne    800c7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c71:	83 ef 04             	sub    $0x4,%edi
  800c74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c7a:	fd                   	std    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 09                	jmp    800c88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c7f:	83 ef 01             	sub    $0x1,%edi
  800c82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c85:	fd                   	std    
  800c86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c88:	fc                   	cld    
  800c89:	eb 1d                	jmp    800ca8 <memmove+0x64>
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8f:	f6 c2 03             	test   $0x3,%dl
  800c92:	75 0f                	jne    800ca3 <memmove+0x5f>
  800c94:	f6 c1 03             	test   $0x3,%cl
  800c97:	75 0a                	jne    800ca3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c99:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	fc                   	cld    
  800c9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca1:	eb 05                	jmp    800ca8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca3:	89 c7                	mov    %eax,%edi
  800ca5:	fc                   	cld    
  800ca6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 04 24             	mov    %eax,(%esp)
  800cc6:	e8 79 ff ff ff       	call   800c44 <memmove>
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdd:	eb 1a                	jmp    800cf9 <memcmp+0x2c>
		if (*s1 != *s2)
  800cdf:	0f b6 02             	movzbl (%edx),%eax
  800ce2:	0f b6 19             	movzbl (%ecx),%ebx
  800ce5:	38 d8                	cmp    %bl,%al
  800ce7:	74 0a                	je     800cf3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ce9:	0f b6 c0             	movzbl %al,%eax
  800cec:	0f b6 db             	movzbl %bl,%ebx
  800cef:	29 d8                	sub    %ebx,%eax
  800cf1:	eb 0f                	jmp    800d02 <memcmp+0x35>
		s1++, s2++;
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf9:	39 f2                	cmp    %esi,%edx
  800cfb:	75 e2                	jne    800cdf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d14:	eb 07                	jmp    800d1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d16:	38 08                	cmp    %cl,(%eax)
  800d18:	74 07                	je     800d21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1a:	83 c0 01             	add    $0x1,%eax
  800d1d:	39 d0                	cmp    %edx,%eax
  800d1f:	72 f5                	jb     800d16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2f:	eb 03                	jmp    800d34 <strtol+0x11>
		s++;
  800d31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d34:	0f b6 0a             	movzbl (%edx),%ecx
  800d37:	80 f9 09             	cmp    $0x9,%cl
  800d3a:	74 f5                	je     800d31 <strtol+0xe>
  800d3c:	80 f9 20             	cmp    $0x20,%cl
  800d3f:	74 f0                	je     800d31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d41:	80 f9 2b             	cmp    $0x2b,%cl
  800d44:	75 0a                	jne    800d50 <strtol+0x2d>
		s++;
  800d46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d49:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4e:	eb 11                	jmp    800d61 <strtol+0x3e>
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d55:	80 f9 2d             	cmp    $0x2d,%cl
  800d58:	75 07                	jne    800d61 <strtol+0x3e>
		s++, neg = 1;
  800d5a:	8d 52 01             	lea    0x1(%edx),%edx
  800d5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d66:	75 15                	jne    800d7d <strtol+0x5a>
  800d68:	80 3a 30             	cmpb   $0x30,(%edx)
  800d6b:	75 10                	jne    800d7d <strtol+0x5a>
  800d6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d71:	75 0a                	jne    800d7d <strtol+0x5a>
		s += 2, base = 16;
  800d73:	83 c2 02             	add    $0x2,%edx
  800d76:	b8 10 00 00 00       	mov    $0x10,%eax
  800d7b:	eb 10                	jmp    800d8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	75 0c                	jne    800d8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d83:	80 3a 30             	cmpb   $0x30,(%edx)
  800d86:	75 05                	jne    800d8d <strtol+0x6a>
		s++, base = 8;
  800d88:	83 c2 01             	add    $0x1,%edx
  800d8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d95:	0f b6 0a             	movzbl (%edx),%ecx
  800d98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	3c 09                	cmp    $0x9,%al
  800d9f:	77 08                	ja     800da9 <strtol+0x86>
			dig = *s - '0';
  800da1:	0f be c9             	movsbl %cl,%ecx
  800da4:	83 e9 30             	sub    $0x30,%ecx
  800da7:	eb 20                	jmp    800dc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800da9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dac:	89 f0                	mov    %esi,%eax
  800dae:	3c 19                	cmp    $0x19,%al
  800db0:	77 08                	ja     800dba <strtol+0x97>
			dig = *s - 'a' + 10;
  800db2:	0f be c9             	movsbl %cl,%ecx
  800db5:	83 e9 57             	sub    $0x57,%ecx
  800db8:	eb 0f                	jmp    800dc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	3c 19                	cmp    $0x19,%al
  800dc1:	77 16                	ja     800dd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800dc3:	0f be c9             	movsbl %cl,%ecx
  800dc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dcc:	7d 0f                	jge    800ddd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dce:	83 c2 01             	add    $0x1,%edx
  800dd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800dd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800dd7:	eb bc                	jmp    800d95 <strtol+0x72>
  800dd9:	89 d8                	mov    %ebx,%eax
  800ddb:	eb 02                	jmp    800ddf <strtol+0xbc>
  800ddd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ddf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de3:	74 05                	je     800dea <strtol+0xc7>
		*endptr = (char *) s;
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800dea:	f7 d8                	neg    %eax
  800dec:	85 ff                	test   %edi,%edi
  800dee:	0f 44 c3             	cmove  %ebx,%eax
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	89 c7                	mov    %eax,%edi
  800e0b:	89 c6                	mov    %eax,%esi
  800e0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e24:	89 d1                	mov    %edx,%ecx
  800e26:	89 d3                	mov    %edx,%ebx
  800e28:	89 d7                	mov    %edx,%edi
  800e2a:	89 d6                	mov    %edx,%esi
  800e2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	b8 03 00 00 00       	mov    $0x3,%eax
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800e78:	e8 0f f5 ff ff       	call   80038c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 02 00 00 00       	mov    $0x2,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_yield>:

void
sys_yield(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb4:	89 d1                	mov    %edx,%ecx
  800eb6:	89 d3                	mov    %edx,%ebx
  800eb8:	89 d7                	mov    %edx,%edi
  800eba:	89 d6                	mov    %edx,%esi
  800ebc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ecc:	be 00 00 00 00       	mov    $0x0,%esi
  800ed1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edf:	89 f7                	mov    %esi,%edi
  800ee1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800f0a:	e8 7d f4 ff ff       	call   80038c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f0f:	83 c4 2c             	add    $0x2c,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f20:	b8 05 00 00 00       	mov    $0x5,%eax
  800f25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f31:	8b 75 18             	mov    0x18(%ebp),%esi
  800f34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 28                	jle    800f62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f45:	00 
  800f46:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800f5d:	e8 2a f4 ff ff       	call   80038c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f62:	83 c4 2c             	add    $0x2c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800fb0:	e8 d7 f3 ff ff       	call   80038c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  801003:	e8 84 f3 ff ff       	call   80038c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	83 c4 2c             	add    $0x2c,%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101e:	b8 09 00 00 00       	mov    $0x9,%eax
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 df                	mov    %ebx,%edi
  80102b:	89 de                	mov    %ebx,%esi
  80102d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 28                	jle    80105b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	89 44 24 10          	mov    %eax,0x10(%esp)
  801037:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80103e:	00 
  80103f:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  801046:	00 
  801047:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104e:	00 
  80104f:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  801056:	e8 31 f3 ff ff       	call   80038c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80105b:	83 c4 2c             	add    $0x2c,%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801071:	b8 0a 00 00 00       	mov    $0xa,%eax
  801076:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801079:	8b 55 08             	mov    0x8(%ebp),%edx
  80107c:	89 df                	mov    %ebx,%edi
  80107e:	89 de                	mov    %ebx,%esi
  801080:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801082:	85 c0                	test   %eax,%eax
  801084:	7e 28                	jle    8010ae <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801091:	00 
  801092:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  801099:	00 
  80109a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a1:	00 
  8010a2:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  8010a9:	e8 de f2 ff ff       	call   80038c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ae:	83 c4 2c             	add    $0x2c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	be 00 00 00 00       	mov    $0x0,%esi
  8010c1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	89 cb                	mov    %ecx,%ebx
  8010f1:	89 cf                	mov    %ecx,%edi
  8010f3:	89 ce                	mov    %ecx,%esi
  8010f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 28                	jle    801123 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ff:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801106:	00 
  801107:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  80111e:	e8 69 f2 ff ff       	call   80038c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801123:	83 c4 2c             	add    $0x2c,%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801131:	ba 00 00 00 00       	mov    $0x0,%edx
  801136:	b8 0e 00 00 00       	mov    $0xe,%eax
  80113b:	89 d1                	mov    %edx,%ecx
  80113d:	89 d3                	mov    %edx,%ebx
  80113f:	89 d7                	mov    %edx,%edi
  801141:	89 d6                	mov    %edx,%esi
  801143:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801153:	bb 00 00 00 00       	mov    $0x0,%ebx
  801158:	b8 0f 00 00 00       	mov    $0xf,%eax
  80115d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
  801163:	89 df                	mov    %ebx,%edi
  801165:	89 de                	mov    %ebx,%esi
  801167:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	7e 28                	jle    801195 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801171:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801178:	00 
  801179:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  801180:	00 
  801181:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  801190:	e8 f7 f1 ff ff       	call   80038c <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801195:	83 c4 2c             	add    $0x2c,%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	89 de                	mov    %ebx,%esi
  8011ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 28                	jle    8011e8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  8011e3:	e8 a4 f1 ff ff       	call   80038c <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8011e8:	83 c4 2c             	add    $0x2c,%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fa:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8011fd:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  8011ff:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	83 39 01             	cmpl   $0x1,(%ecx)
  80120a:	7e 0f                	jle    80121b <argstart+0x2b>
  80120c:	85 d2                	test   %edx,%edx
  80120e:	ba 00 00 00 00       	mov    $0x0,%edx
  801213:	bb a8 2b 80 00       	mov    $0x802ba8,%ebx
  801218:	0f 44 da             	cmove  %edx,%ebx
  80121b:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  80121e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801225:	5b                   	pop    %ebx
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <argnext>:

int
argnext(struct Argstate *args)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801232:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801239:	8b 43 08             	mov    0x8(%ebx),%eax
  80123c:	85 c0                	test   %eax,%eax
  80123e:	74 71                	je     8012b1 <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  801240:	80 38 00             	cmpb   $0x0,(%eax)
  801243:	75 50                	jne    801295 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801245:	8b 0b                	mov    (%ebx),%ecx
  801247:	83 39 01             	cmpl   $0x1,(%ecx)
  80124a:	74 57                	je     8012a3 <argnext+0x7b>
		    || args->argv[1][0] != '-'
  80124c:	8b 53 04             	mov    0x4(%ebx),%edx
  80124f:	8b 42 04             	mov    0x4(%edx),%eax
  801252:	80 38 2d             	cmpb   $0x2d,(%eax)
  801255:	75 4c                	jne    8012a3 <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801257:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80125b:	74 46                	je     8012a3 <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80125d:	83 c0 01             	add    $0x1,%eax
  801260:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801263:	8b 01                	mov    (%ecx),%eax
  801265:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80126c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801270:	8d 42 08             	lea    0x8(%edx),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	83 c2 04             	add    $0x4,%edx
  80127a:	89 14 24             	mov    %edx,(%esp)
  80127d:	e8 c2 f9 ff ff       	call   800c44 <memmove>
		(*args->argc)--;
  801282:	8b 03                	mov    (%ebx),%eax
  801284:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801287:	8b 43 08             	mov    0x8(%ebx),%eax
  80128a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80128d:	75 06                	jne    801295 <argnext+0x6d>
  80128f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801293:	74 0e                	je     8012a3 <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801295:	8b 53 08             	mov    0x8(%ebx),%edx
  801298:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80129b:	83 c2 01             	add    $0x1,%edx
  80129e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8012a1:	eb 13                	jmp    8012b6 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  8012a3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8012aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8012af:	eb 05                	jmp    8012b6 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8012b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8012b6:	83 c4 14             	add    $0x14,%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8012c6:	8b 43 08             	mov    0x8(%ebx),%eax
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 5a                	je     801327 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  8012cd:	80 38 00             	cmpb   $0x0,(%eax)
  8012d0:	74 0c                	je     8012de <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8012d2:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8012d5:	c7 43 08 a8 2b 80 00 	movl   $0x802ba8,0x8(%ebx)
  8012dc:	eb 44                	jmp    801322 <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  8012de:	8b 03                	mov    (%ebx),%eax
  8012e0:	83 38 01             	cmpl   $0x1,(%eax)
  8012e3:	7e 2f                	jle    801314 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  8012e5:	8b 53 04             	mov    0x4(%ebx),%edx
  8012e8:	8b 4a 04             	mov    0x4(%edx),%ecx
  8012eb:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8012ee:	8b 00                	mov    (%eax),%eax
  8012f0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8012f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fb:	8d 42 08             	lea    0x8(%edx),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	83 c2 04             	add    $0x4,%edx
  801305:	89 14 24             	mov    %edx,(%esp)
  801308:	e8 37 f9 ff ff       	call   800c44 <memmove>
		(*args->argc)--;
  80130d:	8b 03                	mov    (%ebx),%eax
  80130f:	83 28 01             	subl   $0x1,(%eax)
  801312:	eb 0e                	jmp    801322 <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  801314:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  80131b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801322:	8b 43 0c             	mov    0xc(%ebx),%eax
  801325:	eb 05                	jmp    80132c <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801327:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  80132c:	83 c4 14             	add    $0x14,%esp
  80132f:	5b                   	pop    %ebx
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 18             	sub    $0x18,%esp
  801338:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80133b:	8b 51 0c             	mov    0xc(%ecx),%edx
  80133e:	89 d0                	mov    %edx,%eax
  801340:	85 d2                	test   %edx,%edx
  801342:	75 08                	jne    80134c <argvalue+0x1a>
  801344:	89 0c 24             	mov    %ecx,(%esp)
  801347:	e8 70 ff ff ff       	call   8012bc <argnextvalue>
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    
  80134e:	66 90                	xchg   %ax,%ax

00801350 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	05 00 00 00 30       	add    $0x30000000,%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
}
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80136b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801370:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801382:	89 c2                	mov    %eax,%edx
  801384:	c1 ea 16             	shr    $0x16,%edx
  801387:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80138e:	f6 c2 01             	test   $0x1,%dl
  801391:	74 11                	je     8013a4 <fd_alloc+0x2d>
  801393:	89 c2                	mov    %eax,%edx
  801395:	c1 ea 0c             	shr    $0xc,%edx
  801398:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80139f:	f6 c2 01             	test   $0x1,%dl
  8013a2:	75 09                	jne    8013ad <fd_alloc+0x36>
			*fd_store = fd;
  8013a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ab:	eb 17                	jmp    8013c4 <fd_alloc+0x4d>
  8013ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013b7:	75 c9                	jne    801382 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013cc:	83 f8 1f             	cmp    $0x1f,%eax
  8013cf:	77 36                	ja     801407 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d1:	c1 e0 0c             	shl    $0xc,%eax
  8013d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 16             	shr    $0x16,%edx
  8013de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 24                	je     80140e <fd_lookup+0x48>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 0c             	shr    $0xc,%edx
  8013ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 1a                	je     801415 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb 13                	jmp    80141a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 0c                	jmp    80141a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801413:	eb 05                	jmp    80141a <fd_lookup+0x54>
  801415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 18             	sub    $0x18,%esp
  801422:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	eb 13                	jmp    80143f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80142c:	39 08                	cmp    %ecx,(%eax)
  80142e:	75 0c                	jne    80143c <dev_lookup+0x20>
			*dev = devtab[i];
  801430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801433:	89 01                	mov    %eax,(%ecx)
			return 0;
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	eb 38                	jmp    801474 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80143c:	83 c2 01             	add    $0x1,%edx
  80143f:	8b 04 95 a8 2f 80 00 	mov    0x802fa8(,%edx,4),%eax
  801446:	85 c0                	test   %eax,%eax
  801448:	75 e2                	jne    80142c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144a:	a1 20 54 80 00       	mov    0x805420,%eax
  80144f:	8b 40 48             	mov    0x48(%eax),%eax
  801452:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145a:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  801461:	e8 1f f0 ff ff       	call   800485 <cprintf>
	*dev = 0;
  801466:	8b 45 0c             	mov    0xc(%ebp),%eax
  801469:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 20             	sub    $0x20,%esp
  80147e:	8b 75 08             	mov    0x8(%ebp),%esi
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80148b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801491:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 2a ff ff ff       	call   8013c6 <fd_lookup>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 05                	js     8014a5 <fd_close+0x2f>
	    || fd != fd2)
  8014a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014a3:	74 0c                	je     8014b1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014a5:	84 db                	test   %bl,%bl
  8014a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ac:	0f 44 c2             	cmove  %edx,%eax
  8014af:	eb 3f                	jmp    8014f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	8b 06                	mov    (%esi),%eax
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	e8 5a ff ff ff       	call   80141c <dev_lookup>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 16                	js     8014de <fd_close+0x68>
		if (dev->dev_close)
  8014c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	74 07                	je     8014de <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8014d7:	89 34 24             	mov    %esi,(%esp)
  8014da:	ff d0                	call   *%eax
  8014dc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e9:	e8 7c fa ff ff       	call   800f6a <sys_page_unmap>
	return r;
  8014ee:	89 d8                	mov    %ebx,%eax
}
  8014f0:	83 c4 20             	add    $0x20,%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5e                   	pop    %esi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 b7 fe ff ff       	call   8013c6 <fd_lookup>
  80150f:	89 c2                	mov    %eax,%edx
  801511:	85 d2                	test   %edx,%edx
  801513:	78 13                	js     801528 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801515:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80151c:	00 
  80151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801520:	89 04 24             	mov    %eax,(%esp)
  801523:	e8 4e ff ff ff       	call   801476 <fd_close>
}
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <close_all>:

void
close_all(void)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801531:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	e8 b9 ff ff ff       	call   8014f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80153e:	83 c3 01             	add    $0x1,%ebx
  801541:	83 fb 20             	cmp    $0x20,%ebx
  801544:	75 f0                	jne    801536 <close_all+0xc>
		close(i);
}
  801546:	83 c4 14             	add    $0x14,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	57                   	push   %edi
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801555:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	89 04 24             	mov    %eax,(%esp)
  801562:	e8 5f fe ff ff       	call   8013c6 <fd_lookup>
  801567:	89 c2                	mov    %eax,%edx
  801569:	85 d2                	test   %edx,%edx
  80156b:	0f 88 e1 00 00 00    	js     801652 <dup+0x106>
		return r;
	close(newfdnum);
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	89 04 24             	mov    %eax,(%esp)
  801577:	e8 7b ff ff ff       	call   8014f7 <close>

	newfd = INDEX2FD(newfdnum);
  80157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80157f:	c1 e3 0c             	shl    $0xc,%ebx
  801582:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158b:	89 04 24             	mov    %eax,(%esp)
  80158e:	e8 cd fd ff ff       	call   801360 <fd2data>
  801593:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801595:	89 1c 24             	mov    %ebx,(%esp)
  801598:	e8 c3 fd ff ff       	call   801360 <fd2data>
  80159d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80159f:	89 f0                	mov    %esi,%eax
  8015a1:	c1 e8 16             	shr    $0x16,%eax
  8015a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ab:	a8 01                	test   $0x1,%al
  8015ad:	74 43                	je     8015f2 <dup+0xa6>
  8015af:	89 f0                	mov    %esi,%eax
  8015b1:	c1 e8 0c             	shr    $0xc,%eax
  8015b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015bb:	f6 c2 01             	test   $0x1,%dl
  8015be:	74 32                	je     8015f2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015db:	00 
  8015dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e7:	e8 2b f9 ff ff       	call   800f17 <sys_page_map>
  8015ec:	89 c6                	mov    %eax,%esi
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 3e                	js     801630 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	c1 ea 0c             	shr    $0xc,%edx
  8015fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801601:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801607:	89 54 24 10          	mov    %edx,0x10(%esp)
  80160b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80160f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801616:	00 
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801622:	e8 f0 f8 ff ff       	call   800f17 <sys_page_map>
  801627:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801629:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80162c:	85 f6                	test   %esi,%esi
  80162e:	79 22                	jns    801652 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163b:	e8 2a f9 ff ff       	call   800f6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801640:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164b:	e8 1a f9 ff ff       	call   800f6a <sys_page_unmap>
	return r;
  801650:	89 f0                	mov    %esi,%eax
}
  801652:	83 c4 3c             	add    $0x3c,%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5f                   	pop    %edi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 24             	sub    $0x24,%esp
  801661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801664:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	89 1c 24             	mov    %ebx,(%esp)
  80166e:	e8 53 fd ff ff       	call   8013c6 <fd_lookup>
  801673:	89 c2                	mov    %eax,%edx
  801675:	85 d2                	test   %edx,%edx
  801677:	78 6d                	js     8016e6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	8b 00                	mov    (%eax),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 8f fd ff ff       	call   80141c <dev_lookup>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 55                	js     8016e6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	8b 50 08             	mov    0x8(%eax),%edx
  801697:	83 e2 03             	and    $0x3,%edx
  80169a:	83 fa 01             	cmp    $0x1,%edx
  80169d:	75 23                	jne    8016c2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80169f:	a1 20 54 80 00       	mov    0x805420,%eax
  8016a4:	8b 40 48             	mov    0x48(%eax),%eax
  8016a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	c7 04 24 6d 2f 80 00 	movl   $0x802f6d,(%esp)
  8016b6:	e8 ca ed ff ff       	call   800485 <cprintf>
		return -E_INVAL;
  8016bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c0:	eb 24                	jmp    8016e6 <read+0x8c>
	}
	if (!dev->dev_read)
  8016c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c5:	8b 52 08             	mov    0x8(%edx),%edx
  8016c8:	85 d2                	test   %edx,%edx
  8016ca:	74 15                	je     8016e1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016da:	89 04 24             	mov    %eax,(%esp)
  8016dd:	ff d2                	call   *%edx
  8016df:	eb 05                	jmp    8016e6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016e6:	83 c4 24             	add    $0x24,%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	57                   	push   %edi
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 1c             	sub    $0x1c,%esp
  8016f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801700:	eb 23                	jmp    801725 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801702:	89 f0                	mov    %esi,%eax
  801704:	29 d8                	sub    %ebx,%eax
  801706:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170a:	89 d8                	mov    %ebx,%eax
  80170c:	03 45 0c             	add    0xc(%ebp),%eax
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	89 3c 24             	mov    %edi,(%esp)
  801716:	e8 3f ff ff ff       	call   80165a <read>
		if (m < 0)
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 10                	js     80172f <readn+0x43>
			return m;
		if (m == 0)
  80171f:	85 c0                	test   %eax,%eax
  801721:	74 0a                	je     80172d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801723:	01 c3                	add    %eax,%ebx
  801725:	39 f3                	cmp    %esi,%ebx
  801727:	72 d9                	jb     801702 <readn+0x16>
  801729:	89 d8                	mov    %ebx,%eax
  80172b:	eb 02                	jmp    80172f <readn+0x43>
  80172d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80172f:	83 c4 1c             	add    $0x1c,%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 24             	sub    $0x24,%esp
  80173e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801741:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	89 1c 24             	mov    %ebx,(%esp)
  80174b:	e8 76 fc ff ff       	call   8013c6 <fd_lookup>
  801750:	89 c2                	mov    %eax,%edx
  801752:	85 d2                	test   %edx,%edx
  801754:	78 68                	js     8017be <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801756:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	8b 00                	mov    (%eax),%eax
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 b2 fc ff ff       	call   80141c <dev_lookup>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 50                	js     8017be <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801775:	75 23                	jne    80179a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801777:	a1 20 54 80 00       	mov    0x805420,%eax
  80177c:	8b 40 48             	mov    0x48(%eax),%eax
  80177f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	c7 04 24 89 2f 80 00 	movl   $0x802f89,(%esp)
  80178e:	e8 f2 ec ff ff       	call   800485 <cprintf>
		return -E_INVAL;
  801793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801798:	eb 24                	jmp    8017be <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80179a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179d:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a0:	85 d2                	test   %edx,%edx
  8017a2:	74 15                	je     8017b9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	ff d2                	call   *%edx
  8017b7:	eb 05                	jmp    8017be <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017be:	83 c4 24             	add    $0x24,%esp
  8017c1:	5b                   	pop    %ebx
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	e8 ea fb ff ff       	call   8013c6 <fd_lookup>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 0e                	js     8017ee <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 24             	sub    $0x24,%esp
  8017f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	89 1c 24             	mov    %ebx,(%esp)
  801804:	e8 bd fb ff ff       	call   8013c6 <fd_lookup>
  801809:	89 c2                	mov    %eax,%edx
  80180b:	85 d2                	test   %edx,%edx
  80180d:	78 61                	js     801870 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801819:	8b 00                	mov    (%eax),%eax
  80181b:	89 04 24             	mov    %eax,(%esp)
  80181e:	e8 f9 fb ff ff       	call   80141c <dev_lookup>
  801823:	85 c0                	test   %eax,%eax
  801825:	78 49                	js     801870 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182e:	75 23                	jne    801853 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801830:	a1 20 54 80 00       	mov    0x805420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801835:	8b 40 48             	mov    0x48(%eax),%eax
  801838:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801840:	c7 04 24 4c 2f 80 00 	movl   $0x802f4c,(%esp)
  801847:	e8 39 ec ff ff       	call   800485 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80184c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801851:	eb 1d                	jmp    801870 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801853:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801856:	8b 52 18             	mov    0x18(%edx),%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	74 0e                	je     80186b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80185d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801860:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	ff d2                	call   *%edx
  801869:	eb 05                	jmp    801870 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80186b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801870:	83 c4 24             	add    $0x24,%esp
  801873:	5b                   	pop    %ebx
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	53                   	push   %ebx
  80187a:	83 ec 24             	sub    $0x24,%esp
  80187d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801883:	89 44 24 04          	mov    %eax,0x4(%esp)
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	89 04 24             	mov    %eax,(%esp)
  80188d:	e8 34 fb ff ff       	call   8013c6 <fd_lookup>
  801892:	89 c2                	mov    %eax,%edx
  801894:	85 d2                	test   %edx,%edx
  801896:	78 52                	js     8018ea <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801898:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a2:	8b 00                	mov    (%eax),%eax
  8018a4:	89 04 24             	mov    %eax,(%esp)
  8018a7:	e8 70 fb ff ff       	call   80141c <dev_lookup>
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 3a                	js     8018ea <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b7:	74 2c                	je     8018e5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c3:	00 00 00 
	stat->st_isdir = 0;
  8018c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018cd:	00 00 00 
	stat->st_dev = dev;
  8018d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018dd:	89 14 24             	mov    %edx,(%esp)
  8018e0:	ff 50 14             	call   *0x14(%eax)
  8018e3:	eb 05                	jmp    8018ea <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ea:	83 c4 24             	add    $0x24,%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ff:	00 
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	89 04 24             	mov    %eax,(%esp)
  801906:	e8 28 02 00 00       	call   801b33 <open>
  80190b:	89 c3                	mov    %eax,%ebx
  80190d:	85 db                	test   %ebx,%ebx
  80190f:	78 1b                	js     80192c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801911:	8b 45 0c             	mov    0xc(%ebp),%eax
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	89 1c 24             	mov    %ebx,(%esp)
  80191b:	e8 56 ff ff ff       	call   801876 <fstat>
  801920:	89 c6                	mov    %eax,%esi
	close(fd);
  801922:	89 1c 24             	mov    %ebx,(%esp)
  801925:	e8 cd fb ff ff       	call   8014f7 <close>
	return r;
  80192a:	89 f0                	mov    %esi,%eax
}
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	83 ec 10             	sub    $0x10,%esp
  80193b:	89 c6                	mov    %eax,%esi
  80193d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80193f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801946:	75 11                	jne    801959 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801948:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80194f:	e8 e1 0e 00 00       	call   802835 <ipc_find_env>
  801954:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801959:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801960:	00 
  801961:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801968:	00 
  801969:	89 74 24 04          	mov    %esi,0x4(%esp)
  80196d:	a1 00 50 80 00       	mov    0x805000,%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 50 0e 00 00       	call   8027ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80197a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801981:	00 
  801982:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801986:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198d:	e8 be 0d 00 00       	call   802750 <ipc_recv>
}
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	5b                   	pop    %ebx
  801996:	5e                   	pop    %esi
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ad:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019bc:	e8 72 ff ff ff       	call   801933 <fsipc>
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8019de:	e8 50 ff ff ff       	call   801933 <fsipc>
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 14             	sub    $0x14,%esp
  8019ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ff:	b8 05 00 00 00       	mov    $0x5,%eax
  801a04:	e8 2a ff ff ff       	call   801933 <fsipc>
  801a09:	89 c2                	mov    %eax,%edx
  801a0b:	85 d2                	test   %edx,%edx
  801a0d:	78 2b                	js     801a3a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a0f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a16:	00 
  801a17:	89 1c 24             	mov    %ebx,(%esp)
  801a1a:	e8 88 f0 ff ff       	call   800aa7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a1f:	a1 80 60 80 00       	mov    0x806080,%eax
  801a24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a2a:	a1 84 60 80 00       	mov    0x806084,%eax
  801a2f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a3a:	83 c4 14             	add    $0x14,%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 18             	sub    $0x18,%esp
  801a46:	8b 45 10             	mov    0x10(%ebp),%eax
  801a49:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a4e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a53:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a56:	8b 55 08             	mov    0x8(%ebp),%edx
  801a59:	8b 52 0c             	mov    0xc(%edx),%edx
  801a5c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a62:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a72:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801a79:	e8 c6 f1 ff ff       	call   800c44 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a83:	b8 04 00 00 00       	mov    $0x4,%eax
  801a88:	e8 a6 fe ff ff       	call   801933 <fsipc>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	83 ec 10             	sub    $0x10,%esp
  801a97:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801aa5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aab:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab5:	e8 79 fe ff ff       	call   801933 <fsipc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 6a                	js     801b2a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ac0:	39 c6                	cmp    %eax,%esi
  801ac2:	73 24                	jae    801ae8 <devfile_read+0x59>
  801ac4:	c7 44 24 0c bc 2f 80 	movl   $0x802fbc,0xc(%esp)
  801acb:	00 
  801acc:	c7 44 24 08 c3 2f 80 	movl   $0x802fc3,0x8(%esp)
  801ad3:	00 
  801ad4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801adb:	00 
  801adc:	c7 04 24 d8 2f 80 00 	movl   $0x802fd8,(%esp)
  801ae3:	e8 a4 e8 ff ff       	call   80038c <_panic>
	assert(r <= PGSIZE);
  801ae8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aed:	7e 24                	jle    801b13 <devfile_read+0x84>
  801aef:	c7 44 24 0c e3 2f 80 	movl   $0x802fe3,0xc(%esp)
  801af6:	00 
  801af7:	c7 44 24 08 c3 2f 80 	movl   $0x802fc3,0x8(%esp)
  801afe:	00 
  801aff:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b06:	00 
  801b07:	c7 04 24 d8 2f 80 00 	movl   $0x802fd8,(%esp)
  801b0e:	e8 79 e8 ff ff       	call   80038c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b17:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b1e:	00 
  801b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b22:	89 04 24             	mov    %eax,(%esp)
  801b25:	e8 1a f1 ff ff       	call   800c44 <memmove>
	return r;
}
  801b2a:	89 d8                	mov    %ebx,%eax
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 24             	sub    $0x24,%esp
  801b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b3d:	89 1c 24             	mov    %ebx,(%esp)
  801b40:	e8 2b ef ff ff       	call   800a70 <strlen>
  801b45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b4a:	7f 60                	jg     801bac <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 20 f8 ff ff       	call   801377 <fd_alloc>
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	85 d2                	test   %edx,%edx
  801b5b:	78 54                	js     801bb1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b61:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801b68:	e8 3a ef ff ff       	call   800aa7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b70:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b78:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7d:	e8 b1 fd ff ff       	call   801933 <fsipc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	79 17                	jns    801b9f <open+0x6c>
		fd_close(fd, 0);
  801b88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b8f:	00 
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	89 04 24             	mov    %eax,(%esp)
  801b96:	e8 db f8 ff ff       	call   801476 <fd_close>
		return r;
  801b9b:	89 d8                	mov    %ebx,%eax
  801b9d:	eb 12                	jmp    801bb1 <open+0x7e>
	}

	return fd2num(fd);
  801b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba2:	89 04 24             	mov    %eax,(%esp)
  801ba5:	e8 a6 f7 ff ff       	call   801350 <fd2num>
  801baa:	eb 05                	jmp    801bb1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bac:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb1:	83 c4 24             	add    $0x24,%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc2:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc7:	e8 67 fd ff ff       	call   801933 <fsipc>
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 14             	sub    $0x14,%esp
  801bd5:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801bd7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801bdb:	7e 31                	jle    801c0e <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801bdd:	8b 40 04             	mov    0x4(%eax),%eax
  801be0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be4:	8d 43 10             	lea    0x10(%ebx),%eax
  801be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801beb:	8b 03                	mov    (%ebx),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 42 fb ff ff       	call   801737 <write>
		if (result > 0)
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	7e 03                	jle    801bfc <writebuf+0x2e>
			b->result += result;
  801bf9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801bfc:	39 43 04             	cmp    %eax,0x4(%ebx)
  801bff:	74 0d                	je     801c0e <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801c01:	85 c0                	test   %eax,%eax
  801c03:	ba 00 00 00 00       	mov    $0x0,%edx
  801c08:	0f 4f c2             	cmovg  %edx,%eax
  801c0b:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c0e:	83 c4 14             	add    $0x14,%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <putch>:

static void
putch(int ch, void *thunk)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c1e:	8b 53 04             	mov    0x4(%ebx),%edx
  801c21:	8d 42 01             	lea    0x1(%edx),%eax
  801c24:	89 43 04             	mov    %eax,0x4(%ebx)
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2a:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c2e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c33:	75 0e                	jne    801c43 <putch+0x2f>
		writebuf(b);
  801c35:	89 d8                	mov    %ebx,%eax
  801c37:	e8 92 ff ff ff       	call   801bce <writebuf>
		b->idx = 0;
  801c3c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c43:	83 c4 04             	add    $0x4,%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c5b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c62:	00 00 00 
	b.result = 0;
  801c65:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c6c:	00 00 00 
	b.error = 1;
  801c6f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c76:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c79:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c91:	c7 04 24 14 1c 80 00 	movl   $0x801c14,(%esp)
  801c98:	e8 71 e9 ff ff       	call   80060e <vprintfmt>
	if (b.idx > 0)
  801c9d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ca4:	7e 0b                	jle    801cb1 <vfprintf+0x68>
		writebuf(&b);
  801ca6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cac:	e8 1d ff ff ff       	call   801bce <writebuf>

	return (b.result ? b.result : b.error);
  801cb1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cc8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	89 04 24             	mov    %eax,(%esp)
  801cdc:	e8 68 ff ff ff       	call   801c49 <vfprintf>
	va_end(ap);

	return cnt;
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <printf>:

int
printf(const char *fmt, ...)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ce9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801cec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801cfe:	e8 46 ff ff ff       	call   801c49 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    
  801d05:	66 90                	xchg   %ax,%ax
  801d07:	66 90                	xchg   %ax,%ax
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d16:	c7 44 24 04 ef 2f 80 	movl   $0x802fef,0x4(%esp)
  801d1d:	00 
  801d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 7e ed ff ff       	call   800aa7 <strcpy>
	return 0;
}
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	53                   	push   %ebx
  801d34:	83 ec 14             	sub    $0x14,%esp
  801d37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d3a:	89 1c 24             	mov    %ebx,(%esp)
  801d3d:	e8 2b 0b 00 00       	call   80286d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d42:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d47:	83 f8 01             	cmp    $0x1,%eax
  801d4a:	75 0d                	jne    801d59 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801d4c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d4f:	89 04 24             	mov    %eax,(%esp)
  801d52:	e8 29 03 00 00       	call   802080 <nsipc_close>
  801d57:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801d59:	89 d0                	mov    %edx,%eax
  801d5b:	83 c4 14             	add    $0x14,%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d6e:	00 
  801d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d72:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	8b 40 0c             	mov    0xc(%eax),%eax
  801d83:	89 04 24             	mov    %eax,(%esp)
  801d86:	e8 f0 03 00 00       	call   80217b <nsipc_send>
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d9a:	00 
  801d9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	8b 40 0c             	mov    0xc(%eax),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 44 03 00 00       	call   8020fb <nsipc_recv>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dbf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dc2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 f8 f5 ff ff       	call   8013c6 <fd_lookup>
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 17                	js     801de9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801ddb:	39 08                	cmp    %ecx,(%eax)
  801ddd:	75 05                	jne    801de4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ddf:	8b 40 0c             	mov    0xc(%eax),%eax
  801de2:	eb 05                	jmp    801de9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801de4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	83 ec 20             	sub    $0x20,%esp
  801df3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801df5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 77 f5 ff ff       	call   801377 <fd_alloc>
  801e00:	89 c3                	mov    %eax,%ebx
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 21                	js     801e27 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0d:	00 
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1c:	e8 a2 f0 ff ff       	call   800ec3 <sys_page_alloc>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	85 c0                	test   %eax,%eax
  801e25:	79 0c                	jns    801e33 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801e27:	89 34 24             	mov    %esi,(%esp)
  801e2a:	e8 51 02 00 00       	call   802080 <nsipc_close>
		return r;
  801e2f:	89 d8                	mov    %ebx,%eax
  801e31:	eb 20                	jmp    801e53 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e33:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e41:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801e48:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801e4b:	89 14 24             	mov    %edx,(%esp)
  801e4e:	e8 fd f4 ff ff       	call   801350 <fd2num>
}
  801e53:	83 c4 20             	add    $0x20,%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	e8 51 ff ff ff       	call   801db9 <fd2sockid>
		return r;
  801e68:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 23                	js     801e91 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e6e:	8b 55 10             	mov    0x10(%ebp),%edx
  801e71:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e78:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 45 01 00 00       	call   801fc9 <nsipc_accept>
		return r;
  801e84:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 07                	js     801e91 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801e8a:	e8 5c ff ff ff       	call   801deb <alloc_sockfd>
  801e8f:	89 c1                	mov    %eax,%ecx
}
  801e91:	89 c8                	mov    %ecx,%eax
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	e8 16 ff ff ff       	call   801db9 <fd2sockid>
  801ea3:	89 c2                	mov    %eax,%edx
  801ea5:	85 d2                	test   %edx,%edx
  801ea7:	78 16                	js     801ebf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801ea9:	8b 45 10             	mov    0x10(%ebp),%eax
  801eac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	89 14 24             	mov    %edx,(%esp)
  801eba:	e8 60 01 00 00       	call   80201f <nsipc_bind>
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <shutdown>:

int
shutdown(int s, int how)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	e8 ea fe ff ff       	call   801db9 <fd2sockid>
  801ecf:	89 c2                	mov    %eax,%edx
  801ed1:	85 d2                	test   %edx,%edx
  801ed3:	78 0f                	js     801ee4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edc:	89 14 24             	mov    %edx,(%esp)
  801edf:	e8 7a 01 00 00       	call   80205e <nsipc_shutdown>
}
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	e8 c5 fe ff ff       	call   801db9 <fd2sockid>
  801ef4:	89 c2                	mov    %eax,%edx
  801ef6:	85 d2                	test   %edx,%edx
  801ef8:	78 16                	js     801f10 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801efa:	8b 45 10             	mov    0x10(%ebp),%eax
  801efd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f08:	89 14 24             	mov    %edx,(%esp)
  801f0b:	e8 8a 01 00 00       	call   80209a <nsipc_connect>
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <listen>:

int
listen(int s, int backlog)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	e8 99 fe ff ff       	call   801db9 <fd2sockid>
  801f20:	89 c2                	mov    %eax,%edx
  801f22:	85 d2                	test   %edx,%edx
  801f24:	78 0f                	js     801f35 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2d:	89 14 24             	mov    %edx,(%esp)
  801f30:	e8 a4 01 00 00       	call   8020d9 <nsipc_listen>
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	89 04 24             	mov    %eax,(%esp)
  801f51:	e8 98 02 00 00       	call   8021ee <nsipc_socket>
  801f56:	89 c2                	mov    %eax,%edx
  801f58:	85 d2                	test   %edx,%edx
  801f5a:	78 05                	js     801f61 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801f5c:	e8 8a fe ff ff       	call   801deb <alloc_sockfd>
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	53                   	push   %ebx
  801f67:	83 ec 14             	sub    $0x14,%esp
  801f6a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f6c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f73:	75 11                	jne    801f86 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f7c:	e8 b4 08 00 00       	call   802835 <ipc_find_env>
  801f81:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f86:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f8d:	00 
  801f8e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801f95:	00 
  801f96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f9a:	a1 04 50 80 00       	mov    0x805004,%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 23 08 00 00       	call   8027ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fa7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fae:	00 
  801faf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fb6:	00 
  801fb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbe:	e8 8d 07 00 00       	call   802750 <ipc_recv>
}
  801fc3:	83 c4 14             	add    $0x14,%esp
  801fc6:	5b                   	pop    %ebx
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 10             	sub    $0x10,%esp
  801fd1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fdc:	8b 06                	mov    (%esi),%eax
  801fde:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe8:	e8 76 ff ff ff       	call   801f63 <nsipc>
  801fed:	89 c3                	mov    %eax,%ebx
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 23                	js     802016 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ff3:	a1 10 70 80 00       	mov    0x807010,%eax
  801ff8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ffc:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802003:	00 
  802004:	8b 45 0c             	mov    0xc(%ebp),%eax
  802007:	89 04 24             	mov    %eax,(%esp)
  80200a:	e8 35 ec ff ff       	call   800c44 <memmove>
		*addrlen = ret->ret_addrlen;
  80200f:	a1 10 70 80 00       	mov    0x807010,%eax
  802014:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802016:	89 d8                	mov    %ebx,%eax
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	5b                   	pop    %ebx
  80201c:	5e                   	pop    %esi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	53                   	push   %ebx
  802023:	83 ec 14             	sub    $0x14,%esp
  802026:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802031:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802035:	8b 45 0c             	mov    0xc(%ebp),%eax
  802038:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802043:	e8 fc eb ff ff       	call   800c44 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802048:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80204e:	b8 02 00 00 00       	mov    $0x2,%eax
  802053:	e8 0b ff ff ff       	call   801f63 <nsipc>
}
  802058:	83 c4 14             	add    $0x14,%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802064:	8b 45 08             	mov    0x8(%ebp),%eax
  802067:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80206c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802074:	b8 03 00 00 00       	mov    $0x3,%eax
  802079:	e8 e5 fe ff ff       	call   801f63 <nsipc>
}
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    

00802080 <nsipc_close>:

int
nsipc_close(int s)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802086:	8b 45 08             	mov    0x8(%ebp),%eax
  802089:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80208e:	b8 04 00 00 00       	mov    $0x4,%eax
  802093:	e8 cb fe ff ff       	call   801f63 <nsipc>
}
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	53                   	push   %ebx
  80209e:	83 ec 14             	sub    $0x14,%esp
  8020a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020be:	e8 81 eb ff ff       	call   800c44 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020c3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020ce:	e8 90 fe ff ff       	call   801f63 <nsipc>
}
  8020d3:	83 c4 14             	add    $0x14,%esp
  8020d6:	5b                   	pop    %ebx
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    

008020d9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ea:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8020f4:	e8 6a fe ff ff       	call   801f63 <nsipc>
}
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    

008020fb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	83 ec 10             	sub    $0x10,%esp
  802103:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802106:	8b 45 08             	mov    0x8(%ebp),%eax
  802109:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80210e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802114:	8b 45 14             	mov    0x14(%ebp),%eax
  802117:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80211c:	b8 07 00 00 00       	mov    $0x7,%eax
  802121:	e8 3d fe ff ff       	call   801f63 <nsipc>
  802126:	89 c3                	mov    %eax,%ebx
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 46                	js     802172 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80212c:	39 f0                	cmp    %esi,%eax
  80212e:	7f 07                	jg     802137 <nsipc_recv+0x3c>
  802130:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802135:	7e 24                	jle    80215b <nsipc_recv+0x60>
  802137:	c7 44 24 0c fb 2f 80 	movl   $0x802ffb,0xc(%esp)
  80213e:	00 
  80213f:	c7 44 24 08 c3 2f 80 	movl   $0x802fc3,0x8(%esp)
  802146:	00 
  802147:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80214e:	00 
  80214f:	c7 04 24 10 30 80 00 	movl   $0x803010,(%esp)
  802156:	e8 31 e2 ff ff       	call   80038c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80215b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802166:	00 
  802167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216a:	89 04 24             	mov    %eax,(%esp)
  80216d:	e8 d2 ea ff ff       	call   800c44 <memmove>
	}

	return r;
}
  802172:	89 d8                	mov    %ebx,%eax
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	53                   	push   %ebx
  80217f:	83 ec 14             	sub    $0x14,%esp
  802182:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802185:	8b 45 08             	mov    0x8(%ebp),%eax
  802188:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80218d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802193:	7e 24                	jle    8021b9 <nsipc_send+0x3e>
  802195:	c7 44 24 0c 1c 30 80 	movl   $0x80301c,0xc(%esp)
  80219c:	00 
  80219d:	c7 44 24 08 c3 2f 80 	movl   $0x802fc3,0x8(%esp)
  8021a4:	00 
  8021a5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021ac:	00 
  8021ad:	c7 04 24 10 30 80 00 	movl   $0x803010,(%esp)
  8021b4:	e8 d3 e1 ff ff       	call   80038c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8021cb:	e8 74 ea ff ff       	call   800c44 <memmove>
	nsipcbuf.send.req_size = size;
  8021d0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8021d9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021de:	b8 08 00 00 00       	mov    $0x8,%eax
  8021e3:	e8 7b fd ff ff       	call   801f63 <nsipc>
}
  8021e8:	83 c4 14             	add    $0x14,%esp
  8021eb:	5b                   	pop    %ebx
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    

008021ee <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ff:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802204:	8b 45 10             	mov    0x10(%ebp),%eax
  802207:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80220c:	b8 09 00 00 00       	mov    $0x9,%eax
  802211:	e8 4d fd ff ff       	call   801f63 <nsipc>
}
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	56                   	push   %esi
  80221c:	53                   	push   %ebx
  80221d:	83 ec 10             	sub    $0x10,%esp
  802220:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802223:	8b 45 08             	mov    0x8(%ebp),%eax
  802226:	89 04 24             	mov    %eax,(%esp)
  802229:	e8 32 f1 ff ff       	call   801360 <fd2data>
  80222e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802230:	c7 44 24 04 28 30 80 	movl   $0x803028,0x4(%esp)
  802237:	00 
  802238:	89 1c 24             	mov    %ebx,(%esp)
  80223b:	e8 67 e8 ff ff       	call   800aa7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802240:	8b 46 04             	mov    0x4(%esi),%eax
  802243:	2b 06                	sub    (%esi),%eax
  802245:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80224b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802252:	00 00 00 
	stat->st_dev = &devpipe;
  802255:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80225c:	40 80 00 
	return 0;
}
  80225f:	b8 00 00 00 00       	mov    $0x0,%eax
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    

0080226b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	53                   	push   %ebx
  80226f:	83 ec 14             	sub    $0x14,%esp
  802272:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802280:	e8 e5 ec ff ff       	call   800f6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802285:	89 1c 24             	mov    %ebx,(%esp)
  802288:	e8 d3 f0 ff ff       	call   801360 <fd2data>
  80228d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802298:	e8 cd ec ff ff       	call   800f6a <sys_page_unmap>
}
  80229d:	83 c4 14             	add    $0x14,%esp
  8022a0:	5b                   	pop    %ebx
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    

008022a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	57                   	push   %edi
  8022a7:	56                   	push   %esi
  8022a8:	53                   	push   %ebx
  8022a9:	83 ec 2c             	sub    $0x2c,%esp
  8022ac:	89 c6                	mov    %eax,%esi
  8022ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022b1:	a1 20 54 80 00       	mov    0x805420,%eax
  8022b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022b9:	89 34 24             	mov    %esi,(%esp)
  8022bc:	e8 ac 05 00 00       	call   80286d <pageref>
  8022c1:	89 c7                	mov    %eax,%edi
  8022c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022c6:	89 04 24             	mov    %eax,(%esp)
  8022c9:	e8 9f 05 00 00       	call   80286d <pageref>
  8022ce:	39 c7                	cmp    %eax,%edi
  8022d0:	0f 94 c2             	sete   %dl
  8022d3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8022d6:	8b 0d 20 54 80 00    	mov    0x805420,%ecx
  8022dc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8022df:	39 fb                	cmp    %edi,%ebx
  8022e1:	74 21                	je     802304 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e3:	84 d2                	test   %dl,%dl
  8022e5:	74 ca                	je     8022b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022e7:	8b 51 58             	mov    0x58(%ecx),%edx
  8022ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ee:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022f6:	c7 04 24 2f 30 80 00 	movl   $0x80302f,(%esp)
  8022fd:	e8 83 e1 ff ff       	call   800485 <cprintf>
  802302:	eb ad                	jmp    8022b1 <_pipeisclosed+0xe>
	}
}
  802304:	83 c4 2c             	add    $0x2c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    

0080230c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	57                   	push   %edi
  802310:	56                   	push   %esi
  802311:	53                   	push   %ebx
  802312:	83 ec 1c             	sub    $0x1c,%esp
  802315:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802318:	89 34 24             	mov    %esi,(%esp)
  80231b:	e8 40 f0 ff ff       	call   801360 <fd2data>
  802320:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802322:	bf 00 00 00 00       	mov    $0x0,%edi
  802327:	eb 45                	jmp    80236e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802329:	89 da                	mov    %ebx,%edx
  80232b:	89 f0                	mov    %esi,%eax
  80232d:	e8 71 ff ff ff       	call   8022a3 <_pipeisclosed>
  802332:	85 c0                	test   %eax,%eax
  802334:	75 41                	jne    802377 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802336:	e8 69 eb ff ff       	call   800ea4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80233b:	8b 43 04             	mov    0x4(%ebx),%eax
  80233e:	8b 0b                	mov    (%ebx),%ecx
  802340:	8d 51 20             	lea    0x20(%ecx),%edx
  802343:	39 d0                	cmp    %edx,%eax
  802345:	73 e2                	jae    802329 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80234a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80234e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802351:	99                   	cltd   
  802352:	c1 ea 1b             	shr    $0x1b,%edx
  802355:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802358:	83 e1 1f             	and    $0x1f,%ecx
  80235b:	29 d1                	sub    %edx,%ecx
  80235d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802361:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802365:	83 c0 01             	add    $0x1,%eax
  802368:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236b:	83 c7 01             	add    $0x1,%edi
  80236e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802371:	75 c8                	jne    80233b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802373:	89 f8                	mov    %edi,%eax
  802375:	eb 05                	jmp    80237c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802377:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    

00802384 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	57                   	push   %edi
  802388:	56                   	push   %esi
  802389:	53                   	push   %ebx
  80238a:	83 ec 1c             	sub    $0x1c,%esp
  80238d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802390:	89 3c 24             	mov    %edi,(%esp)
  802393:	e8 c8 ef ff ff       	call   801360 <fd2data>
  802398:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80239a:	be 00 00 00 00       	mov    $0x0,%esi
  80239f:	eb 3d                	jmp    8023de <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023a1:	85 f6                	test   %esi,%esi
  8023a3:	74 04                	je     8023a9 <devpipe_read+0x25>
				return i;
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	eb 43                	jmp    8023ec <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023a9:	89 da                	mov    %ebx,%edx
  8023ab:	89 f8                	mov    %edi,%eax
  8023ad:	e8 f1 fe ff ff       	call   8022a3 <_pipeisclosed>
  8023b2:	85 c0                	test   %eax,%eax
  8023b4:	75 31                	jne    8023e7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023b6:	e8 e9 ea ff ff       	call   800ea4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023bb:	8b 03                	mov    (%ebx),%eax
  8023bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023c0:	74 df                	je     8023a1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023c2:	99                   	cltd   
  8023c3:	c1 ea 1b             	shr    $0x1b,%edx
  8023c6:	01 d0                	add    %edx,%eax
  8023c8:	83 e0 1f             	and    $0x1f,%eax
  8023cb:	29 d0                	sub    %edx,%eax
  8023cd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8023d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023d5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023d8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023db:	83 c6 01             	add    $0x1,%esi
  8023de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023e1:	75 d8                	jne    8023bb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023e3:	89 f0                	mov    %esi,%eax
  8023e5:	eb 05                	jmp    8023ec <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023ec:	83 c4 1c             	add    $0x1c,%esp
  8023ef:	5b                   	pop    %ebx
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    

008023f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	56                   	push   %esi
  8023f8:	53                   	push   %ebx
  8023f9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ff:	89 04 24             	mov    %eax,(%esp)
  802402:	e8 70 ef ff ff       	call   801377 <fd_alloc>
  802407:	89 c2                	mov    %eax,%edx
  802409:	85 d2                	test   %edx,%edx
  80240b:	0f 88 4d 01 00 00    	js     80255e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802411:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802418:	00 
  802419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802420:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802427:	e8 97 ea ff ff       	call   800ec3 <sys_page_alloc>
  80242c:	89 c2                	mov    %eax,%edx
  80242e:	85 d2                	test   %edx,%edx
  802430:	0f 88 28 01 00 00    	js     80255e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802439:	89 04 24             	mov    %eax,(%esp)
  80243c:	e8 36 ef ff ff       	call   801377 <fd_alloc>
  802441:	89 c3                	mov    %eax,%ebx
  802443:	85 c0                	test   %eax,%eax
  802445:	0f 88 fe 00 00 00    	js     802549 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802452:	00 
  802453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802461:	e8 5d ea ff ff       	call   800ec3 <sys_page_alloc>
  802466:	89 c3                	mov    %eax,%ebx
  802468:	85 c0                	test   %eax,%eax
  80246a:	0f 88 d9 00 00 00    	js     802549 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802470:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802473:	89 04 24             	mov    %eax,(%esp)
  802476:	e8 e5 ee ff ff       	call   801360 <fd2data>
  80247b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80247d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802484:	00 
  802485:	89 44 24 04          	mov    %eax,0x4(%esp)
  802489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802490:	e8 2e ea ff ff       	call   800ec3 <sys_page_alloc>
  802495:	89 c3                	mov    %eax,%ebx
  802497:	85 c0                	test   %eax,%eax
  802499:	0f 88 97 00 00 00    	js     802536 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a2:	89 04 24             	mov    %eax,(%esp)
  8024a5:	e8 b6 ee ff ff       	call   801360 <fd2data>
  8024aa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024b1:	00 
  8024b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024bd:	00 
  8024be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c9:	e8 49 ea ff ff       	call   800f17 <sys_page_map>
  8024ce:	89 c3                	mov    %eax,%ebx
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	78 52                	js     802526 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024d4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024e9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802501:	89 04 24             	mov    %eax,(%esp)
  802504:	e8 47 ee ff ff       	call   801350 <fd2num>
  802509:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80250e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802511:	89 04 24             	mov    %eax,(%esp)
  802514:	e8 37 ee ff ff       	call   801350 <fd2num>
  802519:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80251c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80251f:	b8 00 00 00 00       	mov    $0x0,%eax
  802524:	eb 38                	jmp    80255e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80252a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802531:	e8 34 ea ff ff       	call   800f6a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80253d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802544:	e8 21 ea ff ff       	call   800f6a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802550:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802557:	e8 0e ea ff ff       	call   800f6a <sys_page_unmap>
  80255c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80255e:	83 c4 30             	add    $0x30,%esp
  802561:	5b                   	pop    %ebx
  802562:	5e                   	pop    %esi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    

00802565 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80256b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80256e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802572:	8b 45 08             	mov    0x8(%ebp),%eax
  802575:	89 04 24             	mov    %eax,(%esp)
  802578:	e8 49 ee ff ff       	call   8013c6 <fd_lookup>
  80257d:	89 c2                	mov    %eax,%edx
  80257f:	85 d2                	test   %edx,%edx
  802581:	78 15                	js     802598 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802586:	89 04 24             	mov    %eax,(%esp)
  802589:	e8 d2 ed ff ff       	call   801360 <fd2data>
	return _pipeisclosed(fd, p);
  80258e:	89 c2                	mov    %eax,%edx
  802590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802593:	e8 0b fd ff ff       	call   8022a3 <_pipeisclosed>
}
  802598:	c9                   	leave  
  802599:	c3                   	ret    
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a8:	5d                   	pop    %ebp
  8025a9:	c3                   	ret    

008025aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025b0:	c7 44 24 04 47 30 80 	movl   $0x803047,0x4(%esp)
  8025b7:	00 
  8025b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bb:	89 04 24             	mov    %eax,(%esp)
  8025be:	e8 e4 e4 ff ff       	call   800aa7 <strcpy>
	return 0;
}
  8025c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025c8:	c9                   	leave  
  8025c9:	c3                   	ret    

008025ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025ca:	55                   	push   %ebp
  8025cb:	89 e5                	mov    %esp,%ebp
  8025cd:	57                   	push   %edi
  8025ce:	56                   	push   %esi
  8025cf:	53                   	push   %ebx
  8025d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025e1:	eb 31                	jmp    802614 <devcons_write+0x4a>
		m = n - tot;
  8025e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8025e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025e8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025f0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025f7:	03 45 0c             	add    0xc(%ebp),%eax
  8025fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025fe:	89 3c 24             	mov    %edi,(%esp)
  802601:	e8 3e e6 ff ff       	call   800c44 <memmove>
		sys_cputs(buf, m);
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	89 3c 24             	mov    %edi,(%esp)
  80260d:	e8 e4 e7 ff ff       	call   800df6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802612:	01 f3                	add    %esi,%ebx
  802614:	89 d8                	mov    %ebx,%eax
  802616:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802619:	72 c8                	jb     8025e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80261b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802621:	5b                   	pop    %ebx
  802622:	5e                   	pop    %esi
  802623:	5f                   	pop    %edi
  802624:	5d                   	pop    %ebp
  802625:	c3                   	ret    

00802626 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80262c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802631:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802635:	75 07                	jne    80263e <devcons_read+0x18>
  802637:	eb 2a                	jmp    802663 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802639:	e8 66 e8 ff ff       	call   800ea4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80263e:	66 90                	xchg   %ax,%ax
  802640:	e8 cf e7 ff ff       	call   800e14 <sys_cgetc>
  802645:	85 c0                	test   %eax,%eax
  802647:	74 f0                	je     802639 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802649:	85 c0                	test   %eax,%eax
  80264b:	78 16                	js     802663 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80264d:	83 f8 04             	cmp    $0x4,%eax
  802650:	74 0c                	je     80265e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802652:	8b 55 0c             	mov    0xc(%ebp),%edx
  802655:	88 02                	mov    %al,(%edx)
	return 1;
  802657:	b8 01 00 00 00       	mov    $0x1,%eax
  80265c:	eb 05                	jmp    802663 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80265e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802663:	c9                   	leave  
  802664:	c3                   	ret    

00802665 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802671:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802678:	00 
  802679:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80267c:	89 04 24             	mov    %eax,(%esp)
  80267f:	e8 72 e7 ff ff       	call   800df6 <sys_cputs>
}
  802684:	c9                   	leave  
  802685:	c3                   	ret    

00802686 <getchar>:

int
getchar(void)
{
  802686:	55                   	push   %ebp
  802687:	89 e5                	mov    %esp,%ebp
  802689:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80268c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802693:	00 
  802694:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80269b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026a2:	e8 b3 ef ff ff       	call   80165a <read>
	if (r < 0)
  8026a7:	85 c0                	test   %eax,%eax
  8026a9:	78 0f                	js     8026ba <getchar+0x34>
		return r;
	if (r < 1)
  8026ab:	85 c0                	test   %eax,%eax
  8026ad:	7e 06                	jle    8026b5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8026af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026b3:	eb 05                	jmp    8026ba <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026ba:	c9                   	leave  
  8026bb:	c3                   	ret    

008026bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026bc:	55                   	push   %ebp
  8026bd:	89 e5                	mov    %esp,%ebp
  8026bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cc:	89 04 24             	mov    %eax,(%esp)
  8026cf:	e8 f2 ec ff ff       	call   8013c6 <fd_lookup>
  8026d4:	85 c0                	test   %eax,%eax
  8026d6:	78 11                	js     8026e9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026db:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026e1:	39 10                	cmp    %edx,(%eax)
  8026e3:	0f 94 c0             	sete   %al
  8026e6:	0f b6 c0             	movzbl %al,%eax
}
  8026e9:	c9                   	leave  
  8026ea:	c3                   	ret    

008026eb <opencons>:

int
opencons(void)
{
  8026eb:	55                   	push   %ebp
  8026ec:	89 e5                	mov    %esp,%ebp
  8026ee:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026f4:	89 04 24             	mov    %eax,(%esp)
  8026f7:	e8 7b ec ff ff       	call   801377 <fd_alloc>
		return r;
  8026fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026fe:	85 c0                	test   %eax,%eax
  802700:	78 40                	js     802742 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802702:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802709:	00 
  80270a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802711:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802718:	e8 a6 e7 ff ff       	call   800ec3 <sys_page_alloc>
		return r;
  80271d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80271f:	85 c0                	test   %eax,%eax
  802721:	78 1f                	js     802742 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802723:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80272c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802731:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802738:	89 04 24             	mov    %eax,(%esp)
  80273b:	e8 10 ec ff ff       	call   801350 <fd2num>
  802740:	89 c2                	mov    %eax,%edx
}
  802742:	89 d0                	mov    %edx,%eax
  802744:	c9                   	leave  
  802745:	c3                   	ret    
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
  802753:	56                   	push   %esi
  802754:	53                   	push   %ebx
  802755:	83 ec 10             	sub    $0x10,%esp
  802758:	8b 75 08             	mov    0x8(%ebp),%esi
  80275b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802761:	85 c0                	test   %eax,%eax
  802763:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802768:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80276b:	89 04 24             	mov    %eax,(%esp)
  80276e:	e8 66 e9 ff ff       	call   8010d9 <sys_ipc_recv>

	if(ret < 0) {
  802773:	85 c0                	test   %eax,%eax
  802775:	79 16                	jns    80278d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802777:	85 f6                	test   %esi,%esi
  802779:	74 06                	je     802781 <ipc_recv+0x31>
  80277b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802781:	85 db                	test   %ebx,%ebx
  802783:	74 3e                	je     8027c3 <ipc_recv+0x73>
  802785:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80278b:	eb 36                	jmp    8027c3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80278d:	e8 f3 e6 ff ff       	call   800e85 <sys_getenvid>
  802792:	25 ff 03 00 00       	and    $0x3ff,%eax
  802797:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80279a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80279f:	a3 20 54 80 00       	mov    %eax,0x805420

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8027a4:	85 f6                	test   %esi,%esi
  8027a6:	74 05                	je     8027ad <ipc_recv+0x5d>
  8027a8:	8b 40 74             	mov    0x74(%eax),%eax
  8027ab:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8027ad:	85 db                	test   %ebx,%ebx
  8027af:	74 0a                	je     8027bb <ipc_recv+0x6b>
  8027b1:	a1 20 54 80 00       	mov    0x805420,%eax
  8027b6:	8b 40 78             	mov    0x78(%eax),%eax
  8027b9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8027bb:	a1 20 54 80 00       	mov    0x805420,%eax
  8027c0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027c3:	83 c4 10             	add    $0x10,%esp
  8027c6:	5b                   	pop    %ebx
  8027c7:	5e                   	pop    %esi
  8027c8:	5d                   	pop    %ebp
  8027c9:	c3                   	ret    

008027ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027ca:	55                   	push   %ebp
  8027cb:	89 e5                	mov    %esp,%ebp
  8027cd:	57                   	push   %edi
  8027ce:	56                   	push   %esi
  8027cf:	53                   	push   %ebx
  8027d0:	83 ec 1c             	sub    $0x1c,%esp
  8027d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8027dc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8027de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8027e3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8027e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8027e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027f5:	89 3c 24             	mov    %edi,(%esp)
  8027f8:	e8 b9 e8 ff ff       	call   8010b6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8027fd:	85 c0                	test   %eax,%eax
  8027ff:	79 2c                	jns    80282d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802801:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802804:	74 20                	je     802826 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80280a:	c7 44 24 08 54 30 80 	movl   $0x803054,0x8(%esp)
  802811:	00 
  802812:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802819:	00 
  80281a:	c7 04 24 84 30 80 00 	movl   $0x803084,(%esp)
  802821:	e8 66 db ff ff       	call   80038c <_panic>
		}
		sys_yield();
  802826:	e8 79 e6 ff ff       	call   800ea4 <sys_yield>
	}
  80282b:	eb b9                	jmp    8027e6 <ipc_send+0x1c>
}
  80282d:	83 c4 1c             	add    $0x1c,%esp
  802830:	5b                   	pop    %ebx
  802831:	5e                   	pop    %esi
  802832:	5f                   	pop    %edi
  802833:	5d                   	pop    %ebp
  802834:	c3                   	ret    

00802835 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802835:	55                   	push   %ebp
  802836:	89 e5                	mov    %esp,%ebp
  802838:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80283b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802840:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802843:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802849:	8b 52 50             	mov    0x50(%edx),%edx
  80284c:	39 ca                	cmp    %ecx,%edx
  80284e:	75 0d                	jne    80285d <ipc_find_env+0x28>
			return envs[i].env_id;
  802850:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802853:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802858:	8b 40 40             	mov    0x40(%eax),%eax
  80285b:	eb 0e                	jmp    80286b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80285d:	83 c0 01             	add    $0x1,%eax
  802860:	3d 00 04 00 00       	cmp    $0x400,%eax
  802865:	75 d9                	jne    802840 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802867:	66 b8 00 00          	mov    $0x0,%ax
}
  80286b:	5d                   	pop    %ebp
  80286c:	c3                   	ret    

0080286d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80286d:	55                   	push   %ebp
  80286e:	89 e5                	mov    %esp,%ebp
  802870:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802873:	89 d0                	mov    %edx,%eax
  802875:	c1 e8 16             	shr    $0x16,%eax
  802878:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80287f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802884:	f6 c1 01             	test   $0x1,%cl
  802887:	74 1d                	je     8028a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802889:	c1 ea 0c             	shr    $0xc,%edx
  80288c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802893:	f6 c2 01             	test   $0x1,%dl
  802896:	74 0e                	je     8028a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802898:	c1 ea 0c             	shr    $0xc,%edx
  80289b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028a2:	ef 
  8028a3:	0f b7 c0             	movzwl %ax,%eax
}
  8028a6:	5d                   	pop    %ebp
  8028a7:	c3                   	ret    
  8028a8:	66 90                	xchg   %ax,%ax
  8028aa:	66 90                	xchg   %ax,%ax
  8028ac:	66 90                	xchg   %ax,%ax
  8028ae:	66 90                	xchg   %ax,%ax

008028b0 <__udivdi3>:
  8028b0:	55                   	push   %ebp
  8028b1:	57                   	push   %edi
  8028b2:	56                   	push   %esi
  8028b3:	83 ec 0c             	sub    $0xc,%esp
  8028b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8028ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8028be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8028c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8028c6:	85 c0                	test   %eax,%eax
  8028c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028cc:	89 ea                	mov    %ebp,%edx
  8028ce:	89 0c 24             	mov    %ecx,(%esp)
  8028d1:	75 2d                	jne    802900 <__udivdi3+0x50>
  8028d3:	39 e9                	cmp    %ebp,%ecx
  8028d5:	77 61                	ja     802938 <__udivdi3+0x88>
  8028d7:	85 c9                	test   %ecx,%ecx
  8028d9:	89 ce                	mov    %ecx,%esi
  8028db:	75 0b                	jne    8028e8 <__udivdi3+0x38>
  8028dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8028e2:	31 d2                	xor    %edx,%edx
  8028e4:	f7 f1                	div    %ecx
  8028e6:	89 c6                	mov    %eax,%esi
  8028e8:	31 d2                	xor    %edx,%edx
  8028ea:	89 e8                	mov    %ebp,%eax
  8028ec:	f7 f6                	div    %esi
  8028ee:	89 c5                	mov    %eax,%ebp
  8028f0:	89 f8                	mov    %edi,%eax
  8028f2:	f7 f6                	div    %esi
  8028f4:	89 ea                	mov    %ebp,%edx
  8028f6:	83 c4 0c             	add    $0xc,%esp
  8028f9:	5e                   	pop    %esi
  8028fa:	5f                   	pop    %edi
  8028fb:	5d                   	pop    %ebp
  8028fc:	c3                   	ret    
  8028fd:	8d 76 00             	lea    0x0(%esi),%esi
  802900:	39 e8                	cmp    %ebp,%eax
  802902:	77 24                	ja     802928 <__udivdi3+0x78>
  802904:	0f bd e8             	bsr    %eax,%ebp
  802907:	83 f5 1f             	xor    $0x1f,%ebp
  80290a:	75 3c                	jne    802948 <__udivdi3+0x98>
  80290c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802910:	39 34 24             	cmp    %esi,(%esp)
  802913:	0f 86 9f 00 00 00    	jbe    8029b8 <__udivdi3+0x108>
  802919:	39 d0                	cmp    %edx,%eax
  80291b:	0f 82 97 00 00 00    	jb     8029b8 <__udivdi3+0x108>
  802921:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802928:	31 d2                	xor    %edx,%edx
  80292a:	31 c0                	xor    %eax,%eax
  80292c:	83 c4 0c             	add    $0xc,%esp
  80292f:	5e                   	pop    %esi
  802930:	5f                   	pop    %edi
  802931:	5d                   	pop    %ebp
  802932:	c3                   	ret    
  802933:	90                   	nop
  802934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802938:	89 f8                	mov    %edi,%eax
  80293a:	f7 f1                	div    %ecx
  80293c:	31 d2                	xor    %edx,%edx
  80293e:	83 c4 0c             	add    $0xc,%esp
  802941:	5e                   	pop    %esi
  802942:	5f                   	pop    %edi
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    
  802945:	8d 76 00             	lea    0x0(%esi),%esi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	8b 3c 24             	mov    (%esp),%edi
  80294d:	d3 e0                	shl    %cl,%eax
  80294f:	89 c6                	mov    %eax,%esi
  802951:	b8 20 00 00 00       	mov    $0x20,%eax
  802956:	29 e8                	sub    %ebp,%eax
  802958:	89 c1                	mov    %eax,%ecx
  80295a:	d3 ef                	shr    %cl,%edi
  80295c:	89 e9                	mov    %ebp,%ecx
  80295e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802962:	8b 3c 24             	mov    (%esp),%edi
  802965:	09 74 24 08          	or     %esi,0x8(%esp)
  802969:	89 d6                	mov    %edx,%esi
  80296b:	d3 e7                	shl    %cl,%edi
  80296d:	89 c1                	mov    %eax,%ecx
  80296f:	89 3c 24             	mov    %edi,(%esp)
  802972:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802976:	d3 ee                	shr    %cl,%esi
  802978:	89 e9                	mov    %ebp,%ecx
  80297a:	d3 e2                	shl    %cl,%edx
  80297c:	89 c1                	mov    %eax,%ecx
  80297e:	d3 ef                	shr    %cl,%edi
  802980:	09 d7                	or     %edx,%edi
  802982:	89 f2                	mov    %esi,%edx
  802984:	89 f8                	mov    %edi,%eax
  802986:	f7 74 24 08          	divl   0x8(%esp)
  80298a:	89 d6                	mov    %edx,%esi
  80298c:	89 c7                	mov    %eax,%edi
  80298e:	f7 24 24             	mull   (%esp)
  802991:	39 d6                	cmp    %edx,%esi
  802993:	89 14 24             	mov    %edx,(%esp)
  802996:	72 30                	jb     8029c8 <__udivdi3+0x118>
  802998:	8b 54 24 04          	mov    0x4(%esp),%edx
  80299c:	89 e9                	mov    %ebp,%ecx
  80299e:	d3 e2                	shl    %cl,%edx
  8029a0:	39 c2                	cmp    %eax,%edx
  8029a2:	73 05                	jae    8029a9 <__udivdi3+0xf9>
  8029a4:	3b 34 24             	cmp    (%esp),%esi
  8029a7:	74 1f                	je     8029c8 <__udivdi3+0x118>
  8029a9:	89 f8                	mov    %edi,%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	e9 7a ff ff ff       	jmp    80292c <__udivdi3+0x7c>
  8029b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029b8:	31 d2                	xor    %edx,%edx
  8029ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8029bf:	e9 68 ff ff ff       	jmp    80292c <__udivdi3+0x7c>
  8029c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8029cb:	31 d2                	xor    %edx,%edx
  8029cd:	83 c4 0c             	add    $0xc,%esp
  8029d0:	5e                   	pop    %esi
  8029d1:	5f                   	pop    %edi
  8029d2:	5d                   	pop    %ebp
  8029d3:	c3                   	ret    
  8029d4:	66 90                	xchg   %ax,%ax
  8029d6:	66 90                	xchg   %ax,%ax
  8029d8:	66 90                	xchg   %ax,%ax
  8029da:	66 90                	xchg   %ax,%ax
  8029dc:	66 90                	xchg   %ax,%ax
  8029de:	66 90                	xchg   %ax,%ax

008029e0 <__umoddi3>:
  8029e0:	55                   	push   %ebp
  8029e1:	57                   	push   %edi
  8029e2:	56                   	push   %esi
  8029e3:	83 ec 14             	sub    $0x14,%esp
  8029e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8029f2:	89 c7                	mov    %eax,%edi
  8029f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8029fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802a00:	89 34 24             	mov    %esi,(%esp)
  802a03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a07:	85 c0                	test   %eax,%eax
  802a09:	89 c2                	mov    %eax,%edx
  802a0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a0f:	75 17                	jne    802a28 <__umoddi3+0x48>
  802a11:	39 fe                	cmp    %edi,%esi
  802a13:	76 4b                	jbe    802a60 <__umoddi3+0x80>
  802a15:	89 c8                	mov    %ecx,%eax
  802a17:	89 fa                	mov    %edi,%edx
  802a19:	f7 f6                	div    %esi
  802a1b:	89 d0                	mov    %edx,%eax
  802a1d:	31 d2                	xor    %edx,%edx
  802a1f:	83 c4 14             	add    $0x14,%esp
  802a22:	5e                   	pop    %esi
  802a23:	5f                   	pop    %edi
  802a24:	5d                   	pop    %ebp
  802a25:	c3                   	ret    
  802a26:	66 90                	xchg   %ax,%ax
  802a28:	39 f8                	cmp    %edi,%eax
  802a2a:	77 54                	ja     802a80 <__umoddi3+0xa0>
  802a2c:	0f bd e8             	bsr    %eax,%ebp
  802a2f:	83 f5 1f             	xor    $0x1f,%ebp
  802a32:	75 5c                	jne    802a90 <__umoddi3+0xb0>
  802a34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a38:	39 3c 24             	cmp    %edi,(%esp)
  802a3b:	0f 87 e7 00 00 00    	ja     802b28 <__umoddi3+0x148>
  802a41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a45:	29 f1                	sub    %esi,%ecx
  802a47:	19 c7                	sbb    %eax,%edi
  802a49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a51:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a59:	83 c4 14             	add    $0x14,%esp
  802a5c:	5e                   	pop    %esi
  802a5d:	5f                   	pop    %edi
  802a5e:	5d                   	pop    %ebp
  802a5f:	c3                   	ret    
  802a60:	85 f6                	test   %esi,%esi
  802a62:	89 f5                	mov    %esi,%ebp
  802a64:	75 0b                	jne    802a71 <__umoddi3+0x91>
  802a66:	b8 01 00 00 00       	mov    $0x1,%eax
  802a6b:	31 d2                	xor    %edx,%edx
  802a6d:	f7 f6                	div    %esi
  802a6f:	89 c5                	mov    %eax,%ebp
  802a71:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a75:	31 d2                	xor    %edx,%edx
  802a77:	f7 f5                	div    %ebp
  802a79:	89 c8                	mov    %ecx,%eax
  802a7b:	f7 f5                	div    %ebp
  802a7d:	eb 9c                	jmp    802a1b <__umoddi3+0x3b>
  802a7f:	90                   	nop
  802a80:	89 c8                	mov    %ecx,%eax
  802a82:	89 fa                	mov    %edi,%edx
  802a84:	83 c4 14             	add    $0x14,%esp
  802a87:	5e                   	pop    %esi
  802a88:	5f                   	pop    %edi
  802a89:	5d                   	pop    %ebp
  802a8a:	c3                   	ret    
  802a8b:	90                   	nop
  802a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a90:	8b 04 24             	mov    (%esp),%eax
  802a93:	be 20 00 00 00       	mov    $0x20,%esi
  802a98:	89 e9                	mov    %ebp,%ecx
  802a9a:	29 ee                	sub    %ebp,%esi
  802a9c:	d3 e2                	shl    %cl,%edx
  802a9e:	89 f1                	mov    %esi,%ecx
  802aa0:	d3 e8                	shr    %cl,%eax
  802aa2:	89 e9                	mov    %ebp,%ecx
  802aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802aa8:	8b 04 24             	mov    (%esp),%eax
  802aab:	09 54 24 04          	or     %edx,0x4(%esp)
  802aaf:	89 fa                	mov    %edi,%edx
  802ab1:	d3 e0                	shl    %cl,%eax
  802ab3:	89 f1                	mov    %esi,%ecx
  802ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ab9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802abd:	d3 ea                	shr    %cl,%edx
  802abf:	89 e9                	mov    %ebp,%ecx
  802ac1:	d3 e7                	shl    %cl,%edi
  802ac3:	89 f1                	mov    %esi,%ecx
  802ac5:	d3 e8                	shr    %cl,%eax
  802ac7:	89 e9                	mov    %ebp,%ecx
  802ac9:	09 f8                	or     %edi,%eax
  802acb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802acf:	f7 74 24 04          	divl   0x4(%esp)
  802ad3:	d3 e7                	shl    %cl,%edi
  802ad5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ad9:	89 d7                	mov    %edx,%edi
  802adb:	f7 64 24 08          	mull   0x8(%esp)
  802adf:	39 d7                	cmp    %edx,%edi
  802ae1:	89 c1                	mov    %eax,%ecx
  802ae3:	89 14 24             	mov    %edx,(%esp)
  802ae6:	72 2c                	jb     802b14 <__umoddi3+0x134>
  802ae8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802aec:	72 22                	jb     802b10 <__umoddi3+0x130>
  802aee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802af2:	29 c8                	sub    %ecx,%eax
  802af4:	19 d7                	sbb    %edx,%edi
  802af6:	89 e9                	mov    %ebp,%ecx
  802af8:	89 fa                	mov    %edi,%edx
  802afa:	d3 e8                	shr    %cl,%eax
  802afc:	89 f1                	mov    %esi,%ecx
  802afe:	d3 e2                	shl    %cl,%edx
  802b00:	89 e9                	mov    %ebp,%ecx
  802b02:	d3 ef                	shr    %cl,%edi
  802b04:	09 d0                	or     %edx,%eax
  802b06:	89 fa                	mov    %edi,%edx
  802b08:	83 c4 14             	add    $0x14,%esp
  802b0b:	5e                   	pop    %esi
  802b0c:	5f                   	pop    %edi
  802b0d:	5d                   	pop    %ebp
  802b0e:	c3                   	ret    
  802b0f:	90                   	nop
  802b10:	39 d7                	cmp    %edx,%edi
  802b12:	75 da                	jne    802aee <__umoddi3+0x10e>
  802b14:	8b 14 24             	mov    (%esp),%edx
  802b17:	89 c1                	mov    %eax,%ecx
  802b19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802b1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802b21:	eb cb                	jmp    802aee <__umoddi3+0x10e>
  802b23:	90                   	nop
  802b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802b2c:	0f 82 0f ff ff ff    	jb     802a41 <__umoddi3+0x61>
  802b32:	e9 1a ff ff ff       	jmp    802a51 <__umoddi3+0x71>
