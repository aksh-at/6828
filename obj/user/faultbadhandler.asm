
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 4e 01 00 00       	call   8001a3 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800055:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005c:	de 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 da 02 00 00       	call   800343 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	83 ec 10             	sub    $0x10,%esp
  80007d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800080:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800083:	e8 dd 00 00 00       	call   800165 <sys_getenvid>
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800090:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800095:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 db                	test   %ebx,%ebx
  80009c:	7e 07                	jle    8000a5 <libmain+0x30>
		binaryname = argv[0];
  80009e:	8b 06                	mov    (%esi),%eax
  8000a0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 07 00 00 00       	call   8000bd <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000c3:	e8 e2 05 00 00       	call   8006aa <close_all>
	sys_env_destroy(0);
  8000c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cf:	e8 3f 00 00 00       	call   800113 <sys_env_destroy>
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 c3                	mov    %eax,%ebx
  8000e9:	89 c7                	mov    %eax,%edi
  8000eb:	89 c6                	mov    %eax,%esi
  8000ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	89 d1                	mov    %edx,%ecx
  800106:	89 d3                	mov    %edx,%ebx
  800108:	89 d7                	mov    %edx,%edi
  80010a:	89 d6                	mov    %edx,%esi
  80010c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	b8 03 00 00 00       	mov    $0x3,%eax
  800126:	8b 55 08             	mov    0x8(%ebp),%edx
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 28                	jle    80015d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	89 44 24 10          	mov    %eax,0x10(%esp)
  800139:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800140:	00 
  800141:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800148:	00 
  800149:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800158:	e8 29 16 00 00       	call   801786 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015d:	83 c4 2c             	add    $0x2c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 d3                	mov    %edx,%ebx
  800198:	89 d7                	mov    %edx,%edi
  80019a:	89 d6                	mov    %edx,%esi
  80019c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	be 00 00 00 00       	mov    $0x0,%esi
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	89 f7                	mov    %esi,%edi
  8001c1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	7e 28                	jle    8001ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d2:	00 
  8001d3:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  8001ea:	e8 97 15 00 00       	call   801786 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ef:	83 c4 2c             	add    $0x2c,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800211:	8b 75 18             	mov    0x18(%ebp),%esi
  800214:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 28                	jle    800242 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800225:	00 
  800226:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  80022d:	00 
  80022e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800235:	00 
  800236:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  80023d:	e8 44 15 00 00       	call   801786 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800242:	83 c4 2c             	add    $0x2c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	b8 06 00 00 00       	mov    $0x6,%eax
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7e 28                	jle    800295 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800271:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800278:	00 
  800279:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800280:	00 
  800281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800288:	00 
  800289:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800290:	e8 f1 14 00 00       	call   801786 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800295:	83 c4 2c             	add    $0x2c,%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7e 28                	jle    8002e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002cb:	00 
  8002cc:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  8002d3:	00 
  8002d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002db:	00 
  8002dc:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  8002e3:	e8 9e 14 00 00       	call   801786 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e8:	83 c4 2c             	add    $0x2c,%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	b8 09 00 00 00       	mov    $0x9,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7e 28                	jle    80033b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800313:	89 44 24 10          	mov    %eax,0x10(%esp)
  800317:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80031e:	00 
  80031f:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800326:	00 
  800327:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032e:	00 
  80032f:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800336:	e8 4b 14 00 00       	call   801786 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80033b:	83 c4 2c             	add    $0x2c,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800351:	b8 0a 00 00 00       	mov    $0xa,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 df                	mov    %ebx,%edi
  80035e:	89 de                	mov    %ebx,%esi
  800360:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800389:	e8 f8 13 00 00       	call   801786 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038e:	83 c4 2c             	add    $0x2c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	be 00 00 00 00       	mov    $0x0,%esi
  8003a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003b4:	5b                   	pop    %ebx
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cf:	89 cb                	mov    %ecx,%ebx
  8003d1:	89 cf                	mov    %ecx,%edi
  8003d3:	89 ce                	mov    %ecx,%esi
  8003d5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	7e 28                	jle    800403 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003e6:	00 
  8003e7:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  8003ee:	00 
  8003ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f6:	00 
  8003f7:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  8003fe:	e8 83 13 00 00       	call   801786 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800403:	83 c4 2c             	add    $0x2c,%esp
  800406:	5b                   	pop    %ebx
  800407:	5e                   	pop    %esi
  800408:	5f                   	pop    %edi
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	57                   	push   %edi
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	b8 0e 00 00 00       	mov    $0xe,%eax
  80041b:	89 d1                	mov    %edx,%ecx
  80041d:	89 d3                	mov    %edx,%ebx
  80041f:	89 d7                	mov    %edx,%edi
  800421:	89 d6                	mov    %edx,%esi
  800423:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800425:	5b                   	pop    %ebx
  800426:	5e                   	pop    %esi
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800433:	bb 00 00 00 00       	mov    $0x0,%ebx
  800438:	b8 0f 00 00 00       	mov    $0xf,%eax
  80043d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800440:	8b 55 08             	mov    0x8(%ebp),%edx
  800443:	89 df                	mov    %ebx,%edi
  800445:	89 de                	mov    %ebx,%esi
  800447:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800449:	85 c0                	test   %eax,%eax
  80044b:	7e 28                	jle    800475 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80044d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800451:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800458:	00 
  800459:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800460:	00 
  800461:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800468:	00 
  800469:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800470:	e8 11 13 00 00       	call   801786 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800475:	83 c4 2c             	add    $0x2c,%esp
  800478:	5b                   	pop    %ebx
  800479:	5e                   	pop    %esi
  80047a:	5f                   	pop    %edi
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800486:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048b:	b8 10 00 00 00       	mov    $0x10,%eax
  800490:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800493:	8b 55 08             	mov    0x8(%ebp),%edx
  800496:	89 df                	mov    %ebx,%edi
  800498:	89 de                	mov    %ebx,%esi
  80049a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	7e 28                	jle    8004c8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004ab:	00 
  8004ac:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004bb:	00 
  8004bc:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  8004c3:	e8 be 12 00 00       	call   801786 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8004c8:	83 c4 2c             	add    $0x2c,%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5e                   	pop    %esi
  8004cd:	5f                   	pop    %edi
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004db:	c1 e8 0c             	shr    $0xc,%eax
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8004eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8004f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800502:	89 c2                	mov    %eax,%edx
  800504:	c1 ea 16             	shr    $0x16,%edx
  800507:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80050e:	f6 c2 01             	test   $0x1,%dl
  800511:	74 11                	je     800524 <fd_alloc+0x2d>
  800513:	89 c2                	mov    %eax,%edx
  800515:	c1 ea 0c             	shr    $0xc,%edx
  800518:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80051f:	f6 c2 01             	test   $0x1,%dl
  800522:	75 09                	jne    80052d <fd_alloc+0x36>
			*fd_store = fd;
  800524:	89 01                	mov    %eax,(%ecx)
			return 0;
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	eb 17                	jmp    800544 <fd_alloc+0x4d>
  80052d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800532:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800537:	75 c9                	jne    800502 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800539:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80053f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800544:	5d                   	pop    %ebp
  800545:	c3                   	ret    

00800546 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80054c:	83 f8 1f             	cmp    $0x1f,%eax
  80054f:	77 36                	ja     800587 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800551:	c1 e0 0c             	shl    $0xc,%eax
  800554:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800559:	89 c2                	mov    %eax,%edx
  80055b:	c1 ea 16             	shr    $0x16,%edx
  80055e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800565:	f6 c2 01             	test   $0x1,%dl
  800568:	74 24                	je     80058e <fd_lookup+0x48>
  80056a:	89 c2                	mov    %eax,%edx
  80056c:	c1 ea 0c             	shr    $0xc,%edx
  80056f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800576:	f6 c2 01             	test   $0x1,%dl
  800579:	74 1a                	je     800595 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80057b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057e:	89 02                	mov    %eax,(%edx)
	return 0;
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	eb 13                	jmp    80059a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800587:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80058c:	eb 0c                	jmp    80059a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80058e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800593:	eb 05                	jmp    80059a <fd_lookup+0x54>
  800595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80059a:	5d                   	pop    %ebp
  80059b:	c3                   	ret    

0080059c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	83 ec 18             	sub    $0x18,%esp
  8005a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8005a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005aa:	eb 13                	jmp    8005bf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8005ac:	39 08                	cmp    %ecx,(%eax)
  8005ae:	75 0c                	jne    8005bc <dev_lookup+0x20>
			*dev = devtab[i];
  8005b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8005b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ba:	eb 38                	jmp    8005f4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005bc:	83 c2 01             	add    $0x1,%edx
  8005bf:	8b 04 95 b4 26 80 00 	mov    0x8026b4(,%edx,4),%eax
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	75 e2                	jne    8005ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8005cf:	8b 40 48             	mov    0x48(%eax),%eax
  8005d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005da:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  8005e1:	e8 99 12 00 00       	call   80187f <cprintf>
	*dev = 0;
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8005ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
  8005fb:	83 ec 20             	sub    $0x20,%esp
  8005fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800607:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80060b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800611:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	e8 2a ff ff ff       	call   800546 <fd_lookup>
  80061c:	85 c0                	test   %eax,%eax
  80061e:	78 05                	js     800625 <fd_close+0x2f>
	    || fd != fd2)
  800620:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800623:	74 0c                	je     800631 <fd_close+0x3b>
		return (must_exist ? r : 0);
  800625:	84 db                	test   %bl,%bl
  800627:	ba 00 00 00 00       	mov    $0x0,%edx
  80062c:	0f 44 c2             	cmove  %edx,%eax
  80062f:	eb 3f                	jmp    800670 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	8b 06                	mov    (%esi),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	e8 5a ff ff ff       	call   80059c <dev_lookup>
  800642:	89 c3                	mov    %eax,%ebx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 16                	js     80065e <fd_close+0x68>
		if (dev->dev_close)
  800648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80064e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800653:	85 c0                	test   %eax,%eax
  800655:	74 07                	je     80065e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800657:	89 34 24             	mov    %esi,(%esp)
  80065a:	ff d0                	call   *%eax
  80065c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80065e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800669:	e8 dc fb ff ff       	call   80024a <sys_page_unmap>
	return r;
  80066e:	89 d8                	mov    %ebx,%eax
}
  800670:	83 c4 20             	add    $0x20,%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80067d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800680:	89 44 24 04          	mov    %eax,0x4(%esp)
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	89 04 24             	mov    %eax,(%esp)
  80068a:	e8 b7 fe ff ff       	call   800546 <fd_lookup>
  80068f:	89 c2                	mov    %eax,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	78 13                	js     8006a8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800695:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80069c:	00 
  80069d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 4e ff ff ff       	call   8005f6 <fd_close>
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <close_all>:

void
close_all(void)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	53                   	push   %ebx
  8006ae:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8006b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8006b6:	89 1c 24             	mov    %ebx,(%esp)
  8006b9:	e8 b9 ff ff ff       	call   800677 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8006be:	83 c3 01             	add    $0x1,%ebx
  8006c1:	83 fb 20             	cmp    $0x20,%ebx
  8006c4:	75 f0                	jne    8006b6 <close_all+0xc>
		close(i);
}
  8006c6:	83 c4 14             	add    $0x14,%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	57                   	push   %edi
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8006d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 5f fe ff ff       	call   800546 <fd_lookup>
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	0f 88 e1 00 00 00    	js     8007d2 <dup+0x106>
		return r;
	close(newfdnum);
  8006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	e8 7b ff ff ff       	call   800677 <close>

	newfd = INDEX2FD(newfdnum);
  8006fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ff:	c1 e3 0c             	shl    $0xc,%ebx
  800702:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	e8 cd fd ff ff       	call   8004e0 <fd2data>
  800713:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800715:	89 1c 24             	mov    %ebx,(%esp)
  800718:	e8 c3 fd ff ff       	call   8004e0 <fd2data>
  80071d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80071f:	89 f0                	mov    %esi,%eax
  800721:	c1 e8 16             	shr    $0x16,%eax
  800724:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80072b:	a8 01                	test   $0x1,%al
  80072d:	74 43                	je     800772 <dup+0xa6>
  80072f:	89 f0                	mov    %esi,%eax
  800731:	c1 e8 0c             	shr    $0xc,%eax
  800734:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80073b:	f6 c2 01             	test   $0x1,%dl
  80073e:	74 32                	je     800772 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800740:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800747:	25 07 0e 00 00       	and    $0xe07,%eax
  80074c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800750:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800754:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80075b:	00 
  80075c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800767:	e8 8b fa ff ff       	call   8001f7 <sys_page_map>
  80076c:	89 c6                	mov    %eax,%esi
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 3e                	js     8007b0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800775:	89 c2                	mov    %eax,%edx
  800777:	c1 ea 0c             	shr    $0xc,%edx
  80077a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800781:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800787:	89 54 24 10          	mov    %edx,0x10(%esp)
  80078b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80078f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800796:	00 
  800797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007a2:	e8 50 fa ff ff       	call   8001f7 <sys_page_map>
  8007a7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007ac:	85 f6                	test   %esi,%esi
  8007ae:	79 22                	jns    8007d2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007bb:	e8 8a fa ff ff       	call   80024a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8007c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007cb:	e8 7a fa ff ff       	call   80024a <sys_page_unmap>
	return r;
  8007d0:	89 f0                	mov    %esi,%eax
}
  8007d2:	83 c4 3c             	add    $0x3c,%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5f                   	pop    %edi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	83 ec 24             	sub    $0x24,%esp
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007eb:	89 1c 24             	mov    %ebx,(%esp)
  8007ee:	e8 53 fd ff ff       	call   800546 <fd_lookup>
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	78 6d                	js     800866 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800803:	8b 00                	mov    (%eax),%eax
  800805:	89 04 24             	mov    %eax,(%esp)
  800808:	e8 8f fd ff ff       	call   80059c <dev_lookup>
  80080d:	85 c0                	test   %eax,%eax
  80080f:	78 55                	js     800866 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800814:	8b 50 08             	mov    0x8(%eax),%edx
  800817:	83 e2 03             	and    $0x3,%edx
  80081a:	83 fa 01             	cmp    $0x1,%edx
  80081d:	75 23                	jne    800842 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80081f:	a1 08 40 80 00       	mov    0x804008,%eax
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	c7 04 24 79 26 80 00 	movl   $0x802679,(%esp)
  800836:	e8 44 10 00 00       	call   80187f <cprintf>
		return -E_INVAL;
  80083b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800840:	eb 24                	jmp    800866 <read+0x8c>
	}
	if (!dev->dev_read)
  800842:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800845:	8b 52 08             	mov    0x8(%edx),%edx
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 15                	je     800861 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80084c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80085a:	89 04 24             	mov    %eax,(%esp)
  80085d:	ff d2                	call   *%edx
  80085f:	eb 05                	jmp    800866 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800861:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800866:	83 c4 24             	add    $0x24,%esp
  800869:	5b                   	pop    %ebx
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	57                   	push   %edi
  800870:	56                   	push   %esi
  800871:	53                   	push   %ebx
  800872:	83 ec 1c             	sub    $0x1c,%esp
  800875:	8b 7d 08             	mov    0x8(%ebp),%edi
  800878:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80087b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800880:	eb 23                	jmp    8008a5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800882:	89 f0                	mov    %esi,%eax
  800884:	29 d8                	sub    %ebx,%eax
  800886:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	03 45 0c             	add    0xc(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	89 3c 24             	mov    %edi,(%esp)
  800896:	e8 3f ff ff ff       	call   8007da <read>
		if (m < 0)
  80089b:	85 c0                	test   %eax,%eax
  80089d:	78 10                	js     8008af <readn+0x43>
			return m;
		if (m == 0)
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	74 0a                	je     8008ad <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008a3:	01 c3                	add    %eax,%ebx
  8008a5:	39 f3                	cmp    %esi,%ebx
  8008a7:	72 d9                	jb     800882 <readn+0x16>
  8008a9:	89 d8                	mov    %ebx,%eax
  8008ab:	eb 02                	jmp    8008af <readn+0x43>
  8008ad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008af:	83 c4 1c             	add    $0x1c,%esp
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5f                   	pop    %edi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 24             	sub    $0x24,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	89 1c 24             	mov    %ebx,(%esp)
  8008cb:	e8 76 fc ff ff       	call   800546 <fd_lookup>
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	78 68                	js     80093e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e0:	8b 00                	mov    (%eax),%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 b2 fc ff ff       	call   80059c <dev_lookup>
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	78 50                	js     80093e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008f5:	75 23                	jne    80091a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8008f7:	a1 08 40 80 00       	mov    0x804008,%eax
  8008fc:	8b 40 48             	mov    0x48(%eax),%eax
  8008ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800903:	89 44 24 04          	mov    %eax,0x4(%esp)
  800907:	c7 04 24 95 26 80 00 	movl   $0x802695,(%esp)
  80090e:	e8 6c 0f 00 00       	call   80187f <cprintf>
		return -E_INVAL;
  800913:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800918:	eb 24                	jmp    80093e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80091a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80091d:	8b 52 0c             	mov    0xc(%edx),%edx
  800920:	85 d2                	test   %edx,%edx
  800922:	74 15                	je     800939 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800927:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	ff d2                	call   *%edx
  800937:	eb 05                	jmp    80093e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800939:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80093e:	83 c4 24             	add    $0x24,%esp
  800941:	5b                   	pop    %ebx
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <seek>:

int
seek(int fdnum, off_t offset)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80094a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80094d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	e8 ea fb ff ff       	call   800546 <fd_lookup>
  80095c:	85 c0                	test   %eax,%eax
  80095e:	78 0e                	js     80096e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800960:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
  800966:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	83 ec 24             	sub    $0x24,%esp
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80097a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800981:	89 1c 24             	mov    %ebx,(%esp)
  800984:	e8 bd fb ff ff       	call   800546 <fd_lookup>
  800989:	89 c2                	mov    %eax,%edx
  80098b:	85 d2                	test   %edx,%edx
  80098d:	78 61                	js     8009f0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80098f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800999:	8b 00                	mov    (%eax),%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 f9 fb ff ff       	call   80059c <dev_lookup>
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 49                	js     8009f0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009ae:	75 23                	jne    8009d3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009b0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009b5:	8b 40 48             	mov    0x48(%eax),%eax
  8009b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	c7 04 24 58 26 80 00 	movl   $0x802658,(%esp)
  8009c7:	e8 b3 0e 00 00       	call   80187f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8009cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d1:	eb 1d                	jmp    8009f0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8009d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d6:	8b 52 18             	mov    0x18(%edx),%edx
  8009d9:	85 d2                	test   %edx,%edx
  8009db:	74 0e                	je     8009eb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e4:	89 04 24             	mov    %eax,(%esp)
  8009e7:	ff d2                	call   *%edx
  8009e9:	eb 05                	jmp    8009f0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8009f0:	83 c4 24             	add    $0x24,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	83 ec 24             	sub    $0x24,%esp
  8009fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	89 04 24             	mov    %eax,(%esp)
  800a0d:	e8 34 fb ff ff       	call   800546 <fd_lookup>
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	85 d2                	test   %edx,%edx
  800a16:	78 52                	js     800a6a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a22:	8b 00                	mov    (%eax),%eax
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	e8 70 fb ff ff       	call   80059c <dev_lookup>
  800a2c:	85 c0                	test   %eax,%eax
  800a2e:	78 3a                	js     800a6a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a33:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a37:	74 2c                	je     800a65 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a39:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a3c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a43:	00 00 00 
	stat->st_isdir = 0;
  800a46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a4d:	00 00 00 
	stat->st_dev = dev;
  800a50:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a5d:	89 14 24             	mov    %edx,(%esp)
  800a60:	ff 50 14             	call   *0x14(%eax)
  800a63:	eb 05                	jmp    800a6a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a65:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a6a:	83 c4 24             	add    $0x24,%esp
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a7f:	00 
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 28 02 00 00       	call   800cb3 <open>
  800a8b:	89 c3                	mov    %eax,%ebx
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	78 1b                	js     800aac <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	89 1c 24             	mov    %ebx,(%esp)
  800a9b:	e8 56 ff ff ff       	call   8009f6 <fstat>
  800aa0:	89 c6                	mov    %eax,%esi
	close(fd);
  800aa2:	89 1c 24             	mov    %ebx,(%esp)
  800aa5:	e8 cd fb ff ff       	call   800677 <close>
	return r;
  800aaa:	89 f0                	mov    %esi,%eax
}
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 10             	sub    $0x10,%esp
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800abf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ac6:	75 11                	jne    800ad9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ac8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800acf:	e8 11 18 00 00       	call   8022e5 <ipc_find_env>
  800ad4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ad9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ae0:	00 
  800ae1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ae8:	00 
  800ae9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aed:	a1 00 40 80 00       	mov    0x804000,%eax
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 80 17 00 00       	call   80227a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800afa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b01:	00 
  800b02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b0d:	e8 ee 16 00 00       	call   802200 <ipc_recv>
}
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 40 0c             	mov    0xc(%eax),%eax
  800b25:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3c:	e8 72 ff ff ff       	call   800ab3 <fsipc>
}
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b4f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 06 00 00 00       	mov    $0x6,%eax
  800b5e:	e8 50 ff ff ff       	call   800ab3 <fsipc>
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	53                   	push   %ebx
  800b69:	83 ec 14             	sub    $0x14,%esp
  800b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	8b 40 0c             	mov    0xc(%eax),%eax
  800b75:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b84:	e8 2a ff ff ff       	call   800ab3 <fsipc>
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	85 d2                	test   %edx,%edx
  800b8d:	78 2b                	js     800bba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b8f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b96:	00 
  800b97:	89 1c 24             	mov    %ebx,(%esp)
  800b9a:	e8 08 13 00 00       	call   801ea7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b9f:	a1 80 50 80 00       	mov    0x805080,%eax
  800ba4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800baa:	a1 84 50 80 00       	mov    0x805084,%eax
  800baf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bba:	83 c4 14             	add    $0x14,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 18             	sub    $0x18,%esp
  800bc6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bce:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800bd3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 52 0c             	mov    0xc(%edx),%edx
  800bdc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800be2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  800be7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bf9:	e8 46 14 00 00       	call   802044 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	e8 a6 fe ff ff       	call   800ab3 <fsipc>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 10             	sub    $0x10,%esp
  800c17:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c20:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c25:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 03 00 00 00       	mov    $0x3,%eax
  800c35:	e8 79 fe ff ff       	call   800ab3 <fsipc>
  800c3a:	89 c3                	mov    %eax,%ebx
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	78 6a                	js     800caa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c40:	39 c6                	cmp    %eax,%esi
  800c42:	73 24                	jae    800c68 <devfile_read+0x59>
  800c44:	c7 44 24 0c c8 26 80 	movl   $0x8026c8,0xc(%esp)
  800c4b:	00 
  800c4c:	c7 44 24 08 cf 26 80 	movl   $0x8026cf,0x8(%esp)
  800c53:	00 
  800c54:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c5b:	00 
  800c5c:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800c63:	e8 1e 0b 00 00       	call   801786 <_panic>
	assert(r <= PGSIZE);
  800c68:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c6d:	7e 24                	jle    800c93 <devfile_read+0x84>
  800c6f:	c7 44 24 0c ef 26 80 	movl   $0x8026ef,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 cf 26 80 	movl   $0x8026cf,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800c8e:	e8 f3 0a 00 00       	call   801786 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c97:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c9e:	00 
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	89 04 24             	mov    %eax,(%esp)
  800ca5:	e8 9a 13 00 00       	call   802044 <memmove>
	return r;
}
  800caa:	89 d8                	mov    %ebx,%eax
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 24             	sub    $0x24,%esp
  800cba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800cbd:	89 1c 24             	mov    %ebx,(%esp)
  800cc0:	e8 ab 11 00 00       	call   801e70 <strlen>
  800cc5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cca:	7f 60                	jg     800d2c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ccc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ccf:	89 04 24             	mov    %eax,(%esp)
  800cd2:	e8 20 f8 ff ff       	call   8004f7 <fd_alloc>
  800cd7:	89 c2                	mov    %eax,%edx
  800cd9:	85 d2                	test   %edx,%edx
  800cdb:	78 54                	js     800d31 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ce8:	e8 ba 11 00 00       	call   801ea7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfd:	e8 b1 fd ff ff       	call   800ab3 <fsipc>
  800d02:	89 c3                	mov    %eax,%ebx
  800d04:	85 c0                	test   %eax,%eax
  800d06:	79 17                	jns    800d1f <open+0x6c>
		fd_close(fd, 0);
  800d08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d0f:	00 
  800d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d13:	89 04 24             	mov    %eax,(%esp)
  800d16:	e8 db f8 ff ff       	call   8005f6 <fd_close>
		return r;
  800d1b:	89 d8                	mov    %ebx,%eax
  800d1d:	eb 12                	jmp    800d31 <open+0x7e>
	}

	return fd2num(fd);
  800d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	e8 a6 f7 ff ff       	call   8004d0 <fd2num>
  800d2a:	eb 05                	jmp    800d31 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800d2c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800d31:	83 c4 24             	add    $0x24,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d42:	b8 08 00 00 00       	mov    $0x8,%eax
  800d47:	e8 67 fd ff ff       	call   800ab3 <fsipc>
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d56:	c7 44 24 04 fb 26 80 	movl   $0x8026fb,0x4(%esp)
  800d5d:	00 
  800d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d61:	89 04 24             	mov    %eax,(%esp)
  800d64:	e8 3e 11 00 00       	call   801ea7 <strcpy>
	return 0;
}
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	53                   	push   %ebx
  800d74:	83 ec 14             	sub    $0x14,%esp
  800d77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d7a:	89 1c 24             	mov    %ebx,(%esp)
  800d7d:	e8 9b 15 00 00       	call   80231d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800d87:	83 f8 01             	cmp    $0x1,%eax
  800d8a:	75 0d                	jne    800d99 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800d8c:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d8f:	89 04 24             	mov    %eax,(%esp)
  800d92:	e8 29 03 00 00       	call   8010c0 <nsipc_close>
  800d97:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	83 c4 14             	add    $0x14,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800da7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dae:	00 
  800daf:	8b 45 10             	mov    0x10(%ebp),%eax
  800db2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc3:	89 04 24             	mov    %eax,(%esp)
  800dc6:	e8 f0 03 00 00       	call   8011bb <nsipc_send>
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800dd3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dda:	00 
  800ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 40 0c             	mov    0xc(%eax),%eax
  800def:	89 04 24             	mov    %eax,(%esp)
  800df2:	e8 44 03 00 00       	call   80113b <nsipc_recv>
}
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800dff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e02:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e06:	89 04 24             	mov    %eax,(%esp)
  800e09:	e8 38 f7 ff ff       	call   800546 <fd_lookup>
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 17                	js     800e29 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800e1b:	39 08                	cmp    %ecx,(%eax)
  800e1d:	75 05                	jne    800e24 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800e22:	eb 05                	jmp    800e29 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 20             	sub    $0x20,%esp
  800e33:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 b7 f6 ff ff       	call   8004f7 <fd_alloc>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 21                	js     800e67 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e4d:	00 
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5c:	e8 42 f3 ff ff       	call   8001a3 <sys_page_alloc>
  800e61:	89 c3                	mov    %eax,%ebx
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 0c                	jns    800e73 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  800e67:	89 34 24             	mov    %esi,(%esp)
  800e6a:	e8 51 02 00 00       	call   8010c0 <nsipc_close>
		return r;
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	eb 20                	jmp    800e93 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e81:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800e88:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800e8b:	89 14 24             	mov    %edx,(%esp)
  800e8e:	e8 3d f6 ff ff       	call   8004d0 <fd2num>
}
  800e93:	83 c4 20             	add    $0x20,%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	e8 51 ff ff ff       	call   800df9 <fd2sockid>
		return r;
  800ea8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 23                	js     800ed1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800eae:	8b 55 10             	mov    0x10(%ebp),%edx
  800eb1:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebc:	89 04 24             	mov    %eax,(%esp)
  800ebf:	e8 45 01 00 00       	call   801009 <nsipc_accept>
		return r;
  800ec4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 07                	js     800ed1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  800eca:	e8 5c ff ff ff       	call   800e2b <alloc_sockfd>
  800ecf:	89 c1                	mov    %eax,%ecx
}
  800ed1:	89 c8                	mov    %ecx,%eax
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	e8 16 ff ff ff       	call   800df9 <fd2sockid>
  800ee3:	89 c2                	mov    %eax,%edx
  800ee5:	85 d2                	test   %edx,%edx
  800ee7:	78 16                	js     800eff <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  800ee9:	8b 45 10             	mov    0x10(%ebp),%eax
  800eec:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef7:	89 14 24             	mov    %edx,(%esp)
  800efa:	e8 60 01 00 00       	call   80105f <nsipc_bind>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <shutdown>:

int
shutdown(int s, int how)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	e8 ea fe ff ff       	call   800df9 <fd2sockid>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	85 d2                	test   %edx,%edx
  800f13:	78 0f                	js     800f24 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800f15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1c:	89 14 24             	mov    %edx,(%esp)
  800f1f:	e8 7a 01 00 00       	call   80109e <nsipc_shutdown>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2f:	e8 c5 fe ff ff       	call   800df9 <fd2sockid>
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	85 d2                	test   %edx,%edx
  800f38:	78 16                	js     800f50 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  800f3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	89 14 24             	mov    %edx,(%esp)
  800f4b:	e8 8a 01 00 00       	call   8010da <nsipc_connect>
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <listen>:

int
listen(int s, int backlog)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f58:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5b:	e8 99 fe ff ff       	call   800df9 <fd2sockid>
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	85 d2                	test   %edx,%edx
  800f64:	78 0f                	js     800f75 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6d:	89 14 24             	mov    %edx,(%esp)
  800f70:	e8 a4 01 00 00       	call   801119 <nsipc_listen>
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	89 04 24             	mov    %eax,(%esp)
  800f91:	e8 98 02 00 00       	call   80122e <nsipc_socket>
  800f96:	89 c2                	mov    %eax,%edx
  800f98:	85 d2                	test   %edx,%edx
  800f9a:	78 05                	js     800fa1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  800f9c:	e8 8a fe ff ff       	call   800e2b <alloc_sockfd>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 14             	sub    $0x14,%esp
  800faa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800fac:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800fb3:	75 11                	jne    800fc6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800fb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fbc:	e8 24 13 00 00       	call   8022e5 <ipc_find_env>
  800fc1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800fc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800fd5:	00 
  800fd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fda:	a1 04 40 80 00       	mov    0x804004,%eax
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 93 12 00 00       	call   80227a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800fe7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fee:	00 
  800fef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff6:	00 
  800ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffe:	e8 fd 11 00 00       	call   802200 <ipc_recv>
}
  801003:	83 c4 14             	add    $0x14,%esp
  801006:	5b                   	pop    %ebx
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
  80100e:	83 ec 10             	sub    $0x10,%esp
  801011:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80101c:	8b 06                	mov    (%esi),%eax
  80101e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801023:	b8 01 00 00 00       	mov    $0x1,%eax
  801028:	e8 76 ff ff ff       	call   800fa3 <nsipc>
  80102d:	89 c3                	mov    %eax,%ebx
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 23                	js     801056 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801033:	a1 10 60 80 00       	mov    0x806010,%eax
  801038:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801043:	00 
  801044:	8b 45 0c             	mov    0xc(%ebp),%eax
  801047:	89 04 24             	mov    %eax,(%esp)
  80104a:	e8 f5 0f 00 00       	call   802044 <memmove>
		*addrlen = ret->ret_addrlen;
  80104f:	a1 10 60 80 00       	mov    0x806010,%eax
  801054:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801056:	89 d8                	mov    %ebx,%eax
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 14             	sub    $0x14,%esp
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801071:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801075:	8b 45 0c             	mov    0xc(%ebp),%eax
  801078:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801083:	e8 bc 0f 00 00       	call   802044 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801088:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80108e:	b8 02 00 00 00       	mov    $0x2,%eax
  801093:	e8 0b ff ff ff       	call   800fa3 <nsipc>
}
  801098:	83 c4 14             	add    $0x14,%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8010ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010af:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8010b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b9:	e8 e5 fe ff ff       	call   800fa3 <nsipc>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <nsipc_close>:

int
nsipc_close(int s)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010ce:	b8 04 00 00 00       	mov    $0x4,%eax
  8010d3:	e8 cb fe ff ff       	call   800fa3 <nsipc>
}
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 14             	sub    $0x14,%esp
  8010e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8010ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8010fe:	e8 41 0f 00 00       	call   802044 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801103:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801109:	b8 05 00 00 00       	mov    $0x5,%eax
  80110e:	e8 90 fe ff ff       	call   800fa3 <nsipc>
}
  801113:	83 c4 14             	add    $0x14,%esp
  801116:	5b                   	pop    %ebx
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80112f:	b8 06 00 00 00       	mov    $0x6,%eax
  801134:	e8 6a fe ff ff       	call   800fa3 <nsipc>
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 10             	sub    $0x10,%esp
  801143:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80114e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801154:	8b 45 14             	mov    0x14(%ebp),%eax
  801157:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80115c:	b8 07 00 00 00       	mov    $0x7,%eax
  801161:	e8 3d fe ff ff       	call   800fa3 <nsipc>
  801166:	89 c3                	mov    %eax,%ebx
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 46                	js     8011b2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80116c:	39 f0                	cmp    %esi,%eax
  80116e:	7f 07                	jg     801177 <nsipc_recv+0x3c>
  801170:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801175:	7e 24                	jle    80119b <nsipc_recv+0x60>
  801177:	c7 44 24 0c 07 27 80 	movl   $0x802707,0xc(%esp)
  80117e:	00 
  80117f:	c7 44 24 08 cf 26 80 	movl   $0x8026cf,0x8(%esp)
  801186:	00 
  801187:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80118e:	00 
  80118f:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  801196:	e8 eb 05 00 00       	call   801786 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80119b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011a6:	00 
  8011a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 92 0e 00 00       	call   802044 <memmove>
	}

	return r;
}
  8011b2:	89 d8                	mov    %ebx,%eax
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 14             	sub    $0x14,%esp
  8011c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8011cd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8011d3:	7e 24                	jle    8011f9 <nsipc_send+0x3e>
  8011d5:	c7 44 24 0c 28 27 80 	movl   $0x802728,0xc(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 08 cf 26 80 	movl   $0x8026cf,0x8(%esp)
  8011e4:	00 
  8011e5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011ec:	00 
  8011ed:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  8011f4:	e8 8d 05 00 00       	call   801786 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801200:	89 44 24 04          	mov    %eax,0x4(%esp)
  801204:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80120b:	e8 34 0e 00 00       	call   802044 <memmove>
	nsipcbuf.send.req_size = size;
  801210:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801216:	8b 45 14             	mov    0x14(%ebp),%eax
  801219:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80121e:	b8 08 00 00 00       	mov    $0x8,%eax
  801223:	e8 7b fd ff ff       	call   800fa3 <nsipc>
}
  801228:	83 c4 14             	add    $0x14,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801244:	8b 45 10             	mov    0x10(%ebp),%eax
  801247:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80124c:	b8 09 00 00 00       	mov    $0x9,%eax
  801251:	e8 4d fd ff ff       	call   800fa3 <nsipc>
}
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 10             	sub    $0x10,%esp
  801260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	89 04 24             	mov    %eax,(%esp)
  801269:	e8 72 f2 ff ff       	call   8004e0 <fd2data>
  80126e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801270:	c7 44 24 04 34 27 80 	movl   $0x802734,0x4(%esp)
  801277:	00 
  801278:	89 1c 24             	mov    %ebx,(%esp)
  80127b:	e8 27 0c 00 00       	call   801ea7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801280:	8b 46 04             	mov    0x4(%esi),%eax
  801283:	2b 06                	sub    (%esi),%eax
  801285:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80128b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801292:	00 00 00 
	stat->st_dev = &devpipe;
  801295:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80129c:	30 80 00 
	return 0;
}
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	53                   	push   %ebx
  8012af:	83 ec 14             	sub    $0x14,%esp
  8012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8012b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c0:	e8 85 ef ff ff       	call   80024a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8012c5:	89 1c 24             	mov    %ebx,(%esp)
  8012c8:	e8 13 f2 ff ff       	call   8004e0 <fd2data>
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d8:	e8 6d ef ff ff       	call   80024a <sys_page_unmap>
}
  8012dd:	83 c4 14             	add    $0x14,%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 2c             	sub    $0x2c,%esp
  8012ec:	89 c6                	mov    %eax,%esi
  8012ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012f9:	89 34 24             	mov    %esi,(%esp)
  8012fc:	e8 1c 10 00 00       	call   80231d <pageref>
  801301:	89 c7                	mov    %eax,%edi
  801303:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801306:	89 04 24             	mov    %eax,(%esp)
  801309:	e8 0f 10 00 00       	call   80231d <pageref>
  80130e:	39 c7                	cmp    %eax,%edi
  801310:	0f 94 c2             	sete   %dl
  801313:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801316:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80131c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80131f:	39 fb                	cmp    %edi,%ebx
  801321:	74 21                	je     801344 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801323:	84 d2                	test   %dl,%dl
  801325:	74 ca                	je     8012f1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801327:	8b 51 58             	mov    0x58(%ecx),%edx
  80132a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801332:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801336:	c7 04 24 3b 27 80 00 	movl   $0x80273b,(%esp)
  80133d:	e8 3d 05 00 00       	call   80187f <cprintf>
  801342:	eb ad                	jmp    8012f1 <_pipeisclosed+0xe>
	}
}
  801344:	83 c4 2c             	add    $0x2c,%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	57                   	push   %edi
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
  801352:	83 ec 1c             	sub    $0x1c,%esp
  801355:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801358:	89 34 24             	mov    %esi,(%esp)
  80135b:	e8 80 f1 ff ff       	call   8004e0 <fd2data>
  801360:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801362:	bf 00 00 00 00       	mov    $0x0,%edi
  801367:	eb 45                	jmp    8013ae <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801369:	89 da                	mov    %ebx,%edx
  80136b:	89 f0                	mov    %esi,%eax
  80136d:	e8 71 ff ff ff       	call   8012e3 <_pipeisclosed>
  801372:	85 c0                	test   %eax,%eax
  801374:	75 41                	jne    8013b7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801376:	e8 09 ee ff ff       	call   800184 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80137b:	8b 43 04             	mov    0x4(%ebx),%eax
  80137e:	8b 0b                	mov    (%ebx),%ecx
  801380:	8d 51 20             	lea    0x20(%ecx),%edx
  801383:	39 d0                	cmp    %edx,%eax
  801385:	73 e2                	jae    801369 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80138e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801391:	99                   	cltd   
  801392:	c1 ea 1b             	shr    $0x1b,%edx
  801395:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801398:	83 e1 1f             	and    $0x1f,%ecx
  80139b:	29 d1                	sub    %edx,%ecx
  80139d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8013a1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8013a5:	83 c0 01             	add    $0x1,%eax
  8013a8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013ab:	83 c7 01             	add    $0x1,%edi
  8013ae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8013b1:	75 c8                	jne    80137b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8013b3:	89 f8                	mov    %edi,%eax
  8013b5:	eb 05                	jmp    8013bc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8013bc:	83 c4 1c             	add    $0x1c,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	57                   	push   %edi
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 1c             	sub    $0x1c,%esp
  8013cd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8013d0:	89 3c 24             	mov    %edi,(%esp)
  8013d3:	e8 08 f1 ff ff       	call   8004e0 <fd2data>
  8013d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013da:	be 00 00 00 00       	mov    $0x0,%esi
  8013df:	eb 3d                	jmp    80141e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8013e1:	85 f6                	test   %esi,%esi
  8013e3:	74 04                	je     8013e9 <devpipe_read+0x25>
				return i;
  8013e5:	89 f0                	mov    %esi,%eax
  8013e7:	eb 43                	jmp    80142c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013e9:	89 da                	mov    %ebx,%edx
  8013eb:	89 f8                	mov    %edi,%eax
  8013ed:	e8 f1 fe ff ff       	call   8012e3 <_pipeisclosed>
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	75 31                	jne    801427 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8013f6:	e8 89 ed ff ff       	call   800184 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013fb:	8b 03                	mov    (%ebx),%eax
  8013fd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801400:	74 df                	je     8013e1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801402:	99                   	cltd   
  801403:	c1 ea 1b             	shr    $0x1b,%edx
  801406:	01 d0                	add    %edx,%eax
  801408:	83 e0 1f             	and    $0x1f,%eax
  80140b:	29 d0                	sub    %edx,%eax
  80140d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801412:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801415:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801418:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80141b:	83 c6 01             	add    $0x1,%esi
  80141e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801421:	75 d8                	jne    8013fb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801423:	89 f0                	mov    %esi,%eax
  801425:	eb 05                	jmp    80142c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80142c:	83 c4 1c             	add    $0x1c,%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 b0 f0 ff ff       	call   8004f7 <fd_alloc>
  801447:	89 c2                	mov    %eax,%edx
  801449:	85 d2                	test   %edx,%edx
  80144b:	0f 88 4d 01 00 00    	js     80159e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801451:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801458:	00 
  801459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801467:	e8 37 ed ff ff       	call   8001a3 <sys_page_alloc>
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	0f 88 28 01 00 00    	js     80159e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 76 f0 ff ff       	call   8004f7 <fd_alloc>
  801481:	89 c3                	mov    %eax,%ebx
  801483:	85 c0                	test   %eax,%eax
  801485:	0f 88 fe 00 00 00    	js     801589 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80148b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801492:	00 
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a1:	e8 fd ec ff ff       	call   8001a3 <sys_page_alloc>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	0f 88 d9 00 00 00    	js     801589 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 25 f0 ff ff       	call   8004e0 <fd2data>
  8014bb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014c4:	00 
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d0:	e8 ce ec ff ff       	call   8001a3 <sys_page_alloc>
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	0f 88 97 00 00 00    	js     801576 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	e8 f6 ef ff ff       	call   8004e0 <fd2data>
  8014ea:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8014f1:	00 
  8014f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014fd:	00 
  8014fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801502:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801509:	e8 e9 ec ff ff       	call   8001f7 <sys_page_map>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 52                	js     801566 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801514:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80151f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801522:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801529:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801534:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801537:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80153e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801541:	89 04 24             	mov    %eax,(%esp)
  801544:	e8 87 ef ff ff       	call   8004d0 <fd2num>
  801549:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80154e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 77 ef ff ff       	call   8004d0 <fd2num>
  801559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
  801564:	eb 38                	jmp    80159e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801571:	e8 d4 ec ff ff       	call   80024a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801584:	e8 c1 ec ff ff       	call   80024a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801589:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801590:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801597:	e8 ae ec ff ff       	call   80024a <sys_page_unmap>
  80159c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80159e:	83 c4 30             	add    $0x30,%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	e8 89 ef ff ff       	call   800546 <fd_lookup>
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	78 15                	js     8015d8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c6:	89 04 24             	mov    %eax,(%esp)
  8015c9:	e8 12 ef ff ff       	call   8004e0 <fd2data>
	return _pipeisclosed(fd, p);
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d3:	e8 0b fd ff ff       	call   8012e3 <_pipeisclosed>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    
  8015da:	66 90                	xchg   %ax,%ax
  8015dc:	66 90                	xchg   %ax,%ax
  8015de:	66 90                	xchg   %ax,%ax

008015e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8015e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8015f0:	c7 44 24 04 53 27 80 	movl   $0x802753,0x4(%esp)
  8015f7:	00 
  8015f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fb:	89 04 24             	mov    %eax,(%esp)
  8015fe:	e8 a4 08 00 00       	call   801ea7 <strcpy>
	return 0;
}
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	57                   	push   %edi
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801616:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80161b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801621:	eb 31                	jmp    801654 <devcons_write+0x4a>
		m = n - tot;
  801623:	8b 75 10             	mov    0x10(%ebp),%esi
  801626:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801628:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80162b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801630:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801633:	89 74 24 08          	mov    %esi,0x8(%esp)
  801637:	03 45 0c             	add    0xc(%ebp),%eax
  80163a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163e:	89 3c 24             	mov    %edi,(%esp)
  801641:	e8 fe 09 00 00       	call   802044 <memmove>
		sys_cputs(buf, m);
  801646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164a:	89 3c 24             	mov    %edi,(%esp)
  80164d:	e8 84 ea ff ff       	call   8000d6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801652:	01 f3                	add    %esi,%ebx
  801654:	89 d8                	mov    %ebx,%eax
  801656:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801659:	72 c8                	jb     801623 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80165b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801671:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801675:	75 07                	jne    80167e <devcons_read+0x18>
  801677:	eb 2a                	jmp    8016a3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801679:	e8 06 eb ff ff       	call   800184 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80167e:	66 90                	xchg   %ax,%ax
  801680:	e8 6f ea ff ff       	call   8000f4 <sys_cgetc>
  801685:	85 c0                	test   %eax,%eax
  801687:	74 f0                	je     801679 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 16                	js     8016a3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80168d:	83 f8 04             	cmp    $0x4,%eax
  801690:	74 0c                	je     80169e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801692:	8b 55 0c             	mov    0xc(%ebp),%edx
  801695:	88 02                	mov    %al,(%edx)
	return 1;
  801697:	b8 01 00 00 00       	mov    $0x1,%eax
  80169c:	eb 05                	jmp    8016a3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8016b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b8:	00 
  8016b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016bc:	89 04 24             	mov    %eax,(%esp)
  8016bf:	e8 12 ea ff ff       	call   8000d6 <sys_cputs>
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <getchar>:

int
getchar(void)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8016cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8016d3:	00 
  8016d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e2:	e8 f3 f0 ff ff       	call   8007da <read>
	if (r < 0)
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 0f                	js     8016fa <getchar+0x34>
		return r;
	if (r < 1)
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	7e 06                	jle    8016f5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8016ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8016f3:	eb 05                	jmp    8016fa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8016f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801705:	89 44 24 04          	mov    %eax,0x4(%esp)
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	89 04 24             	mov    %eax,(%esp)
  80170f:	e8 32 ee ff ff       	call   800546 <fd_lookup>
  801714:	85 c0                	test   %eax,%eax
  801716:	78 11                	js     801729 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801721:	39 10                	cmp    %edx,(%eax)
  801723:	0f 94 c0             	sete   %al
  801726:	0f b6 c0             	movzbl %al,%eax
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <opencons>:

int
opencons(void)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	e8 bb ed ff ff       	call   8004f7 <fd_alloc>
		return r;
  80173c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 40                	js     801782 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801742:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801749:	00 
  80174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801758:	e8 46 ea ff ff       	call   8001a3 <sys_page_alloc>
		return r;
  80175d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 1f                	js     801782 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801763:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801771:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801778:	89 04 24             	mov    %eax,(%esp)
  80177b:	e8 50 ed ff ff       	call   8004d0 <fd2num>
  801780:	89 c2                	mov    %eax,%edx
}
  801782:	89 d0                	mov    %edx,%eax
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80178e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801791:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801797:	e8 c9 e9 ff ff       	call   800165 <sys_getenvid>
  80179c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  8017b9:	e8 c1 00 00 00       	call   80187f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c5:	89 04 24             	mov    %eax,(%esp)
  8017c8:	e8 51 00 00 00       	call   80181e <vcprintf>
	cprintf("\n");
  8017cd:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  8017d4:	e8 a6 00 00 00       	call   80187f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017d9:	cc                   	int3   
  8017da:	eb fd                	jmp    8017d9 <_panic+0x53>

008017dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 14             	sub    $0x14,%esp
  8017e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8017e6:	8b 13                	mov    (%ebx),%edx
  8017e8:	8d 42 01             	lea    0x1(%edx),%eax
  8017eb:	89 03                	mov    %eax,(%ebx)
  8017ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8017f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8017f9:	75 19                	jne    801814 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8017fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801802:	00 
  801803:	8d 43 08             	lea    0x8(%ebx),%eax
  801806:	89 04 24             	mov    %eax,(%esp)
  801809:	e8 c8 e8 ff ff       	call   8000d6 <sys_cputs>
		b->idx = 0;
  80180e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801814:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801818:	83 c4 14             	add    $0x14,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801827:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80182e:	00 00 00 
	b.cnt = 0;
  801831:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801838:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	89 44 24 08          	mov    %eax,0x8(%esp)
  801849:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	c7 04 24 dc 17 80 00 	movl   $0x8017dc,(%esp)
  80185a:	e8 af 01 00 00       	call   801a0e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80185f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801865:	89 44 24 04          	mov    %eax,0x4(%esp)
  801869:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 5f e8 ff ff       	call   8000d6 <sys_cputs>

	return b.cnt;
}
  801877:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801885:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 87 ff ff ff       	call   80181e <vcprintf>
	va_end(ap);

	return cnt;
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    
  801899:	66 90                	xchg   %ax,%ax
  80189b:	66 90                	xchg   %ax,%ax
  80189d:	66 90                	xchg   %ax,%ax
  80189f:	90                   	nop

008018a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 3c             	sub    $0x3c,%esp
  8018a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018ac:	89 d7                	mov    %edx,%edi
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8018bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018cd:	39 d9                	cmp    %ebx,%ecx
  8018cf:	72 05                	jb     8018d6 <printnum+0x36>
  8018d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8018d4:	77 69                	ja     80193f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8018d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018dd:	83 ee 01             	sub    $0x1,%esi
  8018e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018f0:	89 c3                	mov    %eax,%ebx
  8018f2:	89 d6                	mov    %edx,%esi
  8018f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8018fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801902:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	e8 4c 0a 00 00       	call   802360 <__udivdi3>
  801914:	89 d9                	mov    %ebx,%ecx
  801916:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80191a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	89 54 24 04          	mov    %edx,0x4(%esp)
  801925:	89 fa                	mov    %edi,%edx
  801927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80192a:	e8 71 ff ff ff       	call   8018a0 <printnum>
  80192f:	eb 1b                	jmp    80194c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801931:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801935:	8b 45 18             	mov    0x18(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	ff d3                	call   *%ebx
  80193d:	eb 03                	jmp    801942 <printnum+0xa2>
  80193f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801942:	83 ee 01             	sub    $0x1,%esi
  801945:	85 f6                	test   %esi,%esi
  801947:	7f e8                	jg     801931 <printnum+0x91>
  801949:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80194c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801950:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801954:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801957:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80195a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801962:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80196b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196f:	e8 1c 0b 00 00       	call   802490 <__umoddi3>
  801974:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801978:	0f be 80 83 27 80 00 	movsbl 0x802783(%eax),%eax
  80197f:	89 04 24             	mov    %eax,(%esp)
  801982:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801985:	ff d0                	call   *%eax
}
  801987:	83 c4 3c             	add    $0x3c,%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5f                   	pop    %edi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801992:	83 fa 01             	cmp    $0x1,%edx
  801995:	7e 0e                	jle    8019a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801997:	8b 10                	mov    (%eax),%edx
  801999:	8d 4a 08             	lea    0x8(%edx),%ecx
  80199c:	89 08                	mov    %ecx,(%eax)
  80199e:	8b 02                	mov    (%edx),%eax
  8019a0:	8b 52 04             	mov    0x4(%edx),%edx
  8019a3:	eb 22                	jmp    8019c7 <getuint+0x38>
	else if (lflag)
  8019a5:	85 d2                	test   %edx,%edx
  8019a7:	74 10                	je     8019b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8019a9:	8b 10                	mov    (%eax),%edx
  8019ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019ae:	89 08                	mov    %ecx,(%eax)
  8019b0:	8b 02                	mov    (%edx),%eax
  8019b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b7:	eb 0e                	jmp    8019c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8019b9:	8b 10                	mov    (%eax),%edx
  8019bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019be:	89 08                	mov    %ecx,(%eax)
  8019c0:	8b 02                	mov    (%edx),%eax
  8019c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8019cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019d3:	8b 10                	mov    (%eax),%edx
  8019d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8019d8:	73 0a                	jae    8019e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8019dd:	89 08                	mov    %ecx,(%eax)
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	88 02                	mov    %al,(%edx)
}
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8019ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a01:	8b 45 08             	mov    0x8(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 02 00 00 00       	call   801a0e <vprintfmt>
	va_end(ap);
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	57                   	push   %edi
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	83 ec 3c             	sub    $0x3c,%esp
  801a17:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a1d:	eb 14                	jmp    801a33 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	0f 84 b3 03 00 00    	je     801dda <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  801a27:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a2b:	89 04 24             	mov    %eax,(%esp)
  801a2e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	8d 73 01             	lea    0x1(%ebx),%esi
  801a36:	0f b6 03             	movzbl (%ebx),%eax
  801a39:	83 f8 25             	cmp    $0x25,%eax
  801a3c:	75 e1                	jne    801a1f <vprintfmt+0x11>
  801a3e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801a42:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801a49:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801a50:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	eb 1d                	jmp    801a7b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a60:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801a64:	eb 15                	jmp    801a7b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a66:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a68:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801a6c:	eb 0d                	jmp    801a7b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801a6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a71:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a74:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801a7e:	0f b6 0e             	movzbl (%esi),%ecx
  801a81:	0f b6 c1             	movzbl %cl,%eax
  801a84:	83 e9 23             	sub    $0x23,%ecx
  801a87:	80 f9 55             	cmp    $0x55,%cl
  801a8a:	0f 87 2a 03 00 00    	ja     801dba <vprintfmt+0x3ac>
  801a90:	0f b6 c9             	movzbl %cl,%ecx
  801a93:	ff 24 8d c0 28 80 00 	jmp    *0x8028c0(,%ecx,4)
  801a9a:	89 de                	mov    %ebx,%esi
  801a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801aa1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801aa4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801aa8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801aab:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801aae:	83 fb 09             	cmp    $0x9,%ebx
  801ab1:	77 36                	ja     801ae9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ab3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801ab6:	eb e9                	jmp    801aa1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  801abb:	8d 48 04             	lea    0x4(%eax),%ecx
  801abe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801ac1:	8b 00                	mov    (%eax),%eax
  801ac3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801ac8:	eb 22                	jmp    801aec <vprintfmt+0xde>
  801aca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801acd:	85 c9                	test   %ecx,%ecx
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	0f 49 c1             	cmovns %ecx,%eax
  801ad7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ada:	89 de                	mov    %ebx,%esi
  801adc:	eb 9d                	jmp    801a7b <vprintfmt+0x6d>
  801ade:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ae0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801ae7:	eb 92                	jmp    801a7b <vprintfmt+0x6d>
  801ae9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801aec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801af0:	79 89                	jns    801a7b <vprintfmt+0x6d>
  801af2:	e9 77 ff ff ff       	jmp    801a6e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801af7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afa:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801afc:	e9 7a ff ff ff       	jmp    801a7b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801b01:	8b 45 14             	mov    0x14(%ebp),%eax
  801b04:	8d 50 04             	lea    0x4(%eax),%edx
  801b07:	89 55 14             	mov    %edx,0x14(%ebp)
  801b0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b0e:	8b 00                	mov    (%eax),%eax
  801b10:	89 04 24             	mov    %eax,(%esp)
  801b13:	ff 55 08             	call   *0x8(%ebp)
			break;
  801b16:	e9 18 ff ff ff       	jmp    801a33 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801b1b:	8b 45 14             	mov    0x14(%ebp),%eax
  801b1e:	8d 50 04             	lea    0x4(%eax),%edx
  801b21:	89 55 14             	mov    %edx,0x14(%ebp)
  801b24:	8b 00                	mov    (%eax),%eax
  801b26:	99                   	cltd   
  801b27:	31 d0                	xor    %edx,%eax
  801b29:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801b2b:	83 f8 0f             	cmp    $0xf,%eax
  801b2e:	7f 0b                	jg     801b3b <vprintfmt+0x12d>
  801b30:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  801b37:	85 d2                	test   %edx,%edx
  801b39:	75 20                	jne    801b5b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  801b3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b3f:	c7 44 24 08 9b 27 80 	movl   $0x80279b,0x8(%esp)
  801b46:	00 
  801b47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 90 fe ff ff       	call   8019e6 <printfmt>
  801b56:	e9 d8 fe ff ff       	jmp    801a33 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801b5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b5f:	c7 44 24 08 e1 26 80 	movl   $0x8026e1,0x8(%esp)
  801b66:	00 
  801b67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 70 fe ff ff       	call   8019e6 <printfmt>
  801b76:	e9 b8 fe ff ff       	jmp    801a33 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b7b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801b7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b81:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b84:	8b 45 14             	mov    0x14(%ebp),%eax
  801b87:	8d 50 04             	lea    0x4(%eax),%edx
  801b8a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b8d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801b8f:	85 f6                	test   %esi,%esi
  801b91:	b8 94 27 80 00       	mov    $0x802794,%eax
  801b96:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801b99:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801b9d:	0f 84 97 00 00 00    	je     801c3a <vprintfmt+0x22c>
  801ba3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801ba7:	0f 8e 9b 00 00 00    	jle    801c48 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801bad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bb1:	89 34 24             	mov    %esi,(%esp)
  801bb4:	e8 cf 02 00 00       	call   801e88 <strnlen>
  801bb9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bbc:	29 c2                	sub    %eax,%edx
  801bbe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  801bc1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801bc5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801bc8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801bcb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801bd1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bd3:	eb 0f                	jmp    801be4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801bd5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bdc:	89 04 24             	mov    %eax,(%esp)
  801bdf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801be1:	83 eb 01             	sub    $0x1,%ebx
  801be4:	85 db                	test   %ebx,%ebx
  801be6:	7f ed                	jg     801bd5 <vprintfmt+0x1c7>
  801be8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801beb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bee:	85 d2                	test   %edx,%edx
  801bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf5:	0f 49 c2             	cmovns %edx,%eax
  801bf8:	29 c2                	sub    %eax,%edx
  801bfa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801bfd:	89 d7                	mov    %edx,%edi
  801bff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c02:	eb 50                	jmp    801c54 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801c04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c08:	74 1e                	je     801c28 <vprintfmt+0x21a>
  801c0a:	0f be d2             	movsbl %dl,%edx
  801c0d:	83 ea 20             	sub    $0x20,%edx
  801c10:	83 fa 5e             	cmp    $0x5e,%edx
  801c13:	76 13                	jbe    801c28 <vprintfmt+0x21a>
					putch('?', putdat);
  801c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801c23:	ff 55 08             	call   *0x8(%ebp)
  801c26:	eb 0d                	jmp    801c35 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801c28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801c35:	83 ef 01             	sub    $0x1,%edi
  801c38:	eb 1a                	jmp    801c54 <vprintfmt+0x246>
  801c3a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c3d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c40:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c43:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c46:	eb 0c                	jmp    801c54 <vprintfmt+0x246>
  801c48:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c4b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c4e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c54:	83 c6 01             	add    $0x1,%esi
  801c57:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801c5b:	0f be c2             	movsbl %dl,%eax
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	74 27                	je     801c89 <vprintfmt+0x27b>
  801c62:	85 db                	test   %ebx,%ebx
  801c64:	78 9e                	js     801c04 <vprintfmt+0x1f6>
  801c66:	83 eb 01             	sub    $0x1,%ebx
  801c69:	79 99                	jns    801c04 <vprintfmt+0x1f6>
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c70:	8b 75 08             	mov    0x8(%ebp),%esi
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	eb 1a                	jmp    801c91 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c7b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801c82:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c84:	83 eb 01             	sub    $0x1,%ebx
  801c87:	eb 08                	jmp    801c91 <vprintfmt+0x283>
  801c89:	89 fb                	mov    %edi,%ebx
  801c8b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c91:	85 db                	test   %ebx,%ebx
  801c93:	7f e2                	jg     801c77 <vprintfmt+0x269>
  801c95:	89 75 08             	mov    %esi,0x8(%ebp)
  801c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c9b:	e9 93 fd ff ff       	jmp    801a33 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ca0:	83 fa 01             	cmp    $0x1,%edx
  801ca3:	7e 16                	jle    801cbb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  801ca5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca8:	8d 50 08             	lea    0x8(%eax),%edx
  801cab:	89 55 14             	mov    %edx,0x14(%ebp)
  801cae:	8b 50 04             	mov    0x4(%eax),%edx
  801cb1:	8b 00                	mov    (%eax),%eax
  801cb3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cb6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801cb9:	eb 32                	jmp    801ced <vprintfmt+0x2df>
	else if (lflag)
  801cbb:	85 d2                	test   %edx,%edx
  801cbd:	74 18                	je     801cd7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  801cbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc2:	8d 50 04             	lea    0x4(%eax),%edx
  801cc5:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc8:	8b 30                	mov    (%eax),%esi
  801cca:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801ccd:	89 f0                	mov    %esi,%eax
  801ccf:	c1 f8 1f             	sar    $0x1f,%eax
  801cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cd5:	eb 16                	jmp    801ced <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  801cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  801cda:	8d 50 04             	lea    0x4(%eax),%edx
  801cdd:	89 55 14             	mov    %edx,0x14(%ebp)
  801ce0:	8b 30                	mov    (%eax),%esi
  801ce2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	c1 f8 1f             	sar    $0x1f,%eax
  801cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801cf3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801cf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801cfc:	0f 89 80 00 00 00    	jns    801d82 <vprintfmt+0x374>
				putch('-', putdat);
  801d02:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d06:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801d0d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801d10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d13:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d16:	f7 d8                	neg    %eax
  801d18:	83 d2 00             	adc    $0x0,%edx
  801d1b:	f7 da                	neg    %edx
			}
			base = 10;
  801d1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801d22:	eb 5e                	jmp    801d82 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801d24:	8d 45 14             	lea    0x14(%ebp),%eax
  801d27:	e8 63 fc ff ff       	call   80198f <getuint>
			base = 10;
  801d2c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801d31:	eb 4f                	jmp    801d82 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801d33:	8d 45 14             	lea    0x14(%ebp),%eax
  801d36:	e8 54 fc ff ff       	call   80198f <getuint>
			base = 8;
  801d3b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801d40:	eb 40                	jmp    801d82 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801d42:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d46:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801d4d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801d50:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d54:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801d5b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801d5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d61:	8d 50 04             	lea    0x4(%eax),%edx
  801d64:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801d67:	8b 00                	mov    (%eax),%eax
  801d69:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d6e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d73:	eb 0d                	jmp    801d82 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d75:	8d 45 14             	lea    0x14(%ebp),%eax
  801d78:	e8 12 fc ff ff       	call   80198f <getuint>
			base = 16;
  801d7d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d82:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801d86:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d8a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801d8d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d91:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d9c:	89 fa                	mov    %edi,%edx
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	e8 fa fa ff ff       	call   8018a0 <printnum>
			break;
  801da6:	e9 88 fc ff ff       	jmp    801a33 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801dab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	ff 55 08             	call   *0x8(%ebp)
			break;
  801db5:	e9 79 fc ff ff       	jmp    801a33 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801dba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dbe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801dc5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801dc8:	89 f3                	mov    %esi,%ebx
  801dca:	eb 03                	jmp    801dcf <vprintfmt+0x3c1>
  801dcc:	83 eb 01             	sub    $0x1,%ebx
  801dcf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801dd3:	75 f7                	jne    801dcc <vprintfmt+0x3be>
  801dd5:	e9 59 fc ff ff       	jmp    801a33 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801dda:	83 c4 3c             	add    $0x3c,%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5f                   	pop    %edi
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 28             	sub    $0x28,%esp
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801df1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801df5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801df8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	74 30                	je     801e33 <vsnprintf+0x51>
  801e03:	85 d2                	test   %edx,%edx
  801e05:	7e 2c                	jle    801e33 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801e07:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801e18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1c:	c7 04 24 c9 19 80 00 	movl   $0x8019c9,(%esp)
  801e23:	e8 e6 fb ff ff       	call   801a0e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801e28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	eb 05                	jmp    801e38 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801e33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801e40:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801e43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e47:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	8b 45 08             	mov    0x8(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	e8 82 ff ff ff       	call   801de2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    
  801e62:	66 90                	xchg   %ax,%ax
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801e76:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7b:	eb 03                	jmp    801e80 <strlen+0x10>
		n++;
  801e7d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801e80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801e84:	75 f7                	jne    801e7d <strlen+0xd>
		n++;
	return n;
}
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
  801e96:	eb 03                	jmp    801e9b <strnlen+0x13>
		n++;
  801e98:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e9b:	39 d0                	cmp    %edx,%eax
  801e9d:	74 06                	je     801ea5 <strnlen+0x1d>
  801e9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801ea3:	75 f3                	jne    801e98 <strnlen+0x10>
		n++;
	return n;
}
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801eb1:	89 c2                	mov    %eax,%edx
  801eb3:	83 c2 01             	add    $0x1,%edx
  801eb6:	83 c1 01             	add    $0x1,%ecx
  801eb9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ebd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ec0:	84 db                	test   %bl,%bl
  801ec2:	75 ef                	jne    801eb3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ec4:	5b                   	pop    %ebx
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ed1:	89 1c 24             	mov    %ebx,(%esp)
  801ed4:	e8 97 ff ff ff       	call   801e70 <strlen>
	strcpy(dst + len, src);
  801ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee0:	01 d8                	add    %ebx,%eax
  801ee2:	89 04 24             	mov    %eax,(%esp)
  801ee5:	e8 bd ff ff ff       	call   801ea7 <strcpy>
	return dst;
}
  801eea:	89 d8                	mov    %ebx,%eax
  801eec:	83 c4 08             	add    $0x8,%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	56                   	push   %esi
  801ef6:	53                   	push   %ebx
  801ef7:	8b 75 08             	mov    0x8(%ebp),%esi
  801efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801efd:	89 f3                	mov    %esi,%ebx
  801eff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801f02:	89 f2                	mov    %esi,%edx
  801f04:	eb 0f                	jmp    801f15 <strncpy+0x23>
		*dst++ = *src;
  801f06:	83 c2 01             	add    $0x1,%edx
  801f09:	0f b6 01             	movzbl (%ecx),%eax
  801f0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801f0f:	80 39 01             	cmpb   $0x1,(%ecx)
  801f12:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801f15:	39 da                	cmp    %ebx,%edx
  801f17:	75 ed                	jne    801f06 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	5b                   	pop    %ebx
  801f1c:	5e                   	pop    %esi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	8b 75 08             	mov    0x8(%ebp),%esi
  801f27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801f2d:	89 f0                	mov    %esi,%eax
  801f2f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801f33:	85 c9                	test   %ecx,%ecx
  801f35:	75 0b                	jne    801f42 <strlcpy+0x23>
  801f37:	eb 1d                	jmp    801f56 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801f39:	83 c0 01             	add    $0x1,%eax
  801f3c:	83 c2 01             	add    $0x1,%edx
  801f3f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801f42:	39 d8                	cmp    %ebx,%eax
  801f44:	74 0b                	je     801f51 <strlcpy+0x32>
  801f46:	0f b6 0a             	movzbl (%edx),%ecx
  801f49:	84 c9                	test   %cl,%cl
  801f4b:	75 ec                	jne    801f39 <strlcpy+0x1a>
  801f4d:	89 c2                	mov    %eax,%edx
  801f4f:	eb 02                	jmp    801f53 <strlcpy+0x34>
  801f51:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801f53:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801f56:	29 f0                	sub    %esi,%eax
}
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    

00801f5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801f65:	eb 06                	jmp    801f6d <strcmp+0x11>
		p++, q++;
  801f67:	83 c1 01             	add    $0x1,%ecx
  801f6a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801f6d:	0f b6 01             	movzbl (%ecx),%eax
  801f70:	84 c0                	test   %al,%al
  801f72:	74 04                	je     801f78 <strcmp+0x1c>
  801f74:	3a 02                	cmp    (%edx),%al
  801f76:	74 ef                	je     801f67 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801f78:	0f b6 c0             	movzbl %al,%eax
  801f7b:	0f b6 12             	movzbl (%edx),%edx
  801f7e:	29 d0                	sub    %edx,%eax
}
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	53                   	push   %ebx
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801f91:	eb 06                	jmp    801f99 <strncmp+0x17>
		n--, p++, q++;
  801f93:	83 c0 01             	add    $0x1,%eax
  801f96:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801f99:	39 d8                	cmp    %ebx,%eax
  801f9b:	74 15                	je     801fb2 <strncmp+0x30>
  801f9d:	0f b6 08             	movzbl (%eax),%ecx
  801fa0:	84 c9                	test   %cl,%cl
  801fa2:	74 04                	je     801fa8 <strncmp+0x26>
  801fa4:	3a 0a                	cmp    (%edx),%cl
  801fa6:	74 eb                	je     801f93 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801fa8:	0f b6 00             	movzbl (%eax),%eax
  801fab:	0f b6 12             	movzbl (%edx),%edx
  801fae:	29 d0                	sub    %edx,%eax
  801fb0:	eb 05                	jmp    801fb7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801fb7:	5b                   	pop    %ebx
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fc4:	eb 07                	jmp    801fcd <strchr+0x13>
		if (*s == c)
  801fc6:	38 ca                	cmp    %cl,%dl
  801fc8:	74 0f                	je     801fd9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	0f b6 10             	movzbl (%eax),%edx
  801fd0:	84 d2                	test   %dl,%dl
  801fd2:	75 f2                	jne    801fc6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fe5:	eb 07                	jmp    801fee <strfind+0x13>
		if (*s == c)
  801fe7:	38 ca                	cmp    %cl,%dl
  801fe9:	74 0a                	je     801ff5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801feb:	83 c0 01             	add    $0x1,%eax
  801fee:	0f b6 10             	movzbl (%eax),%edx
  801ff1:	84 d2                	test   %dl,%dl
  801ff3:	75 f2                	jne    801fe7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801ff5:	5d                   	pop    %ebp
  801ff6:	c3                   	ret    

00801ff7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802000:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802003:	85 c9                	test   %ecx,%ecx
  802005:	74 36                	je     80203d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802007:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80200d:	75 28                	jne    802037 <memset+0x40>
  80200f:	f6 c1 03             	test   $0x3,%cl
  802012:	75 23                	jne    802037 <memset+0x40>
		c &= 0xFF;
  802014:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802018:	89 d3                	mov    %edx,%ebx
  80201a:	c1 e3 08             	shl    $0x8,%ebx
  80201d:	89 d6                	mov    %edx,%esi
  80201f:	c1 e6 18             	shl    $0x18,%esi
  802022:	89 d0                	mov    %edx,%eax
  802024:	c1 e0 10             	shl    $0x10,%eax
  802027:	09 f0                	or     %esi,%eax
  802029:	09 c2                	or     %eax,%edx
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80202f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802032:	fc                   	cld    
  802033:	f3 ab                	rep stos %eax,%es:(%edi)
  802035:	eb 06                	jmp    80203d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802037:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203a:	fc                   	cld    
  80203b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80203d:	89 f8                	mov    %edi,%eax
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	57                   	push   %edi
  802048:	56                   	push   %esi
  802049:	8b 45 08             	mov    0x8(%ebp),%eax
  80204c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802052:	39 c6                	cmp    %eax,%esi
  802054:	73 35                	jae    80208b <memmove+0x47>
  802056:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802059:	39 d0                	cmp    %edx,%eax
  80205b:	73 2e                	jae    80208b <memmove+0x47>
		s += n;
		d += n;
  80205d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802060:	89 d6                	mov    %edx,%esi
  802062:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802064:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80206a:	75 13                	jne    80207f <memmove+0x3b>
  80206c:	f6 c1 03             	test   $0x3,%cl
  80206f:	75 0e                	jne    80207f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802071:	83 ef 04             	sub    $0x4,%edi
  802074:	8d 72 fc             	lea    -0x4(%edx),%esi
  802077:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80207a:	fd                   	std    
  80207b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80207d:	eb 09                	jmp    802088 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80207f:	83 ef 01             	sub    $0x1,%edi
  802082:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802085:	fd                   	std    
  802086:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802088:	fc                   	cld    
  802089:	eb 1d                	jmp    8020a8 <memmove+0x64>
  80208b:	89 f2                	mov    %esi,%edx
  80208d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80208f:	f6 c2 03             	test   $0x3,%dl
  802092:	75 0f                	jne    8020a3 <memmove+0x5f>
  802094:	f6 c1 03             	test   $0x3,%cl
  802097:	75 0a                	jne    8020a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802099:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80209c:	89 c7                	mov    %eax,%edi
  80209e:	fc                   	cld    
  80209f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8020a1:	eb 05                	jmp    8020a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8020a3:	89 c7                	mov    %eax,%edi
  8020a5:	fc                   	cld    
  8020a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8020b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c3:	89 04 24             	mov    %eax,(%esp)
  8020c6:	e8 79 ff ff ff       	call   802044 <memmove>
}
  8020cb:	c9                   	leave  
  8020cc:	c3                   	ret    

008020cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	56                   	push   %esi
  8020d1:	53                   	push   %ebx
  8020d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8020d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d8:	89 d6                	mov    %edx,%esi
  8020da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020dd:	eb 1a                	jmp    8020f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8020df:	0f b6 02             	movzbl (%edx),%eax
  8020e2:	0f b6 19             	movzbl (%ecx),%ebx
  8020e5:	38 d8                	cmp    %bl,%al
  8020e7:	74 0a                	je     8020f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8020e9:	0f b6 c0             	movzbl %al,%eax
  8020ec:	0f b6 db             	movzbl %bl,%ebx
  8020ef:	29 d8                	sub    %ebx,%eax
  8020f1:	eb 0f                	jmp    802102 <memcmp+0x35>
		s1++, s2++;
  8020f3:	83 c2 01             	add    $0x1,%edx
  8020f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020f9:	39 f2                	cmp    %esi,%edx
  8020fb:	75 e2                	jne    8020df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8020fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802102:	5b                   	pop    %ebx
  802103:	5e                   	pop    %esi
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	8b 45 08             	mov    0x8(%ebp),%eax
  80210c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80210f:	89 c2                	mov    %eax,%edx
  802111:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802114:	eb 07                	jmp    80211d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  802116:	38 08                	cmp    %cl,(%eax)
  802118:	74 07                	je     802121 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80211a:	83 c0 01             	add    $0x1,%eax
  80211d:	39 d0                	cmp    %edx,%eax
  80211f:	72 f5                	jb     802116 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    

00802123 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802123:	55                   	push   %ebp
  802124:	89 e5                	mov    %esp,%ebp
  802126:	57                   	push   %edi
  802127:	56                   	push   %esi
  802128:	53                   	push   %ebx
  802129:	8b 55 08             	mov    0x8(%ebp),%edx
  80212c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80212f:	eb 03                	jmp    802134 <strtol+0x11>
		s++;
  802131:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802134:	0f b6 0a             	movzbl (%edx),%ecx
  802137:	80 f9 09             	cmp    $0x9,%cl
  80213a:	74 f5                	je     802131 <strtol+0xe>
  80213c:	80 f9 20             	cmp    $0x20,%cl
  80213f:	74 f0                	je     802131 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802141:	80 f9 2b             	cmp    $0x2b,%cl
  802144:	75 0a                	jne    802150 <strtol+0x2d>
		s++;
  802146:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802149:	bf 00 00 00 00       	mov    $0x0,%edi
  80214e:	eb 11                	jmp    802161 <strtol+0x3e>
  802150:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802155:	80 f9 2d             	cmp    $0x2d,%cl
  802158:	75 07                	jne    802161 <strtol+0x3e>
		s++, neg = 1;
  80215a:	8d 52 01             	lea    0x1(%edx),%edx
  80215d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802161:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802166:	75 15                	jne    80217d <strtol+0x5a>
  802168:	80 3a 30             	cmpb   $0x30,(%edx)
  80216b:	75 10                	jne    80217d <strtol+0x5a>
  80216d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802171:	75 0a                	jne    80217d <strtol+0x5a>
		s += 2, base = 16;
  802173:	83 c2 02             	add    $0x2,%edx
  802176:	b8 10 00 00 00       	mov    $0x10,%eax
  80217b:	eb 10                	jmp    80218d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80217d:	85 c0                	test   %eax,%eax
  80217f:	75 0c                	jne    80218d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802181:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802183:	80 3a 30             	cmpb   $0x30,(%edx)
  802186:	75 05                	jne    80218d <strtol+0x6a>
		s++, base = 8;
  802188:	83 c2 01             	add    $0x1,%edx
  80218b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80218d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802192:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802195:	0f b6 0a             	movzbl (%edx),%ecx
  802198:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80219b:	89 f0                	mov    %esi,%eax
  80219d:	3c 09                	cmp    $0x9,%al
  80219f:	77 08                	ja     8021a9 <strtol+0x86>
			dig = *s - '0';
  8021a1:	0f be c9             	movsbl %cl,%ecx
  8021a4:	83 e9 30             	sub    $0x30,%ecx
  8021a7:	eb 20                	jmp    8021c9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8021a9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8021ac:	89 f0                	mov    %esi,%eax
  8021ae:	3c 19                	cmp    $0x19,%al
  8021b0:	77 08                	ja     8021ba <strtol+0x97>
			dig = *s - 'a' + 10;
  8021b2:	0f be c9             	movsbl %cl,%ecx
  8021b5:	83 e9 57             	sub    $0x57,%ecx
  8021b8:	eb 0f                	jmp    8021c9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8021ba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8021bd:	89 f0                	mov    %esi,%eax
  8021bf:	3c 19                	cmp    $0x19,%al
  8021c1:	77 16                	ja     8021d9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8021c3:	0f be c9             	movsbl %cl,%ecx
  8021c6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8021c9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8021cc:	7d 0f                	jge    8021dd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8021ce:	83 c2 01             	add    $0x1,%edx
  8021d1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8021d5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8021d7:	eb bc                	jmp    802195 <strtol+0x72>
  8021d9:	89 d8                	mov    %ebx,%eax
  8021db:	eb 02                	jmp    8021df <strtol+0xbc>
  8021dd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8021df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021e3:	74 05                	je     8021ea <strtol+0xc7>
		*endptr = (char *) s;
  8021e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021e8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8021ea:	f7 d8                	neg    %eax
  8021ec:	85 ff                	test   %edi,%edi
  8021ee:	0f 44 c3             	cmove  %ebx,%eax
}
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5f                   	pop    %edi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	83 ec 10             	sub    $0x10,%esp
  802208:	8b 75 08             	mov    0x8(%ebp),%esi
  80220b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802211:	85 c0                	test   %eax,%eax
  802213:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802218:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80221b:	89 04 24             	mov    %eax,(%esp)
  80221e:	e8 96 e1 ff ff       	call   8003b9 <sys_ipc_recv>

	if(ret < 0) {
  802223:	85 c0                	test   %eax,%eax
  802225:	79 16                	jns    80223d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802227:	85 f6                	test   %esi,%esi
  802229:	74 06                	je     802231 <ipc_recv+0x31>
  80222b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802231:	85 db                	test   %ebx,%ebx
  802233:	74 3e                	je     802273 <ipc_recv+0x73>
  802235:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80223b:	eb 36                	jmp    802273 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80223d:	e8 23 df ff ff       	call   800165 <sys_getenvid>
  802242:	25 ff 03 00 00       	and    $0x3ff,%eax
  802247:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80224a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80224f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802254:	85 f6                	test   %esi,%esi
  802256:	74 05                	je     80225d <ipc_recv+0x5d>
  802258:	8b 40 74             	mov    0x74(%eax),%eax
  80225b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80225d:	85 db                	test   %ebx,%ebx
  80225f:	74 0a                	je     80226b <ipc_recv+0x6b>
  802261:	a1 08 40 80 00       	mov    0x804008,%eax
  802266:	8b 40 78             	mov    0x78(%eax),%eax
  802269:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80226b:	a1 08 40 80 00       	mov    0x804008,%eax
  802270:	8b 40 70             	mov    0x70(%eax),%eax
}
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	5b                   	pop    %ebx
  802277:	5e                   	pop    %esi
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    

0080227a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
  80227d:	57                   	push   %edi
  80227e:	56                   	push   %esi
  80227f:	53                   	push   %ebx
  802280:	83 ec 1c             	sub    $0x1c,%esp
  802283:	8b 7d 08             	mov    0x8(%ebp),%edi
  802286:	8b 75 0c             	mov    0xc(%ebp),%esi
  802289:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80228c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80228e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802293:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802296:	8b 45 14             	mov    0x14(%ebp),%eax
  802299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a5:	89 3c 24             	mov    %edi,(%esp)
  8022a8:	e8 e9 e0 ff ff       	call   800396 <sys_ipc_try_send>

		if(ret >= 0) break;
  8022ad:	85 c0                	test   %eax,%eax
  8022af:	79 2c                	jns    8022dd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8022b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b4:	74 20                	je     8022d6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8022b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ba:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  8022c1:	00 
  8022c2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8022c9:	00 
  8022ca:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  8022d1:	e8 b0 f4 ff ff       	call   801786 <_panic>
		}
		sys_yield();
  8022d6:	e8 a9 de ff ff       	call   800184 <sys_yield>
	}
  8022db:	eb b9                	jmp    802296 <ipc_send+0x1c>
}
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    

008022e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022f0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022f9:	8b 52 50             	mov    0x50(%edx),%edx
  8022fc:	39 ca                	cmp    %ecx,%edx
  8022fe:	75 0d                	jne    80230d <ipc_find_env+0x28>
			return envs[i].env_id;
  802300:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802303:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802308:	8b 40 40             	mov    0x40(%eax),%eax
  80230b:	eb 0e                	jmp    80231b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80230d:	83 c0 01             	add    $0x1,%eax
  802310:	3d 00 04 00 00       	cmp    $0x400,%eax
  802315:	75 d9                	jne    8022f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802317:	66 b8 00 00          	mov    $0x0,%ax
}
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    

0080231d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80231d:	55                   	push   %ebp
  80231e:	89 e5                	mov    %esp,%ebp
  802320:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802323:	89 d0                	mov    %edx,%eax
  802325:	c1 e8 16             	shr    $0x16,%eax
  802328:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802334:	f6 c1 01             	test   $0x1,%cl
  802337:	74 1d                	je     802356 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802339:	c1 ea 0c             	shr    $0xc,%edx
  80233c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802343:	f6 c2 01             	test   $0x1,%dl
  802346:	74 0e                	je     802356 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802348:	c1 ea 0c             	shr    $0xc,%edx
  80234b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802352:	ef 
  802353:	0f b7 c0             	movzwl %ax,%eax
}
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 0c             	sub    $0xc,%esp
  802366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80236a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80236e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802372:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802376:	85 c0                	test   %eax,%eax
  802378:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80237c:	89 ea                	mov    %ebp,%edx
  80237e:	89 0c 24             	mov    %ecx,(%esp)
  802381:	75 2d                	jne    8023b0 <__udivdi3+0x50>
  802383:	39 e9                	cmp    %ebp,%ecx
  802385:	77 61                	ja     8023e8 <__udivdi3+0x88>
  802387:	85 c9                	test   %ecx,%ecx
  802389:	89 ce                	mov    %ecx,%esi
  80238b:	75 0b                	jne    802398 <__udivdi3+0x38>
  80238d:	b8 01 00 00 00       	mov    $0x1,%eax
  802392:	31 d2                	xor    %edx,%edx
  802394:	f7 f1                	div    %ecx
  802396:	89 c6                	mov    %eax,%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	89 e8                	mov    %ebp,%eax
  80239c:	f7 f6                	div    %esi
  80239e:	89 c5                	mov    %eax,%ebp
  8023a0:	89 f8                	mov    %edi,%eax
  8023a2:	f7 f6                	div    %esi
  8023a4:	89 ea                	mov    %ebp,%edx
  8023a6:	83 c4 0c             	add    $0xc,%esp
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	39 e8                	cmp    %ebp,%eax
  8023b2:	77 24                	ja     8023d8 <__udivdi3+0x78>
  8023b4:	0f bd e8             	bsr    %eax,%ebp
  8023b7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ba:	75 3c                	jne    8023f8 <__udivdi3+0x98>
  8023bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023c0:	39 34 24             	cmp    %esi,(%esp)
  8023c3:	0f 86 9f 00 00 00    	jbe    802468 <__udivdi3+0x108>
  8023c9:	39 d0                	cmp    %edx,%eax
  8023cb:	0f 82 97 00 00 00    	jb     802468 <__udivdi3+0x108>
  8023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	31 c0                	xor    %eax,%eax
  8023dc:	83 c4 0c             	add    $0xc,%esp
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	89 f8                	mov    %edi,%eax
  8023ea:	f7 f1                	div    %ecx
  8023ec:	31 d2                	xor    %edx,%edx
  8023ee:	83 c4 0c             	add    $0xc,%esp
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	8b 3c 24             	mov    (%esp),%edi
  8023fd:	d3 e0                	shl    %cl,%eax
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	b8 20 00 00 00       	mov    $0x20,%eax
  802406:	29 e8                	sub    %ebp,%eax
  802408:	89 c1                	mov    %eax,%ecx
  80240a:	d3 ef                	shr    %cl,%edi
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802412:	8b 3c 24             	mov    (%esp),%edi
  802415:	09 74 24 08          	or     %esi,0x8(%esp)
  802419:	89 d6                	mov    %edx,%esi
  80241b:	d3 e7                	shl    %cl,%edi
  80241d:	89 c1                	mov    %eax,%ecx
  80241f:	89 3c 24             	mov    %edi,(%esp)
  802422:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802426:	d3 ee                	shr    %cl,%esi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	d3 e2                	shl    %cl,%edx
  80242c:	89 c1                	mov    %eax,%ecx
  80242e:	d3 ef                	shr    %cl,%edi
  802430:	09 d7                	or     %edx,%edi
  802432:	89 f2                	mov    %esi,%edx
  802434:	89 f8                	mov    %edi,%eax
  802436:	f7 74 24 08          	divl   0x8(%esp)
  80243a:	89 d6                	mov    %edx,%esi
  80243c:	89 c7                	mov    %eax,%edi
  80243e:	f7 24 24             	mull   (%esp)
  802441:	39 d6                	cmp    %edx,%esi
  802443:	89 14 24             	mov    %edx,(%esp)
  802446:	72 30                	jb     802478 <__udivdi3+0x118>
  802448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80244c:	89 e9                	mov    %ebp,%ecx
  80244e:	d3 e2                	shl    %cl,%edx
  802450:	39 c2                	cmp    %eax,%edx
  802452:	73 05                	jae    802459 <__udivdi3+0xf9>
  802454:	3b 34 24             	cmp    (%esp),%esi
  802457:	74 1f                	je     802478 <__udivdi3+0x118>
  802459:	89 f8                	mov    %edi,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	e9 7a ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	b8 01 00 00 00       	mov    $0x1,%eax
  80246f:	e9 68 ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	8d 47 ff             	lea    -0x1(%edi),%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	83 c4 0c             	add    $0xc,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	83 ec 14             	sub    $0x14,%esp
  802496:	8b 44 24 28          	mov    0x28(%esp),%eax
  80249a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80249e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024a2:	89 c7                	mov    %eax,%edi
  8024a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024b0:	89 34 24             	mov    %esi,(%esp)
  8024b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024bf:	75 17                	jne    8024d8 <__umoddi3+0x48>
  8024c1:	39 fe                	cmp    %edi,%esi
  8024c3:	76 4b                	jbe    802510 <__umoddi3+0x80>
  8024c5:	89 c8                	mov    %ecx,%eax
  8024c7:	89 fa                	mov    %edi,%edx
  8024c9:	f7 f6                	div    %esi
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	31 d2                	xor    %edx,%edx
  8024cf:	83 c4 14             	add    $0x14,%esp
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	5d                   	pop    %ebp
  8024d5:	c3                   	ret    
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	39 f8                	cmp    %edi,%eax
  8024da:	77 54                	ja     802530 <__umoddi3+0xa0>
  8024dc:	0f bd e8             	bsr    %eax,%ebp
  8024df:	83 f5 1f             	xor    $0x1f,%ebp
  8024e2:	75 5c                	jne    802540 <__umoddi3+0xb0>
  8024e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024e8:	39 3c 24             	cmp    %edi,(%esp)
  8024eb:	0f 87 e7 00 00 00    	ja     8025d8 <__umoddi3+0x148>
  8024f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024f5:	29 f1                	sub    %esi,%ecx
  8024f7:	19 c7                	sbb    %eax,%edi
  8024f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802501:	8b 44 24 08          	mov    0x8(%esp),%eax
  802505:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802509:	83 c4 14             	add    $0x14,%esp
  80250c:	5e                   	pop    %esi
  80250d:	5f                   	pop    %edi
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    
  802510:	85 f6                	test   %esi,%esi
  802512:	89 f5                	mov    %esi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f6                	div    %esi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	8b 44 24 04          	mov    0x4(%esp),%eax
  802525:	31 d2                	xor    %edx,%edx
  802527:	f7 f5                	div    %ebp
  802529:	89 c8                	mov    %ecx,%eax
  80252b:	f7 f5                	div    %ebp
  80252d:	eb 9c                	jmp    8024cb <__umoddi3+0x3b>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 fa                	mov    %edi,%edx
  802534:	83 c4 14             	add    $0x14,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 04 24             	mov    (%esp),%eax
  802543:	be 20 00 00 00       	mov    $0x20,%esi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ee                	sub    %ebp,%esi
  80254c:	d3 e2                	shl    %cl,%edx
  80254e:	89 f1                	mov    %esi,%ecx
  802550:	d3 e8                	shr    %cl,%eax
  802552:	89 e9                	mov    %ebp,%ecx
  802554:	89 44 24 04          	mov    %eax,0x4(%esp)
  802558:	8b 04 24             	mov    (%esp),%eax
  80255b:	09 54 24 04          	or     %edx,0x4(%esp)
  80255f:	89 fa                	mov    %edi,%edx
  802561:	d3 e0                	shl    %cl,%eax
  802563:	89 f1                	mov    %esi,%ecx
  802565:	89 44 24 08          	mov    %eax,0x8(%esp)
  802569:	8b 44 24 10          	mov    0x10(%esp),%eax
  80256d:	d3 ea                	shr    %cl,%edx
  80256f:	89 e9                	mov    %ebp,%ecx
  802571:	d3 e7                	shl    %cl,%edi
  802573:	89 f1                	mov    %esi,%ecx
  802575:	d3 e8                	shr    %cl,%eax
  802577:	89 e9                	mov    %ebp,%ecx
  802579:	09 f8                	or     %edi,%eax
  80257b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80257f:	f7 74 24 04          	divl   0x4(%esp)
  802583:	d3 e7                	shl    %cl,%edi
  802585:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802589:	89 d7                	mov    %edx,%edi
  80258b:	f7 64 24 08          	mull   0x8(%esp)
  80258f:	39 d7                	cmp    %edx,%edi
  802591:	89 c1                	mov    %eax,%ecx
  802593:	89 14 24             	mov    %edx,(%esp)
  802596:	72 2c                	jb     8025c4 <__umoddi3+0x134>
  802598:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80259c:	72 22                	jb     8025c0 <__umoddi3+0x130>
  80259e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025a2:	29 c8                	sub    %ecx,%eax
  8025a4:	19 d7                	sbb    %edx,%edi
  8025a6:	89 e9                	mov    %ebp,%ecx
  8025a8:	89 fa                	mov    %edi,%edx
  8025aa:	d3 e8                	shr    %cl,%eax
  8025ac:	89 f1                	mov    %esi,%ecx
  8025ae:	d3 e2                	shl    %cl,%edx
  8025b0:	89 e9                	mov    %ebp,%ecx
  8025b2:	d3 ef                	shr    %cl,%edi
  8025b4:	09 d0                	or     %edx,%eax
  8025b6:	89 fa                	mov    %edi,%edx
  8025b8:	83 c4 14             	add    $0x14,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	39 d7                	cmp    %edx,%edi
  8025c2:	75 da                	jne    80259e <__umoddi3+0x10e>
  8025c4:	8b 14 24             	mov    (%esp),%edx
  8025c7:	89 c1                	mov    %eax,%ecx
  8025c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025d1:	eb cb                	jmp    80259e <__umoddi3+0x10e>
  8025d3:	90                   	nop
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025dc:	0f 82 0f ff ff ff    	jb     8024f1 <__umoddi3+0x61>
  8025e2:	e9 1a ff ff ff       	jmp    802501 <__umoddi3+0x71>
