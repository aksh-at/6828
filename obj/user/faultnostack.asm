
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 b4 04 80 	movl   $0x8004b4,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 da 02 00 00       	call   800327 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800067:	e8 dd 00 00 00       	call   800149 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 07 00 00 00       	call   8000a1 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a7:	e8 0e 06 00 00       	call   8006ba <close_all>
	sys_env_destroy(0);
  8000ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b3:	e8 3f 00 00 00       	call   8000f7 <sys_env_destroy>
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800100:	b9 00 00 00 00       	mov    $0x0,%ecx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 cb                	mov    %ecx,%ebx
  80010f:	89 cf                	mov    %ecx,%edi
  800111:	89 ce                	mov    %ecx,%esi
  800113:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800115:	85 c0                	test   %eax,%eax
  800117:	7e 28                	jle    800141 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800124:	00 
  800125:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  80012c:	00 
  80012d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800134:	00 
  800135:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  80013c:	e8 55 16 00 00       	call   801796 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800141:	83 c4 2c             	add    $0x2c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_yield>:

void
sys_yield(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 0b 00 00 00       	mov    $0xb,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800190:	be 00 00 00 00       	mov    $0x0,%esi
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	89 f7                	mov    %esi,%edi
  8001a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	7e 28                	jle    8001d3 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  8001ce:	e8 c3 15 00 00       	call   801796 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  800221:	e8 70 15 00 00       	call   801796 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800226:	83 c4 2c             	add    $0x2c,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	b8 06 00 00 00       	mov    $0x6,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 df                	mov    %ebx,%edi
  800249:	89 de                	mov    %ebx,%esi
  80024b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	7e 28                	jle    800279 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800251:	89 44 24 10          	mov    %eax,0x10(%esp)
  800255:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025c:	00 
  80025d:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  800264:	00 
  800265:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026c:	00 
  80026d:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  800274:	e8 1d 15 00 00       	call   801796 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800279:	83 c4 2c             	add    $0x2c,%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	b8 08 00 00 00       	mov    $0x8,%eax
  800294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 df                	mov    %ebx,%edi
  80029c:	89 de                	mov    %ebx,%esi
  80029e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	7e 28                	jle    8002cc <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002af:	00 
  8002b0:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  8002b7:	00 
  8002b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bf:	00 
  8002c0:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  8002c7:	e8 ca 14 00 00       	call   801796 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002cc:	83 c4 2c             	add    $0x2c,%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 df                	mov    %ebx,%edi
  8002ef:	89 de                	mov    %ebx,%esi
  8002f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	7e 28                	jle    80031f <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800302:	00 
  800303:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  80030a:	00 
  80030b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800312:	00 
  800313:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  80031a:	e8 77 14 00 00       	call   801796 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80031f:	83 c4 2c             	add    $0x2c,%esp
  800322:	5b                   	pop    %ebx
  800323:	5e                   	pop    %esi
  800324:	5f                   	pop    %edi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800330:	bb 00 00 00 00       	mov    $0x0,%ebx
  800335:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	89 df                	mov    %ebx,%edi
  800342:	89 de                	mov    %ebx,%esi
  800344:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 28                	jle    800372 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800355:	00 
  800356:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  80036d:	e8 24 14 00 00       	call   801796 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800372:	83 c4 2c             	add    $0x2c,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	be 00 00 00 00       	mov    $0x0,%esi
  800385:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800393:	8b 7d 14             	mov    0x14(%ebp),%edi
  800396:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800398:	5b                   	pop    %ebx
  800399:	5e                   	pop    %esi
  80039a:	5f                   	pop    %edi
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	89 cb                	mov    %ecx,%ebx
  8003b5:	89 cf                	mov    %ecx,%edi
  8003b7:	89 ce                	mov    %ecx,%esi
  8003b9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	7e 28                	jle    8003e7 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c3:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ca:	00 
  8003cb:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  8003d2:	00 
  8003d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003da:	00 
  8003db:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  8003e2:	e8 af 13 00 00       	call   801796 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e7:	83 c4 2c             	add    $0x2c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003ff:	89 d1                	mov    %edx,%ecx
  800401:	89 d3                	mov    %edx,%ebx
  800403:	89 d7                	mov    %edx,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 df                	mov    %ebx,%edi
  800429:	89 de                	mov    %ebx,%esi
  80042b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80042d:	85 c0                	test   %eax,%eax
  80042f:	7e 28                	jle    800459 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800431:	89 44 24 10          	mov    %eax,0x10(%esp)
  800435:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80043c:	00 
  80043d:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  800444:	00 
  800445:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80044c:	00 
  80044d:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  800454:	e8 3d 13 00 00       	call   801796 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800459:	83 c4 2c             	add    $0x2c,%esp
  80045c:	5b                   	pop    %ebx
  80045d:	5e                   	pop    %esi
  80045e:	5f                   	pop    %edi
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80046f:	b8 10 00 00 00       	mov    $0x10,%eax
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	8b 55 08             	mov    0x8(%ebp),%edx
  80047a:	89 df                	mov    %ebx,%edi
  80047c:	89 de                	mov    %ebx,%esi
  80047e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800480:	85 c0                	test   %eax,%eax
  800482:	7e 28                	jle    8004ac <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800484:	89 44 24 10          	mov    %eax,0x10(%esp)
  800488:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80048f:	00 
  800490:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  800497:	00 
  800498:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80049f:	00 
  8004a0:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  8004a7:	e8 ea 12 00 00       	call   801796 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8004ac:	83 c4 2c             	add    $0x2c,%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5f                   	pop    %edi
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8004b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8004b5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8004ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8004bc:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8004bf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8004c4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8004c8:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8004cc:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8004ce:	83 c4 08             	add    $0x8,%esp
	popal
  8004d1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8004d2:	83 c4 04             	add    $0x4,%esp
	popfl
  8004d5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8004d6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8004d7:	c3                   	ret    
  8004d8:	66 90                	xchg   %ax,%ax
  8004da:	66 90                	xchg   %ax,%ax
  8004dc:	66 90                	xchg   %ax,%ax
  8004de:	66 90                	xchg   %ax,%ax

008004e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8004fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800500:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800512:	89 c2                	mov    %eax,%edx
  800514:	c1 ea 16             	shr    $0x16,%edx
  800517:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80051e:	f6 c2 01             	test   $0x1,%dl
  800521:	74 11                	je     800534 <fd_alloc+0x2d>
  800523:	89 c2                	mov    %eax,%edx
  800525:	c1 ea 0c             	shr    $0xc,%edx
  800528:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80052f:	f6 c2 01             	test   $0x1,%dl
  800532:	75 09                	jne    80053d <fd_alloc+0x36>
			*fd_store = fd;
  800534:	89 01                	mov    %eax,(%ecx)
			return 0;
  800536:	b8 00 00 00 00       	mov    $0x0,%eax
  80053b:	eb 17                	jmp    800554 <fd_alloc+0x4d>
  80053d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800542:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800547:	75 c9                	jne    800512 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800549:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80054f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80055c:	83 f8 1f             	cmp    $0x1f,%eax
  80055f:	77 36                	ja     800597 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800561:	c1 e0 0c             	shl    $0xc,%eax
  800564:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800569:	89 c2                	mov    %eax,%edx
  80056b:	c1 ea 16             	shr    $0x16,%edx
  80056e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800575:	f6 c2 01             	test   $0x1,%dl
  800578:	74 24                	je     80059e <fd_lookup+0x48>
  80057a:	89 c2                	mov    %eax,%edx
  80057c:	c1 ea 0c             	shr    $0xc,%edx
  80057f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800586:	f6 c2 01             	test   $0x1,%dl
  800589:	74 1a                	je     8005a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80058b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058e:	89 02                	mov    %eax,(%edx)
	return 0;
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	eb 13                	jmp    8005aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80059c:	eb 0c                	jmp    8005aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80059e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005a3:	eb 05                	jmp    8005aa <fd_lookup+0x54>
  8005a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	83 ec 18             	sub    $0x18,%esp
  8005b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8005b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ba:	eb 13                	jmp    8005cf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8005bc:	39 08                	cmp    %ecx,(%eax)
  8005be:	75 0c                	jne    8005cc <dev_lookup+0x20>
			*dev = devtab[i];
  8005c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8005c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ca:	eb 38                	jmp    800604 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005cc:	83 c2 01             	add    $0x1,%edx
  8005cf:	8b 04 95 14 27 80 00 	mov    0x802714(,%edx,4),%eax
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	75 e2                	jne    8005bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005da:	a1 08 40 80 00       	mov    0x804008,%eax
  8005df:	8b 40 48             	mov    0x48(%eax),%eax
  8005e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ea:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  8005f1:	e8 99 12 00 00       	call   80188f <cprintf>
	*dev = 0;
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8005ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	56                   	push   %esi
  80060a:	53                   	push   %ebx
  80060b:	83 ec 20             	sub    $0x20,%esp
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80061b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 2a ff ff ff       	call   800556 <fd_lookup>
  80062c:	85 c0                	test   %eax,%eax
  80062e:	78 05                	js     800635 <fd_close+0x2f>
	    || fd != fd2)
  800630:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800633:	74 0c                	je     800641 <fd_close+0x3b>
		return (must_exist ? r : 0);
  800635:	84 db                	test   %bl,%bl
  800637:	ba 00 00 00 00       	mov    $0x0,%edx
  80063c:	0f 44 c2             	cmove  %edx,%eax
  80063f:	eb 3f                	jmp    800680 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	89 44 24 04          	mov    %eax,0x4(%esp)
  800648:	8b 06                	mov    (%esi),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	e8 5a ff ff ff       	call   8005ac <dev_lookup>
  800652:	89 c3                	mov    %eax,%ebx
  800654:	85 c0                	test   %eax,%eax
  800656:	78 16                	js     80066e <fd_close+0x68>
		if (dev->dev_close)
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80065e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800663:	85 c0                	test   %eax,%eax
  800665:	74 07                	je     80066e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800667:	89 34 24             	mov    %esi,(%esp)
  80066a:	ff d0                	call   *%eax
  80066c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800679:	e8 b0 fb ff ff       	call   80022e <sys_page_unmap>
	return r;
  80067e:	89 d8                	mov    %ebx,%eax
}
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	5b                   	pop    %ebx
  800684:	5e                   	pop    %esi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	e8 b7 fe ff ff       	call   800556 <fd_lookup>
  80069f:	89 c2                	mov    %eax,%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	78 13                	js     8006b8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8006a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8006ac:	00 
  8006ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 4e ff ff ff       	call   800606 <fd_close>
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <close_all>:

void
close_all(void)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8006c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8006c6:	89 1c 24             	mov    %ebx,(%esp)
  8006c9:	e8 b9 ff ff ff       	call   800687 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8006ce:	83 c3 01             	add    $0x1,%ebx
  8006d1:	83 fb 20             	cmp    $0x20,%ebx
  8006d4:	75 f0                	jne    8006c6 <close_all+0xc>
		close(i);
}
  8006d6:	83 c4 14             	add    $0x14,%esp
  8006d9:	5b                   	pop    %ebx
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	57                   	push   %edi
  8006e0:	56                   	push   %esi
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8006e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 5f fe ff ff       	call   800556 <fd_lookup>
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	0f 88 e1 00 00 00    	js     8007e2 <dup+0x106>
		return r;
	close(newfdnum);
  800701:	8b 45 0c             	mov    0xc(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 7b ff ff ff       	call   800687 <close>

	newfd = INDEX2FD(newfdnum);
  80070c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070f:	c1 e3 0c             	shl    $0xc,%ebx
  800712:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 cd fd ff ff       	call   8004f0 <fd2data>
  800723:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800725:	89 1c 24             	mov    %ebx,(%esp)
  800728:	e8 c3 fd ff ff       	call   8004f0 <fd2data>
  80072d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80072f:	89 f0                	mov    %esi,%eax
  800731:	c1 e8 16             	shr    $0x16,%eax
  800734:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80073b:	a8 01                	test   $0x1,%al
  80073d:	74 43                	je     800782 <dup+0xa6>
  80073f:	89 f0                	mov    %esi,%eax
  800741:	c1 e8 0c             	shr    $0xc,%eax
  800744:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80074b:	f6 c2 01             	test   $0x1,%dl
  80074e:	74 32                	je     800782 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800750:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800757:	25 07 0e 00 00       	and    $0xe07,%eax
  80075c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800760:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800764:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80076b:	00 
  80076c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800770:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800777:	e8 5f fa ff ff       	call   8001db <sys_page_map>
  80077c:	89 c6                	mov    %eax,%esi
  80077e:	85 c0                	test   %eax,%eax
  800780:	78 3e                	js     8007c0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800785:	89 c2                	mov    %eax,%edx
  800787:	c1 ea 0c             	shr    $0xc,%edx
  80078a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800791:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800797:	89 54 24 10          	mov    %edx,0x10(%esp)
  80079b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80079f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007a6:	00 
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007b2:	e8 24 fa ff ff       	call   8001db <sys_page_map>
  8007b7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007bc:	85 f6                	test   %esi,%esi
  8007be:	79 22                	jns    8007e2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8007c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007cb:	e8 5e fa ff ff       	call   80022e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8007d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007db:	e8 4e fa ff ff       	call   80022e <sys_page_unmap>
	return r;
  8007e0:	89 f0                	mov    %esi,%eax
}
  8007e2:	83 c4 3c             	add    $0x3c,%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	83 ec 24             	sub    $0x24,%esp
  8007f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	89 1c 24             	mov    %ebx,(%esp)
  8007fe:	e8 53 fd ff ff       	call   800556 <fd_lookup>
  800803:	89 c2                	mov    %eax,%edx
  800805:	85 d2                	test   %edx,%edx
  800807:	78 6d                	js     800876 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800813:	8b 00                	mov    (%eax),%eax
  800815:	89 04 24             	mov    %eax,(%esp)
  800818:	e8 8f fd ff ff       	call   8005ac <dev_lookup>
  80081d:	85 c0                	test   %eax,%eax
  80081f:	78 55                	js     800876 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800824:	8b 50 08             	mov    0x8(%eax),%edx
  800827:	83 e2 03             	and    $0x3,%edx
  80082a:	83 fa 01             	cmp    $0x1,%edx
  80082d:	75 23                	jne    800852 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80082f:	a1 08 40 80 00       	mov    0x804008,%eax
  800834:	8b 40 48             	mov    0x48(%eax),%eax
  800837:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083f:	c7 04 24 d9 26 80 00 	movl   $0x8026d9,(%esp)
  800846:	e8 44 10 00 00       	call   80188f <cprintf>
		return -E_INVAL;
  80084b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800850:	eb 24                	jmp    800876 <read+0x8c>
	}
	if (!dev->dev_read)
  800852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800855:	8b 52 08             	mov    0x8(%edx),%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 15                	je     800871 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80085c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80085f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80086a:	89 04 24             	mov    %eax,(%esp)
  80086d:	ff d2                	call   *%edx
  80086f:	eb 05                	jmp    800876 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800876:	83 c4 24             	add    $0x24,%esp
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	83 ec 1c             	sub    $0x1c,%esp
  800885:	8b 7d 08             	mov    0x8(%ebp),%edi
  800888:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80088b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800890:	eb 23                	jmp    8008b5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800892:	89 f0                	mov    %esi,%eax
  800894:	29 d8                	sub    %ebx,%eax
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	03 45 0c             	add    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	89 3c 24             	mov    %edi,(%esp)
  8008a6:	e8 3f ff ff ff       	call   8007ea <read>
		if (m < 0)
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	78 10                	js     8008bf <readn+0x43>
			return m;
		if (m == 0)
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	74 0a                	je     8008bd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008b3:	01 c3                	add    %eax,%ebx
  8008b5:	39 f3                	cmp    %esi,%ebx
  8008b7:	72 d9                	jb     800892 <readn+0x16>
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	eb 02                	jmp    8008bf <readn+0x43>
  8008bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008bf:	83 c4 1c             	add    $0x1c,%esp
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 24             	sub    $0x24,%esp
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	89 1c 24             	mov    %ebx,(%esp)
  8008db:	e8 76 fc ff ff       	call   800556 <fd_lookup>
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	78 68                	js     80094e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f0:	8b 00                	mov    (%eax),%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 b2 fc ff ff       	call   8005ac <dev_lookup>
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	78 50                	js     80094e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800901:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800905:	75 23                	jne    80092a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800907:	a1 08 40 80 00       	mov    0x804008,%eax
  80090c:	8b 40 48             	mov    0x48(%eax),%eax
  80090f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800913:	89 44 24 04          	mov    %eax,0x4(%esp)
  800917:	c7 04 24 f5 26 80 00 	movl   $0x8026f5,(%esp)
  80091e:	e8 6c 0f 00 00       	call   80188f <cprintf>
		return -E_INVAL;
  800923:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800928:	eb 24                	jmp    80094e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80092a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80092d:	8b 52 0c             	mov    0xc(%edx),%edx
  800930:	85 d2                	test   %edx,%edx
  800932:	74 15                	je     800949 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800937:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	ff d2                	call   *%edx
  800947:	eb 05                	jmp    80094e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800949:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80094e:	83 c4 24             	add    $0x24,%esp
  800951:	5b                   	pop    %ebx
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <seek>:

int
seek(int fdnum, off_t offset)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80095a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 ea fb ff ff       	call   800556 <fd_lookup>
  80096c:	85 c0                	test   %eax,%eax
  80096e:	78 0e                	js     80097e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800970:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 24             	sub    $0x24,%esp
  800987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80098a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800991:	89 1c 24             	mov    %ebx,(%esp)
  800994:	e8 bd fb ff ff       	call   800556 <fd_lookup>
  800999:	89 c2                	mov    %eax,%edx
  80099b:	85 d2                	test   %edx,%edx
  80099d:	78 61                	js     800a00 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a9:	8b 00                	mov    (%eax),%eax
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	e8 f9 fb ff ff       	call   8005ac <dev_lookup>
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	78 49                	js     800a00 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009be:	75 23                	jne    8009e3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009c0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009c5:	8b 40 48             	mov    0x48(%eax),%eax
  8009c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	c7 04 24 b8 26 80 00 	movl   $0x8026b8,(%esp)
  8009d7:	e8 b3 0e 00 00       	call   80188f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8009dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e1:	eb 1d                	jmp    800a00 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8009e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009e6:	8b 52 18             	mov    0x18(%edx),%edx
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 0e                	je     8009fb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	ff d2                	call   *%edx
  8009f9:	eb 05                	jmp    800a00 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a00:	83 c4 24             	add    $0x24,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	83 ec 24             	sub    $0x24,%esp
  800a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	89 04 24             	mov    %eax,(%esp)
  800a1d:	e8 34 fb ff ff       	call   800556 <fd_lookup>
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	85 d2                	test   %edx,%edx
  800a26:	78 52                	js     800a7a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a32:	8b 00                	mov    (%eax),%eax
  800a34:	89 04 24             	mov    %eax,(%esp)
  800a37:	e8 70 fb ff ff       	call   8005ac <dev_lookup>
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 3a                	js     800a7a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a43:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a47:	74 2c                	je     800a75 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a49:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a4c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a53:	00 00 00 
	stat->st_isdir = 0;
  800a56:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a5d:	00 00 00 
	stat->st_dev = dev;
  800a60:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a6d:	89 14 24             	mov    %edx,(%esp)
  800a70:	ff 50 14             	call   *0x14(%eax)
  800a73:	eb 05                	jmp    800a7a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a7a:	83 c4 24             	add    $0x24,%esp
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a8f:	00 
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 28 02 00 00       	call   800cc3 <open>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	78 1b                	js     800abc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	89 1c 24             	mov    %ebx,(%esp)
  800aab:	e8 56 ff ff ff       	call   800a06 <fstat>
  800ab0:	89 c6                	mov    %eax,%esi
	close(fd);
  800ab2:	89 1c 24             	mov    %ebx,(%esp)
  800ab5:	e8 cd fb ff ff       	call   800687 <close>
	return r;
  800aba:	89 f0                	mov    %esi,%eax
}
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 10             	sub    $0x10,%esp
  800acb:	89 c6                	mov    %eax,%esi
  800acd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800acf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ad6:	75 11                	jne    800ae9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ad8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800adf:	e8 61 18 00 00       	call   802345 <ipc_find_env>
  800ae4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ae9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800af0:	00 
  800af1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800af8:	00 
  800af9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afd:	a1 00 40 80 00       	mov    0x804000,%eax
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 d0 17 00 00       	call   8022da <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b11:	00 
  800b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b1d:	e8 3e 17 00 00       	call   802260 <ipc_recv>
}
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 40 0c             	mov    0xc(%eax),%eax
  800b35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4c:	e8 72 ff ff ff       	call   800ac3 <fsipc>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 06 00 00 00       	mov    $0x6,%eax
  800b6e:	e8 50 ff ff ff       	call   800ac3 <fsipc>
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	83 ec 14             	sub    $0x14,%esp
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 40 0c             	mov    0xc(%eax),%eax
  800b85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b94:	e8 2a ff ff ff       	call   800ac3 <fsipc>
  800b99:	89 c2                	mov    %eax,%edx
  800b9b:	85 d2                	test   %edx,%edx
  800b9d:	78 2b                	js     800bca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b9f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ba6:	00 
  800ba7:	89 1c 24             	mov    %ebx,(%esp)
  800baa:	e8 08 13 00 00       	call   801eb7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800baf:	a1 80 50 80 00       	mov    0x805080,%eax
  800bb4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bba:	a1 84 50 80 00       	mov    0x805084,%eax
  800bbf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bca:	83 c4 14             	add    $0x14,%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 18             	sub    $0x18,%esp
  800bd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bde:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800be3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 52 0c             	mov    0xc(%edx),%edx
  800bec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800bf2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  800bf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c02:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c09:	e8 46 14 00 00       	call   802054 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 04 00 00 00       	mov    $0x4,%eax
  800c18:	e8 a6 fe ff ff       	call   800ac3 <fsipc>
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 10             	sub    $0x10,%esp
  800c27:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c30:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c35:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 03 00 00 00       	mov    $0x3,%eax
  800c45:	e8 79 fe ff ff       	call   800ac3 <fsipc>
  800c4a:	89 c3                	mov    %eax,%ebx
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	78 6a                	js     800cba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c50:	39 c6                	cmp    %eax,%esi
  800c52:	73 24                	jae    800c78 <devfile_read+0x59>
  800c54:	c7 44 24 0c 28 27 80 	movl   $0x802728,0xc(%esp)
  800c5b:	00 
  800c5c:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  800c63:	00 
  800c64:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c6b:	00 
  800c6c:	c7 04 24 44 27 80 00 	movl   $0x802744,(%esp)
  800c73:	e8 1e 0b 00 00       	call   801796 <_panic>
	assert(r <= PGSIZE);
  800c78:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c7d:	7e 24                	jle    800ca3 <devfile_read+0x84>
  800c7f:	c7 44 24 0c 4f 27 80 	movl   $0x80274f,0xc(%esp)
  800c86:	00 
  800c87:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c96:	00 
  800c97:	c7 04 24 44 27 80 00 	movl   $0x802744,(%esp)
  800c9e:	e8 f3 0a 00 00       	call   801796 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800cae:	00 
  800caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb2:	89 04 24             	mov    %eax,(%esp)
  800cb5:	e8 9a 13 00 00       	call   802054 <memmove>
	return r;
}
  800cba:	89 d8                	mov    %ebx,%eax
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 24             	sub    $0x24,%esp
  800cca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ccd:	89 1c 24             	mov    %ebx,(%esp)
  800cd0:	e8 ab 11 00 00       	call   801e80 <strlen>
  800cd5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cda:	7f 60                	jg     800d3c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cdf:	89 04 24             	mov    %eax,(%esp)
  800ce2:	e8 20 f8 ff ff       	call   800507 <fd_alloc>
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	85 d2                	test   %edx,%edx
  800ceb:	78 54                	js     800d41 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cf1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cf8:	e8 ba 11 00 00       	call   801eb7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d00:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d08:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0d:	e8 b1 fd ff ff       	call   800ac3 <fsipc>
  800d12:	89 c3                	mov    %eax,%ebx
  800d14:	85 c0                	test   %eax,%eax
  800d16:	79 17                	jns    800d2f <open+0x6c>
		fd_close(fd, 0);
  800d18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d1f:	00 
  800d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d23:	89 04 24             	mov    %eax,(%esp)
  800d26:	e8 db f8 ff ff       	call   800606 <fd_close>
		return r;
  800d2b:	89 d8                	mov    %ebx,%eax
  800d2d:	eb 12                	jmp    800d41 <open+0x7e>
	}

	return fd2num(fd);
  800d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d32:	89 04 24             	mov    %eax,(%esp)
  800d35:	e8 a6 f7 ff ff       	call   8004e0 <fd2num>
  800d3a:	eb 05                	jmp    800d41 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800d3c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800d41:	83 c4 24             	add    $0x24,%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 08 00 00 00       	mov    $0x8,%eax
  800d57:	e8 67 fd ff ff       	call   800ac3 <fsipc>
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d66:	c7 44 24 04 5b 27 80 	movl   $0x80275b,0x4(%esp)
  800d6d:	00 
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	89 04 24             	mov    %eax,(%esp)
  800d74:	e8 3e 11 00 00       	call   801eb7 <strcpy>
	return 0;
}
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	83 ec 14             	sub    $0x14,%esp
  800d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d8a:	89 1c 24             	mov    %ebx,(%esp)
  800d8d:	e8 eb 15 00 00       	call   80237d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800d97:	83 f8 01             	cmp    $0x1,%eax
  800d9a:	75 0d                	jne    800da9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800d9c:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d9f:	89 04 24             	mov    %eax,(%esp)
  800da2:	e8 29 03 00 00       	call   8010d0 <nsipc_close>
  800da7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  800da9:	89 d0                	mov    %edx,%eax
  800dab:	83 c4 14             	add    $0x14,%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800db7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dbe:	00 
  800dbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	8b 40 0c             	mov    0xc(%eax),%eax
  800dd3:	89 04 24             	mov    %eax,(%esp)
  800dd6:	e8 f0 03 00 00       	call   8011cb <nsipc_send>
}
  800ddb:	c9                   	leave  
  800ddc:	c3                   	ret    

00800ddd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800de3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dea:	00 
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dff:	89 04 24             	mov    %eax,(%esp)
  800e02:	e8 44 03 00 00       	call   80114b <nsipc_recv>
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e0f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e12:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e16:	89 04 24             	mov    %eax,(%esp)
  800e19:	e8 38 f7 ff ff       	call   800556 <fd_lookup>
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	78 17                	js     800e39 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e25:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800e2b:	39 08                	cmp    %ecx,(%eax)
  800e2d:	75 05                	jne    800e34 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e2f:	8b 40 0c             	mov    0xc(%eax),%eax
  800e32:	eb 05                	jmp    800e39 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e34:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 20             	sub    $0x20,%esp
  800e43:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e48:	89 04 24             	mov    %eax,(%esp)
  800e4b:	e8 b7 f6 ff ff       	call   800507 <fd_alloc>
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	85 c0                	test   %eax,%eax
  800e54:	78 21                	js     800e77 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e56:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e5d:	00 
  800e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6c:	e8 16 f3 ff ff       	call   800187 <sys_page_alloc>
  800e71:	89 c3                	mov    %eax,%ebx
  800e73:	85 c0                	test   %eax,%eax
  800e75:	79 0c                	jns    800e83 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  800e77:	89 34 24             	mov    %esi,(%esp)
  800e7a:	e8 51 02 00 00       	call   8010d0 <nsipc_close>
		return r;
  800e7f:	89 d8                	mov    %ebx,%eax
  800e81:	eb 20                	jmp    800ea3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e91:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800e98:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800e9b:	89 14 24             	mov    %edx,(%esp)
  800e9e:	e8 3d f6 ff ff       	call   8004e0 <fd2num>
}
  800ea3:	83 c4 20             	add    $0x20,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	e8 51 ff ff ff       	call   800e09 <fd2sockid>
		return r;
  800eb8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 23                	js     800ee1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ebe:	8b 55 10             	mov    0x10(%ebp),%edx
  800ec1:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ecc:	89 04 24             	mov    %eax,(%esp)
  800ecf:	e8 45 01 00 00       	call   801019 <nsipc_accept>
		return r;
  800ed4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 07                	js     800ee1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  800eda:	e8 5c ff ff ff       	call   800e3b <alloc_sockfd>
  800edf:	89 c1                	mov    %eax,%ecx
}
  800ee1:	89 c8                	mov    %ecx,%eax
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	e8 16 ff ff ff       	call   800e09 <fd2sockid>
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	85 d2                	test   %edx,%edx
  800ef7:	78 16                	js     800f0f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f07:	89 14 24             	mov    %edx,(%esp)
  800f0a:	e8 60 01 00 00       	call   80106f <nsipc_bind>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <shutdown>:

int
shutdown(int s, int how)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	e8 ea fe ff ff       	call   800e09 <fd2sockid>
  800f1f:	89 c2                	mov    %eax,%edx
  800f21:	85 d2                	test   %edx,%edx
  800f23:	78 0f                	js     800f34 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2c:	89 14 24             	mov    %edx,(%esp)
  800f2f:	e8 7a 01 00 00       	call   8010ae <nsipc_shutdown>
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3f:	e8 c5 fe ff ff       	call   800e09 <fd2sockid>
  800f44:	89 c2                	mov    %eax,%edx
  800f46:	85 d2                	test   %edx,%edx
  800f48:	78 16                	js     800f60 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	89 14 24             	mov    %edx,(%esp)
  800f5b:	e8 8a 01 00 00       	call   8010ea <nsipc_connect>
}
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    

00800f62 <listen>:

int
listen(int s, int backlog)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f68:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6b:	e8 99 fe ff ff       	call   800e09 <fd2sockid>
  800f70:	89 c2                	mov    %eax,%edx
  800f72:	85 d2                	test   %edx,%edx
  800f74:	78 0f                	js     800f85 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800f76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7d:	89 14 24             	mov    %edx,(%esp)
  800f80:	e8 a4 01 00 00       	call   801129 <nsipc_listen>
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 98 02 00 00       	call   80123e <nsipc_socket>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	85 d2                	test   %edx,%edx
  800faa:	78 05                	js     800fb1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  800fac:	e8 8a fe ff ff       	call   800e3b <alloc_sockfd>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 14             	sub    $0x14,%esp
  800fba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800fbc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800fc3:	75 11                	jne    800fd6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800fc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fcc:	e8 74 13 00 00       	call   802345 <ipc_find_env>
  800fd1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800fd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fdd:	00 
  800fde:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800fe5:	00 
  800fe6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fea:	a1 04 40 80 00       	mov    0x804004,%eax
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	e8 e3 12 00 00       	call   8022da <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800ff7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100e:	e8 4d 12 00 00       	call   802260 <ipc_recv>
}
  801013:	83 c4 14             	add    $0x14,%esp
  801016:	5b                   	pop    %ebx
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
  80101e:	83 ec 10             	sub    $0x10,%esp
  801021:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80102c:	8b 06                	mov    (%esi),%eax
  80102e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801033:	b8 01 00 00 00       	mov    $0x1,%eax
  801038:	e8 76 ff ff ff       	call   800fb3 <nsipc>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 23                	js     801066 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801043:	a1 10 60 80 00       	mov    0x806010,%eax
  801048:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801053:	00 
  801054:	8b 45 0c             	mov    0xc(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 f5 0f 00 00       	call   802054 <memmove>
		*addrlen = ret->ret_addrlen;
  80105f:	a1 10 60 80 00       	mov    0x806010,%eax
  801064:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801066:	89 d8                	mov    %ebx,%eax
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	53                   	push   %ebx
  801073:	83 ec 14             	sub    $0x14,%esp
  801076:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801081:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801085:	8b 45 0c             	mov    0xc(%ebp),%eax
  801088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801093:	e8 bc 0f 00 00       	call   802054 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801098:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80109e:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a3:	e8 0b ff ff ff       	call   800fb3 <nsipc>
}
  8010a8:	83 c4 14             	add    $0x14,%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8010bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8010c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c9:	e8 e5 fe ff ff       	call   800fb3 <nsipc>
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <nsipc_close>:

int
nsipc_close(int s)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010de:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e3:	e8 cb fe ff ff       	call   800fb3 <nsipc>
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 14             	sub    $0x14,%esp
  8010f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8010fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801100:	8b 45 0c             	mov    0xc(%ebp),%eax
  801103:	89 44 24 04          	mov    %eax,0x4(%esp)
  801107:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80110e:	e8 41 0f 00 00       	call   802054 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801113:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801119:	b8 05 00 00 00       	mov    $0x5,%eax
  80111e:	e8 90 fe ff ff       	call   800fb3 <nsipc>
}
  801123:	83 c4 14             	add    $0x14,%esp
  801126:	5b                   	pop    %ebx
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80113f:	b8 06 00 00 00       	mov    $0x6,%eax
  801144:	e8 6a fe ff ff       	call   800fb3 <nsipc>
}
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 10             	sub    $0x10,%esp
  801153:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80115e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801164:	8b 45 14             	mov    0x14(%ebp),%eax
  801167:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80116c:	b8 07 00 00 00       	mov    $0x7,%eax
  801171:	e8 3d fe ff ff       	call   800fb3 <nsipc>
  801176:	89 c3                	mov    %eax,%ebx
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 46                	js     8011c2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80117c:	39 f0                	cmp    %esi,%eax
  80117e:	7f 07                	jg     801187 <nsipc_recv+0x3c>
  801180:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801185:	7e 24                	jle    8011ab <nsipc_recv+0x60>
  801187:	c7 44 24 0c 67 27 80 	movl   $0x802767,0xc(%esp)
  80118e:	00 
  80118f:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  801196:	00 
  801197:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80119e:	00 
  80119f:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  8011a6:	e8 eb 05 00 00       	call   801796 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011af:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011b6:	00 
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 92 0e 00 00       	call   802054 <memmove>
	}

	return r;
}
  8011c2:	89 d8                	mov    %ebx,%eax
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	53                   	push   %ebx
  8011cf:	83 ec 14             	sub    $0x14,%esp
  8011d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8011dd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8011e3:	7e 24                	jle    801209 <nsipc_send+0x3e>
  8011e5:	c7 44 24 0c 88 27 80 	movl   $0x802788,0xc(%esp)
  8011ec:	00 
  8011ed:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  8011f4:	00 
  8011f5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011fc:	00 
  8011fd:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  801204:	e8 8d 05 00 00       	call   801796 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801210:	89 44 24 04          	mov    %eax,0x4(%esp)
  801214:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80121b:	e8 34 0e 00 00       	call   802054 <memmove>
	nsipcbuf.send.req_size = size;
  801220:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801226:	8b 45 14             	mov    0x14(%ebp),%eax
  801229:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80122e:	b8 08 00 00 00       	mov    $0x8,%eax
  801233:	e8 7b fd ff ff       	call   800fb3 <nsipc>
}
  801238:	83 c4 14             	add    $0x14,%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80124c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801254:	8b 45 10             	mov    0x10(%ebp),%eax
  801257:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80125c:	b8 09 00 00 00       	mov    $0x9,%eax
  801261:	e8 4d fd ff ff       	call   800fb3 <nsipc>
}
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 10             	sub    $0x10,%esp
  801270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 72 f2 ff ff       	call   8004f0 <fd2data>
  80127e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801280:	c7 44 24 04 94 27 80 	movl   $0x802794,0x4(%esp)
  801287:	00 
  801288:	89 1c 24             	mov    %ebx,(%esp)
  80128b:	e8 27 0c 00 00       	call   801eb7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801290:	8b 46 04             	mov    0x4(%esi),%eax
  801293:	2b 06                	sub    (%esi),%eax
  801295:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80129b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a2:	00 00 00 
	stat->st_dev = &devpipe;
  8012a5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8012ac:	30 80 00 
	return 0;
}
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 14             	sub    $0x14,%esp
  8012c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8012c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d0:	e8 59 ef ff ff       	call   80022e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8012d5:	89 1c 24             	mov    %ebx,(%esp)
  8012d8:	e8 13 f2 ff ff       	call   8004f0 <fd2data>
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e8:	e8 41 ef ff ff       	call   80022e <sys_page_unmap>
}
  8012ed:	83 c4 14             	add    $0x14,%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 2c             	sub    $0x2c,%esp
  8012fc:	89 c6                	mov    %eax,%esi
  8012fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801301:	a1 08 40 80 00       	mov    0x804008,%eax
  801306:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801309:	89 34 24             	mov    %esi,(%esp)
  80130c:	e8 6c 10 00 00       	call   80237d <pageref>
  801311:	89 c7                	mov    %eax,%edi
  801313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	e8 5f 10 00 00       	call   80237d <pageref>
  80131e:	39 c7                	cmp    %eax,%edi
  801320:	0f 94 c2             	sete   %dl
  801323:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801326:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80132c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80132f:	39 fb                	cmp    %edi,%ebx
  801331:	74 21                	je     801354 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801333:	84 d2                	test   %dl,%dl
  801335:	74 ca                	je     801301 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801337:	8b 51 58             	mov    0x58(%ecx),%edx
  80133a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801342:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801346:	c7 04 24 9b 27 80 00 	movl   $0x80279b,(%esp)
  80134d:	e8 3d 05 00 00       	call   80188f <cprintf>
  801352:	eb ad                	jmp    801301 <_pipeisclosed+0xe>
	}
}
  801354:	83 c4 2c             	add    $0x2c,%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	57                   	push   %edi
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
  801362:	83 ec 1c             	sub    $0x1c,%esp
  801365:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801368:	89 34 24             	mov    %esi,(%esp)
  80136b:	e8 80 f1 ff ff       	call   8004f0 <fd2data>
  801370:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801372:	bf 00 00 00 00       	mov    $0x0,%edi
  801377:	eb 45                	jmp    8013be <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801379:	89 da                	mov    %ebx,%edx
  80137b:	89 f0                	mov    %esi,%eax
  80137d:	e8 71 ff ff ff       	call   8012f3 <_pipeisclosed>
  801382:	85 c0                	test   %eax,%eax
  801384:	75 41                	jne    8013c7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801386:	e8 dd ed ff ff       	call   800168 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80138b:	8b 43 04             	mov    0x4(%ebx),%eax
  80138e:	8b 0b                	mov    (%ebx),%ecx
  801390:	8d 51 20             	lea    0x20(%ecx),%edx
  801393:	39 d0                	cmp    %edx,%eax
  801395:	73 e2                	jae    801379 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801397:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80139e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8013a1:	99                   	cltd   
  8013a2:	c1 ea 1b             	shr    $0x1b,%edx
  8013a5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8013a8:	83 e1 1f             	and    $0x1f,%ecx
  8013ab:	29 d1                	sub    %edx,%ecx
  8013ad:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8013b1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8013b5:	83 c0 01             	add    $0x1,%eax
  8013b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013bb:	83 c7 01             	add    $0x1,%edi
  8013be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8013c1:	75 c8                	jne    80138b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8013c3:	89 f8                	mov    %edi,%eax
  8013c5:	eb 05                	jmp    8013cc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8013cc:	83 c4 1c             	add    $0x1c,%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 1c             	sub    $0x1c,%esp
  8013dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8013e0:	89 3c 24             	mov    %edi,(%esp)
  8013e3:	e8 08 f1 ff ff       	call   8004f0 <fd2data>
  8013e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013ea:	be 00 00 00 00       	mov    $0x0,%esi
  8013ef:	eb 3d                	jmp    80142e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8013f1:	85 f6                	test   %esi,%esi
  8013f3:	74 04                	je     8013f9 <devpipe_read+0x25>
				return i;
  8013f5:	89 f0                	mov    %esi,%eax
  8013f7:	eb 43                	jmp    80143c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013f9:	89 da                	mov    %ebx,%edx
  8013fb:	89 f8                	mov    %edi,%eax
  8013fd:	e8 f1 fe ff ff       	call   8012f3 <_pipeisclosed>
  801402:	85 c0                	test   %eax,%eax
  801404:	75 31                	jne    801437 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801406:	e8 5d ed ff ff       	call   800168 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80140b:	8b 03                	mov    (%ebx),%eax
  80140d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801410:	74 df                	je     8013f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801412:	99                   	cltd   
  801413:	c1 ea 1b             	shr    $0x1b,%edx
  801416:	01 d0                	add    %edx,%eax
  801418:	83 e0 1f             	and    $0x1f,%eax
  80141b:	29 d0                	sub    %edx,%eax
  80141d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801425:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801428:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80142b:	83 c6 01             	add    $0x1,%esi
  80142e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801431:	75 d8                	jne    80140b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801433:	89 f0                	mov    %esi,%eax
  801435:	eb 05                	jmp    80143c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80143c:	83 c4 1c             	add    $0x1c,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 b0 f0 ff ff       	call   800507 <fd_alloc>
  801457:	89 c2                	mov    %eax,%edx
  801459:	85 d2                	test   %edx,%edx
  80145b:	0f 88 4d 01 00 00    	js     8015ae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801461:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801468:	00 
  801469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801477:	e8 0b ed ff ff       	call   800187 <sys_page_alloc>
  80147c:	89 c2                	mov    %eax,%edx
  80147e:	85 d2                	test   %edx,%edx
  801480:	0f 88 28 01 00 00    	js     8015ae <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	89 04 24             	mov    %eax,(%esp)
  80148c:	e8 76 f0 ff ff       	call   800507 <fd_alloc>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	85 c0                	test   %eax,%eax
  801495:	0f 88 fe 00 00 00    	js     801599 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80149b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014a2:	00 
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b1:	e8 d1 ec ff ff       	call   800187 <sys_page_alloc>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	0f 88 d9 00 00 00    	js     801599 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 25 f0 ff ff       	call   8004f0 <fd2data>
  8014cb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014d4:	00 
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e0:	e8 a2 ec ff ff       	call   800187 <sys_page_alloc>
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	0f 88 97 00 00 00    	js     801586 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	e8 f6 ef ff ff       	call   8004f0 <fd2data>
  8014fa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801501:	00 
  801502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801506:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80150d:	00 
  80150e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801512:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801519:	e8 bd ec ff ff       	call   8001db <sys_page_map>
  80151e:	89 c3                	mov    %eax,%ebx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 52                	js     801576 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801524:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80152f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801532:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801539:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80153f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801542:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 87 ef ff ff       	call   8004e0 <fd2num>
  801559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	89 04 24             	mov    %eax,(%esp)
  801564:	e8 77 ef ff ff       	call   8004e0 <fd2num>
  801569:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
  801574:	eb 38                	jmp    8015ae <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801581:	e8 a8 ec ff ff       	call   80022e <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801594:	e8 95 ec ff ff       	call   80022e <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a7:	e8 82 ec ff ff       	call   80022e <sys_page_unmap>
  8015ac:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8015ae:	83 c4 30             	add    $0x30,%esp
  8015b1:	5b                   	pop    %ebx
  8015b2:	5e                   	pop    %esi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 89 ef ff ff       	call   800556 <fd_lookup>
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	78 15                	js     8015e8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8015d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d6:	89 04 24             	mov    %eax,(%esp)
  8015d9:	e8 12 ef ff ff       	call   8004f0 <fd2data>
	return _pipeisclosed(fd, p);
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e3:	e8 0b fd ff ff       	call   8012f3 <_pipeisclosed>
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    
  8015ea:	66 90                	xchg   %ax,%ax
  8015ec:	66 90                	xchg   %ax,%ax
  8015ee:	66 90                	xchg   %ax,%ax

008015f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    

008015fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801600:	c7 44 24 04 b3 27 80 	movl   $0x8027b3,0x4(%esp)
  801607:	00 
  801608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160b:	89 04 24             	mov    %eax,(%esp)
  80160e:	e8 a4 08 00 00       	call   801eb7 <strcpy>
	return 0;
}
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80162b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801631:	eb 31                	jmp    801664 <devcons_write+0x4a>
		m = n - tot;
  801633:	8b 75 10             	mov    0x10(%ebp),%esi
  801636:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801638:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80163b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801640:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801643:	89 74 24 08          	mov    %esi,0x8(%esp)
  801647:	03 45 0c             	add    0xc(%ebp),%eax
  80164a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164e:	89 3c 24             	mov    %edi,(%esp)
  801651:	e8 fe 09 00 00       	call   802054 <memmove>
		sys_cputs(buf, m);
  801656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165a:	89 3c 24             	mov    %edi,(%esp)
  80165d:	e8 58 ea ff ff       	call   8000ba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801662:	01 f3                	add    %esi,%ebx
  801664:	89 d8                	mov    %ebx,%eax
  801666:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801669:	72 c8                	jb     801633 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80166b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801681:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801685:	75 07                	jne    80168e <devcons_read+0x18>
  801687:	eb 2a                	jmp    8016b3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801689:	e8 da ea ff ff       	call   800168 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80168e:	66 90                	xchg   %ax,%ax
  801690:	e8 43 ea ff ff       	call   8000d8 <sys_cgetc>
  801695:	85 c0                	test   %eax,%eax
  801697:	74 f0                	je     801689 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 16                	js     8016b3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80169d:	83 f8 04             	cmp    $0x4,%eax
  8016a0:	74 0c                	je     8016ae <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	88 02                	mov    %al,(%edx)
	return 1;
  8016a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ac:	eb 05                	jmp    8016b3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8016c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016c8:	00 
  8016c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 e6 e9 ff ff       	call   8000ba <sys_cputs>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <getchar>:

int
getchar(void)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8016dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8016e3:	00 
  8016e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f2:	e8 f3 f0 ff ff       	call   8007ea <read>
	if (r < 0)
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 0f                	js     80170a <getchar+0x34>
		return r;
	if (r < 1)
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	7e 06                	jle    801705 <getchar+0x2f>
		return -E_EOF;
	return c;
  8016ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801703:	eb 05                	jmp    80170a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801705:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 32 ee ff ff       	call   800556 <fd_lookup>
  801724:	85 c0                	test   %eax,%eax
  801726:	78 11                	js     801739 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801731:	39 10                	cmp    %edx,(%eax)
  801733:	0f 94 c0             	sete   %al
  801736:	0f b6 c0             	movzbl %al,%eax
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <opencons>:

int
opencons(void)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	89 04 24             	mov    %eax,(%esp)
  801747:	e8 bb ed ff ff       	call   800507 <fd_alloc>
		return r;
  80174c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 40                	js     801792 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801752:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801759:	00 
  80175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801768:	e8 1a ea ff ff       	call   800187 <sys_page_alloc>
		return r;
  80176d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 1f                	js     801792 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801773:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801781:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 50 ed ff ff       	call   8004e0 <fd2num>
  801790:	89 c2                	mov    %eax,%edx
}
  801792:	89 d0                	mov    %edx,%eax
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80179e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017a1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8017a7:	e8 9d e9 ff ff       	call   800149 <sys_getenvid>
  8017ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8017be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c2:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  8017c9:	e8 c1 00 00 00       	call   80188f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 51 00 00 00       	call   80182e <vcprintf>
	cprintf("\n");
  8017dd:	c7 04 24 ac 27 80 00 	movl   $0x8027ac,(%esp)
  8017e4:	e8 a6 00 00 00       	call   80188f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017e9:	cc                   	int3   
  8017ea:	eb fd                	jmp    8017e9 <_panic+0x53>

008017ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 14             	sub    $0x14,%esp
  8017f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8017f6:	8b 13                	mov    (%ebx),%edx
  8017f8:	8d 42 01             	lea    0x1(%edx),%eax
  8017fb:	89 03                	mov    %eax,(%ebx)
  8017fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801800:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801804:	3d ff 00 00 00       	cmp    $0xff,%eax
  801809:	75 19                	jne    801824 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80180b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801812:	00 
  801813:	8d 43 08             	lea    0x8(%ebx),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 9c e8 ff ff       	call   8000ba <sys_cputs>
		b->idx = 0;
  80181e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801824:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801828:	83 c4 14             	add    $0x14,%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801837:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80183e:	00 00 00 
	b.cnt = 0;
  801841:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801848:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	89 44 24 08          	mov    %eax,0x8(%esp)
  801859:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 ec 17 80 00 	movl   $0x8017ec,(%esp)
  80186a:	e8 af 01 00 00       	call   801a1e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80186f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 33 e8 ff ff       	call   8000ba <sys_cputs>

	return b.cnt;
}
  801887:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801895:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	89 04 24             	mov    %eax,(%esp)
  8018a2:	e8 87 ff ff ff       	call   80182e <vcprintf>
	va_end(ap);

	return cnt;
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    
  8018a9:	66 90                	xchg   %ax,%ax
  8018ab:	66 90                	xchg   %ax,%ax
  8018ad:	66 90                	xchg   %ax,%ax
  8018af:	90                   	nop

008018b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 3c             	sub    $0x3c,%esp
  8018b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018bc:	89 d7                	mov    %edx,%edi
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8018cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018dd:	39 d9                	cmp    %ebx,%ecx
  8018df:	72 05                	jb     8018e6 <printnum+0x36>
  8018e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8018e4:	77 69                	ja     80194f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8018e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018ed:	83 ee 01             	sub    $0x1,%esi
  8018f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801900:	89 c3                	mov    %eax,%ebx
  801902:	89 d6                	mov    %edx,%esi
  801904:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801907:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80190a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80190e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801912:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80191b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191f:	e8 9c 0a 00 00       	call   8023c0 <__udivdi3>
  801924:	89 d9                	mov    %ebx,%ecx
  801926:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80192a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	89 54 24 04          	mov    %edx,0x4(%esp)
  801935:	89 fa                	mov    %edi,%edx
  801937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193a:	e8 71 ff ff ff       	call   8018b0 <printnum>
  80193f:	eb 1b                	jmp    80195c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801941:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801945:	8b 45 18             	mov    0x18(%ebp),%eax
  801948:	89 04 24             	mov    %eax,(%esp)
  80194b:	ff d3                	call   *%ebx
  80194d:	eb 03                	jmp    801952 <printnum+0xa2>
  80194f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801952:	83 ee 01             	sub    $0x1,%esi
  801955:	85 f6                	test   %esi,%esi
  801957:	7f e8                	jg     801941 <printnum+0x91>
  801959:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80195c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801960:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801964:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801967:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80196a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801972:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	e8 6c 0b 00 00       	call   8024f0 <__umoddi3>
  801984:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801988:	0f be 80 e3 27 80 00 	movsbl 0x8027e3(%eax),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801995:	ff d0                	call   *%eax
}
  801997:	83 c4 3c             	add    $0x3c,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5f                   	pop    %edi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8019a2:	83 fa 01             	cmp    $0x1,%edx
  8019a5:	7e 0e                	jle    8019b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8019a7:	8b 10                	mov    (%eax),%edx
  8019a9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8019ac:	89 08                	mov    %ecx,(%eax)
  8019ae:	8b 02                	mov    (%edx),%eax
  8019b0:	8b 52 04             	mov    0x4(%edx),%edx
  8019b3:	eb 22                	jmp    8019d7 <getuint+0x38>
	else if (lflag)
  8019b5:	85 d2                	test   %edx,%edx
  8019b7:	74 10                	je     8019c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8019b9:	8b 10                	mov    (%eax),%edx
  8019bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019be:	89 08                	mov    %ecx,(%eax)
  8019c0:	8b 02                	mov    (%edx),%eax
  8019c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c7:	eb 0e                	jmp    8019d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8019c9:	8b 10                	mov    (%eax),%edx
  8019cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019ce:	89 08                	mov    %ecx,(%eax)
  8019d0:	8b 02                	mov    (%edx),%eax
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8019df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019e3:	8b 10                	mov    (%eax),%edx
  8019e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8019e8:	73 0a                	jae    8019f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8019ed:	89 08                	mov    %ecx,(%eax)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	88 02                	mov    %al,(%edx)
}
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8019fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a03:	8b 45 10             	mov    0x10(%ebp),%eax
  801a06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	89 04 24             	mov    %eax,(%esp)
  801a17:	e8 02 00 00 00       	call   801a1e <vprintfmt>
	va_end(ap);
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 3c             	sub    $0x3c,%esp
  801a27:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a2d:	eb 14                	jmp    801a43 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	0f 84 b3 03 00 00    	je     801dea <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  801a37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a41:	89 f3                	mov    %esi,%ebx
  801a43:	8d 73 01             	lea    0x1(%ebx),%esi
  801a46:	0f b6 03             	movzbl (%ebx),%eax
  801a49:	83 f8 25             	cmp    $0x25,%eax
  801a4c:	75 e1                	jne    801a2f <vprintfmt+0x11>
  801a4e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801a52:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801a59:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801a60:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	eb 1d                	jmp    801a8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a6e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a70:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801a74:	eb 15                	jmp    801a8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a76:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a78:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801a7c:	eb 0d                	jmp    801a8b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801a7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a81:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a84:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801a8e:	0f b6 0e             	movzbl (%esi),%ecx
  801a91:	0f b6 c1             	movzbl %cl,%eax
  801a94:	83 e9 23             	sub    $0x23,%ecx
  801a97:	80 f9 55             	cmp    $0x55,%cl
  801a9a:	0f 87 2a 03 00 00    	ja     801dca <vprintfmt+0x3ac>
  801aa0:	0f b6 c9             	movzbl %cl,%ecx
  801aa3:	ff 24 8d 20 29 80 00 	jmp    *0x802920(,%ecx,4)
  801aaa:	89 de                	mov    %ebx,%esi
  801aac:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801ab1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801ab4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801ab8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801abb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801abe:	83 fb 09             	cmp    $0x9,%ebx
  801ac1:	77 36                	ja     801af9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ac3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801ac6:	eb e9                	jmp    801ab1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  801acb:	8d 48 04             	lea    0x4(%eax),%ecx
  801ace:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801ad1:	8b 00                	mov    (%eax),%eax
  801ad3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801ad8:	eb 22                	jmp    801afc <vprintfmt+0xde>
  801ada:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801add:	85 c9                	test   %ecx,%ecx
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae4:	0f 49 c1             	cmovns %ecx,%eax
  801ae7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aea:	89 de                	mov    %ebx,%esi
  801aec:	eb 9d                	jmp    801a8b <vprintfmt+0x6d>
  801aee:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801af0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801af7:	eb 92                	jmp    801a8b <vprintfmt+0x6d>
  801af9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801afc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b00:	79 89                	jns    801a8b <vprintfmt+0x6d>
  801b02:	e9 77 ff ff ff       	jmp    801a7e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801b07:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801b0c:	e9 7a ff ff ff       	jmp    801a8b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801b11:	8b 45 14             	mov    0x14(%ebp),%eax
  801b14:	8d 50 04             	lea    0x4(%eax),%edx
  801b17:	89 55 14             	mov    %edx,0x14(%ebp)
  801b1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b1e:	8b 00                	mov    (%eax),%eax
  801b20:	89 04 24             	mov    %eax,(%esp)
  801b23:	ff 55 08             	call   *0x8(%ebp)
			break;
  801b26:	e9 18 ff ff ff       	jmp    801a43 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801b2e:	8d 50 04             	lea    0x4(%eax),%edx
  801b31:	89 55 14             	mov    %edx,0x14(%ebp)
  801b34:	8b 00                	mov    (%eax),%eax
  801b36:	99                   	cltd   
  801b37:	31 d0                	xor    %edx,%eax
  801b39:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801b3b:	83 f8 0f             	cmp    $0xf,%eax
  801b3e:	7f 0b                	jg     801b4b <vprintfmt+0x12d>
  801b40:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  801b47:	85 d2                	test   %edx,%edx
  801b49:	75 20                	jne    801b6b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  801b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4f:	c7 44 24 08 fb 27 80 	movl   $0x8027fb,0x8(%esp)
  801b56:	00 
  801b57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	89 04 24             	mov    %eax,(%esp)
  801b61:	e8 90 fe ff ff       	call   8019f6 <printfmt>
  801b66:	e9 d8 fe ff ff       	jmp    801a43 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801b6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b6f:	c7 44 24 08 41 27 80 	movl   $0x802741,0x8(%esp)
  801b76:	00 
  801b77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	89 04 24             	mov    %eax,(%esp)
  801b81:	e8 70 fe ff ff       	call   8019f6 <printfmt>
  801b86:	e9 b8 fe ff ff       	jmp    801a43 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b8b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801b8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b91:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b94:	8b 45 14             	mov    0x14(%ebp),%eax
  801b97:	8d 50 04             	lea    0x4(%eax),%edx
  801b9a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b9d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801b9f:	85 f6                	test   %esi,%esi
  801ba1:	b8 f4 27 80 00       	mov    $0x8027f4,%eax
  801ba6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801ba9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801bad:	0f 84 97 00 00 00    	je     801c4a <vprintfmt+0x22c>
  801bb3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801bb7:	0f 8e 9b 00 00 00    	jle    801c58 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801bbd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bc1:	89 34 24             	mov    %esi,(%esp)
  801bc4:	e8 cf 02 00 00       	call   801e98 <strnlen>
  801bc9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bcc:	29 c2                	sub    %eax,%edx
  801bce:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  801bd1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801bd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801bd8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801bdb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bde:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801be1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801be3:	eb 0f                	jmp    801bf4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801be5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801be9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	85 db                	test   %ebx,%ebx
  801bf6:	7f ed                	jg     801be5 <vprintfmt+0x1c7>
  801bf8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801bfb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bfe:	85 d2                	test   %edx,%edx
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
  801c05:	0f 49 c2             	cmovns %edx,%eax
  801c08:	29 c2                	sub    %eax,%edx
  801c0a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c0d:	89 d7                	mov    %edx,%edi
  801c0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c12:	eb 50                	jmp    801c64 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801c14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c18:	74 1e                	je     801c38 <vprintfmt+0x21a>
  801c1a:	0f be d2             	movsbl %dl,%edx
  801c1d:	83 ea 20             	sub    $0x20,%edx
  801c20:	83 fa 5e             	cmp    $0x5e,%edx
  801c23:	76 13                	jbe    801c38 <vprintfmt+0x21a>
					putch('?', putdat);
  801c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801c33:	ff 55 08             	call   *0x8(%ebp)
  801c36:	eb 0d                	jmp    801c45 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801c38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801c45:	83 ef 01             	sub    $0x1,%edi
  801c48:	eb 1a                	jmp    801c64 <vprintfmt+0x246>
  801c4a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c4d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c56:	eb 0c                	jmp    801c64 <vprintfmt+0x246>
  801c58:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c5b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c64:	83 c6 01             	add    $0x1,%esi
  801c67:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801c6b:	0f be c2             	movsbl %dl,%eax
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	74 27                	je     801c99 <vprintfmt+0x27b>
  801c72:	85 db                	test   %ebx,%ebx
  801c74:	78 9e                	js     801c14 <vprintfmt+0x1f6>
  801c76:	83 eb 01             	sub    $0x1,%ebx
  801c79:	79 99                	jns    801c14 <vprintfmt+0x1f6>
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	eb 1a                	jmp    801ca1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801c92:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c94:	83 eb 01             	sub    $0x1,%ebx
  801c97:	eb 08                	jmp    801ca1 <vprintfmt+0x283>
  801c99:	89 fb                	mov    %edi,%ebx
  801c9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ca1:	85 db                	test   %ebx,%ebx
  801ca3:	7f e2                	jg     801c87 <vprintfmt+0x269>
  801ca5:	89 75 08             	mov    %esi,0x8(%ebp)
  801ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cab:	e9 93 fd ff ff       	jmp    801a43 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801cb0:	83 fa 01             	cmp    $0x1,%edx
  801cb3:	7e 16                	jle    801ccb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  801cb5:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb8:	8d 50 08             	lea    0x8(%eax),%edx
  801cbb:	89 55 14             	mov    %edx,0x14(%ebp)
  801cbe:	8b 50 04             	mov    0x4(%eax),%edx
  801cc1:	8b 00                	mov    (%eax),%eax
  801cc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801cc9:	eb 32                	jmp    801cfd <vprintfmt+0x2df>
	else if (lflag)
  801ccb:	85 d2                	test   %edx,%edx
  801ccd:	74 18                	je     801ce7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  801ccf:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd2:	8d 50 04             	lea    0x4(%eax),%edx
  801cd5:	89 55 14             	mov    %edx,0x14(%ebp)
  801cd8:	8b 30                	mov    (%eax),%esi
  801cda:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801cdd:	89 f0                	mov    %esi,%eax
  801cdf:	c1 f8 1f             	sar    $0x1f,%eax
  801ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ce5:	eb 16                	jmp    801cfd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  801ce7:	8b 45 14             	mov    0x14(%ebp),%eax
  801cea:	8d 50 04             	lea    0x4(%eax),%edx
  801ced:	89 55 14             	mov    %edx,0x14(%ebp)
  801cf0:	8b 30                	mov    (%eax),%esi
  801cf2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801cf5:	89 f0                	mov    %esi,%eax
  801cf7:	c1 f8 1f             	sar    $0x1f,%eax
  801cfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801d03:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801d08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801d0c:	0f 89 80 00 00 00    	jns    801d92 <vprintfmt+0x374>
				putch('-', putdat);
  801d12:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d16:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801d1d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801d20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d26:	f7 d8                	neg    %eax
  801d28:	83 d2 00             	adc    $0x0,%edx
  801d2b:	f7 da                	neg    %edx
			}
			base = 10;
  801d2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801d32:	eb 5e                	jmp    801d92 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801d34:	8d 45 14             	lea    0x14(%ebp),%eax
  801d37:	e8 63 fc ff ff       	call   80199f <getuint>
			base = 10;
  801d3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801d41:	eb 4f                	jmp    801d92 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801d43:	8d 45 14             	lea    0x14(%ebp),%eax
  801d46:	e8 54 fc ff ff       	call   80199f <getuint>
			base = 8;
  801d4b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801d50:	eb 40                	jmp    801d92 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801d52:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d56:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801d5d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801d60:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801d6b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801d6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d71:	8d 50 04             	lea    0x4(%eax),%edx
  801d74:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801d77:	8b 00                	mov    (%eax),%eax
  801d79:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d7e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d83:	eb 0d                	jmp    801d92 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d85:	8d 45 14             	lea    0x14(%ebp),%eax
  801d88:	e8 12 fc ff ff       	call   80199f <getuint>
			base = 16;
  801d8d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d92:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801d96:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d9a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801d9d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801da1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da5:	89 04 24             	mov    %eax,(%esp)
  801da8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dac:	89 fa                	mov    %edi,%edx
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	e8 fa fa ff ff       	call   8018b0 <printnum>
			break;
  801db6:	e9 88 fc ff ff       	jmp    801a43 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801dbb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dbf:	89 04 24             	mov    %eax,(%esp)
  801dc2:	ff 55 08             	call   *0x8(%ebp)
			break;
  801dc5:	e9 79 fc ff ff       	jmp    801a43 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801dca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801dd5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801dd8:	89 f3                	mov    %esi,%ebx
  801dda:	eb 03                	jmp    801ddf <vprintfmt+0x3c1>
  801ddc:	83 eb 01             	sub    $0x1,%ebx
  801ddf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801de3:	75 f7                	jne    801ddc <vprintfmt+0x3be>
  801de5:	e9 59 fc ff ff       	jmp    801a43 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801dea:	83 c4 3c             	add    $0x3c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 28             	sub    $0x28,%esp
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801dfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e01:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801e05:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801e08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	74 30                	je     801e43 <vsnprintf+0x51>
  801e13:	85 d2                	test   %edx,%edx
  801e15:	7e 2c                	jle    801e43 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801e17:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801e28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2c:	c7 04 24 d9 19 80 00 	movl   $0x8019d9,(%esp)
  801e33:	e8 e6 fb ff ff       	call   801a1e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801e38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e3b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	eb 05                	jmp    801e48 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801e50:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801e53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e57:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	89 04 24             	mov    %eax,(%esp)
  801e6b:	e8 82 ff ff ff       	call   801df2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801e86:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8b:	eb 03                	jmp    801e90 <strlen+0x10>
		n++;
  801e8d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801e90:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801e94:	75 f7                	jne    801e8d <strlen+0xd>
		n++;
	return n;
}
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea6:	eb 03                	jmp    801eab <strnlen+0x13>
		n++;
  801ea8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801eab:	39 d0                	cmp    %edx,%eax
  801ead:	74 06                	je     801eb5 <strnlen+0x1d>
  801eaf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801eb3:	75 f3                	jne    801ea8 <strnlen+0x10>
		n++;
	return n;
}
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    

00801eb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	53                   	push   %ebx
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	83 c2 01             	add    $0x1,%edx
  801ec6:	83 c1 01             	add    $0x1,%ecx
  801ec9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ecd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ed0:	84 db                	test   %bl,%bl
  801ed2:	75 ef                	jne    801ec3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ed4:	5b                   	pop    %ebx
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    

00801ed7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	53                   	push   %ebx
  801edb:	83 ec 08             	sub    $0x8,%esp
  801ede:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ee1:	89 1c 24             	mov    %ebx,(%esp)
  801ee4:	e8 97 ff ff ff       	call   801e80 <strlen>
	strcpy(dst + len, src);
  801ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eec:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef0:	01 d8                	add    %ebx,%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 bd ff ff ff       	call   801eb7 <strcpy>
	return dst;
}
  801efa:	89 d8                	mov    %ebx,%eax
  801efc:	83 c4 08             	add    $0x8,%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	56                   	push   %esi
  801f06:	53                   	push   %ebx
  801f07:	8b 75 08             	mov    0x8(%ebp),%esi
  801f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f0d:	89 f3                	mov    %esi,%ebx
  801f0f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801f12:	89 f2                	mov    %esi,%edx
  801f14:	eb 0f                	jmp    801f25 <strncpy+0x23>
		*dst++ = *src;
  801f16:	83 c2 01             	add    $0x1,%edx
  801f19:	0f b6 01             	movzbl (%ecx),%eax
  801f1c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801f1f:	80 39 01             	cmpb   $0x1,(%ecx)
  801f22:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801f25:	39 da                	cmp    %ebx,%edx
  801f27:	75 ed                	jne    801f16 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801f29:	89 f0                	mov    %esi,%eax
  801f2b:	5b                   	pop    %ebx
  801f2c:	5e                   	pop    %esi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    

00801f2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	8b 75 08             	mov    0x8(%ebp),%esi
  801f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801f3d:	89 f0                	mov    %esi,%eax
  801f3f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801f43:	85 c9                	test   %ecx,%ecx
  801f45:	75 0b                	jne    801f52 <strlcpy+0x23>
  801f47:	eb 1d                	jmp    801f66 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801f49:	83 c0 01             	add    $0x1,%eax
  801f4c:	83 c2 01             	add    $0x1,%edx
  801f4f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801f52:	39 d8                	cmp    %ebx,%eax
  801f54:	74 0b                	je     801f61 <strlcpy+0x32>
  801f56:	0f b6 0a             	movzbl (%edx),%ecx
  801f59:	84 c9                	test   %cl,%cl
  801f5b:	75 ec                	jne    801f49 <strlcpy+0x1a>
  801f5d:	89 c2                	mov    %eax,%edx
  801f5f:	eb 02                	jmp    801f63 <strlcpy+0x34>
  801f61:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801f63:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801f66:	29 f0                	sub    %esi,%eax
}
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f72:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801f75:	eb 06                	jmp    801f7d <strcmp+0x11>
		p++, q++;
  801f77:	83 c1 01             	add    $0x1,%ecx
  801f7a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801f7d:	0f b6 01             	movzbl (%ecx),%eax
  801f80:	84 c0                	test   %al,%al
  801f82:	74 04                	je     801f88 <strcmp+0x1c>
  801f84:	3a 02                	cmp    (%edx),%al
  801f86:	74 ef                	je     801f77 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801f88:	0f b6 c0             	movzbl %al,%eax
  801f8b:	0f b6 12             	movzbl (%edx),%edx
  801f8e:	29 d0                	sub    %edx,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9c:	89 c3                	mov    %eax,%ebx
  801f9e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801fa1:	eb 06                	jmp    801fa9 <strncmp+0x17>
		n--, p++, q++;
  801fa3:	83 c0 01             	add    $0x1,%eax
  801fa6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801fa9:	39 d8                	cmp    %ebx,%eax
  801fab:	74 15                	je     801fc2 <strncmp+0x30>
  801fad:	0f b6 08             	movzbl (%eax),%ecx
  801fb0:	84 c9                	test   %cl,%cl
  801fb2:	74 04                	je     801fb8 <strncmp+0x26>
  801fb4:	3a 0a                	cmp    (%edx),%cl
  801fb6:	74 eb                	je     801fa3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801fb8:	0f b6 00             	movzbl (%eax),%eax
  801fbb:	0f b6 12             	movzbl (%edx),%edx
  801fbe:	29 d0                	sub    %edx,%eax
  801fc0:	eb 05                	jmp    801fc7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801fc7:	5b                   	pop    %ebx
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fd4:	eb 07                	jmp    801fdd <strchr+0x13>
		if (*s == c)
  801fd6:	38 ca                	cmp    %cl,%dl
  801fd8:	74 0f                	je     801fe9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801fda:	83 c0 01             	add    $0x1,%eax
  801fdd:	0f b6 10             	movzbl (%eax),%edx
  801fe0:	84 d2                	test   %dl,%dl
  801fe2:	75 f2                	jne    801fd6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ff5:	eb 07                	jmp    801ffe <strfind+0x13>
		if (*s == c)
  801ff7:	38 ca                	cmp    %cl,%dl
  801ff9:	74 0a                	je     802005 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ffb:	83 c0 01             	add    $0x1,%eax
  801ffe:	0f b6 10             	movzbl (%eax),%edx
  802001:	84 d2                	test   %dl,%dl
  802003:	75 f2                	jne    801ff7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    

00802007 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	57                   	push   %edi
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802010:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802013:	85 c9                	test   %ecx,%ecx
  802015:	74 36                	je     80204d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802017:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80201d:	75 28                	jne    802047 <memset+0x40>
  80201f:	f6 c1 03             	test   $0x3,%cl
  802022:	75 23                	jne    802047 <memset+0x40>
		c &= 0xFF;
  802024:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802028:	89 d3                	mov    %edx,%ebx
  80202a:	c1 e3 08             	shl    $0x8,%ebx
  80202d:	89 d6                	mov    %edx,%esi
  80202f:	c1 e6 18             	shl    $0x18,%esi
  802032:	89 d0                	mov    %edx,%eax
  802034:	c1 e0 10             	shl    $0x10,%eax
  802037:	09 f0                	or     %esi,%eax
  802039:	09 c2                	or     %eax,%edx
  80203b:	89 d0                	mov    %edx,%eax
  80203d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80203f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802042:	fc                   	cld    
  802043:	f3 ab                	rep stos %eax,%es:(%edi)
  802045:	eb 06                	jmp    80204d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204a:	fc                   	cld    
  80204b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80204d:	89 f8                	mov    %edi,%eax
  80204f:	5b                   	pop    %ebx
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    

00802054 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	57                   	push   %edi
  802058:	56                   	push   %esi
  802059:	8b 45 08             	mov    0x8(%ebp),%eax
  80205c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80205f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802062:	39 c6                	cmp    %eax,%esi
  802064:	73 35                	jae    80209b <memmove+0x47>
  802066:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802069:	39 d0                	cmp    %edx,%eax
  80206b:	73 2e                	jae    80209b <memmove+0x47>
		s += n;
		d += n;
  80206d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802070:	89 d6                	mov    %edx,%esi
  802072:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802074:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80207a:	75 13                	jne    80208f <memmove+0x3b>
  80207c:	f6 c1 03             	test   $0x3,%cl
  80207f:	75 0e                	jne    80208f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802081:	83 ef 04             	sub    $0x4,%edi
  802084:	8d 72 fc             	lea    -0x4(%edx),%esi
  802087:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80208a:	fd                   	std    
  80208b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80208d:	eb 09                	jmp    802098 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80208f:	83 ef 01             	sub    $0x1,%edi
  802092:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802095:	fd                   	std    
  802096:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802098:	fc                   	cld    
  802099:	eb 1d                	jmp    8020b8 <memmove+0x64>
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80209f:	f6 c2 03             	test   $0x3,%dl
  8020a2:	75 0f                	jne    8020b3 <memmove+0x5f>
  8020a4:	f6 c1 03             	test   $0x3,%cl
  8020a7:	75 0a                	jne    8020b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8020a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8020ac:	89 c7                	mov    %eax,%edi
  8020ae:	fc                   	cld    
  8020af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8020b1:	eb 05                	jmp    8020b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8020b3:	89 c7                	mov    %eax,%edi
  8020b5:	fc                   	cld    
  8020b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8020c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d3:	89 04 24             	mov    %eax,(%esp)
  8020d6:	e8 79 ff ff ff       	call   802054 <memmove>
}
  8020db:	c9                   	leave  
  8020dc:	c3                   	ret    

008020dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	56                   	push   %esi
  8020e1:	53                   	push   %ebx
  8020e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8020e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020e8:	89 d6                	mov    %edx,%esi
  8020ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020ed:	eb 1a                	jmp    802109 <memcmp+0x2c>
		if (*s1 != *s2)
  8020ef:	0f b6 02             	movzbl (%edx),%eax
  8020f2:	0f b6 19             	movzbl (%ecx),%ebx
  8020f5:	38 d8                	cmp    %bl,%al
  8020f7:	74 0a                	je     802103 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8020f9:	0f b6 c0             	movzbl %al,%eax
  8020fc:	0f b6 db             	movzbl %bl,%ebx
  8020ff:	29 d8                	sub    %ebx,%eax
  802101:	eb 0f                	jmp    802112 <memcmp+0x35>
		s1++, s2++;
  802103:	83 c2 01             	add    $0x1,%edx
  802106:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802109:	39 f2                	cmp    %esi,%edx
  80210b:	75 e2                	jne    8020ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802112:	5b                   	pop    %ebx
  802113:	5e                   	pop    %esi
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80211f:	89 c2                	mov    %eax,%edx
  802121:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802124:	eb 07                	jmp    80212d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  802126:	38 08                	cmp    %cl,(%eax)
  802128:	74 07                	je     802131 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80212a:	83 c0 01             	add    $0x1,%eax
  80212d:	39 d0                	cmp    %edx,%eax
  80212f:	72 f5                	jb     802126 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    

00802133 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	57                   	push   %edi
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	8b 55 08             	mov    0x8(%ebp),%edx
  80213c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80213f:	eb 03                	jmp    802144 <strtol+0x11>
		s++;
  802141:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802144:	0f b6 0a             	movzbl (%edx),%ecx
  802147:	80 f9 09             	cmp    $0x9,%cl
  80214a:	74 f5                	je     802141 <strtol+0xe>
  80214c:	80 f9 20             	cmp    $0x20,%cl
  80214f:	74 f0                	je     802141 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802151:	80 f9 2b             	cmp    $0x2b,%cl
  802154:	75 0a                	jne    802160 <strtol+0x2d>
		s++;
  802156:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802159:	bf 00 00 00 00       	mov    $0x0,%edi
  80215e:	eb 11                	jmp    802171 <strtol+0x3e>
  802160:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802165:	80 f9 2d             	cmp    $0x2d,%cl
  802168:	75 07                	jne    802171 <strtol+0x3e>
		s++, neg = 1;
  80216a:	8d 52 01             	lea    0x1(%edx),%edx
  80216d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802171:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802176:	75 15                	jne    80218d <strtol+0x5a>
  802178:	80 3a 30             	cmpb   $0x30,(%edx)
  80217b:	75 10                	jne    80218d <strtol+0x5a>
  80217d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802181:	75 0a                	jne    80218d <strtol+0x5a>
		s += 2, base = 16;
  802183:	83 c2 02             	add    $0x2,%edx
  802186:	b8 10 00 00 00       	mov    $0x10,%eax
  80218b:	eb 10                	jmp    80219d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80218d:	85 c0                	test   %eax,%eax
  80218f:	75 0c                	jne    80219d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802191:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802193:	80 3a 30             	cmpb   $0x30,(%edx)
  802196:	75 05                	jne    80219d <strtol+0x6a>
		s++, base = 8;
  802198:	83 c2 01             	add    $0x1,%edx
  80219b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80219d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021a2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8021a5:	0f b6 0a             	movzbl (%edx),%ecx
  8021a8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8021ab:	89 f0                	mov    %esi,%eax
  8021ad:	3c 09                	cmp    $0x9,%al
  8021af:	77 08                	ja     8021b9 <strtol+0x86>
			dig = *s - '0';
  8021b1:	0f be c9             	movsbl %cl,%ecx
  8021b4:	83 e9 30             	sub    $0x30,%ecx
  8021b7:	eb 20                	jmp    8021d9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8021b9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8021bc:	89 f0                	mov    %esi,%eax
  8021be:	3c 19                	cmp    $0x19,%al
  8021c0:	77 08                	ja     8021ca <strtol+0x97>
			dig = *s - 'a' + 10;
  8021c2:	0f be c9             	movsbl %cl,%ecx
  8021c5:	83 e9 57             	sub    $0x57,%ecx
  8021c8:	eb 0f                	jmp    8021d9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8021ca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8021cd:	89 f0                	mov    %esi,%eax
  8021cf:	3c 19                	cmp    $0x19,%al
  8021d1:	77 16                	ja     8021e9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8021d3:	0f be c9             	movsbl %cl,%ecx
  8021d6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8021d9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8021dc:	7d 0f                	jge    8021ed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8021de:	83 c2 01             	add    $0x1,%edx
  8021e1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8021e5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8021e7:	eb bc                	jmp    8021a5 <strtol+0x72>
  8021e9:	89 d8                	mov    %ebx,%eax
  8021eb:	eb 02                	jmp    8021ef <strtol+0xbc>
  8021ed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8021ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021f3:	74 05                	je     8021fa <strtol+0xc7>
		*endptr = (char *) s;
  8021f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021f8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8021fa:	f7 d8                	neg    %eax
  8021fc:	85 ff                	test   %edi,%edi
  8021fe:	0f 44 c3             	cmove  %ebx,%eax
}
  802201:	5b                   	pop    %ebx
  802202:	5e                   	pop    %esi
  802203:	5f                   	pop    %edi
  802204:	5d                   	pop    %ebp
  802205:	c3                   	ret    

00802206 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	53                   	push   %ebx
  80220a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80220d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802214:	75 2f                	jne    802245 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802216:	e8 2e df ff ff       	call   800149 <sys_getenvid>
  80221b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80221d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802224:	00 
  802225:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80222c:	ee 
  80222d:	89 04 24             	mov    %eax,(%esp)
  802230:	e8 52 df ff ff       	call   800187 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802235:	c7 44 24 04 b4 04 80 	movl   $0x8004b4,0x4(%esp)
  80223c:	00 
  80223d:	89 1c 24             	mov    %ebx,(%esp)
  802240:	e8 e2 e0 ff ff       	call   800327 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802245:	8b 45 08             	mov    0x8(%ebp),%eax
  802248:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80224d:	83 c4 14             	add    $0x14,%esp
  802250:	5b                   	pop    %ebx
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    
  802253:	66 90                	xchg   %ax,%ax
  802255:	66 90                	xchg   %ax,%ax
  802257:	66 90                	xchg   %ax,%ax
  802259:	66 90                	xchg   %ax,%ax
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	56                   	push   %esi
  802264:	53                   	push   %ebx
  802265:	83 ec 10             	sub    $0x10,%esp
  802268:	8b 75 08             	mov    0x8(%ebp),%esi
  80226b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802271:	85 c0                	test   %eax,%eax
  802273:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802278:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80227b:	89 04 24             	mov    %eax,(%esp)
  80227e:	e8 1a e1 ff ff       	call   80039d <sys_ipc_recv>

	if(ret < 0) {
  802283:	85 c0                	test   %eax,%eax
  802285:	79 16                	jns    80229d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802287:	85 f6                	test   %esi,%esi
  802289:	74 06                	je     802291 <ipc_recv+0x31>
  80228b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802291:	85 db                	test   %ebx,%ebx
  802293:	74 3e                	je     8022d3 <ipc_recv+0x73>
  802295:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80229b:	eb 36                	jmp    8022d3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80229d:	e8 a7 de ff ff       	call   800149 <sys_getenvid>
  8022a2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8022a7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022aa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022af:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8022b4:	85 f6                	test   %esi,%esi
  8022b6:	74 05                	je     8022bd <ipc_recv+0x5d>
  8022b8:	8b 40 74             	mov    0x74(%eax),%eax
  8022bb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8022bd:	85 db                	test   %ebx,%ebx
  8022bf:	74 0a                	je     8022cb <ipc_recv+0x6b>
  8022c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8022c6:	8b 40 78             	mov    0x78(%eax),%eax
  8022c9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8022cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8022d0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022d3:	83 c4 10             	add    $0x10,%esp
  8022d6:	5b                   	pop    %ebx
  8022d7:	5e                   	pop    %esi
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    

008022da <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022da:	55                   	push   %ebp
  8022db:	89 e5                	mov    %esp,%ebp
  8022dd:	57                   	push   %edi
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 1c             	sub    $0x1c,%esp
  8022e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8022ec:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8022ee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022f3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8022f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802301:	89 74 24 04          	mov    %esi,0x4(%esp)
  802305:	89 3c 24             	mov    %edi,(%esp)
  802308:	e8 6d e0 ff ff       	call   80037a <sys_ipc_try_send>

		if(ret >= 0) break;
  80230d:	85 c0                	test   %eax,%eax
  80230f:	79 2c                	jns    80233d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802311:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802314:	74 20                	je     802336 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802316:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231a:	c7 44 24 08 e0 2a 80 	movl   $0x802ae0,0x8(%esp)
  802321:	00 
  802322:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802329:	00 
  80232a:	c7 04 24 10 2b 80 00 	movl   $0x802b10,(%esp)
  802331:	e8 60 f4 ff ff       	call   801796 <_panic>
		}
		sys_yield();
  802336:	e8 2d de ff ff       	call   800168 <sys_yield>
	}
  80233b:	eb b9                	jmp    8022f6 <ipc_send+0x1c>
}
  80233d:	83 c4 1c             	add    $0x1c,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    

00802345 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80234b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802350:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802353:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802359:	8b 52 50             	mov    0x50(%edx),%edx
  80235c:	39 ca                	cmp    %ecx,%edx
  80235e:	75 0d                	jne    80236d <ipc_find_env+0x28>
			return envs[i].env_id;
  802360:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802363:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802368:	8b 40 40             	mov    0x40(%eax),%eax
  80236b:	eb 0e                	jmp    80237b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80236d:	83 c0 01             	add    $0x1,%eax
  802370:	3d 00 04 00 00       	cmp    $0x400,%eax
  802375:	75 d9                	jne    802350 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802377:	66 b8 00 00          	mov    $0x0,%ax
}
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802383:	89 d0                	mov    %edx,%eax
  802385:	c1 e8 16             	shr    $0x16,%eax
  802388:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80238f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802394:	f6 c1 01             	test   $0x1,%cl
  802397:	74 1d                	je     8023b6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802399:	c1 ea 0c             	shr    $0xc,%edx
  80239c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023a3:	f6 c2 01             	test   $0x1,%dl
  8023a6:	74 0e                	je     8023b6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a8:	c1 ea 0c             	shr    $0xc,%edx
  8023ab:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023b2:	ef 
  8023b3:	0f b7 c0             	movzwl %ax,%eax
}
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__udivdi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	83 ec 0c             	sub    $0xc,%esp
  8023c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8023d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023dc:	89 ea                	mov    %ebp,%edx
  8023de:	89 0c 24             	mov    %ecx,(%esp)
  8023e1:	75 2d                	jne    802410 <__udivdi3+0x50>
  8023e3:	39 e9                	cmp    %ebp,%ecx
  8023e5:	77 61                	ja     802448 <__udivdi3+0x88>
  8023e7:	85 c9                	test   %ecx,%ecx
  8023e9:	89 ce                	mov    %ecx,%esi
  8023eb:	75 0b                	jne    8023f8 <__udivdi3+0x38>
  8023ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f2:	31 d2                	xor    %edx,%edx
  8023f4:	f7 f1                	div    %ecx
  8023f6:	89 c6                	mov    %eax,%esi
  8023f8:	31 d2                	xor    %edx,%edx
  8023fa:	89 e8                	mov    %ebp,%eax
  8023fc:	f7 f6                	div    %esi
  8023fe:	89 c5                	mov    %eax,%ebp
  802400:	89 f8                	mov    %edi,%eax
  802402:	f7 f6                	div    %esi
  802404:	89 ea                	mov    %ebp,%edx
  802406:	83 c4 0c             	add    $0xc,%esp
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	39 e8                	cmp    %ebp,%eax
  802412:	77 24                	ja     802438 <__udivdi3+0x78>
  802414:	0f bd e8             	bsr    %eax,%ebp
  802417:	83 f5 1f             	xor    $0x1f,%ebp
  80241a:	75 3c                	jne    802458 <__udivdi3+0x98>
  80241c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802420:	39 34 24             	cmp    %esi,(%esp)
  802423:	0f 86 9f 00 00 00    	jbe    8024c8 <__udivdi3+0x108>
  802429:	39 d0                	cmp    %edx,%eax
  80242b:	0f 82 97 00 00 00    	jb     8024c8 <__udivdi3+0x108>
  802431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802438:	31 d2                	xor    %edx,%edx
  80243a:	31 c0                	xor    %eax,%eax
  80243c:	83 c4 0c             	add    $0xc,%esp
  80243f:	5e                   	pop    %esi
  802440:	5f                   	pop    %edi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
  802443:	90                   	nop
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	89 f8                	mov    %edi,%eax
  80244a:	f7 f1                	div    %ecx
  80244c:	31 d2                	xor    %edx,%edx
  80244e:	83 c4 0c             	add    $0xc,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	8b 3c 24             	mov    (%esp),%edi
  80245d:	d3 e0                	shl    %cl,%eax
  80245f:	89 c6                	mov    %eax,%esi
  802461:	b8 20 00 00 00       	mov    $0x20,%eax
  802466:	29 e8                	sub    %ebp,%eax
  802468:	89 c1                	mov    %eax,%ecx
  80246a:	d3 ef                	shr    %cl,%edi
  80246c:	89 e9                	mov    %ebp,%ecx
  80246e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802472:	8b 3c 24             	mov    (%esp),%edi
  802475:	09 74 24 08          	or     %esi,0x8(%esp)
  802479:	89 d6                	mov    %edx,%esi
  80247b:	d3 e7                	shl    %cl,%edi
  80247d:	89 c1                	mov    %eax,%ecx
  80247f:	89 3c 24             	mov    %edi,(%esp)
  802482:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802486:	d3 ee                	shr    %cl,%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	d3 e2                	shl    %cl,%edx
  80248c:	89 c1                	mov    %eax,%ecx
  80248e:	d3 ef                	shr    %cl,%edi
  802490:	09 d7                	or     %edx,%edi
  802492:	89 f2                	mov    %esi,%edx
  802494:	89 f8                	mov    %edi,%eax
  802496:	f7 74 24 08          	divl   0x8(%esp)
  80249a:	89 d6                	mov    %edx,%esi
  80249c:	89 c7                	mov    %eax,%edi
  80249e:	f7 24 24             	mull   (%esp)
  8024a1:	39 d6                	cmp    %edx,%esi
  8024a3:	89 14 24             	mov    %edx,(%esp)
  8024a6:	72 30                	jb     8024d8 <__udivdi3+0x118>
  8024a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024ac:	89 e9                	mov    %ebp,%ecx
  8024ae:	d3 e2                	shl    %cl,%edx
  8024b0:	39 c2                	cmp    %eax,%edx
  8024b2:	73 05                	jae    8024b9 <__udivdi3+0xf9>
  8024b4:	3b 34 24             	cmp    (%esp),%esi
  8024b7:	74 1f                	je     8024d8 <__udivdi3+0x118>
  8024b9:	89 f8                	mov    %edi,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	e9 7a ff ff ff       	jmp    80243c <__udivdi3+0x7c>
  8024c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8024cf:	e9 68 ff ff ff       	jmp    80243c <__udivdi3+0x7c>
  8024d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	83 c4 0c             	add    $0xc,%esp
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__umoddi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	83 ec 14             	sub    $0x14,%esp
  8024f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802502:	89 c7                	mov    %eax,%edi
  802504:	89 44 24 04          	mov    %eax,0x4(%esp)
  802508:	8b 44 24 30          	mov    0x30(%esp),%eax
  80250c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802510:	89 34 24             	mov    %esi,(%esp)
  802513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802517:	85 c0                	test   %eax,%eax
  802519:	89 c2                	mov    %eax,%edx
  80251b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80251f:	75 17                	jne    802538 <__umoddi3+0x48>
  802521:	39 fe                	cmp    %edi,%esi
  802523:	76 4b                	jbe    802570 <__umoddi3+0x80>
  802525:	89 c8                	mov    %ecx,%eax
  802527:	89 fa                	mov    %edi,%edx
  802529:	f7 f6                	div    %esi
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	31 d2                	xor    %edx,%edx
  80252f:	83 c4 14             	add    $0x14,%esp
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    
  802536:	66 90                	xchg   %ax,%ax
  802538:	39 f8                	cmp    %edi,%eax
  80253a:	77 54                	ja     802590 <__umoddi3+0xa0>
  80253c:	0f bd e8             	bsr    %eax,%ebp
  80253f:	83 f5 1f             	xor    $0x1f,%ebp
  802542:	75 5c                	jne    8025a0 <__umoddi3+0xb0>
  802544:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802548:	39 3c 24             	cmp    %edi,(%esp)
  80254b:	0f 87 e7 00 00 00    	ja     802638 <__umoddi3+0x148>
  802551:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802555:	29 f1                	sub    %esi,%ecx
  802557:	19 c7                	sbb    %eax,%edi
  802559:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80255d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802561:	8b 44 24 08          	mov    0x8(%esp),%eax
  802565:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802569:	83 c4 14             	add    $0x14,%esp
  80256c:	5e                   	pop    %esi
  80256d:	5f                   	pop    %edi
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    
  802570:	85 f6                	test   %esi,%esi
  802572:	89 f5                	mov    %esi,%ebp
  802574:	75 0b                	jne    802581 <__umoddi3+0x91>
  802576:	b8 01 00 00 00       	mov    $0x1,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	f7 f6                	div    %esi
  80257f:	89 c5                	mov    %eax,%ebp
  802581:	8b 44 24 04          	mov    0x4(%esp),%eax
  802585:	31 d2                	xor    %edx,%edx
  802587:	f7 f5                	div    %ebp
  802589:	89 c8                	mov    %ecx,%eax
  80258b:	f7 f5                	div    %ebp
  80258d:	eb 9c                	jmp    80252b <__umoddi3+0x3b>
  80258f:	90                   	nop
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 fa                	mov    %edi,%edx
  802594:	83 c4 14             	add    $0x14,%esp
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    
  80259b:	90                   	nop
  80259c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	8b 04 24             	mov    (%esp),%eax
  8025a3:	be 20 00 00 00       	mov    $0x20,%esi
  8025a8:	89 e9                	mov    %ebp,%ecx
  8025aa:	29 ee                	sub    %ebp,%esi
  8025ac:	d3 e2                	shl    %cl,%edx
  8025ae:	89 f1                	mov    %esi,%ecx
  8025b0:	d3 e8                	shr    %cl,%eax
  8025b2:	89 e9                	mov    %ebp,%ecx
  8025b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b8:	8b 04 24             	mov    (%esp),%eax
  8025bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8025bf:	89 fa                	mov    %edi,%edx
  8025c1:	d3 e0                	shl    %cl,%eax
  8025c3:	89 f1                	mov    %esi,%ecx
  8025c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025cd:	d3 ea                	shr    %cl,%edx
  8025cf:	89 e9                	mov    %ebp,%ecx
  8025d1:	d3 e7                	shl    %cl,%edi
  8025d3:	89 f1                	mov    %esi,%ecx
  8025d5:	d3 e8                	shr    %cl,%eax
  8025d7:	89 e9                	mov    %ebp,%ecx
  8025d9:	09 f8                	or     %edi,%eax
  8025db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8025df:	f7 74 24 04          	divl   0x4(%esp)
  8025e3:	d3 e7                	shl    %cl,%edi
  8025e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025e9:	89 d7                	mov    %edx,%edi
  8025eb:	f7 64 24 08          	mull   0x8(%esp)
  8025ef:	39 d7                	cmp    %edx,%edi
  8025f1:	89 c1                	mov    %eax,%ecx
  8025f3:	89 14 24             	mov    %edx,(%esp)
  8025f6:	72 2c                	jb     802624 <__umoddi3+0x134>
  8025f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8025fc:	72 22                	jb     802620 <__umoddi3+0x130>
  8025fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802602:	29 c8                	sub    %ecx,%eax
  802604:	19 d7                	sbb    %edx,%edi
  802606:	89 e9                	mov    %ebp,%ecx
  802608:	89 fa                	mov    %edi,%edx
  80260a:	d3 e8                	shr    %cl,%eax
  80260c:	89 f1                	mov    %esi,%ecx
  80260e:	d3 e2                	shl    %cl,%edx
  802610:	89 e9                	mov    %ebp,%ecx
  802612:	d3 ef                	shr    %cl,%edi
  802614:	09 d0                	or     %edx,%eax
  802616:	89 fa                	mov    %edi,%edx
  802618:	83 c4 14             	add    $0x14,%esp
  80261b:	5e                   	pop    %esi
  80261c:	5f                   	pop    %edi
  80261d:	5d                   	pop    %ebp
  80261e:	c3                   	ret    
  80261f:	90                   	nop
  802620:	39 d7                	cmp    %edx,%edi
  802622:	75 da                	jne    8025fe <__umoddi3+0x10e>
  802624:	8b 14 24             	mov    (%esp),%edx
  802627:	89 c1                	mov    %eax,%ecx
  802629:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80262d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802631:	eb cb                	jmp    8025fe <__umoddi3+0x10e>
  802633:	90                   	nop
  802634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802638:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80263c:	0f 82 0f ff ff ff    	jb     802551 <__umoddi3+0x61>
  802642:	e9 1a ff ff ff       	jmp    802561 <__umoddi3+0x71>
