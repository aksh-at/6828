
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 30 80 00       	mov    0x803000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 63 00 00 00       	call   8000b1 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 dd 00 00 00       	call   800140 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 e7 05 00 00       	call   80068a <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 3f 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7e 28                	jle    800138 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	89 44 24 10          	mov    %eax,0x10(%esp)
  800114:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011b:	00 
  80011c:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  800133:	e8 2e 16 00 00       	call   801766 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	83 c4 2c             	add    $0x2c,%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800187:	be 00 00 00 00       	mov    $0x0,%esi
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019a:	89 f7                	mov    %esi,%edi
  80019c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	7e 28                	jle    8001ca <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  8001b5:	00 
  8001b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bd:	00 
  8001be:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  8001c5:	e8 9c 15 00 00       	call   801766 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ca:	83 c4 2c             	add    $0x2c,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 28                	jle    80021d <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800200:	00 
  800201:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  800218:	e8 49 15 00 00       	call   801766 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021d:	83 c4 2c             	add    $0x2c,%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 28                	jle    800270 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800253:	00 
  800254:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  80026b:	e8 f6 14 00 00       	call   801766 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800270:	83 c4 2c             	add    $0x2c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 08 00 00 00       	mov    $0x8,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  8002be:	e8 a3 14 00 00       	call   801766 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c3:	83 c4 2c             	add    $0x2c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 df                	mov    %ebx,%edi
  8002e6:	89 de                	mov    %ebx,%esi
  8002e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  800311:	e8 50 14 00 00       	call   801766 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800316:	83 c4 2c             	add    $0x2c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 df                	mov    %ebx,%edi
  800339:	89 de                	mov    %ebx,%esi
  80033b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033d:	85 c0                	test   %eax,%eax
  80033f:	7e 28                	jle    800369 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800341:	89 44 24 10          	mov    %eax,0x10(%esp)
  800345:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034c:	00 
  80034d:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  800354:	00 
  800355:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035c:	00 
  80035d:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  800364:	e8 fd 13 00 00       	call   801766 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800369:	83 c4 2c             	add    $0x2c,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800377:	be 00 00 00 00       	mov    $0x0,%esi
  80037c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	7e 28                	jle    8003de <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ba:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c1:	00 
  8003c2:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  8003d9:	e8 88 13 00 00       	call   801766 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003de:	83 c4 2c             	add    $0x2c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	57                   	push   %edi
  8003ea:	56                   	push   %esi
  8003eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f6:	89 d1                	mov    %edx,%ecx
  8003f8:	89 d3                	mov    %edx,%ebx
  8003fa:	89 d7                	mov    %edx,%edi
  8003fc:	89 d6                	mov    %edx,%esi
  8003fe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800400:	5b                   	pop    %ebx
  800401:	5e                   	pop    %esi
  800402:	5f                   	pop    %edi
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	57                   	push   %edi
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800413:	b8 0f 00 00 00       	mov    $0xf,%eax
  800418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	89 df                	mov    %ebx,%edi
  800420:	89 de                	mov    %ebx,%esi
  800422:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800424:	85 c0                	test   %eax,%eax
  800426:	7e 28                	jle    800450 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800428:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042c:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800433:	00 
  800434:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  80043b:	00 
  80043c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800443:	00 
  800444:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  80044b:	e8 16 13 00 00       	call   801766 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800450:	83 c4 2c             	add    $0x2c,%esp
  800453:	5b                   	pop    %ebx
  800454:	5e                   	pop    %esi
  800455:	5f                   	pop    %edi
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    

00800458 <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	57                   	push   %edi
  80045c:	56                   	push   %esi
  80045d:	53                   	push   %ebx
  80045e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800461:	bb 00 00 00 00       	mov    $0x0,%ebx
  800466:	b8 10 00 00 00       	mov    $0x10,%eax
  80046b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046e:	8b 55 08             	mov    0x8(%ebp),%edx
  800471:	89 df                	mov    %ebx,%edi
  800473:	89 de                	mov    %ebx,%esi
  800475:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800477:	85 c0                	test   %eax,%eax
  800479:	7e 28                	jle    8004a3 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80047b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80047f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800486:	00 
  800487:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  80048e:	00 
  80048f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800496:	00 
  800497:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  80049e:	e8 c3 12 00 00       	call   801766 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8004a3:	83 c4 2c             	add    $0x2c,%esp
  8004a6:	5b                   	pop    %ebx
  8004a7:	5e                   	pop    %esi
  8004a8:	5f                   	pop    %edi
  8004a9:	5d                   	pop    %ebp
  8004aa:	c3                   	ret    
  8004ab:	66 90                	xchg   %ax,%ax
  8004ad:	66 90                	xchg   %ax,%ax
  8004af:	90                   	nop

008004b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8004cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8004d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8004e2:	89 c2                	mov    %eax,%edx
  8004e4:	c1 ea 16             	shr    $0x16,%edx
  8004e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004ee:	f6 c2 01             	test   $0x1,%dl
  8004f1:	74 11                	je     800504 <fd_alloc+0x2d>
  8004f3:	89 c2                	mov    %eax,%edx
  8004f5:	c1 ea 0c             	shr    $0xc,%edx
  8004f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ff:	f6 c2 01             	test   $0x1,%dl
  800502:	75 09                	jne    80050d <fd_alloc+0x36>
			*fd_store = fd;
  800504:	89 01                	mov    %eax,(%ecx)
			return 0;
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	eb 17                	jmp    800524 <fd_alloc+0x4d>
  80050d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800512:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800517:	75 c9                	jne    8004e2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800519:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80051f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800524:	5d                   	pop    %ebp
  800525:	c3                   	ret    

00800526 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80052c:	83 f8 1f             	cmp    $0x1f,%eax
  80052f:	77 36                	ja     800567 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800531:	c1 e0 0c             	shl    $0xc,%eax
  800534:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800539:	89 c2                	mov    %eax,%edx
  80053b:	c1 ea 16             	shr    $0x16,%edx
  80053e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800545:	f6 c2 01             	test   $0x1,%dl
  800548:	74 24                	je     80056e <fd_lookup+0x48>
  80054a:	89 c2                	mov    %eax,%edx
  80054c:	c1 ea 0c             	shr    $0xc,%edx
  80054f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800556:	f6 c2 01             	test   $0x1,%dl
  800559:	74 1a                	je     800575 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80055b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055e:	89 02                	mov    %eax,(%edx)
	return 0;
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	eb 13                	jmp    80057a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800567:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80056c:	eb 0c                	jmp    80057a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80056e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800573:	eb 05                	jmp    80057a <fd_lookup+0x54>
  800575:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80057a:	5d                   	pop    %ebp
  80057b:	c3                   	ret    

0080057c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	83 ec 18             	sub    $0x18,%esp
  800582:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800585:	ba 00 00 00 00       	mov    $0x0,%edx
  80058a:	eb 13                	jmp    80059f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80058c:	39 08                	cmp    %ecx,(%eax)
  80058e:	75 0c                	jne    80059c <dev_lookup+0x20>
			*dev = devtab[i];
  800590:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800593:	89 01                	mov    %eax,(%ecx)
			return 0;
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	eb 38                	jmp    8005d4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80059c:	83 c2 01             	add    $0x1,%edx
  80059f:	8b 04 95 a0 26 80 00 	mov    0x8026a0(,%edx,4),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	75 e2                	jne    80058c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8005af:	8b 40 48             	mov    0x48(%eax),%eax
  8005b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	c7 04 24 24 26 80 00 	movl   $0x802624,(%esp)
  8005c1:	e8 99 12 00 00       	call   80185f <cprintf>
	*dev = 0;
  8005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8005cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005d4:	c9                   	leave  
  8005d5:	c3                   	ret    

008005d6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	56                   	push   %esi
  8005da:	53                   	push   %ebx
  8005db:	83 ec 20             	sub    $0x20,%esp
  8005de:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8005eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8005f1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 2a ff ff ff       	call   800526 <fd_lookup>
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	78 05                	js     800605 <fd_close+0x2f>
	    || fd != fd2)
  800600:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800603:	74 0c                	je     800611 <fd_close+0x3b>
		return (must_exist ? r : 0);
  800605:	84 db                	test   %bl,%bl
  800607:	ba 00 00 00 00       	mov    $0x0,%edx
  80060c:	0f 44 c2             	cmove  %edx,%eax
  80060f:	eb 3f                	jmp    800650 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	8b 06                	mov    (%esi),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 5a ff ff ff       	call   80057c <dev_lookup>
  800622:	89 c3                	mov    %eax,%ebx
  800624:	85 c0                	test   %eax,%eax
  800626:	78 16                	js     80063e <fd_close+0x68>
		if (dev->dev_close)
  800628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80062e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800633:	85 c0                	test   %eax,%eax
  800635:	74 07                	je     80063e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	ff d0                	call   *%eax
  80063c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800649:	e8 d7 fb ff ff       	call   800225 <sys_page_unmap>
	return r;
  80064e:	89 d8                	mov    %ebx,%eax
}
  800650:	83 c4 20             	add    $0x20,%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80065d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800660:	89 44 24 04          	mov    %eax,0x4(%esp)
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 b7 fe ff ff       	call   800526 <fd_lookup>
  80066f:	89 c2                	mov    %eax,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	78 13                	js     800688 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800675:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80067c:	00 
  80067d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	e8 4e ff ff ff       	call   8005d6 <fd_close>
}
  800688:	c9                   	leave  
  800689:	c3                   	ret    

0080068a <close_all>:

void
close_all(void)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	53                   	push   %ebx
  80068e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800691:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800696:	89 1c 24             	mov    %ebx,(%esp)
  800699:	e8 b9 ff ff ff       	call   800657 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80069e:	83 c3 01             	add    $0x1,%ebx
  8006a1:	83 fb 20             	cmp    $0x20,%ebx
  8006a4:	75 f0                	jne    800696 <close_all+0xc>
		close(i);
}
  8006a6:	83 c4 14             	add    $0x14,%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	57                   	push   %edi
  8006b0:	56                   	push   %esi
  8006b1:	53                   	push   %ebx
  8006b2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8006b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	e8 5f fe ff ff       	call   800526 <fd_lookup>
  8006c7:	89 c2                	mov    %eax,%edx
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	0f 88 e1 00 00 00    	js     8007b2 <dup+0x106>
		return r;
	close(newfdnum);
  8006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	e8 7b ff ff ff       	call   800657 <close>

	newfd = INDEX2FD(newfdnum);
  8006dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006df:	c1 e3 0c             	shl    $0xc,%ebx
  8006e2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8006e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 cd fd ff ff       	call   8004c0 <fd2data>
  8006f3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8006f5:	89 1c 24             	mov    %ebx,(%esp)
  8006f8:	e8 c3 fd ff ff       	call   8004c0 <fd2data>
  8006fd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006ff:	89 f0                	mov    %esi,%eax
  800701:	c1 e8 16             	shr    $0x16,%eax
  800704:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80070b:	a8 01                	test   $0x1,%al
  80070d:	74 43                	je     800752 <dup+0xa6>
  80070f:	89 f0                	mov    %esi,%eax
  800711:	c1 e8 0c             	shr    $0xc,%eax
  800714:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80071b:	f6 c2 01             	test   $0x1,%dl
  80071e:	74 32                	je     800752 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800720:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800727:	25 07 0e 00 00       	and    $0xe07,%eax
  80072c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800730:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800734:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80073b:	00 
  80073c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800747:	e8 86 fa ff ff       	call   8001d2 <sys_page_map>
  80074c:	89 c6                	mov    %eax,%esi
  80074e:	85 c0                	test   %eax,%eax
  800750:	78 3e                	js     800790 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800755:	89 c2                	mov    %eax,%edx
  800757:	c1 ea 0c             	shr    $0xc,%edx
  80075a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800761:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800767:	89 54 24 10          	mov    %edx,0x10(%esp)
  80076b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80076f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800776:	00 
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800782:	e8 4b fa ff ff       	call   8001d2 <sys_page_map>
  800787:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80078c:	85 f6                	test   %esi,%esi
  80078e:	79 22                	jns    8007b2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80079b:	e8 85 fa ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8007a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007ab:	e8 75 fa ff ff       	call   800225 <sys_page_unmap>
	return r;
  8007b0:	89 f0                	mov    %esi,%eax
}
  8007b2:	83 c4 3c             	add    $0x3c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 24             	sub    $0x24,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	89 1c 24             	mov    %ebx,(%esp)
  8007ce:	e8 53 fd ff ff       	call   800526 <fd_lookup>
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	78 6d                	js     800846 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	e8 8f fd ff ff       	call   80057c <dev_lookup>
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 55                	js     800846 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f4:	8b 50 08             	mov    0x8(%eax),%edx
  8007f7:	83 e2 03             	and    $0x3,%edx
  8007fa:	83 fa 01             	cmp    $0x1,%edx
  8007fd:	75 23                	jne    800822 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ff:	a1 08 40 80 00       	mov    0x804008,%eax
  800804:	8b 40 48             	mov    0x48(%eax),%eax
  800807:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80080b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080f:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800816:	e8 44 10 00 00       	call   80185f <cprintf>
		return -E_INVAL;
  80081b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800820:	eb 24                	jmp    800846 <read+0x8c>
	}
	if (!dev->dev_read)
  800822:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800825:	8b 52 08             	mov    0x8(%edx),%edx
  800828:	85 d2                	test   %edx,%edx
  80082a:	74 15                	je     800841 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80082c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	ff d2                	call   *%edx
  80083f:	eb 05                	jmp    800846 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800841:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800846:	83 c4 24             	add    $0x24,%esp
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	83 ec 1c             	sub    $0x1c,%esp
  800855:	8b 7d 08             	mov    0x8(%ebp),%edi
  800858:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80085b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800860:	eb 23                	jmp    800885 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800862:	89 f0                	mov    %esi,%eax
  800864:	29 d8                	sub    %ebx,%eax
  800866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	03 45 0c             	add    0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	89 3c 24             	mov    %edi,(%esp)
  800876:	e8 3f ff ff ff       	call   8007ba <read>
		if (m < 0)
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 10                	js     80088f <readn+0x43>
			return m;
		if (m == 0)
  80087f:	85 c0                	test   %eax,%eax
  800881:	74 0a                	je     80088d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800883:	01 c3                	add    %eax,%ebx
  800885:	39 f3                	cmp    %esi,%ebx
  800887:	72 d9                	jb     800862 <readn+0x16>
  800889:	89 d8                	mov    %ebx,%eax
  80088b:	eb 02                	jmp    80088f <readn+0x43>
  80088d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80088f:	83 c4 1c             	add    $0x1c,%esp
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5f                   	pop    %edi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 24             	sub    $0x24,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	89 1c 24             	mov    %ebx,(%esp)
  8008ab:	e8 76 fc ff ff       	call   800526 <fd_lookup>
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	78 68                	js     80091e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 b2 fc ff ff       	call   80057c <dev_lookup>
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	78 50                	js     80091e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d5:	75 23                	jne    8008fa <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8008d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8008dc:	8b 40 48             	mov    0x48(%eax),%eax
  8008df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e7:	c7 04 24 81 26 80 00 	movl   $0x802681,(%esp)
  8008ee:	e8 6c 0f 00 00       	call   80185f <cprintf>
		return -E_INVAL;
  8008f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f8:	eb 24                	jmp    80091e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008fd:	8b 52 0c             	mov    0xc(%edx),%edx
  800900:	85 d2                	test   %edx,%edx
  800902:	74 15                	je     800919 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	ff d2                	call   *%edx
  800917:	eb 05                	jmp    80091e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80091e:	83 c4 24             	add    $0x24,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <seek>:

int
seek(int fdnum, off_t offset)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80092a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 ea fb ff ff       	call   800526 <fd_lookup>
  80093c:	85 c0                	test   %eax,%eax
  80093e:	78 0e                	js     80094e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800949:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	83 ec 24             	sub    $0x24,%esp
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80095a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	89 1c 24             	mov    %ebx,(%esp)
  800964:	e8 bd fb ff ff       	call   800526 <fd_lookup>
  800969:	89 c2                	mov    %eax,%edx
  80096b:	85 d2                	test   %edx,%edx
  80096d:	78 61                	js     8009d0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80096f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800979:	8b 00                	mov    (%eax),%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 f9 fb ff ff       	call   80057c <dev_lookup>
  800983:	85 c0                	test   %eax,%eax
  800985:	78 49                	js     8009d0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80098a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80098e:	75 23                	jne    8009b3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800990:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800995:	8b 40 48             	mov    0x48(%eax),%eax
  800998:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 44 26 80 00 	movl   $0x802644,(%esp)
  8009a7:	e8 b3 0e 00 00       	call   80185f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8009ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b1:	eb 1d                	jmp    8009d0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8009b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b6:	8b 52 18             	mov    0x18(%edx),%edx
  8009b9:	85 d2                	test   %edx,%edx
  8009bb:	74 0e                	je     8009cb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	ff d2                	call   *%edx
  8009c9:	eb 05                	jmp    8009d0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8009d0:	83 c4 24             	add    $0x24,%esp
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 24             	sub    $0x24,%esp
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	e8 34 fb ff ff       	call   800526 <fd_lookup>
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	78 52                	js     800a4a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a02:	8b 00                	mov    (%eax),%eax
  800a04:	89 04 24             	mov    %eax,(%esp)
  800a07:	e8 70 fb ff ff       	call   80057c <dev_lookup>
  800a0c:	85 c0                	test   %eax,%eax
  800a0e:	78 3a                	js     800a4a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a13:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a17:	74 2c                	je     800a45 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a19:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a1c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a23:	00 00 00 
	stat->st_isdir = 0;
  800a26:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a2d:	00 00 00 
	stat->st_dev = dev;
  800a30:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a3d:	89 14 24             	mov    %edx,(%esp)
  800a40:	ff 50 14             	call   *0x14(%eax)
  800a43:	eb 05                	jmp    800a4a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a45:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a4a:	83 c4 24             	add    $0x24,%esp
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a5f:	00 
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 28 02 00 00       	call   800c93 <open>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	78 1b                	js     800a8c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	89 1c 24             	mov    %ebx,(%esp)
  800a7b:	e8 56 ff ff ff       	call   8009d6 <fstat>
  800a80:	89 c6                	mov    %eax,%esi
	close(fd);
  800a82:	89 1c 24             	mov    %ebx,(%esp)
  800a85:	e8 cd fb ff ff       	call   800657 <close>
	return r;
  800a8a:	89 f0                	mov    %esi,%eax
}
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 10             	sub    $0x10,%esp
  800a9b:	89 c6                	mov    %eax,%esi
  800a9d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a9f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800aa6:	75 11                	jne    800ab9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800aa8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800aaf:	e8 11 18 00 00       	call   8022c5 <ipc_find_env>
  800ab4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ab9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ac0:	00 
  800ac1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ac8:	00 
  800ac9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800acd:	a1 00 40 80 00       	mov    0x804000,%eax
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	e8 80 17 00 00       	call   80225a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ada:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ae1:	00 
  800ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aed:	e8 ee 16 00 00       	call   8021e0 <ipc_recv>
}
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 40 0c             	mov    0xc(%eax),%eax
  800b05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1c:	e8 72 ff ff ff       	call   800a93 <fsipc>
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b2f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 06 00 00 00       	mov    $0x6,%eax
  800b3e:	e8 50 ff ff ff       	call   800a93 <fsipc>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	53                   	push   %ebx
  800b49:	83 ec 14             	sub    $0x14,%esp
  800b4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 40 0c             	mov    0xc(%eax),%eax
  800b55:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b64:	e8 2a ff ff ff       	call   800a93 <fsipc>
  800b69:	89 c2                	mov    %eax,%edx
  800b6b:	85 d2                	test   %edx,%edx
  800b6d:	78 2b                	js     800b9a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b6f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b76:	00 
  800b77:	89 1c 24             	mov    %ebx,(%esp)
  800b7a:	e8 08 13 00 00       	call   801e87 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b7f:	a1 80 50 80 00       	mov    0x805080,%eax
  800b84:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b8a:	a1 84 50 80 00       	mov    0x805084,%eax
  800b8f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9a:	83 c4 14             	add    $0x14,%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 18             	sub    $0x18,%esp
  800ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bae:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800bb3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 52 0c             	mov    0xc(%edx),%edx
  800bbc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800bc2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  800bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bd9:	e8 46 14 00 00       	call   802024 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 04 00 00 00       	mov    $0x4,%eax
  800be8:	e8 a6 fe ff ff       	call   800a93 <fsipc>
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 10             	sub    $0x10,%esp
  800bf7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	8b 40 0c             	mov    0xc(%eax),%eax
  800c00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c05:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 03 00 00 00       	mov    $0x3,%eax
  800c15:	e8 79 fe ff ff       	call   800a93 <fsipc>
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	78 6a                	js     800c8a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	73 24                	jae    800c48 <devfile_read+0x59>
  800c24:	c7 44 24 0c b4 26 80 	movl   $0x8026b4,0xc(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  800c33:	00 
  800c34:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c3b:	00 
  800c3c:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  800c43:	e8 1e 0b 00 00       	call   801766 <_panic>
	assert(r <= PGSIZE);
  800c48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c4d:	7e 24                	jle    800c73 <devfile_read+0x84>
  800c4f:	c7 44 24 0c db 26 80 	movl   $0x8026db,0xc(%esp)
  800c56:	00 
  800c57:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c66:	00 
  800c67:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  800c6e:	e8 f3 0a 00 00       	call   801766 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c77:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c7e:	00 
  800c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 9a 13 00 00       	call   802024 <memmove>
	return r;
}
  800c8a:	89 d8                	mov    %ebx,%eax
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	53                   	push   %ebx
  800c97:	83 ec 24             	sub    $0x24,%esp
  800c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c9d:	89 1c 24             	mov    %ebx,(%esp)
  800ca0:	e8 ab 11 00 00       	call   801e50 <strlen>
  800ca5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800caa:	7f 60                	jg     800d0c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800cac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800caf:	89 04 24             	mov    %eax,(%esp)
  800cb2:	e8 20 f8 ff ff       	call   8004d7 <fd_alloc>
  800cb7:	89 c2                	mov    %eax,%edx
  800cb9:	85 d2                	test   %edx,%edx
  800cbb:	78 54                	js     800d11 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cc8:	e8 ba 11 00 00       	call   801e87 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdd:	e8 b1 fd ff ff       	call   800a93 <fsipc>
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	79 17                	jns    800cff <open+0x6c>
		fd_close(fd, 0);
  800ce8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cef:	00 
  800cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf3:	89 04 24             	mov    %eax,(%esp)
  800cf6:	e8 db f8 ff ff       	call   8005d6 <fd_close>
		return r;
  800cfb:	89 d8                	mov    %ebx,%eax
  800cfd:	eb 12                	jmp    800d11 <open+0x7e>
	}

	return fd2num(fd);
  800cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 a6 f7 ff ff       	call   8004b0 <fd2num>
  800d0a:	eb 05                	jmp    800d11 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800d0c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800d11:	83 c4 24             	add    $0x24,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 08 00 00 00       	mov    $0x8,%eax
  800d27:	e8 67 fd ff ff       	call   800a93 <fsipc>
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d36:	c7 44 24 04 e7 26 80 	movl   $0x8026e7,0x4(%esp)
  800d3d:	00 
  800d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d41:	89 04 24             	mov    %eax,(%esp)
  800d44:	e8 3e 11 00 00       	call   801e87 <strcpy>
	return 0;
}
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	53                   	push   %ebx
  800d54:	83 ec 14             	sub    $0x14,%esp
  800d57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d5a:	89 1c 24             	mov    %ebx,(%esp)
  800d5d:	e8 9b 15 00 00       	call   8022fd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800d62:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800d67:	83 f8 01             	cmp    $0x1,%eax
  800d6a:	75 0d                	jne    800d79 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800d6c:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d6f:	89 04 24             	mov    %eax,(%esp)
  800d72:	e8 29 03 00 00       	call   8010a0 <nsipc_close>
  800d77:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	83 c4 14             	add    $0x14,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d8e:	00 
  800d8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	8b 40 0c             	mov    0xc(%eax),%eax
  800da3:	89 04 24             	mov    %eax,(%esp)
  800da6:	e8 f0 03 00 00       	call   80119b <nsipc_send>
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800db3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dba:	00 
  800dbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcf:	89 04 24             	mov    %eax,(%esp)
  800dd2:	e8 44 03 00 00       	call   80111b <nsipc_recv>
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800ddf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800de2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800de6:	89 04 24             	mov    %eax,(%esp)
  800de9:	e8 38 f7 ff ff       	call   800526 <fd_lookup>
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 17                	js     800e09 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800dfb:	39 08                	cmp    %ecx,(%eax)
  800dfd:	75 05                	jne    800e04 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800dff:	8b 40 0c             	mov    0xc(%eax),%eax
  800e02:	eb 05                	jmp    800e09 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 20             	sub    $0x20,%esp
  800e13:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e18:	89 04 24             	mov    %eax,(%esp)
  800e1b:	e8 b7 f6 ff ff       	call   8004d7 <fd_alloc>
  800e20:	89 c3                	mov    %eax,%ebx
  800e22:	85 c0                	test   %eax,%eax
  800e24:	78 21                	js     800e47 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e2d:	00 
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3c:	e8 3d f3 ff ff       	call   80017e <sys_page_alloc>
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 0c                	jns    800e53 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  800e47:	89 34 24             	mov    %esi,(%esp)
  800e4a:	e8 51 02 00 00       	call   8010a0 <nsipc_close>
		return r;
  800e4f:	89 d8                	mov    %ebx,%eax
  800e51:	eb 20                	jmp    800e73 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e53:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e61:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800e68:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800e6b:	89 14 24             	mov    %edx,(%esp)
  800e6e:	e8 3d f6 ff ff       	call   8004b0 <fd2num>
}
  800e73:	83 c4 20             	add    $0x20,%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	e8 51 ff ff ff       	call   800dd9 <fd2sockid>
		return r;
  800e88:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	78 23                	js     800eb1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e8e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e91:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	e8 45 01 00 00       	call   800fe9 <nsipc_accept>
		return r;
  800ea4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 07                	js     800eb1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  800eaa:	e8 5c ff ff ff       	call   800e0b <alloc_sockfd>
  800eaf:	89 c1                	mov    %eax,%ecx
}
  800eb1:	89 c8                	mov    %ecx,%eax
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	e8 16 ff ff ff       	call   800dd9 <fd2sockid>
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	85 d2                	test   %edx,%edx
  800ec7:	78 16                	js     800edf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  800ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed7:	89 14 24             	mov    %edx,(%esp)
  800eda:	e8 60 01 00 00       	call   80103f <nsipc_bind>
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <shutdown>:

int
shutdown(int s, int how)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	e8 ea fe ff ff       	call   800dd9 <fd2sockid>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	85 d2                	test   %edx,%edx
  800ef3:	78 0f                	js     800f04 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efc:	89 14 24             	mov    %edx,(%esp)
  800eff:	e8 7a 01 00 00       	call   80107e <nsipc_shutdown>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	e8 c5 fe ff ff       	call   800dd9 <fd2sockid>
  800f14:	89 c2                	mov    %eax,%edx
  800f16:	85 d2                	test   %edx,%edx
  800f18:	78 16                	js     800f30 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  800f1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f28:	89 14 24             	mov    %edx,(%esp)
  800f2b:	e8 8a 01 00 00       	call   8010ba <nsipc_connect>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <listen>:

int
listen(int s, int backlog)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	e8 99 fe ff ff       	call   800dd9 <fd2sockid>
  800f40:	89 c2                	mov    %eax,%edx
  800f42:	85 d2                	test   %edx,%edx
  800f44:	78 0f                	js     800f55 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4d:	89 14 24             	mov    %edx,(%esp)
  800f50:	e8 a4 01 00 00       	call   8010f9 <nsipc_listen>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	89 04 24             	mov    %eax,(%esp)
  800f71:	e8 98 02 00 00       	call   80120e <nsipc_socket>
  800f76:	89 c2                	mov    %eax,%edx
  800f78:	85 d2                	test   %edx,%edx
  800f7a:	78 05                	js     800f81 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  800f7c:	e8 8a fe ff ff       	call   800e0b <alloc_sockfd>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 14             	sub    $0x14,%esp
  800f8a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f8c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f93:	75 11                	jne    800fa6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f9c:	e8 24 13 00 00       	call   8022c5 <ipc_find_env>
  800fa1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800fa6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fad:	00 
  800fae:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800fb5:	00 
  800fb6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fba:	a1 04 40 80 00       	mov    0x804004,%eax
  800fbf:	89 04 24             	mov    %eax,(%esp)
  800fc2:	e8 93 12 00 00       	call   80225a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800fc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd6:	00 
  800fd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fde:	e8 fd 11 00 00       	call   8021e0 <ipc_recv>
}
  800fe3:	83 c4 14             	add    $0x14,%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 10             	sub    $0x10,%esp
  800ff1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ffc:	8b 06                	mov    (%esi),%eax
  800ffe:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
  801008:	e8 76 ff ff ff       	call   800f83 <nsipc>
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 23                	js     801036 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801013:	a1 10 60 80 00       	mov    0x806010,%eax
  801018:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801023:	00 
  801024:	8b 45 0c             	mov    0xc(%ebp),%eax
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	e8 f5 0f 00 00       	call   802024 <memmove>
		*addrlen = ret->ret_addrlen;
  80102f:	a1 10 60 80 00       	mov    0x806010,%eax
  801034:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801036:	89 d8                	mov    %ebx,%eax
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	53                   	push   %ebx
  801043:	83 ec 14             	sub    $0x14,%esp
  801046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801051:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801055:	8b 45 0c             	mov    0xc(%ebp),%eax
  801058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801063:	e8 bc 0f 00 00       	call   802024 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801068:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80106e:	b8 02 00 00 00       	mov    $0x2,%eax
  801073:	e8 0b ff ff ff       	call   800f83 <nsipc>
}
  801078:	83 c4 14             	add    $0x14,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
  801087:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80108c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801094:	b8 03 00 00 00       	mov    $0x3,%eax
  801099:	e8 e5 fe ff ff       	call   800f83 <nsipc>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <nsipc_close>:

int
nsipc_close(int s)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b3:	e8 cb fe ff ff       	call   800f83 <nsipc>
}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 14             	sub    $0x14,%esp
  8010c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8010cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8010de:	e8 41 0f 00 00       	call   802024 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8010e3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8010e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ee:	e8 90 fe ff ff       	call   800f83 <nsipc>
}
  8010f3:	83 c4 14             	add    $0x14,%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80110f:	b8 06 00 00 00       	mov    $0x6,%eax
  801114:	e8 6a fe ff ff       	call   800f83 <nsipc>
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 10             	sub    $0x10,%esp
  801123:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80112e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801134:	8b 45 14             	mov    0x14(%ebp),%eax
  801137:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80113c:	b8 07 00 00 00       	mov    $0x7,%eax
  801141:	e8 3d fe ff ff       	call   800f83 <nsipc>
  801146:	89 c3                	mov    %eax,%ebx
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 46                	js     801192 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80114c:	39 f0                	cmp    %esi,%eax
  80114e:	7f 07                	jg     801157 <nsipc_recv+0x3c>
  801150:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801155:	7e 24                	jle    80117b <nsipc_recv+0x60>
  801157:	c7 44 24 0c f3 26 80 	movl   $0x8026f3,0xc(%esp)
  80115e:	00 
  80115f:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  801166:	00 
  801167:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  801176:	e8 eb 05 00 00       	call   801766 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80117b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801186:	00 
  801187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118a:	89 04 24             	mov    %eax,(%esp)
  80118d:	e8 92 0e 00 00       	call   802024 <memmove>
	}

	return r;
}
  801192:	89 d8                	mov    %ebx,%eax
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	83 ec 14             	sub    $0x14,%esp
  8011a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8011ad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8011b3:	7e 24                	jle    8011d9 <nsipc_send+0x3e>
  8011b5:	c7 44 24 0c 14 27 80 	movl   $0x802714,0xc(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  8011d4:	e8 8d 05 00 00       	call   801766 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e4:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8011eb:	e8 34 0e 00 00       	call   802024 <memmove>
	nsipcbuf.send.req_size = size;
  8011f0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8011f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8011f9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801203:	e8 7b fd ff ff       	call   800f83 <nsipc>
}
  801208:	83 c4 14             	add    $0x14,%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80121c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801224:	8b 45 10             	mov    0x10(%ebp),%eax
  801227:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80122c:	b8 09 00 00 00       	mov    $0x9,%eax
  801231:	e8 4d fd ff ff       	call   800f83 <nsipc>
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 10             	sub    $0x10,%esp
  801240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	e8 72 f2 ff ff       	call   8004c0 <fd2data>
  80124e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801250:	c7 44 24 04 20 27 80 	movl   $0x802720,0x4(%esp)
  801257:	00 
  801258:	89 1c 24             	mov    %ebx,(%esp)
  80125b:	e8 27 0c 00 00       	call   801e87 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801260:	8b 46 04             	mov    0x4(%esi),%eax
  801263:	2b 06                	sub    (%esi),%eax
  801265:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80126b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801272:	00 00 00 
	stat->st_dev = &devpipe;
  801275:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80127c:	30 80 00 
	return 0;
}
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	5b                   	pop    %ebx
  801288:	5e                   	pop    %esi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	83 ec 14             	sub    $0x14,%esp
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801295:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801299:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a0:	e8 80 ef ff ff       	call   800225 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8012a5:	89 1c 24             	mov    %ebx,(%esp)
  8012a8:	e8 13 f2 ff ff       	call   8004c0 <fd2data>
  8012ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b8:	e8 68 ef ff ff       	call   800225 <sys_page_unmap>
}
  8012bd:	83 c4 14             	add    $0x14,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	57                   	push   %edi
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 2c             	sub    $0x2c,%esp
  8012cc:	89 c6                	mov    %eax,%esi
  8012ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012d9:	89 34 24             	mov    %esi,(%esp)
  8012dc:	e8 1c 10 00 00       	call   8022fd <pageref>
  8012e1:	89 c7                	mov    %eax,%edi
  8012e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 0f 10 00 00       	call   8022fd <pageref>
  8012ee:	39 c7                	cmp    %eax,%edi
  8012f0:	0f 94 c2             	sete   %dl
  8012f3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8012f6:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8012fc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8012ff:	39 fb                	cmp    %edi,%ebx
  801301:	74 21                	je     801324 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801303:	84 d2                	test   %dl,%dl
  801305:	74 ca                	je     8012d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801307:	8b 51 58             	mov    0x58(%ecx),%edx
  80130a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801312:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801316:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  80131d:	e8 3d 05 00 00       	call   80185f <cprintf>
  801322:	eb ad                	jmp    8012d1 <_pipeisclosed+0xe>
	}
}
  801324:	83 c4 2c             	add    $0x2c,%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	57                   	push   %edi
  801330:	56                   	push   %esi
  801331:	53                   	push   %ebx
  801332:	83 ec 1c             	sub    $0x1c,%esp
  801335:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801338:	89 34 24             	mov    %esi,(%esp)
  80133b:	e8 80 f1 ff ff       	call   8004c0 <fd2data>
  801340:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801342:	bf 00 00 00 00       	mov    $0x0,%edi
  801347:	eb 45                	jmp    80138e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801349:	89 da                	mov    %ebx,%edx
  80134b:	89 f0                	mov    %esi,%eax
  80134d:	e8 71 ff ff ff       	call   8012c3 <_pipeisclosed>
  801352:	85 c0                	test   %eax,%eax
  801354:	75 41                	jne    801397 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801356:	e8 04 ee ff ff       	call   80015f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80135b:	8b 43 04             	mov    0x4(%ebx),%eax
  80135e:	8b 0b                	mov    (%ebx),%ecx
  801360:	8d 51 20             	lea    0x20(%ecx),%edx
  801363:	39 d0                	cmp    %edx,%eax
  801365:	73 e2                	jae    801349 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801367:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80136e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801371:	99                   	cltd   
  801372:	c1 ea 1b             	shr    $0x1b,%edx
  801375:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801378:	83 e1 1f             	and    $0x1f,%ecx
  80137b:	29 d1                	sub    %edx,%ecx
  80137d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801381:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801385:	83 c0 01             	add    $0x1,%eax
  801388:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80138b:	83 c7 01             	add    $0x1,%edi
  80138e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801391:	75 c8                	jne    80135b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801393:	89 f8                	mov    %edi,%eax
  801395:	eb 05                	jmp    80139c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80139c:	83 c4 1c             	add    $0x1c,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	57                   	push   %edi
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 1c             	sub    $0x1c,%esp
  8013ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8013b0:	89 3c 24             	mov    %edi,(%esp)
  8013b3:	e8 08 f1 ff ff       	call   8004c0 <fd2data>
  8013b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013ba:	be 00 00 00 00       	mov    $0x0,%esi
  8013bf:	eb 3d                	jmp    8013fe <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8013c1:	85 f6                	test   %esi,%esi
  8013c3:	74 04                	je     8013c9 <devpipe_read+0x25>
				return i;
  8013c5:	89 f0                	mov    %esi,%eax
  8013c7:	eb 43                	jmp    80140c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013c9:	89 da                	mov    %ebx,%edx
  8013cb:	89 f8                	mov    %edi,%eax
  8013cd:	e8 f1 fe ff ff       	call   8012c3 <_pipeisclosed>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	75 31                	jne    801407 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8013d6:	e8 84 ed ff ff       	call   80015f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013db:	8b 03                	mov    (%ebx),%eax
  8013dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8013e0:	74 df                	je     8013c1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8013e2:	99                   	cltd   
  8013e3:	c1 ea 1b             	shr    $0x1b,%edx
  8013e6:	01 d0                	add    %edx,%eax
  8013e8:	83 e0 1f             	and    $0x1f,%eax
  8013eb:	29 d0                	sub    %edx,%eax
  8013ed:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8013f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8013f8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013fb:	83 c6 01             	add    $0x1,%esi
  8013fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801401:	75 d8                	jne    8013db <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801403:	89 f0                	mov    %esi,%eax
  801405:	eb 05                	jmp    80140c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80140c:	83 c4 1c             	add    $0x1c,%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80141c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 b0 f0 ff ff       	call   8004d7 <fd_alloc>
  801427:	89 c2                	mov    %eax,%edx
  801429:	85 d2                	test   %edx,%edx
  80142b:	0f 88 4d 01 00 00    	js     80157e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801431:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801438:	00 
  801439:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801447:	e8 32 ed ff ff       	call   80017e <sys_page_alloc>
  80144c:	89 c2                	mov    %eax,%edx
  80144e:	85 d2                	test   %edx,%edx
  801450:	0f 88 28 01 00 00    	js     80157e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801456:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801459:	89 04 24             	mov    %eax,(%esp)
  80145c:	e8 76 f0 ff ff       	call   8004d7 <fd_alloc>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 88 fe 00 00 00    	js     801569 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80146b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801472:	00 
  801473:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801481:	e8 f8 ec ff ff       	call   80017e <sys_page_alloc>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	85 c0                	test   %eax,%eax
  80148a:	0f 88 d9 00 00 00    	js     801569 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 25 f0 ff ff       	call   8004c0 <fd2data>
  80149b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80149d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014a4:	00 
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b0:	e8 c9 ec ff ff       	call   80017e <sys_page_alloc>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	0f 88 97 00 00 00    	js     801556 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 f6 ef ff ff       	call   8004c0 <fd2data>
  8014ca:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8014d1:	00 
  8014d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014dd:	00 
  8014de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e9:	e8 e4 ec ff ff       	call   8001d2 <sys_page_map>
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 52                	js     801546 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8014f4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801502:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801509:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801514:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801517:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80151e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801521:	89 04 24             	mov    %eax,(%esp)
  801524:	e8 87 ef ff ff       	call   8004b0 <fd2num>
  801529:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801531:	89 04 24             	mov    %eax,(%esp)
  801534:	e8 77 ef ff ff       	call   8004b0 <fd2num>
  801539:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	eb 38                	jmp    80157e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80154a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801551:	e8 cf ec ff ff       	call   800225 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801564:	e8 bc ec ff ff       	call   800225 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801569:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801577:	e8 a9 ec ff ff       	call   800225 <sys_page_unmap>
  80157c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80157e:	83 c4 30             	add    $0x30,%esp
  801581:	5b                   	pop    %ebx
  801582:	5e                   	pop    %esi
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 89 ef ff ff       	call   800526 <fd_lookup>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 d2                	test   %edx,%edx
  8015a1:	78 15                	js     8015b8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a6:	89 04 24             	mov    %eax,(%esp)
  8015a9:	e8 12 ef ff ff       	call   8004c0 <fd2data>
	return _pipeisclosed(fd, p);
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b3:	e8 0b fd ff ff       	call   8012c3 <_pipeisclosed>
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    
  8015ba:	66 90                	xchg   %ax,%ax
  8015bc:	66 90                	xchg   %ax,%ax
  8015be:	66 90                	xchg   %ax,%ax

008015c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8015c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8015d0:	c7 44 24 04 3f 27 80 	movl   $0x80273f,0x4(%esp)
  8015d7:	00 
  8015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015db:	89 04 24             	mov    %eax,(%esp)
  8015de:	e8 a4 08 00 00       	call   801e87 <strcpy>
	return 0;
}
  8015e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8015fb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801601:	eb 31                	jmp    801634 <devcons_write+0x4a>
		m = n - tot;
  801603:	8b 75 10             	mov    0x10(%ebp),%esi
  801606:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801608:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80160b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801610:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801613:	89 74 24 08          	mov    %esi,0x8(%esp)
  801617:	03 45 0c             	add    0xc(%ebp),%eax
  80161a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161e:	89 3c 24             	mov    %edi,(%esp)
  801621:	e8 fe 09 00 00       	call   802024 <memmove>
		sys_cputs(buf, m);
  801626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162a:	89 3c 24             	mov    %edi,(%esp)
  80162d:	e8 7f ea ff ff       	call   8000b1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801632:	01 f3                	add    %esi,%ebx
  801634:	89 d8                	mov    %ebx,%eax
  801636:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801639:	72 c8                	jb     801603 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80163b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80164c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801651:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801655:	75 07                	jne    80165e <devcons_read+0x18>
  801657:	eb 2a                	jmp    801683 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801659:	e8 01 eb ff ff       	call   80015f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80165e:	66 90                	xchg   %ax,%ax
  801660:	e8 6a ea ff ff       	call   8000cf <sys_cgetc>
  801665:	85 c0                	test   %eax,%eax
  801667:	74 f0                	je     801659 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 16                	js     801683 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80166d:	83 f8 04             	cmp    $0x4,%eax
  801670:	74 0c                	je     80167e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801672:	8b 55 0c             	mov    0xc(%ebp),%edx
  801675:	88 02                	mov    %al,(%edx)
	return 1;
  801677:	b8 01 00 00 00       	mov    $0x1,%eax
  80167c:	eb 05                	jmp    801683 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801691:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801698:	00 
  801699:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 0d ea ff ff       	call   8000b1 <sys_cputs>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <getchar>:

int
getchar(void)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8016ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8016b3:	00 
  8016b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c2:	e8 f3 f0 ff ff       	call   8007ba <read>
	if (r < 0)
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 0f                	js     8016da <getchar+0x34>
		return r;
	if (r < 1)
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	7e 06                	jle    8016d5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8016cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8016d3:	eb 05                	jmp    8016da <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8016d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 32 ee ff ff       	call   800526 <fd_lookup>
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 11                	js     801709 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8016f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fb:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801701:	39 10                	cmp    %edx,(%eax)
  801703:	0f 94 c0             	sete   %al
  801706:	0f b6 c0             	movzbl %al,%eax
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <opencons>:

int
opencons(void)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 bb ed ff ff       	call   8004d7 <fd_alloc>
		return r;
  80171c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 40                	js     801762 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801722:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801729:	00 
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801738:	e8 41 ea ff ff       	call   80017e <sys_page_alloc>
		return r;
  80173d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 1f                	js     801762 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801743:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801751:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801758:	89 04 24             	mov    %eax,(%esp)
  80175b:	e8 50 ed ff ff       	call   8004b0 <fd2num>
  801760:	89 c2                	mov    %eax,%edx
}
  801762:	89 d0                	mov    %edx,%eax
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80176e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801771:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801777:	e8 c4 e9 ff ff       	call   800140 <sys_getenvid>
  80177c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801783:	8b 55 08             	mov    0x8(%ebp),%edx
  801786:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80178a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80178e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801792:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  801799:	e8 c1 00 00 00       	call   80185f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80179e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 51 00 00 00       	call   8017fe <vcprintf>
	cprintf("\n");
  8017ad:	c7 04 24 38 27 80 00 	movl   $0x802738,(%esp)
  8017b4:	e8 a6 00 00 00       	call   80185f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017b9:	cc                   	int3   
  8017ba:	eb fd                	jmp    8017b9 <_panic+0x53>

008017bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 14             	sub    $0x14,%esp
  8017c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8017c6:	8b 13                	mov    (%ebx),%edx
  8017c8:	8d 42 01             	lea    0x1(%edx),%eax
  8017cb:	89 03                	mov    %eax,(%ebx)
  8017cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8017d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8017d9:	75 19                	jne    8017f4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8017db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8017e2:	00 
  8017e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	e8 c3 e8 ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  8017ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8017f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8017f8:	83 c4 14             	add    $0x14,%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801807:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80180e:	00 00 00 
	b.cnt = 0;
  801811:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801818:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	89 44 24 08          	mov    %eax,0x8(%esp)
  801829:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	c7 04 24 bc 17 80 00 	movl   $0x8017bc,(%esp)
  80183a:	e8 af 01 00 00       	call   8019ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80183f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	e8 5a e8 ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  801857:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801865:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 87 ff ff ff       	call   8017fe <vcprintf>
	va_end(ap);

	return cnt;
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    
  801879:	66 90                	xchg   %ax,%ax
  80187b:	66 90                	xchg   %ax,%ax
  80187d:	66 90                	xchg   %ax,%ax
  80187f:	90                   	nop

00801880 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 3c             	sub    $0x3c,%esp
  801889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80188c:	89 d7                	mov    %edx,%edi
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	89 c3                	mov    %eax,%ebx
  801899:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80189c:	8b 45 10             	mov    0x10(%ebp),%eax
  80189f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018ad:	39 d9                	cmp    %ebx,%ecx
  8018af:	72 05                	jb     8018b6 <printnum+0x36>
  8018b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8018b4:	77 69                	ja     80191f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8018b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018bd:	83 ee 01             	sub    $0x1,%esi
  8018c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	89 d6                	mov    %edx,%esi
  8018d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8018da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	e8 4c 0a 00 00       	call   802340 <__udivdi3>
  8018f4:	89 d9                	mov    %ebx,%ecx
  8018f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	89 54 24 04          	mov    %edx,0x4(%esp)
  801905:	89 fa                	mov    %edi,%edx
  801907:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190a:	e8 71 ff ff ff       	call   801880 <printnum>
  80190f:	eb 1b                	jmp    80192c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801911:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801915:	8b 45 18             	mov    0x18(%ebp),%eax
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	ff d3                	call   *%ebx
  80191d:	eb 03                	jmp    801922 <printnum+0xa2>
  80191f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801922:	83 ee 01             	sub    $0x1,%esi
  801925:	85 f6                	test   %esi,%esi
  801927:	7f e8                	jg     801911 <printnum+0x91>
  801929:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80192c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801930:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801934:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801937:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80193a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801942:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	e8 1c 0b 00 00       	call   802470 <__umoddi3>
  801954:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801958:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801965:	ff d0                	call   *%eax
}
  801967:	83 c4 3c             	add    $0x3c,%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5f                   	pop    %edi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801972:	83 fa 01             	cmp    $0x1,%edx
  801975:	7e 0e                	jle    801985 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801977:	8b 10                	mov    (%eax),%edx
  801979:	8d 4a 08             	lea    0x8(%edx),%ecx
  80197c:	89 08                	mov    %ecx,(%eax)
  80197e:	8b 02                	mov    (%edx),%eax
  801980:	8b 52 04             	mov    0x4(%edx),%edx
  801983:	eb 22                	jmp    8019a7 <getuint+0x38>
	else if (lflag)
  801985:	85 d2                	test   %edx,%edx
  801987:	74 10                	je     801999 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801989:	8b 10                	mov    (%eax),%edx
  80198b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80198e:	89 08                	mov    %ecx,(%eax)
  801990:	8b 02                	mov    (%edx),%eax
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
  801997:	eb 0e                	jmp    8019a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801999:	8b 10                	mov    (%eax),%edx
  80199b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80199e:	89 08                	mov    %ecx,(%eax)
  8019a0:	8b 02                	mov    (%edx),%eax
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8019af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019b3:	8b 10                	mov    (%eax),%edx
  8019b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8019b8:	73 0a                	jae    8019c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8019bd:	89 08                	mov    %ecx,(%eax)
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	88 02                	mov    %al,(%edx)
}
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8019cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 02 00 00 00       	call   8019ee <vprintfmt>
	va_end(ap);
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 3c             	sub    $0x3c,%esp
  8019f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019fd:	eb 14                	jmp    801a13 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	0f 84 b3 03 00 00    	je     801dba <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  801a07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	8d 73 01             	lea    0x1(%ebx),%esi
  801a16:	0f b6 03             	movzbl (%ebx),%eax
  801a19:	83 f8 25             	cmp    $0x25,%eax
  801a1c:	75 e1                	jne    8019ff <vprintfmt+0x11>
  801a1e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801a22:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801a29:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801a30:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801a37:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3c:	eb 1d                	jmp    801a5b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a40:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801a44:	eb 15                	jmp    801a5b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a46:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a48:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801a4c:	eb 0d                	jmp    801a5b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801a4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a54:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801a5e:	0f b6 0e             	movzbl (%esi),%ecx
  801a61:	0f b6 c1             	movzbl %cl,%eax
  801a64:	83 e9 23             	sub    $0x23,%ecx
  801a67:	80 f9 55             	cmp    $0x55,%cl
  801a6a:	0f 87 2a 03 00 00    	ja     801d9a <vprintfmt+0x3ac>
  801a70:	0f b6 c9             	movzbl %cl,%ecx
  801a73:	ff 24 8d c0 28 80 00 	jmp    *0x8028c0(,%ecx,4)
  801a7a:	89 de                	mov    %ebx,%esi
  801a7c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a81:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801a84:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801a88:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801a8b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801a8e:	83 fb 09             	cmp    $0x9,%ebx
  801a91:	77 36                	ja     801ac9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a93:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a96:	eb e9                	jmp    801a81 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a98:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9b:	8d 48 04             	lea    0x4(%eax),%ecx
  801a9e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801aa1:	8b 00                	mov    (%eax),%eax
  801aa3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801aa8:	eb 22                	jmp    801acc <vprintfmt+0xde>
  801aaa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801aad:	85 c9                	test   %ecx,%ecx
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab4:	0f 49 c1             	cmovns %ecx,%eax
  801ab7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aba:	89 de                	mov    %ebx,%esi
  801abc:	eb 9d                	jmp    801a5b <vprintfmt+0x6d>
  801abe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ac0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801ac7:	eb 92                	jmp    801a5b <vprintfmt+0x6d>
  801ac9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801acc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ad0:	79 89                	jns    801a5b <vprintfmt+0x6d>
  801ad2:	e9 77 ff ff ff       	jmp    801a4e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801ad7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ada:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801adc:	e9 7a ff ff ff       	jmp    801a5b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae4:	8d 50 04             	lea    0x4(%eax),%edx
  801ae7:	89 55 14             	mov    %edx,0x14(%ebp)
  801aea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aee:	8b 00                	mov    (%eax),%eax
  801af0:	89 04 24             	mov    %eax,(%esp)
  801af3:	ff 55 08             	call   *0x8(%ebp)
			break;
  801af6:	e9 18 ff ff ff       	jmp    801a13 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801afb:	8b 45 14             	mov    0x14(%ebp),%eax
  801afe:	8d 50 04             	lea    0x4(%eax),%edx
  801b01:	89 55 14             	mov    %edx,0x14(%ebp)
  801b04:	8b 00                	mov    (%eax),%eax
  801b06:	99                   	cltd   
  801b07:	31 d0                	xor    %edx,%eax
  801b09:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801b0b:	83 f8 0f             	cmp    $0xf,%eax
  801b0e:	7f 0b                	jg     801b1b <vprintfmt+0x12d>
  801b10:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  801b17:	85 d2                	test   %edx,%edx
  801b19:	75 20                	jne    801b3b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  801b1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b1f:	c7 44 24 08 87 27 80 	movl   $0x802787,0x8(%esp)
  801b26:	00 
  801b27:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 90 fe ff ff       	call   8019c6 <printfmt>
  801b36:	e9 d8 fe ff ff       	jmp    801a13 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801b3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b3f:	c7 44 24 08 cd 26 80 	movl   $0x8026cd,0x8(%esp)
  801b46:	00 
  801b47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 70 fe ff ff       	call   8019c6 <printfmt>
  801b56:	e9 b8 fe ff ff       	jmp    801a13 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b5b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b61:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b64:	8b 45 14             	mov    0x14(%ebp),%eax
  801b67:	8d 50 04             	lea    0x4(%eax),%edx
  801b6a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b6d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801b6f:	85 f6                	test   %esi,%esi
  801b71:	b8 80 27 80 00       	mov    $0x802780,%eax
  801b76:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801b79:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801b7d:	0f 84 97 00 00 00    	je     801c1a <vprintfmt+0x22c>
  801b83:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801b87:	0f 8e 9b 00 00 00    	jle    801c28 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b8d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b91:	89 34 24             	mov    %esi,(%esp)
  801b94:	e8 cf 02 00 00       	call   801e68 <strnlen>
  801b99:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801b9c:	29 c2                	sub    %eax,%edx
  801b9e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  801ba1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801ba5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ba8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801bab:	8b 75 08             	mov    0x8(%ebp),%esi
  801bae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801bb1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bb3:	eb 0f                	jmp    801bc4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801bb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bc1:	83 eb 01             	sub    $0x1,%ebx
  801bc4:	85 db                	test   %ebx,%ebx
  801bc6:	7f ed                	jg     801bb5 <vprintfmt+0x1c7>
  801bc8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801bcb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bce:	85 d2                	test   %edx,%edx
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd5:	0f 49 c2             	cmovns %edx,%eax
  801bd8:	29 c2                	sub    %eax,%edx
  801bda:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801bdd:	89 d7                	mov    %edx,%edi
  801bdf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801be2:	eb 50                	jmp    801c34 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801be4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801be8:	74 1e                	je     801c08 <vprintfmt+0x21a>
  801bea:	0f be d2             	movsbl %dl,%edx
  801bed:	83 ea 20             	sub    $0x20,%edx
  801bf0:	83 fa 5e             	cmp    $0x5e,%edx
  801bf3:	76 13                	jbe    801c08 <vprintfmt+0x21a>
					putch('?', putdat);
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801c03:	ff 55 08             	call   *0x8(%ebp)
  801c06:	eb 0d                	jmp    801c15 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801c08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c0f:	89 04 24             	mov    %eax,(%esp)
  801c12:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801c15:	83 ef 01             	sub    $0x1,%edi
  801c18:	eb 1a                	jmp    801c34 <vprintfmt+0x246>
  801c1a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c1d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c20:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c26:	eb 0c                	jmp    801c34 <vprintfmt+0x246>
  801c28:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c2b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c2e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c34:	83 c6 01             	add    $0x1,%esi
  801c37:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801c3b:	0f be c2             	movsbl %dl,%eax
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	74 27                	je     801c69 <vprintfmt+0x27b>
  801c42:	85 db                	test   %ebx,%ebx
  801c44:	78 9e                	js     801be4 <vprintfmt+0x1f6>
  801c46:	83 eb 01             	sub    $0x1,%ebx
  801c49:	79 99                	jns    801be4 <vprintfmt+0x1f6>
  801c4b:	89 f8                	mov    %edi,%eax
  801c4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	eb 1a                	jmp    801c71 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801c62:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c64:	83 eb 01             	sub    $0x1,%ebx
  801c67:	eb 08                	jmp    801c71 <vprintfmt+0x283>
  801c69:	89 fb                	mov    %edi,%ebx
  801c6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c71:	85 db                	test   %ebx,%ebx
  801c73:	7f e2                	jg     801c57 <vprintfmt+0x269>
  801c75:	89 75 08             	mov    %esi,0x8(%ebp)
  801c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c7b:	e9 93 fd ff ff       	jmp    801a13 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801c80:	83 fa 01             	cmp    $0x1,%edx
  801c83:	7e 16                	jle    801c9b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  801c85:	8b 45 14             	mov    0x14(%ebp),%eax
  801c88:	8d 50 08             	lea    0x8(%eax),%edx
  801c8b:	89 55 14             	mov    %edx,0x14(%ebp)
  801c8e:	8b 50 04             	mov    0x4(%eax),%edx
  801c91:	8b 00                	mov    (%eax),%eax
  801c93:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c99:	eb 32                	jmp    801ccd <vprintfmt+0x2df>
	else if (lflag)
  801c9b:	85 d2                	test   %edx,%edx
  801c9d:	74 18                	je     801cb7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  801c9f:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca2:	8d 50 04             	lea    0x4(%eax),%edx
  801ca5:	89 55 14             	mov    %edx,0x14(%ebp)
  801ca8:	8b 30                	mov    (%eax),%esi
  801caa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801cad:	89 f0                	mov    %esi,%eax
  801caf:	c1 f8 1f             	sar    $0x1f,%eax
  801cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cb5:	eb 16                	jmp    801ccd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  801cb7:	8b 45 14             	mov    0x14(%ebp),%eax
  801cba:	8d 50 04             	lea    0x4(%eax),%edx
  801cbd:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc0:	8b 30                	mov    (%eax),%esi
  801cc2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801cc5:	89 f0                	mov    %esi,%eax
  801cc7:	c1 f8 1f             	sar    $0x1f,%eax
  801cca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ccd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801cd3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801cd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801cdc:	0f 89 80 00 00 00    	jns    801d62 <vprintfmt+0x374>
				putch('-', putdat);
  801ce2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ce6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801ced:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cf6:	f7 d8                	neg    %eax
  801cf8:	83 d2 00             	adc    $0x0,%edx
  801cfb:	f7 da                	neg    %edx
			}
			base = 10;
  801cfd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801d02:	eb 5e                	jmp    801d62 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801d04:	8d 45 14             	lea    0x14(%ebp),%eax
  801d07:	e8 63 fc ff ff       	call   80196f <getuint>
			base = 10;
  801d0c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801d11:	eb 4f                	jmp    801d62 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801d13:	8d 45 14             	lea    0x14(%ebp),%eax
  801d16:	e8 54 fc ff ff       	call   80196f <getuint>
			base = 8;
  801d1b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801d20:	eb 40                	jmp    801d62 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801d22:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d26:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801d2d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801d30:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d34:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801d3b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801d3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d41:	8d 50 04             	lea    0x4(%eax),%edx
  801d44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801d47:	8b 00                	mov    (%eax),%eax
  801d49:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d53:	eb 0d                	jmp    801d62 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d55:	8d 45 14             	lea    0x14(%ebp),%eax
  801d58:	e8 12 fc ff ff       	call   80196f <getuint>
			base = 16;
  801d5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d62:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801d66:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d6a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801d6d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d71:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d7c:	89 fa                	mov    %edi,%edx
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	e8 fa fa ff ff       	call   801880 <printnum>
			break;
  801d86:	e9 88 fc ff ff       	jmp    801a13 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d8f:	89 04 24             	mov    %eax,(%esp)
  801d92:	ff 55 08             	call   *0x8(%ebp)
			break;
  801d95:	e9 79 fc ff ff       	jmp    801a13 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801d9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801da5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801da8:	89 f3                	mov    %esi,%ebx
  801daa:	eb 03                	jmp    801daf <vprintfmt+0x3c1>
  801dac:	83 eb 01             	sub    $0x1,%ebx
  801daf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801db3:	75 f7                	jne    801dac <vprintfmt+0x3be>
  801db5:	e9 59 fc ff ff       	jmp    801a13 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801dba:	83 c4 3c             	add    $0x3c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 28             	sub    $0x28,%esp
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801dd1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801dd5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801dd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	74 30                	je     801e13 <vsnprintf+0x51>
  801de3:	85 d2                	test   %edx,%edx
  801de5:	7e 2c                	jle    801e13 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801de7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dee:	8b 45 10             	mov    0x10(%ebp),%eax
  801df1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801df8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfc:	c7 04 24 a9 19 80 00 	movl   $0x8019a9,(%esp)
  801e03:	e8 e6 fb ff ff       	call   8019ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801e08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	eb 05                	jmp    801e18 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801e13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801e20:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801e23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e27:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	89 04 24             	mov    %eax,(%esp)
  801e3b:	e8 82 ff ff ff       	call   801dc2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801e56:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5b:	eb 03                	jmp    801e60 <strlen+0x10>
		n++;
  801e5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801e60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801e64:	75 f7                	jne    801e5d <strlen+0xd>
		n++;
	return n;
}
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	eb 03                	jmp    801e7b <strnlen+0x13>
		n++;
  801e78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e7b:	39 d0                	cmp    %edx,%eax
  801e7d:	74 06                	je     801e85 <strnlen+0x1d>
  801e7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801e83:	75 f3                	jne    801e78 <strnlen+0x10>
		n++;
	return n;
}
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801e91:	89 c2                	mov    %eax,%edx
  801e93:	83 c2 01             	add    $0x1,%edx
  801e96:	83 c1 01             	add    $0x1,%ecx
  801e99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801e9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ea0:	84 db                	test   %bl,%bl
  801ea2:	75 ef                	jne    801e93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ea4:	5b                   	pop    %ebx
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 08             	sub    $0x8,%esp
  801eae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801eb1:	89 1c 24             	mov    %ebx,(%esp)
  801eb4:	e8 97 ff ff ff       	call   801e50 <strlen>
	strcpy(dst + len, src);
  801eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec0:	01 d8                	add    %ebx,%eax
  801ec2:	89 04 24             	mov    %eax,(%esp)
  801ec5:	e8 bd ff ff ff       	call   801e87 <strcpy>
	return dst;
}
  801eca:	89 d8                	mov    %ebx,%eax
  801ecc:	83 c4 08             	add    $0x8,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801edd:	89 f3                	mov    %esi,%ebx
  801edf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ee2:	89 f2                	mov    %esi,%edx
  801ee4:	eb 0f                	jmp    801ef5 <strncpy+0x23>
		*dst++ = *src;
  801ee6:	83 c2 01             	add    $0x1,%edx
  801ee9:	0f b6 01             	movzbl (%ecx),%eax
  801eec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801eef:	80 39 01             	cmpb   $0x1,(%ecx)
  801ef2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ef5:	39 da                	cmp    %ebx,%edx
  801ef7:	75 ed                	jne    801ee6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	8b 75 08             	mov    0x8(%ebp),%esi
  801f07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801f13:	85 c9                	test   %ecx,%ecx
  801f15:	75 0b                	jne    801f22 <strlcpy+0x23>
  801f17:	eb 1d                	jmp    801f36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801f19:	83 c0 01             	add    $0x1,%eax
  801f1c:	83 c2 01             	add    $0x1,%edx
  801f1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801f22:	39 d8                	cmp    %ebx,%eax
  801f24:	74 0b                	je     801f31 <strlcpy+0x32>
  801f26:	0f b6 0a             	movzbl (%edx),%ecx
  801f29:	84 c9                	test   %cl,%cl
  801f2b:	75 ec                	jne    801f19 <strlcpy+0x1a>
  801f2d:	89 c2                	mov    %eax,%edx
  801f2f:	eb 02                	jmp    801f33 <strlcpy+0x34>
  801f31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801f33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801f36:	29 f0                	sub    %esi,%eax
}
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801f45:	eb 06                	jmp    801f4d <strcmp+0x11>
		p++, q++;
  801f47:	83 c1 01             	add    $0x1,%ecx
  801f4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801f4d:	0f b6 01             	movzbl (%ecx),%eax
  801f50:	84 c0                	test   %al,%al
  801f52:	74 04                	je     801f58 <strcmp+0x1c>
  801f54:	3a 02                	cmp    (%edx),%al
  801f56:	74 ef                	je     801f47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801f58:	0f b6 c0             	movzbl %al,%eax
  801f5b:	0f b6 12             	movzbl (%edx),%edx
  801f5e:	29 d0                	sub    %edx,%eax
}
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	53                   	push   %ebx
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801f71:	eb 06                	jmp    801f79 <strncmp+0x17>
		n--, p++, q++;
  801f73:	83 c0 01             	add    $0x1,%eax
  801f76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801f79:	39 d8                	cmp    %ebx,%eax
  801f7b:	74 15                	je     801f92 <strncmp+0x30>
  801f7d:	0f b6 08             	movzbl (%eax),%ecx
  801f80:	84 c9                	test   %cl,%cl
  801f82:	74 04                	je     801f88 <strncmp+0x26>
  801f84:	3a 0a                	cmp    (%edx),%cl
  801f86:	74 eb                	je     801f73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801f88:	0f b6 00             	movzbl (%eax),%eax
  801f8b:	0f b6 12             	movzbl (%edx),%edx
  801f8e:	29 d0                	sub    %edx,%eax
  801f90:	eb 05                	jmp    801f97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801f97:	5b                   	pop    %ebx
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fa4:	eb 07                	jmp    801fad <strchr+0x13>
		if (*s == c)
  801fa6:	38 ca                	cmp    %cl,%dl
  801fa8:	74 0f                	je     801fb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801faa:	83 c0 01             	add    $0x1,%eax
  801fad:	0f b6 10             	movzbl (%eax),%edx
  801fb0:	84 d2                	test   %dl,%dl
  801fb2:	75 f2                	jne    801fa6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fc5:	eb 07                	jmp    801fce <strfind+0x13>
		if (*s == c)
  801fc7:	38 ca                	cmp    %cl,%dl
  801fc9:	74 0a                	je     801fd5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801fcb:	83 c0 01             	add    $0x1,%eax
  801fce:	0f b6 10             	movzbl (%eax),%edx
  801fd1:	84 d2                	test   %dl,%dl
  801fd3:	75 f2                	jne    801fc7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	57                   	push   %edi
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801fe3:	85 c9                	test   %ecx,%ecx
  801fe5:	74 36                	je     80201d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801fe7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801fed:	75 28                	jne    802017 <memset+0x40>
  801fef:	f6 c1 03             	test   $0x3,%cl
  801ff2:	75 23                	jne    802017 <memset+0x40>
		c &= 0xFF;
  801ff4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ff8:	89 d3                	mov    %edx,%ebx
  801ffa:	c1 e3 08             	shl    $0x8,%ebx
  801ffd:	89 d6                	mov    %edx,%esi
  801fff:	c1 e6 18             	shl    $0x18,%esi
  802002:	89 d0                	mov    %edx,%eax
  802004:	c1 e0 10             	shl    $0x10,%eax
  802007:	09 f0                	or     %esi,%eax
  802009:	09 c2                	or     %eax,%edx
  80200b:	89 d0                	mov    %edx,%eax
  80200d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80200f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802012:	fc                   	cld    
  802013:	f3 ab                	rep stos %eax,%es:(%edi)
  802015:	eb 06                	jmp    80201d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	fc                   	cld    
  80201b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80201d:	89 f8                	mov    %edi,%eax
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802032:	39 c6                	cmp    %eax,%esi
  802034:	73 35                	jae    80206b <memmove+0x47>
  802036:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802039:	39 d0                	cmp    %edx,%eax
  80203b:	73 2e                	jae    80206b <memmove+0x47>
		s += n;
		d += n;
  80203d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802040:	89 d6                	mov    %edx,%esi
  802042:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802044:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80204a:	75 13                	jne    80205f <memmove+0x3b>
  80204c:	f6 c1 03             	test   $0x3,%cl
  80204f:	75 0e                	jne    80205f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802051:	83 ef 04             	sub    $0x4,%edi
  802054:	8d 72 fc             	lea    -0x4(%edx),%esi
  802057:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80205a:	fd                   	std    
  80205b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80205d:	eb 09                	jmp    802068 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80205f:	83 ef 01             	sub    $0x1,%edi
  802062:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802065:	fd                   	std    
  802066:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802068:	fc                   	cld    
  802069:	eb 1d                	jmp    802088 <memmove+0x64>
  80206b:	89 f2                	mov    %esi,%edx
  80206d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80206f:	f6 c2 03             	test   $0x3,%dl
  802072:	75 0f                	jne    802083 <memmove+0x5f>
  802074:	f6 c1 03             	test   $0x3,%cl
  802077:	75 0a                	jne    802083 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802079:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80207c:	89 c7                	mov    %eax,%edi
  80207e:	fc                   	cld    
  80207f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802081:	eb 05                	jmp    802088 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802083:	89 c7                	mov    %eax,%edi
  802085:	fc                   	cld    
  802086:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802092:	8b 45 10             	mov    0x10(%ebp),%eax
  802095:	89 44 24 08          	mov    %eax,0x8(%esp)
  802099:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	89 04 24             	mov    %eax,(%esp)
  8020a6:	e8 79 ff ff ff       	call   802024 <memmove>
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    

008020ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8020b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b8:	89 d6                	mov    %edx,%esi
  8020ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020bd:	eb 1a                	jmp    8020d9 <memcmp+0x2c>
		if (*s1 != *s2)
  8020bf:	0f b6 02             	movzbl (%edx),%eax
  8020c2:	0f b6 19             	movzbl (%ecx),%ebx
  8020c5:	38 d8                	cmp    %bl,%al
  8020c7:	74 0a                	je     8020d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8020c9:	0f b6 c0             	movzbl %al,%eax
  8020cc:	0f b6 db             	movzbl %bl,%ebx
  8020cf:	29 d8                	sub    %ebx,%eax
  8020d1:	eb 0f                	jmp    8020e2 <memcmp+0x35>
		s1++, s2++;
  8020d3:	83 c2 01             	add    $0x1,%edx
  8020d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020d9:	39 f2                	cmp    %esi,%edx
  8020db:	75 e2                	jne    8020bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e2:	5b                   	pop    %ebx
  8020e3:	5e                   	pop    %esi
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8020ef:	89 c2                	mov    %eax,%edx
  8020f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8020f4:	eb 07                	jmp    8020fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8020f6:	38 08                	cmp    %cl,(%eax)
  8020f8:	74 07                	je     802101 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8020fa:	83 c0 01             	add    $0x1,%eax
  8020fd:	39 d0                	cmp    %edx,%eax
  8020ff:	72 f5                	jb     8020f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	57                   	push   %edi
  802107:	56                   	push   %esi
  802108:	53                   	push   %ebx
  802109:	8b 55 08             	mov    0x8(%ebp),%edx
  80210c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80210f:	eb 03                	jmp    802114 <strtol+0x11>
		s++;
  802111:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802114:	0f b6 0a             	movzbl (%edx),%ecx
  802117:	80 f9 09             	cmp    $0x9,%cl
  80211a:	74 f5                	je     802111 <strtol+0xe>
  80211c:	80 f9 20             	cmp    $0x20,%cl
  80211f:	74 f0                	je     802111 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802121:	80 f9 2b             	cmp    $0x2b,%cl
  802124:	75 0a                	jne    802130 <strtol+0x2d>
		s++;
  802126:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802129:	bf 00 00 00 00       	mov    $0x0,%edi
  80212e:	eb 11                	jmp    802141 <strtol+0x3e>
  802130:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802135:	80 f9 2d             	cmp    $0x2d,%cl
  802138:	75 07                	jne    802141 <strtol+0x3e>
		s++, neg = 1;
  80213a:	8d 52 01             	lea    0x1(%edx),%edx
  80213d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802141:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802146:	75 15                	jne    80215d <strtol+0x5a>
  802148:	80 3a 30             	cmpb   $0x30,(%edx)
  80214b:	75 10                	jne    80215d <strtol+0x5a>
  80214d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802151:	75 0a                	jne    80215d <strtol+0x5a>
		s += 2, base = 16;
  802153:	83 c2 02             	add    $0x2,%edx
  802156:	b8 10 00 00 00       	mov    $0x10,%eax
  80215b:	eb 10                	jmp    80216d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80215d:	85 c0                	test   %eax,%eax
  80215f:	75 0c                	jne    80216d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802161:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802163:	80 3a 30             	cmpb   $0x30,(%edx)
  802166:	75 05                	jne    80216d <strtol+0x6a>
		s++, base = 8;
  802168:	83 c2 01             	add    $0x1,%edx
  80216b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80216d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802172:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802175:	0f b6 0a             	movzbl (%edx),%ecx
  802178:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80217b:	89 f0                	mov    %esi,%eax
  80217d:	3c 09                	cmp    $0x9,%al
  80217f:	77 08                	ja     802189 <strtol+0x86>
			dig = *s - '0';
  802181:	0f be c9             	movsbl %cl,%ecx
  802184:	83 e9 30             	sub    $0x30,%ecx
  802187:	eb 20                	jmp    8021a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  802189:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80218c:	89 f0                	mov    %esi,%eax
  80218e:	3c 19                	cmp    $0x19,%al
  802190:	77 08                	ja     80219a <strtol+0x97>
			dig = *s - 'a' + 10;
  802192:	0f be c9             	movsbl %cl,%ecx
  802195:	83 e9 57             	sub    $0x57,%ecx
  802198:	eb 0f                	jmp    8021a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80219a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80219d:	89 f0                	mov    %esi,%eax
  80219f:	3c 19                	cmp    $0x19,%al
  8021a1:	77 16                	ja     8021b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8021a3:	0f be c9             	movsbl %cl,%ecx
  8021a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8021a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8021ac:	7d 0f                	jge    8021bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8021ae:	83 c2 01             	add    $0x1,%edx
  8021b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8021b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8021b7:	eb bc                	jmp    802175 <strtol+0x72>
  8021b9:	89 d8                	mov    %ebx,%eax
  8021bb:	eb 02                	jmp    8021bf <strtol+0xbc>
  8021bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8021bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021c3:	74 05                	je     8021ca <strtol+0xc7>
		*endptr = (char *) s;
  8021c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8021ca:	f7 d8                	neg    %eax
  8021cc:	85 ff                	test   %edi,%edi
  8021ce:	0f 44 c3             	cmove  %ebx,%eax
}
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	56                   	push   %esi
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 10             	sub    $0x10,%esp
  8021e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021f8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 91 e1 ff ff       	call   800394 <sys_ipc_recv>

	if(ret < 0) {
  802203:	85 c0                	test   %eax,%eax
  802205:	79 16                	jns    80221d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802207:	85 f6                	test   %esi,%esi
  802209:	74 06                	je     802211 <ipc_recv+0x31>
  80220b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802211:	85 db                	test   %ebx,%ebx
  802213:	74 3e                	je     802253 <ipc_recv+0x73>
  802215:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80221b:	eb 36                	jmp    802253 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80221d:	e8 1e df ff ff       	call   800140 <sys_getenvid>
  802222:	25 ff 03 00 00       	and    $0x3ff,%eax
  802227:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80222a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80222f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802234:	85 f6                	test   %esi,%esi
  802236:	74 05                	je     80223d <ipc_recv+0x5d>
  802238:	8b 40 74             	mov    0x74(%eax),%eax
  80223b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80223d:	85 db                	test   %ebx,%ebx
  80223f:	74 0a                	je     80224b <ipc_recv+0x6b>
  802241:	a1 08 40 80 00       	mov    0x804008,%eax
  802246:	8b 40 78             	mov    0x78(%eax),%eax
  802249:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80224b:	a1 08 40 80 00       	mov    0x804008,%eax
  802250:	8b 40 70             	mov    0x70(%eax),%eax
}
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	5b                   	pop    %ebx
  802257:	5e                   	pop    %esi
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    

0080225a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	57                   	push   %edi
  80225e:	56                   	push   %esi
  80225f:	53                   	push   %ebx
  802260:	83 ec 1c             	sub    $0x1c,%esp
  802263:	8b 7d 08             	mov    0x8(%ebp),%edi
  802266:	8b 75 0c             	mov    0xc(%ebp),%esi
  802269:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80226c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80226e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802273:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802276:	8b 45 14             	mov    0x14(%ebp),%eax
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802281:	89 74 24 04          	mov    %esi,0x4(%esp)
  802285:	89 3c 24             	mov    %edi,(%esp)
  802288:	e8 e4 e0 ff ff       	call   800371 <sys_ipc_try_send>

		if(ret >= 0) break;
  80228d:	85 c0                	test   %eax,%eax
  80228f:	79 2c                	jns    8022bd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802291:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802294:	74 20                	je     8022b6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802296:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229a:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  8022a1:	00 
  8022a2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8022a9:	00 
  8022aa:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  8022b1:	e8 b0 f4 ff ff       	call   801766 <_panic>
		}
		sys_yield();
  8022b6:	e8 a4 de ff ff       	call   80015f <sys_yield>
	}
  8022bb:	eb b9                	jmp    802276 <ipc_send+0x1c>
}
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022cb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022d0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022d9:	8b 52 50             	mov    0x50(%edx),%edx
  8022dc:	39 ca                	cmp    %ecx,%edx
  8022de:	75 0d                	jne    8022ed <ipc_find_env+0x28>
			return envs[i].env_id;
  8022e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022e3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022e8:	8b 40 40             	mov    0x40(%eax),%eax
  8022eb:	eb 0e                	jmp    8022fb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ed:	83 c0 01             	add    $0x1,%eax
  8022f0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f5:	75 d9                	jne    8022d0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022f7:	66 b8 00 00          	mov    $0x0,%ax
}
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    

008022fd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802303:	89 d0                	mov    %edx,%eax
  802305:	c1 e8 16             	shr    $0x16,%eax
  802308:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802314:	f6 c1 01             	test   $0x1,%cl
  802317:	74 1d                	je     802336 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802319:	c1 ea 0c             	shr    $0xc,%edx
  80231c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802323:	f6 c2 01             	test   $0x1,%dl
  802326:	74 0e                	je     802336 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802328:	c1 ea 0c             	shr    $0xc,%edx
  80232b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802332:	ef 
  802333:	0f b7 c0             	movzwl %ax,%eax
}
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	83 ec 0c             	sub    $0xc,%esp
  802346:	8b 44 24 28          	mov    0x28(%esp),%eax
  80234a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80234e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802352:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802356:	85 c0                	test   %eax,%eax
  802358:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80235c:	89 ea                	mov    %ebp,%edx
  80235e:	89 0c 24             	mov    %ecx,(%esp)
  802361:	75 2d                	jne    802390 <__udivdi3+0x50>
  802363:	39 e9                	cmp    %ebp,%ecx
  802365:	77 61                	ja     8023c8 <__udivdi3+0x88>
  802367:	85 c9                	test   %ecx,%ecx
  802369:	89 ce                	mov    %ecx,%esi
  80236b:	75 0b                	jne    802378 <__udivdi3+0x38>
  80236d:	b8 01 00 00 00       	mov    $0x1,%eax
  802372:	31 d2                	xor    %edx,%edx
  802374:	f7 f1                	div    %ecx
  802376:	89 c6                	mov    %eax,%esi
  802378:	31 d2                	xor    %edx,%edx
  80237a:	89 e8                	mov    %ebp,%eax
  80237c:	f7 f6                	div    %esi
  80237e:	89 c5                	mov    %eax,%ebp
  802380:	89 f8                	mov    %edi,%eax
  802382:	f7 f6                	div    %esi
  802384:	89 ea                	mov    %ebp,%edx
  802386:	83 c4 0c             	add    $0xc,%esp
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	39 e8                	cmp    %ebp,%eax
  802392:	77 24                	ja     8023b8 <__udivdi3+0x78>
  802394:	0f bd e8             	bsr    %eax,%ebp
  802397:	83 f5 1f             	xor    $0x1f,%ebp
  80239a:	75 3c                	jne    8023d8 <__udivdi3+0x98>
  80239c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023a0:	39 34 24             	cmp    %esi,(%esp)
  8023a3:	0f 86 9f 00 00 00    	jbe    802448 <__udivdi3+0x108>
  8023a9:	39 d0                	cmp    %edx,%eax
  8023ab:	0f 82 97 00 00 00    	jb     802448 <__udivdi3+0x108>
  8023b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	31 c0                	xor    %eax,%eax
  8023bc:	83 c4 0c             	add    $0xc,%esp
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
  8023c3:	90                   	nop
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	89 f8                	mov    %edi,%eax
  8023ca:	f7 f1                	div    %ecx
  8023cc:	31 d2                	xor    %edx,%edx
  8023ce:	83 c4 0c             	add    $0xc,%esp
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	8b 3c 24             	mov    (%esp),%edi
  8023dd:	d3 e0                	shl    %cl,%eax
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e6:	29 e8                	sub    %ebp,%eax
  8023e8:	89 c1                	mov    %eax,%ecx
  8023ea:	d3 ef                	shr    %cl,%edi
  8023ec:	89 e9                	mov    %ebp,%ecx
  8023ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023f2:	8b 3c 24             	mov    (%esp),%edi
  8023f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023f9:	89 d6                	mov    %edx,%esi
  8023fb:	d3 e7                	shl    %cl,%edi
  8023fd:	89 c1                	mov    %eax,%ecx
  8023ff:	89 3c 24             	mov    %edi,(%esp)
  802402:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802406:	d3 ee                	shr    %cl,%esi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	d3 e2                	shl    %cl,%edx
  80240c:	89 c1                	mov    %eax,%ecx
  80240e:	d3 ef                	shr    %cl,%edi
  802410:	09 d7                	or     %edx,%edi
  802412:	89 f2                	mov    %esi,%edx
  802414:	89 f8                	mov    %edi,%eax
  802416:	f7 74 24 08          	divl   0x8(%esp)
  80241a:	89 d6                	mov    %edx,%esi
  80241c:	89 c7                	mov    %eax,%edi
  80241e:	f7 24 24             	mull   (%esp)
  802421:	39 d6                	cmp    %edx,%esi
  802423:	89 14 24             	mov    %edx,(%esp)
  802426:	72 30                	jb     802458 <__udivdi3+0x118>
  802428:	8b 54 24 04          	mov    0x4(%esp),%edx
  80242c:	89 e9                	mov    %ebp,%ecx
  80242e:	d3 e2                	shl    %cl,%edx
  802430:	39 c2                	cmp    %eax,%edx
  802432:	73 05                	jae    802439 <__udivdi3+0xf9>
  802434:	3b 34 24             	cmp    (%esp),%esi
  802437:	74 1f                	je     802458 <__udivdi3+0x118>
  802439:	89 f8                	mov    %edi,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	e9 7a ff ff ff       	jmp    8023bc <__udivdi3+0x7c>
  802442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802448:	31 d2                	xor    %edx,%edx
  80244a:	b8 01 00 00 00       	mov    $0x1,%eax
  80244f:	e9 68 ff ff ff       	jmp    8023bc <__udivdi3+0x7c>
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	8d 47 ff             	lea    -0x1(%edi),%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	83 c4 0c             	add    $0xc,%esp
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	83 ec 14             	sub    $0x14,%esp
  802476:	8b 44 24 28          	mov    0x28(%esp),%eax
  80247a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80247e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802482:	89 c7                	mov    %eax,%edi
  802484:	89 44 24 04          	mov    %eax,0x4(%esp)
  802488:	8b 44 24 30          	mov    0x30(%esp),%eax
  80248c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802490:	89 34 24             	mov    %esi,(%esp)
  802493:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802497:	85 c0                	test   %eax,%eax
  802499:	89 c2                	mov    %eax,%edx
  80249b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80249f:	75 17                	jne    8024b8 <__umoddi3+0x48>
  8024a1:	39 fe                	cmp    %edi,%esi
  8024a3:	76 4b                	jbe    8024f0 <__umoddi3+0x80>
  8024a5:	89 c8                	mov    %ecx,%eax
  8024a7:	89 fa                	mov    %edi,%edx
  8024a9:	f7 f6                	div    %esi
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	31 d2                	xor    %edx,%edx
  8024af:	83 c4 14             	add    $0x14,%esp
  8024b2:	5e                   	pop    %esi
  8024b3:	5f                   	pop    %edi
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	39 f8                	cmp    %edi,%eax
  8024ba:	77 54                	ja     802510 <__umoddi3+0xa0>
  8024bc:	0f bd e8             	bsr    %eax,%ebp
  8024bf:	83 f5 1f             	xor    $0x1f,%ebp
  8024c2:	75 5c                	jne    802520 <__umoddi3+0xb0>
  8024c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024c8:	39 3c 24             	cmp    %edi,(%esp)
  8024cb:	0f 87 e7 00 00 00    	ja     8025b8 <__umoddi3+0x148>
  8024d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024d5:	29 f1                	sub    %esi,%ecx
  8024d7:	19 c7                	sbb    %eax,%edi
  8024d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024e9:	83 c4 14             	add    $0x14,%esp
  8024ec:	5e                   	pop    %esi
  8024ed:	5f                   	pop    %edi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    
  8024f0:	85 f6                	test   %esi,%esi
  8024f2:	89 f5                	mov    %esi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f6                	div    %esi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	8b 44 24 04          	mov    0x4(%esp),%eax
  802505:	31 d2                	xor    %edx,%edx
  802507:	f7 f5                	div    %ebp
  802509:	89 c8                	mov    %ecx,%eax
  80250b:	f7 f5                	div    %ebp
  80250d:	eb 9c                	jmp    8024ab <__umoddi3+0x3b>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 fa                	mov    %edi,%edx
  802514:	83 c4 14             	add    $0x14,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 04 24             	mov    (%esp),%eax
  802523:	be 20 00 00 00       	mov    $0x20,%esi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ee                	sub    %ebp,%esi
  80252c:	d3 e2                	shl    %cl,%edx
  80252e:	89 f1                	mov    %esi,%ecx
  802530:	d3 e8                	shr    %cl,%eax
  802532:	89 e9                	mov    %ebp,%ecx
  802534:	89 44 24 04          	mov    %eax,0x4(%esp)
  802538:	8b 04 24             	mov    (%esp),%eax
  80253b:	09 54 24 04          	or     %edx,0x4(%esp)
  80253f:	89 fa                	mov    %edi,%edx
  802541:	d3 e0                	shl    %cl,%eax
  802543:	89 f1                	mov    %esi,%ecx
  802545:	89 44 24 08          	mov    %eax,0x8(%esp)
  802549:	8b 44 24 10          	mov    0x10(%esp),%eax
  80254d:	d3 ea                	shr    %cl,%edx
  80254f:	89 e9                	mov    %ebp,%ecx
  802551:	d3 e7                	shl    %cl,%edi
  802553:	89 f1                	mov    %esi,%ecx
  802555:	d3 e8                	shr    %cl,%eax
  802557:	89 e9                	mov    %ebp,%ecx
  802559:	09 f8                	or     %edi,%eax
  80255b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80255f:	f7 74 24 04          	divl   0x4(%esp)
  802563:	d3 e7                	shl    %cl,%edi
  802565:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802569:	89 d7                	mov    %edx,%edi
  80256b:	f7 64 24 08          	mull   0x8(%esp)
  80256f:	39 d7                	cmp    %edx,%edi
  802571:	89 c1                	mov    %eax,%ecx
  802573:	89 14 24             	mov    %edx,(%esp)
  802576:	72 2c                	jb     8025a4 <__umoddi3+0x134>
  802578:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80257c:	72 22                	jb     8025a0 <__umoddi3+0x130>
  80257e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802582:	29 c8                	sub    %ecx,%eax
  802584:	19 d7                	sbb    %edx,%edi
  802586:	89 e9                	mov    %ebp,%ecx
  802588:	89 fa                	mov    %edi,%edx
  80258a:	d3 e8                	shr    %cl,%eax
  80258c:	89 f1                	mov    %esi,%ecx
  80258e:	d3 e2                	shl    %cl,%edx
  802590:	89 e9                	mov    %ebp,%ecx
  802592:	d3 ef                	shr    %cl,%edi
  802594:	09 d0                	or     %edx,%eax
  802596:	89 fa                	mov    %edi,%edx
  802598:	83 c4 14             	add    $0x14,%esp
  80259b:	5e                   	pop    %esi
  80259c:	5f                   	pop    %edi
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    
  80259f:	90                   	nop
  8025a0:	39 d7                	cmp    %edx,%edi
  8025a2:	75 da                	jne    80257e <__umoddi3+0x10e>
  8025a4:	8b 14 24             	mov    (%esp),%edx
  8025a7:	89 c1                	mov    %eax,%ecx
  8025a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025b1:	eb cb                	jmp    80257e <__umoddi3+0x10e>
  8025b3:	90                   	nop
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025bc:	0f 82 0f ff ff ff    	jb     8024d1 <__umoddi3+0x61>
  8025c2:	e9 1a ff ff ff       	jmp    8024e1 <__umoddi3+0x71>
