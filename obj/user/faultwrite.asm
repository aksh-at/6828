
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800050:	e8 dd 00 00 00       	call   800132 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800090:	e8 e5 05 00 00       	call   80067a <close_all>
	sys_env_destroy(0);
  800095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009c:	e8 3f 00 00 00       	call   8000e0 <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 28                	jle    80012a <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	89 44 24 10          	mov    %eax,0x10(%esp)
  800106:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010d:	00 
  80010e:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011d:	00 
  80011e:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  800125:	e8 2c 16 00 00       	call   801756 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	83 c4 2c             	add    $0x2c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 28                	jle    8001bc <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	89 44 24 10          	mov    %eax,0x10(%esp)
  800198:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019f:	00 
  8001a0:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  8001b7:	e8 9a 15 00 00       	call   801756 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	83 c4 2c             	add    $0x2c,%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 28                	jle    80020f <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001eb:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800202:	00 
  800203:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  80020a:	e8 47 15 00 00       	call   801756 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020f:	83 c4 2c             	add    $0x2c,%esp
  800212:	5b                   	pop    %ebx
  800213:	5e                   	pop    %esi
  800214:	5f                   	pop    %edi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	89 df                	mov    %ebx,%edi
  800232:	89 de                	mov    %ebx,%esi
  800234:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800236:	85 c0                	test   %eax,%eax
  800238:	7e 28                	jle    800262 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800255:	00 
  800256:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  80025d:	e8 f4 14 00 00       	call   801756 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800262:	83 c4 2c             	add    $0x2c,%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	57                   	push   %edi
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800273:	bb 00 00 00 00       	mov    $0x0,%ebx
  800278:	b8 08 00 00 00       	mov    $0x8,%eax
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	89 df                	mov    %ebx,%edi
  800285:	89 de                	mov    %ebx,%esi
  800287:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800289:	85 c0                	test   %eax,%eax
  80028b:	7e 28                	jle    8002b5 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800291:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800298:	00 
  800299:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a8:	00 
  8002a9:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  8002b0:	e8 a1 14 00 00       	call   801756 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b5:	83 c4 2c             	add    $0x2c,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 df                	mov    %ebx,%edi
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7e 28                	jle    800308 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fb:	00 
  8002fc:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  800303:	e8 4e 14 00 00       	call   801756 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800308:	83 c4 2c             	add    $0x2c,%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 df                	mov    %ebx,%edi
  80032b:	89 de                	mov    %ebx,%esi
  80032d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032f:	85 c0                	test   %eax,%eax
  800331:	7e 28                	jle    80035b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800333:	89 44 24 10          	mov    %eax,0x10(%esp)
  800337:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80033e:	00 
  80033f:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  800346:	00 
  800347:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034e:	00 
  80034f:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  800356:	e8 fb 13 00 00       	call   801756 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80035b:	83 c4 2c             	add    $0x2c,%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800369:	be 00 00 00 00       	mov    $0x0,%esi
  80036e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800376:	8b 55 08             	mov    0x8(%ebp),%edx
  800379:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	b8 0d 00 00 00       	mov    $0xd,%eax
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 cb                	mov    %ecx,%ebx
  80039e:	89 cf                	mov    %ecx,%edi
  8003a0:	89 ce                	mov    %ecx,%esi
  8003a2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	7e 28                	jle    8003d0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ac:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b3:	00 
  8003b4:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c3:	00 
  8003c4:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  8003cb:	e8 86 13 00 00       	call   801756 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d0:	83 c4 2c             	add    $0x2c,%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003e8:	89 d1                	mov    %edx,%ecx
  8003ea:	89 d3                	mov    %edx,%ebx
  8003ec:	89 d7                	mov    %edx,%edi
  8003ee:	89 d6                	mov    %edx,%esi
  8003f0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003f2:	5b                   	pop    %ebx
  8003f3:	5e                   	pop    %esi
  8003f4:	5f                   	pop    %edi
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800400:	bb 00 00 00 00       	mov    $0x0,%ebx
  800405:	b8 0f 00 00 00       	mov    $0xf,%eax
  80040a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80040d:	8b 55 08             	mov    0x8(%ebp),%edx
  800410:	89 df                	mov    %ebx,%edi
  800412:	89 de                	mov    %ebx,%esi
  800414:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800416:	85 c0                	test   %eax,%eax
  800418:	7e 28                	jle    800442 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041e:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800425:	00 
  800426:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  80042d:	00 
  80042e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800435:	00 
  800436:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  80043d:	e8 14 13 00 00       	call   801756 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800442:	83 c4 2c             	add    $0x2c,%esp
  800445:	5b                   	pop    %ebx
  800446:	5e                   	pop    %esi
  800447:	5f                   	pop    %edi
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800453:	bb 00 00 00 00       	mov    $0x0,%ebx
  800458:	b8 10 00 00 00       	mov    $0x10,%eax
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	8b 55 08             	mov    0x8(%ebp),%edx
  800463:	89 df                	mov    %ebx,%edi
  800465:	89 de                	mov    %ebx,%esi
  800467:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800469:	85 c0                	test   %eax,%eax
  80046b:	7e 28                	jle    800495 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80046d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800471:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800478:	00 
  800479:	c7 44 24 08 ca 25 80 	movl   $0x8025ca,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  800490:	e8 c1 12 00 00       	call   801756 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800495:	83 c4 2c             	add    $0x2c,%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5f                   	pop    %edi
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    
  80049d:	66 90                	xchg   %ax,%ax
  80049f:	90                   	nop

008004a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8004bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8004c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004c5:	5d                   	pop    %ebp
  8004c6:	c3                   	ret    

008004c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8004d2:	89 c2                	mov    %eax,%edx
  8004d4:	c1 ea 16             	shr    $0x16,%edx
  8004d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004de:	f6 c2 01             	test   $0x1,%dl
  8004e1:	74 11                	je     8004f4 <fd_alloc+0x2d>
  8004e3:	89 c2                	mov    %eax,%edx
  8004e5:	c1 ea 0c             	shr    $0xc,%edx
  8004e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ef:	f6 c2 01             	test   $0x1,%dl
  8004f2:	75 09                	jne    8004fd <fd_alloc+0x36>
			*fd_store = fd;
  8004f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	eb 17                	jmp    800514 <fd_alloc+0x4d>
  8004fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800502:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800507:	75 c9                	jne    8004d2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800509:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80050f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80051c:	83 f8 1f             	cmp    $0x1f,%eax
  80051f:	77 36                	ja     800557 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800521:	c1 e0 0c             	shl    $0xc,%eax
  800524:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800529:	89 c2                	mov    %eax,%edx
  80052b:	c1 ea 16             	shr    $0x16,%edx
  80052e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800535:	f6 c2 01             	test   $0x1,%dl
  800538:	74 24                	je     80055e <fd_lookup+0x48>
  80053a:	89 c2                	mov    %eax,%edx
  80053c:	c1 ea 0c             	shr    $0xc,%edx
  80053f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800546:	f6 c2 01             	test   $0x1,%dl
  800549:	74 1a                	je     800565 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80054b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054e:	89 02                	mov    %eax,(%edx)
	return 0;
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	eb 13                	jmp    80056a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80055c:	eb 0c                	jmp    80056a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80055e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800563:	eb 05                	jmp    80056a <fd_lookup+0x54>
  800565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80056a:	5d                   	pop    %ebp
  80056b:	c3                   	ret    

0080056c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 18             	sub    $0x18,%esp
  800572:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800575:	ba 00 00 00 00       	mov    $0x0,%edx
  80057a:	eb 13                	jmp    80058f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80057c:	39 08                	cmp    %ecx,(%eax)
  80057e:	75 0c                	jne    80058c <dev_lookup+0x20>
			*dev = devtab[i];
  800580:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800583:	89 01                	mov    %eax,(%ecx)
			return 0;
  800585:	b8 00 00 00 00       	mov    $0x0,%eax
  80058a:	eb 38                	jmp    8005c4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80058c:	83 c2 01             	add    $0x1,%edx
  80058f:	8b 04 95 74 26 80 00 	mov    0x802674(,%edx,4),%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	75 e2                	jne    80057c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80059a:	a1 08 40 80 00       	mov    0x804008,%eax
  80059f:	8b 40 48             	mov    0x48(%eax),%eax
  8005a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005aa:	c7 04 24 f8 25 80 00 	movl   $0x8025f8,(%esp)
  8005b1:	e8 99 12 00 00       	call   80184f <cprintf>
	*dev = 0;
  8005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8005bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005c4:	c9                   	leave  
  8005c5:	c3                   	ret    

008005c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8005c6:	55                   	push   %ebp
  8005c7:	89 e5                	mov    %esp,%ebp
  8005c9:	56                   	push   %esi
  8005ca:	53                   	push   %ebx
  8005cb:	83 ec 20             	sub    $0x20,%esp
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8005db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8005e1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	e8 2a ff ff ff       	call   800516 <fd_lookup>
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	78 05                	js     8005f5 <fd_close+0x2f>
	    || fd != fd2)
  8005f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005f3:	74 0c                	je     800601 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8005f5:	84 db                	test   %bl,%bl
  8005f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fc:	0f 44 c2             	cmove  %edx,%eax
  8005ff:	eb 3f                	jmp    800640 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	8b 06                	mov    (%esi),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 5a ff ff ff       	call   80056c <dev_lookup>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	85 c0                	test   %eax,%eax
  800616:	78 16                	js     80062e <fd_close+0x68>
		if (dev->dev_close)
  800618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80061e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800623:	85 c0                	test   %eax,%eax
  800625:	74 07                	je     80062e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800627:	89 34 24             	mov    %esi,(%esp)
  80062a:	ff d0                	call   *%eax
  80062c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80062e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800639:	e8 d9 fb ff ff       	call   800217 <sys_page_unmap>
	return r;
  80063e:	89 d8                	mov    %ebx,%eax
}
  800640:	83 c4 20             	add    $0x20,%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80064d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800650:	89 44 24 04          	mov    %eax,0x4(%esp)
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	e8 b7 fe ff ff       	call   800516 <fd_lookup>
  80065f:	89 c2                	mov    %eax,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	78 13                	js     800678 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800665:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80066c:	00 
  80066d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	e8 4e ff ff ff       	call   8005c6 <fd_close>
}
  800678:	c9                   	leave  
  800679:	c3                   	ret    

0080067a <close_all>:

void
close_all(void)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	53                   	push   %ebx
  80067e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800681:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800686:	89 1c 24             	mov    %ebx,(%esp)
  800689:	e8 b9 ff ff ff       	call   800647 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80068e:	83 c3 01             	add    $0x1,%ebx
  800691:	83 fb 20             	cmp    $0x20,%ebx
  800694:	75 f0                	jne    800686 <close_all+0xc>
		close(i);
}
  800696:	83 c4 14             	add    $0x14,%esp
  800699:	5b                   	pop    %ebx
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	57                   	push   %edi
  8006a0:	56                   	push   %esi
  8006a1:	53                   	push   %ebx
  8006a2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8006a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 5f fe ff ff       	call   800516 <fd_lookup>
  8006b7:	89 c2                	mov    %eax,%edx
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	0f 88 e1 00 00 00    	js     8007a2 <dup+0x106>
		return r;
	close(newfdnum);
  8006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 7b ff ff ff       	call   800647 <close>

	newfd = INDEX2FD(newfdnum);
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	c1 e3 0c             	shl    $0xc,%ebx
  8006d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8006d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 cd fd ff ff       	call   8004b0 <fd2data>
  8006e3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8006e5:	89 1c 24             	mov    %ebx,(%esp)
  8006e8:	e8 c3 fd ff ff       	call   8004b0 <fd2data>
  8006ed:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	c1 e8 16             	shr    $0x16,%eax
  8006f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006fb:	a8 01                	test   $0x1,%al
  8006fd:	74 43                	je     800742 <dup+0xa6>
  8006ff:	89 f0                	mov    %esi,%eax
  800701:	c1 e8 0c             	shr    $0xc,%eax
  800704:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80070b:	f6 c2 01             	test   $0x1,%dl
  80070e:	74 32                	je     800742 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800710:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800717:	25 07 0e 00 00       	and    $0xe07,%eax
  80071c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800720:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800724:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80072b:	00 
  80072c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800737:	e8 88 fa ff ff       	call   8001c4 <sys_page_map>
  80073c:	89 c6                	mov    %eax,%esi
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 3e                	js     800780 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800742:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800745:	89 c2                	mov    %eax,%edx
  800747:	c1 ea 0c             	shr    $0xc,%edx
  80074a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800751:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800757:	89 54 24 10          	mov    %edx,0x10(%esp)
  80075b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80075f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800766:	00 
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800772:	e8 4d fa ff ff       	call   8001c4 <sys_page_map>
  800777:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80077c:	85 f6                	test   %esi,%esi
  80077e:	79 22                	jns    8007a2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80078b:	e8 87 fa ff ff       	call   800217 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800790:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80079b:	e8 77 fa ff ff       	call   800217 <sys_page_unmap>
	return r;
  8007a0:	89 f0                	mov    %esi,%eax
}
  8007a2:	83 c4 3c             	add    $0x3c,%esp
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	5f                   	pop    %edi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	83 ec 24             	sub    $0x24,%esp
  8007b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	89 1c 24             	mov    %ebx,(%esp)
  8007be:	e8 53 fd ff ff       	call   800516 <fd_lookup>
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	78 6d                	js     800836 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d3:	8b 00                	mov    (%eax),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	e8 8f fd ff ff       	call   80056c <dev_lookup>
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	78 55                	js     800836 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e4:	8b 50 08             	mov    0x8(%eax),%edx
  8007e7:	83 e2 03             	and    $0x3,%edx
  8007ea:	83 fa 01             	cmp    $0x1,%edx
  8007ed:	75 23                	jne    800812 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ff:	c7 04 24 39 26 80 00 	movl   $0x802639,(%esp)
  800806:	e8 44 10 00 00       	call   80184f <cprintf>
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800810:	eb 24                	jmp    800836 <read+0x8c>
	}
	if (!dev->dev_read)
  800812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800815:	8b 52 08             	mov    0x8(%edx),%edx
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 15                	je     800831 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80081c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80081f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80082a:	89 04 24             	mov    %eax,(%esp)
  80082d:	ff d2                	call   *%edx
  80082f:	eb 05                	jmp    800836 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800831:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800836:	83 c4 24             	add    $0x24,%esp
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	57                   	push   %edi
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	83 ec 1c             	sub    $0x1c,%esp
  800845:	8b 7d 08             	mov    0x8(%ebp),%edi
  800848:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80084b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800850:	eb 23                	jmp    800875 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800852:	89 f0                	mov    %esi,%eax
  800854:	29 d8                	sub    %ebx,%eax
  800856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085a:	89 d8                	mov    %ebx,%eax
  80085c:	03 45 0c             	add    0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	89 3c 24             	mov    %edi,(%esp)
  800866:	e8 3f ff ff ff       	call   8007aa <read>
		if (m < 0)
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 10                	js     80087f <readn+0x43>
			return m;
		if (m == 0)
  80086f:	85 c0                	test   %eax,%eax
  800871:	74 0a                	je     80087d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800873:	01 c3                	add    %eax,%ebx
  800875:	39 f3                	cmp    %esi,%ebx
  800877:	72 d9                	jb     800852 <readn+0x16>
  800879:	89 d8                	mov    %ebx,%eax
  80087b:	eb 02                	jmp    80087f <readn+0x43>
  80087d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80087f:	83 c4 1c             	add    $0x1c,%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 24             	sub    $0x24,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800891:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800894:	89 44 24 04          	mov    %eax,0x4(%esp)
  800898:	89 1c 24             	mov    %ebx,(%esp)
  80089b:	e8 76 fc ff ff       	call   800516 <fd_lookup>
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	78 68                	js     80090e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b0:	8b 00                	mov    (%eax),%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 b2 fc ff ff       	call   80056c <dev_lookup>
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 50                	js     80090e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008c5:	75 23                	jne    8008ea <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8008c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8008cc:	8b 40 48             	mov    0x48(%eax),%eax
  8008cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d7:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  8008de:	e8 6c 0f 00 00       	call   80184f <cprintf>
		return -E_INVAL;
  8008e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e8:	eb 24                	jmp    80090e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	74 15                	je     800909 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	ff d2                	call   *%edx
  800907:	eb 05                	jmp    80090e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800909:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80090e:	83 c4 24             	add    $0x24,%esp
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <seek>:

int
seek(int fdnum, off_t offset)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80091a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80091d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	e8 ea fb ff ff       	call   800516 <fd_lookup>
  80092c:	85 c0                	test   %eax,%eax
  80092e:	78 0e                	js     80093e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	83 ec 24             	sub    $0x24,%esp
  800947:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80094a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80094d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800951:	89 1c 24             	mov    %ebx,(%esp)
  800954:	e8 bd fb ff ff       	call   800516 <fd_lookup>
  800959:	89 c2                	mov    %eax,%edx
  80095b:	85 d2                	test   %edx,%edx
  80095d:	78 61                	js     8009c0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 f9 fb ff ff       	call   80056c <dev_lookup>
  800973:	85 c0                	test   %eax,%eax
  800975:	78 49                	js     8009c0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80097e:	75 23                	jne    8009a3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800980:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800985:	8b 40 48             	mov    0x48(%eax),%eax
  800988:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  800997:	e8 b3 0e 00 00       	call   80184f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80099c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a1:	eb 1d                	jmp    8009c0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8009a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009a6:	8b 52 18             	mov    0x18(%edx),%edx
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 0e                	je     8009bb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b4:	89 04 24             	mov    %eax,(%esp)
  8009b7:	ff d2                	call   *%edx
  8009b9:	eb 05                	jmp    8009c0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8009c0:	83 c4 24             	add    $0x24,%esp
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	83 ec 24             	sub    $0x24,%esp
  8009cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	89 04 24             	mov    %eax,(%esp)
  8009dd:	e8 34 fb ff ff       	call   800516 <fd_lookup>
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	85 d2                	test   %edx,%edx
  8009e6:	78 52                	js     800a3a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f2:	8b 00                	mov    (%eax),%eax
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	e8 70 fb ff ff       	call   80056c <dev_lookup>
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 3a                	js     800a3a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a03:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a07:	74 2c                	je     800a35 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a09:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a0c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a13:	00 00 00 
	stat->st_isdir = 0;
  800a16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a1d:	00 00 00 
	stat->st_dev = dev;
  800a20:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a2d:	89 14 24             	mov    %edx,(%esp)
  800a30:	ff 50 14             	call   *0x14(%eax)
  800a33:	eb 05                	jmp    800a3a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a35:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a3a:	83 c4 24             	add    $0x24,%esp
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a4f:	00 
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	e8 28 02 00 00       	call   800c83 <open>
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	78 1b                	js     800a7c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a68:	89 1c 24             	mov    %ebx,(%esp)
  800a6b:	e8 56 ff ff ff       	call   8009c6 <fstat>
  800a70:	89 c6                	mov    %eax,%esi
	close(fd);
  800a72:	89 1c 24             	mov    %ebx,(%esp)
  800a75:	e8 cd fb ff ff       	call   800647 <close>
	return r;
  800a7a:	89 f0                	mov    %esi,%eax
}
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	83 ec 10             	sub    $0x10,%esp
  800a8b:	89 c6                	mov    %eax,%esi
  800a8d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a8f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a96:	75 11                	jne    800aa9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9f:	e8 11 18 00 00       	call   8022b5 <ipc_find_env>
  800aa4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800aa9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ab0:	00 
  800ab1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ab8:	00 
  800ab9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800abd:	a1 00 40 80 00       	mov    0x804000,%eax
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	e8 80 17 00 00       	call   80224a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800aca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ad1:	00 
  800ad2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800add:	e8 ee 16 00 00       	call   8021d0 <ipc_recv>
}
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 40 0c             	mov    0xc(%eax),%eax
  800af5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0c:	e8 72 ff ff ff       	call   800a83 <fsipc>
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 06 00 00 00       	mov    $0x6,%eax
  800b2e:	e8 50 ff ff ff       	call   800a83 <fsipc>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	83 ec 14             	sub    $0x14,%esp
  800b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 40 0c             	mov    0xc(%eax),%eax
  800b45:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b54:	e8 2a ff ff ff       	call   800a83 <fsipc>
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	85 d2                	test   %edx,%edx
  800b5d:	78 2b                	js     800b8a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b5f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b66:	00 
  800b67:	89 1c 24             	mov    %ebx,(%esp)
  800b6a:	e8 08 13 00 00       	call   801e77 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b6f:	a1 80 50 80 00       	mov    0x805080,%eax
  800b74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b7a:	a1 84 50 80 00       	mov    0x805084,%eax
  800b7f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8a:	83 c4 14             	add    $0x14,%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 18             	sub    $0x18,%esp
  800b96:	8b 45 10             	mov    0x10(%ebp),%eax
  800b99:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b9e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800ba3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 52 0c             	mov    0xc(%edx),%edx
  800bac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800bb2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  800bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bc9:	e8 46 14 00 00       	call   802014 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd8:	e8 a6 fe ff ff       	call   800a83 <fsipc>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 10             	sub    $0x10,%esp
  800be7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bf5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	e8 79 fe ff ff       	call   800a83 <fsipc>
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 6a                	js     800c7a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c10:	39 c6                	cmp    %eax,%esi
  800c12:	73 24                	jae    800c38 <devfile_read+0x59>
  800c14:	c7 44 24 0c 88 26 80 	movl   $0x802688,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800c33:	e8 1e 0b 00 00       	call   801756 <_panic>
	assert(r <= PGSIZE);
  800c38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c3d:	7e 24                	jle    800c63 <devfile_read+0x84>
  800c3f:	c7 44 24 0c af 26 80 	movl   $0x8026af,0xc(%esp)
  800c46:	00 
  800c47:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800c5e:	e8 f3 0a 00 00       	call   801756 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c67:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c6e:	00 
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	89 04 24             	mov    %eax,(%esp)
  800c75:	e8 9a 13 00 00       	call   802014 <memmove>
	return r;
}
  800c7a:	89 d8                	mov    %ebx,%eax
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	53                   	push   %ebx
  800c87:	83 ec 24             	sub    $0x24,%esp
  800c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c8d:	89 1c 24             	mov    %ebx,(%esp)
  800c90:	e8 ab 11 00 00       	call   801e40 <strlen>
  800c95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c9a:	7f 60                	jg     800cfc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9f:	89 04 24             	mov    %eax,(%esp)
  800ca2:	e8 20 f8 ff ff       	call   8004c7 <fd_alloc>
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	85 d2                	test   %edx,%edx
  800cab:	78 54                	js     800d01 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cb1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cb8:	e8 ba 11 00 00       	call   801e77 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccd:	e8 b1 fd ff ff       	call   800a83 <fsipc>
  800cd2:	89 c3                	mov    %eax,%ebx
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	79 17                	jns    800cef <open+0x6c>
		fd_close(fd, 0);
  800cd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cdf:	00 
  800ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce3:	89 04 24             	mov    %eax,(%esp)
  800ce6:	e8 db f8 ff ff       	call   8005c6 <fd_close>
		return r;
  800ceb:	89 d8                	mov    %ebx,%eax
  800ced:	eb 12                	jmp    800d01 <open+0x7e>
	}

	return fd2num(fd);
  800cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 a6 f7 ff ff       	call   8004a0 <fd2num>
  800cfa:	eb 05                	jmp    800d01 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cfc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800d01:	83 c4 24             	add    $0x24,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 08 00 00 00       	mov    $0x8,%eax
  800d17:	e8 67 fd ff ff       	call   800a83 <fsipc>
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d26:	c7 44 24 04 bb 26 80 	movl   $0x8026bb,0x4(%esp)
  800d2d:	00 
  800d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d31:	89 04 24             	mov    %eax,(%esp)
  800d34:	e8 3e 11 00 00       	call   801e77 <strcpy>
	return 0;
}
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	83 ec 14             	sub    $0x14,%esp
  800d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d4a:	89 1c 24             	mov    %ebx,(%esp)
  800d4d:	e8 9b 15 00 00       	call   8022ed <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800d52:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800d57:	83 f8 01             	cmp    $0x1,%eax
  800d5a:	75 0d                	jne    800d69 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800d5c:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 29 03 00 00       	call   801090 <nsipc_close>
  800d67:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	83 c4 14             	add    $0x14,%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d7e:	00 
  800d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	8b 40 0c             	mov    0xc(%eax),%eax
  800d93:	89 04 24             	mov    %eax,(%esp)
  800d96:	e8 f0 03 00 00       	call   80118b <nsipc_send>
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800da3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800daa:	00 
  800dab:	8b 45 10             	mov    0x10(%ebp),%eax
  800dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbf:	89 04 24             	mov    %eax,(%esp)
  800dc2:	e8 44 03 00 00       	call   80110b <nsipc_recv>
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800dcf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800dd2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dd6:	89 04 24             	mov    %eax,(%esp)
  800dd9:	e8 38 f7 ff ff       	call   800516 <fd_lookup>
  800dde:	85 c0                	test   %eax,%eax
  800de0:	78 17                	js     800df9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800deb:	39 08                	cmp    %ecx,(%eax)
  800ded:	75 05                	jne    800df4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800def:	8b 40 0c             	mov    0xc(%eax),%eax
  800df2:	eb 05                	jmp    800df9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800df4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 20             	sub    $0x20,%esp
  800e03:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e08:	89 04 24             	mov    %eax,(%esp)
  800e0b:	e8 b7 f6 ff ff       	call   8004c7 <fd_alloc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 21                	js     800e37 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e1d:	00 
  800e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e2c:	e8 3f f3 ff ff       	call   800170 <sys_page_alloc>
  800e31:	89 c3                	mov    %eax,%ebx
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 0c                	jns    800e43 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  800e37:	89 34 24             	mov    %esi,(%esp)
  800e3a:	e8 51 02 00 00       	call   801090 <nsipc_close>
		return r;
  800e3f:	89 d8                	mov    %ebx,%eax
  800e41:	eb 20                	jmp    800e63 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e51:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800e58:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800e5b:	89 14 24             	mov    %edx,(%esp)
  800e5e:	e8 3d f6 ff ff       	call   8004a0 <fd2num>
}
  800e63:	83 c4 20             	add    $0x20,%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	e8 51 ff ff ff       	call   800dc9 <fd2sockid>
		return r;
  800e78:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	78 23                	js     800ea1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e81:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e88:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e8c:	89 04 24             	mov    %eax,(%esp)
  800e8f:	e8 45 01 00 00       	call   800fd9 <nsipc_accept>
		return r;
  800e94:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 07                	js     800ea1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  800e9a:	e8 5c ff ff ff       	call   800dfb <alloc_sockfd>
  800e9f:	89 c1                	mov    %eax,%ecx
}
  800ea1:	89 c8                	mov    %ecx,%eax
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	e8 16 ff ff ff       	call   800dc9 <fd2sockid>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	85 d2                	test   %edx,%edx
  800eb7:	78 16                	js     800ecf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  800eb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec7:	89 14 24             	mov    %edx,(%esp)
  800eca:	e8 60 01 00 00       	call   80102f <nsipc_bind>
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <shutdown>:

int
shutdown(int s, int how)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	e8 ea fe ff ff       	call   800dc9 <fd2sockid>
  800edf:	89 c2                	mov    %eax,%edx
  800ee1:	85 d2                	test   %edx,%edx
  800ee3:	78 0f                	js     800ef4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eec:	89 14 24             	mov    %edx,(%esp)
  800eef:	e8 7a 01 00 00       	call   80106e <nsipc_shutdown>
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	e8 c5 fe ff ff       	call   800dc9 <fd2sockid>
  800f04:	89 c2                	mov    %eax,%edx
  800f06:	85 d2                	test   %edx,%edx
  800f08:	78 16                	js     800f20 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  800f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f18:	89 14 24             	mov    %edx,(%esp)
  800f1b:	e8 8a 01 00 00       	call   8010aa <nsipc_connect>
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <listen>:

int
listen(int s, int backlog)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	e8 99 fe ff ff       	call   800dc9 <fd2sockid>
  800f30:	89 c2                	mov    %eax,%edx
  800f32:	85 d2                	test   %edx,%edx
  800f34:	78 0f                	js     800f45 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3d:	89 14 24             	mov    %edx,(%esp)
  800f40:	e8 a4 01 00 00       	call   8010e9 <nsipc_listen>
}
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	89 04 24             	mov    %eax,(%esp)
  800f61:	e8 98 02 00 00       	call   8011fe <nsipc_socket>
  800f66:	89 c2                	mov    %eax,%edx
  800f68:	85 d2                	test   %edx,%edx
  800f6a:	78 05                	js     800f71 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  800f6c:	e8 8a fe ff ff       	call   800dfb <alloc_sockfd>
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	53                   	push   %ebx
  800f77:	83 ec 14             	sub    $0x14,%esp
  800f7a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f7c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f83:	75 11                	jne    800f96 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f8c:	e8 24 13 00 00       	call   8022b5 <ipc_find_env>
  800f91:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800fa5:	00 
  800fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800faa:	a1 04 40 80 00       	mov    0x804004,%eax
  800faf:	89 04 24             	mov    %eax,(%esp)
  800fb2:	e8 93 12 00 00       	call   80224a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800fb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fce:	e8 fd 11 00 00       	call   8021d0 <ipc_recv>
}
  800fd3:	83 c4 14             	add    $0x14,%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 10             	sub    $0x10,%esp
  800fe1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fec:	8b 06                	mov    (%esi),%eax
  800fee:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff8:	e8 76 ff ff ff       	call   800f73 <nsipc>
  800ffd:	89 c3                	mov    %eax,%ebx
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 23                	js     801026 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801003:	a1 10 60 80 00       	mov    0x806010,%eax
  801008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801013:	00 
  801014:	8b 45 0c             	mov    0xc(%ebp),%eax
  801017:	89 04 24             	mov    %eax,(%esp)
  80101a:	e8 f5 0f 00 00       	call   802014 <memmove>
		*addrlen = ret->ret_addrlen;
  80101f:	a1 10 60 80 00       	mov    0x806010,%eax
  801024:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801026:	89 d8                	mov    %ebx,%eax
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	53                   	push   %ebx
  801033:	83 ec 14             	sub    $0x14,%esp
  801036:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801039:	8b 45 08             	mov    0x8(%ebp),%eax
  80103c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801041:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801045:	8b 45 0c             	mov    0xc(%ebp),%eax
  801048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801053:	e8 bc 0f 00 00       	call   802014 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801058:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80105e:	b8 02 00 00 00       	mov    $0x2,%eax
  801063:	e8 0b ff ff ff       	call   800f73 <nsipc>
}
  801068:	83 c4 14             	add    $0x14,%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801084:	b8 03 00 00 00       	mov    $0x3,%eax
  801089:	e8 e5 fe ff ff       	call   800f73 <nsipc>
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <nsipc_close>:

int
nsipc_close(int s)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80109e:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a3:	e8 cb fe ff ff       	call   800f73 <nsipc>
}
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 14             	sub    $0x14,%esp
  8010b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8010bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8010ce:	e8 41 0f 00 00       	call   802014 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8010d3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8010d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8010de:	e8 90 fe ff ff       	call   800f73 <nsipc>
}
  8010e3:	83 c4 14             	add    $0x14,%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fa:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801104:	e8 6a fe ff ff       	call   800f73 <nsipc>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	56                   	push   %esi
  80110f:	53                   	push   %ebx
  801110:	83 ec 10             	sub    $0x10,%esp
  801113:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80111e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801124:	8b 45 14             	mov    0x14(%ebp),%eax
  801127:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80112c:	b8 07 00 00 00       	mov    $0x7,%eax
  801131:	e8 3d fe ff ff       	call   800f73 <nsipc>
  801136:	89 c3                	mov    %eax,%ebx
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 46                	js     801182 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80113c:	39 f0                	cmp    %esi,%eax
  80113e:	7f 07                	jg     801147 <nsipc_recv+0x3c>
  801140:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801145:	7e 24                	jle    80116b <nsipc_recv+0x60>
  801147:	c7 44 24 0c c7 26 80 	movl   $0x8026c7,0xc(%esp)
  80114e:	00 
  80114f:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  801166:	e8 eb 05 00 00       	call   801756 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80116b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801176:	00 
  801177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117a:	89 04 24             	mov    %eax,(%esp)
  80117d:	e8 92 0e 00 00       	call   802014 <memmove>
	}

	return r;
}
  801182:	89 d8                	mov    %ebx,%eax
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	53                   	push   %ebx
  80118f:	83 ec 14             	sub    $0x14,%esp
  801192:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801195:	8b 45 08             	mov    0x8(%ebp),%eax
  801198:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80119d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8011a3:	7e 24                	jle    8011c9 <nsipc_send+0x3e>
  8011a5:	c7 44 24 0c e8 26 80 	movl   $0x8026e8,0xc(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011bc:	00 
  8011bd:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  8011c4:	e8 8d 05 00 00       	call   801756 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d4:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8011db:	e8 34 0e 00 00       	call   802014 <memmove>
	nsipcbuf.send.req_size = size;
  8011e0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8011e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8011e9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f3:	e8 7b fd ff ff       	call   800f73 <nsipc>
}
  8011f8:	83 c4 14             	add    $0x14,%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801204:	8b 45 08             	mov    0x8(%ebp),%eax
  801207:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80120c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801214:	8b 45 10             	mov    0x10(%ebp),%eax
  801217:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80121c:	b8 09 00 00 00       	mov    $0x9,%eax
  801221:	e8 4d fd ff ff       	call   800f73 <nsipc>
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 10             	sub    $0x10,%esp
  801230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	89 04 24             	mov    %eax,(%esp)
  801239:	e8 72 f2 ff ff       	call   8004b0 <fd2data>
  80123e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801240:	c7 44 24 04 f4 26 80 	movl   $0x8026f4,0x4(%esp)
  801247:	00 
  801248:	89 1c 24             	mov    %ebx,(%esp)
  80124b:	e8 27 0c 00 00       	call   801e77 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801250:	8b 46 04             	mov    0x4(%esi),%eax
  801253:	2b 06                	sub    (%esi),%eax
  801255:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80125b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801262:	00 00 00 
	stat->st_dev = &devpipe;
  801265:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80126c:	30 80 00 
	return 0;
}
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 14             	sub    $0x14,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801285:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801290:	e8 82 ef ff ff       	call   800217 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801295:	89 1c 24             	mov    %ebx,(%esp)
  801298:	e8 13 f2 ff ff       	call   8004b0 <fd2data>
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a8:	e8 6a ef ff ff       	call   800217 <sys_page_unmap>
}
  8012ad:	83 c4 14             	add    $0x14,%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 2c             	sub    $0x2c,%esp
  8012bc:	89 c6                	mov    %eax,%esi
  8012be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012c9:	89 34 24             	mov    %esi,(%esp)
  8012cc:	e8 1c 10 00 00       	call   8022ed <pageref>
  8012d1:	89 c7                	mov    %eax,%edi
  8012d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d6:	89 04 24             	mov    %eax,(%esp)
  8012d9:	e8 0f 10 00 00       	call   8022ed <pageref>
  8012de:	39 c7                	cmp    %eax,%edi
  8012e0:	0f 94 c2             	sete   %dl
  8012e3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8012e6:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8012ec:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8012ef:	39 fb                	cmp    %edi,%ebx
  8012f1:	74 21                	je     801314 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8012f3:	84 d2                	test   %dl,%dl
  8012f5:	74 ca                	je     8012c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012f7:	8b 51 58             	mov    0x58(%ecx),%edx
  8012fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  801302:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801306:	c7 04 24 fb 26 80 00 	movl   $0x8026fb,(%esp)
  80130d:	e8 3d 05 00 00       	call   80184f <cprintf>
  801312:	eb ad                	jmp    8012c1 <_pipeisclosed+0xe>
	}
}
  801314:	83 c4 2c             	add    $0x2c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 1c             	sub    $0x1c,%esp
  801325:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801328:	89 34 24             	mov    %esi,(%esp)
  80132b:	e8 80 f1 ff ff       	call   8004b0 <fd2data>
  801330:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801332:	bf 00 00 00 00       	mov    $0x0,%edi
  801337:	eb 45                	jmp    80137e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801339:	89 da                	mov    %ebx,%edx
  80133b:	89 f0                	mov    %esi,%eax
  80133d:	e8 71 ff ff ff       	call   8012b3 <_pipeisclosed>
  801342:	85 c0                	test   %eax,%eax
  801344:	75 41                	jne    801387 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801346:	e8 06 ee ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80134b:	8b 43 04             	mov    0x4(%ebx),%eax
  80134e:	8b 0b                	mov    (%ebx),%ecx
  801350:	8d 51 20             	lea    0x20(%ecx),%edx
  801353:	39 d0                	cmp    %edx,%eax
  801355:	73 e2                	jae    801339 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80135e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801361:	99                   	cltd   
  801362:	c1 ea 1b             	shr    $0x1b,%edx
  801365:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801368:	83 e1 1f             	and    $0x1f,%ecx
  80136b:	29 d1                	sub    %edx,%ecx
  80136d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801371:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801375:	83 c0 01             	add    $0x1,%eax
  801378:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80137b:	83 c7 01             	add    $0x1,%edi
  80137e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801381:	75 c8                	jne    80134b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801383:	89 f8                	mov    %edi,%eax
  801385:	eb 05                	jmp    80138c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80138c:	83 c4 1c             	add    $0x1c,%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	57                   	push   %edi
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	83 ec 1c             	sub    $0x1c,%esp
  80139d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8013a0:	89 3c 24             	mov    %edi,(%esp)
  8013a3:	e8 08 f1 ff ff       	call   8004b0 <fd2data>
  8013a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013aa:	be 00 00 00 00       	mov    $0x0,%esi
  8013af:	eb 3d                	jmp    8013ee <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8013b1:	85 f6                	test   %esi,%esi
  8013b3:	74 04                	je     8013b9 <devpipe_read+0x25>
				return i;
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	eb 43                	jmp    8013fc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013b9:	89 da                	mov    %ebx,%edx
  8013bb:	89 f8                	mov    %edi,%eax
  8013bd:	e8 f1 fe ff ff       	call   8012b3 <_pipeisclosed>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	75 31                	jne    8013f7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8013c6:	e8 86 ed ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013cb:	8b 03                	mov    (%ebx),%eax
  8013cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8013d0:	74 df                	je     8013b1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8013d2:	99                   	cltd   
  8013d3:	c1 ea 1b             	shr    $0x1b,%edx
  8013d6:	01 d0                	add    %edx,%eax
  8013d8:	83 e0 1f             	and    $0x1f,%eax
  8013db:	29 d0                	sub    %edx,%eax
  8013dd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8013e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8013e8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013eb:	83 c6 01             	add    $0x1,%esi
  8013ee:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013f1:	75 d8                	jne    8013cb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013f3:	89 f0                	mov    %esi,%eax
  8013f5:	eb 05                	jmp    8013fc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013fc:	83 c4 1c             	add    $0x1c,%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80140c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140f:	89 04 24             	mov    %eax,(%esp)
  801412:	e8 b0 f0 ff ff       	call   8004c7 <fd_alloc>
  801417:	89 c2                	mov    %eax,%edx
  801419:	85 d2                	test   %edx,%edx
  80141b:	0f 88 4d 01 00 00    	js     80156e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801421:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801428:	00 
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801437:	e8 34 ed ff ff       	call   800170 <sys_page_alloc>
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	85 d2                	test   %edx,%edx
  801440:	0f 88 28 01 00 00    	js     80156e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 76 f0 ff ff       	call   8004c7 <fd_alloc>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	85 c0                	test   %eax,%eax
  801455:	0f 88 fe 00 00 00    	js     801559 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80145b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801462:	00 
  801463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801471:	e8 fa ec ff ff       	call   800170 <sys_page_alloc>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	85 c0                	test   %eax,%eax
  80147a:	0f 88 d9 00 00 00    	js     801559 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 25 f0 ff ff       	call   8004b0 <fd2data>
  80148b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80148d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801494:	00 
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a0:	e8 cb ec ff ff       	call   800170 <sys_page_alloc>
  8014a5:	89 c3                	mov    %eax,%ebx
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	0f 88 97 00 00 00    	js     801546 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	89 04 24             	mov    %eax,(%esp)
  8014b5:	e8 f6 ef ff ff       	call   8004b0 <fd2data>
  8014ba:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8014c1:	00 
  8014c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014cd:	00 
  8014ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d9:	e8 e6 ec ff ff       	call   8001c4 <sys_page_map>
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 52                	js     801536 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8014e4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801507:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801511:	89 04 24             	mov    %eax,(%esp)
  801514:	e8 87 ef ff ff       	call   8004a0 <fd2num>
  801519:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	89 04 24             	mov    %eax,(%esp)
  801524:	e8 77 ef ff ff       	call   8004a0 <fd2num>
  801529:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80152f:	b8 00 00 00 00       	mov    $0x0,%eax
  801534:	eb 38                	jmp    80156e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801541:	e8 d1 ec ff ff       	call   800217 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801554:	e8 be ec ff ff       	call   800217 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801560:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801567:	e8 ab ec ff ff       	call   800217 <sys_page_unmap>
  80156c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80156e:	83 c4 30             	add    $0x30,%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	89 04 24             	mov    %eax,(%esp)
  801588:	e8 89 ef ff ff       	call   800516 <fd_lookup>
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	85 d2                	test   %edx,%edx
  801591:	78 15                	js     8015a8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801596:	89 04 24             	mov    %eax,(%esp)
  801599:	e8 12 ef ff ff       	call   8004b0 <fd2data>
	return _pipeisclosed(fd, p);
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a3:	e8 0b fd ff ff       	call   8012b3 <_pipeisclosed>
}
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    
  8015aa:	66 90                	xchg   %ax,%ax
  8015ac:	66 90                	xchg   %ax,%ax
  8015ae:	66 90                	xchg   %ax,%ax

008015b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8015c0:	c7 44 24 04 13 27 80 	movl   $0x802713,0x4(%esp)
  8015c7:	00 
  8015c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 a4 08 00 00       	call   801e77 <strcpy>
	return 0;
}
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	57                   	push   %edi
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8015eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015f1:	eb 31                	jmp    801624 <devcons_write+0x4a>
		m = n - tot;
  8015f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8015f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015f8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8015fb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801600:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801603:	89 74 24 08          	mov    %esi,0x8(%esp)
  801607:	03 45 0c             	add    0xc(%ebp),%eax
  80160a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160e:	89 3c 24             	mov    %edi,(%esp)
  801611:	e8 fe 09 00 00       	call   802014 <memmove>
		sys_cputs(buf, m);
  801616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80161a:	89 3c 24             	mov    %edi,(%esp)
  80161d:	e8 81 ea ff ff       	call   8000a3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801622:	01 f3                	add    %esi,%ebx
  801624:	89 d8                	mov    %ebx,%eax
  801626:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801629:	72 c8                	jb     8015f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80162b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801645:	75 07                	jne    80164e <devcons_read+0x18>
  801647:	eb 2a                	jmp    801673 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801649:	e8 03 eb ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80164e:	66 90                	xchg   %ax,%ax
  801650:	e8 6c ea ff ff       	call   8000c1 <sys_cgetc>
  801655:	85 c0                	test   %eax,%eax
  801657:	74 f0                	je     801649 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 16                	js     801673 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80165d:	83 f8 04             	cmp    $0x4,%eax
  801660:	74 0c                	je     80166e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801662:	8b 55 0c             	mov    0xc(%ebp),%edx
  801665:	88 02                	mov    %al,(%edx)
	return 1;
  801667:	b8 01 00 00 00       	mov    $0x1,%eax
  80166c:	eb 05                	jmp    801673 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80166e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801681:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801688:	00 
  801689:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 0f ea ff ff       	call   8000a3 <sys_cputs>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <getchar>:

int
getchar(void)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80169c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8016a3:	00 
  8016a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b2:	e8 f3 f0 ff ff       	call   8007aa <read>
	if (r < 0)
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 0f                	js     8016ca <getchar+0x34>
		return r;
	if (r < 1)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	7e 06                	jle    8016c5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8016bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8016c3:	eb 05                	jmp    8016ca <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8016c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 32 ee ff ff       	call   800516 <fd_lookup>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 11                	js     8016f9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016f1:	39 10                	cmp    %edx,(%eax)
  8016f3:	0f 94 c0             	sete   %al
  8016f6:	0f b6 c0             	movzbl %al,%eax
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <opencons>:

int
opencons(void)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	e8 bb ed ff ff       	call   8004c7 <fd_alloc>
		return r;
  80170c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 40                	js     801752 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801712:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801719:	00 
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801728:	e8 43 ea ff ff       	call   800170 <sys_page_alloc>
		return r;
  80172d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 1f                	js     801752 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801733:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	e8 50 ed ff ff       	call   8004a0 <fd2num>
  801750:	89 c2                	mov    %eax,%edx
}
  801752:	89 d0                	mov    %edx,%eax
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80175e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801761:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801767:	e8 c6 e9 ff ff       	call   800132 <sys_getenvid>
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801773:	8b 55 08             	mov    0x8(%ebp),%edx
  801776:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80177a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80177e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801782:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  801789:	e8 c1 00 00 00       	call   80184f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80178e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801792:	8b 45 10             	mov    0x10(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 51 00 00 00       	call   8017ee <vcprintf>
	cprintf("\n");
  80179d:	c7 04 24 0c 27 80 00 	movl   $0x80270c,(%esp)
  8017a4:	e8 a6 00 00 00       	call   80184f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017a9:	cc                   	int3   
  8017aa:	eb fd                	jmp    8017a9 <_panic+0x53>

008017ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 14             	sub    $0x14,%esp
  8017b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8017b6:	8b 13                	mov    (%ebx),%edx
  8017b8:	8d 42 01             	lea    0x1(%edx),%eax
  8017bb:	89 03                	mov    %eax,(%ebx)
  8017bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8017c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8017c9:	75 19                	jne    8017e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8017cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8017d2:	00 
  8017d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 c5 e8 ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  8017de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8017e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8017e8:	83 c4 14             	add    $0x14,%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8017f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017fe:	00 00 00 
	b.cnt = 0;
  801801:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801808:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80180b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	89 44 24 08          	mov    %eax,0x8(%esp)
  801819:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	c7 04 24 ac 17 80 00 	movl   $0x8017ac,(%esp)
  80182a:	e8 af 01 00 00       	call   8019de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80182f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 5c e8 ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  801847:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801855:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 87 ff ff ff       	call   8017ee <vcprintf>
	va_end(ap);

	return cnt;
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    
  801869:	66 90                	xchg   %ax,%ax
  80186b:	66 90                	xchg   %ax,%ax
  80186d:	66 90                	xchg   %ax,%ax
  80186f:	90                   	nop

00801870 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	57                   	push   %edi
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	83 ec 3c             	sub    $0x3c,%esp
  801879:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80187c:	89 d7                	mov    %edx,%edi
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801884:	8b 45 0c             	mov    0xc(%ebp),%eax
  801887:	89 c3                	mov    %eax,%ebx
  801889:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80188c:	8b 45 10             	mov    0x10(%ebp),%eax
  80188f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801892:	b9 00 00 00 00       	mov    $0x0,%ecx
  801897:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80189a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80189d:	39 d9                	cmp    %ebx,%ecx
  80189f:	72 05                	jb     8018a6 <printnum+0x36>
  8018a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8018a4:	77 69                	ja     80190f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8018a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018ad:	83 ee 01             	sub    $0x1,%esi
  8018b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018c0:	89 c3                	mov    %eax,%ebx
  8018c2:	89 d6                	mov    %edx,%esi
  8018c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8018ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d5:	89 04 24             	mov    %eax,(%esp)
  8018d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018df:	e8 4c 0a 00 00       	call   802330 <__udivdi3>
  8018e4:	89 d9                	mov    %ebx,%ecx
  8018e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018f5:	89 fa                	mov    %edi,%edx
  8018f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fa:	e8 71 ff ff ff       	call   801870 <printnum>
  8018ff:	eb 1b                	jmp    80191c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801901:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801905:	8b 45 18             	mov    0x18(%ebp),%eax
  801908:	89 04 24             	mov    %eax,(%esp)
  80190b:	ff d3                	call   *%ebx
  80190d:	eb 03                	jmp    801912 <printnum+0xa2>
  80190f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801912:	83 ee 01             	sub    $0x1,%esi
  801915:	85 f6                	test   %esi,%esi
  801917:	7f e8                	jg     801901 <printnum+0x91>
  801919:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80191c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801920:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801924:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801927:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80192a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801932:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193f:	e8 1c 0b 00 00       	call   802460 <__umoddi3>
  801944:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801948:	0f be 80 43 27 80 00 	movsbl 0x802743(%eax),%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801955:	ff d0                	call   *%eax
}
  801957:	83 c4 3c             	add    $0x3c,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5f                   	pop    %edi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801962:	83 fa 01             	cmp    $0x1,%edx
  801965:	7e 0e                	jle    801975 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801967:	8b 10                	mov    (%eax),%edx
  801969:	8d 4a 08             	lea    0x8(%edx),%ecx
  80196c:	89 08                	mov    %ecx,(%eax)
  80196e:	8b 02                	mov    (%edx),%eax
  801970:	8b 52 04             	mov    0x4(%edx),%edx
  801973:	eb 22                	jmp    801997 <getuint+0x38>
	else if (lflag)
  801975:	85 d2                	test   %edx,%edx
  801977:	74 10                	je     801989 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801979:	8b 10                	mov    (%eax),%edx
  80197b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80197e:	89 08                	mov    %ecx,(%eax)
  801980:	8b 02                	mov    (%edx),%eax
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	eb 0e                	jmp    801997 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801989:	8b 10                	mov    (%eax),%edx
  80198b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80198e:	89 08                	mov    %ecx,(%eax)
  801990:	8b 02                	mov    (%edx),%eax
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80199f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019a3:	8b 10                	mov    (%eax),%edx
  8019a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8019a8:	73 0a                	jae    8019b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8019ad:	89 08                	mov    %ecx,(%eax)
  8019af:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b2:	88 02                	mov    %al,(%edx)
}
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8019bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	e8 02 00 00 00       	call   8019de <vprintfmt>
	va_end(ap);
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 3c             	sub    $0x3c,%esp
  8019e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ed:	eb 14                	jmp    801a03 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	0f 84 b3 03 00 00    	je     801daa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8019f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a01:	89 f3                	mov    %esi,%ebx
  801a03:	8d 73 01             	lea    0x1(%ebx),%esi
  801a06:	0f b6 03             	movzbl (%ebx),%eax
  801a09:	83 f8 25             	cmp    $0x25,%eax
  801a0c:	75 e1                	jne    8019ef <vprintfmt+0x11>
  801a0e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801a12:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801a19:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801a20:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801a27:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2c:	eb 1d                	jmp    801a4b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a2e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a30:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801a34:	eb 15                	jmp    801a4b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a36:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a38:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801a3c:	eb 0d                	jmp    801a4b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801a3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a41:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a44:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801a4e:	0f b6 0e             	movzbl (%esi),%ecx
  801a51:	0f b6 c1             	movzbl %cl,%eax
  801a54:	83 e9 23             	sub    $0x23,%ecx
  801a57:	80 f9 55             	cmp    $0x55,%cl
  801a5a:	0f 87 2a 03 00 00    	ja     801d8a <vprintfmt+0x3ac>
  801a60:	0f b6 c9             	movzbl %cl,%ecx
  801a63:	ff 24 8d 80 28 80 00 	jmp    *0x802880(,%ecx,4)
  801a6a:	89 de                	mov    %ebx,%esi
  801a6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a71:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801a74:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801a78:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801a7b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801a7e:	83 fb 09             	cmp    $0x9,%ebx
  801a81:	77 36                	ja     801ab9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a83:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a86:	eb e9                	jmp    801a71 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a88:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8b:	8d 48 04             	lea    0x4(%eax),%ecx
  801a8e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801a91:	8b 00                	mov    (%eax),%eax
  801a93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a96:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a98:	eb 22                	jmp    801abc <vprintfmt+0xde>
  801a9a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801a9d:	85 c9                	test   %ecx,%ecx
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa4:	0f 49 c1             	cmovns %ecx,%eax
  801aa7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aaa:	89 de                	mov    %ebx,%esi
  801aac:	eb 9d                	jmp    801a4b <vprintfmt+0x6d>
  801aae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ab0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801ab7:	eb 92                	jmp    801a4b <vprintfmt+0x6d>
  801ab9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801abc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ac0:	79 89                	jns    801a4b <vprintfmt+0x6d>
  801ac2:	e9 77 ff ff ff       	jmp    801a3e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801ac7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aca:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801acc:	e9 7a ff ff ff       	jmp    801a4b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801ad1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad4:	8d 50 04             	lea    0x4(%eax),%edx
  801ad7:	89 55 14             	mov    %edx,0x14(%ebp)
  801ada:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ade:	8b 00                	mov    (%eax),%eax
  801ae0:	89 04 24             	mov    %eax,(%esp)
  801ae3:	ff 55 08             	call   *0x8(%ebp)
			break;
  801ae6:	e9 18 ff ff ff       	jmp    801a03 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  801aee:	8d 50 04             	lea    0x4(%eax),%edx
  801af1:	89 55 14             	mov    %edx,0x14(%ebp)
  801af4:	8b 00                	mov    (%eax),%eax
  801af6:	99                   	cltd   
  801af7:	31 d0                	xor    %edx,%eax
  801af9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801afb:	83 f8 0f             	cmp    $0xf,%eax
  801afe:	7f 0b                	jg     801b0b <vprintfmt+0x12d>
  801b00:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  801b07:	85 d2                	test   %edx,%edx
  801b09:	75 20                	jne    801b2b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  801b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0f:	c7 44 24 08 5b 27 80 	movl   $0x80275b,0x8(%esp)
  801b16:	00 
  801b17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 90 fe ff ff       	call   8019b6 <printfmt>
  801b26:	e9 d8 fe ff ff       	jmp    801a03 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801b2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b2f:	c7 44 24 08 a1 26 80 	movl   $0x8026a1,0x8(%esp)
  801b36:	00 
  801b37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	89 04 24             	mov    %eax,(%esp)
  801b41:	e8 70 fe ff ff       	call   8019b6 <printfmt>
  801b46:	e9 b8 fe ff ff       	jmp    801a03 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b4b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801b4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b51:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b54:	8b 45 14             	mov    0x14(%ebp),%eax
  801b57:	8d 50 04             	lea    0x4(%eax),%edx
  801b5a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b5d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801b5f:	85 f6                	test   %esi,%esi
  801b61:	b8 54 27 80 00       	mov    $0x802754,%eax
  801b66:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801b69:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801b6d:	0f 84 97 00 00 00    	je     801c0a <vprintfmt+0x22c>
  801b73:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801b77:	0f 8e 9b 00 00 00    	jle    801c18 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b81:	89 34 24             	mov    %esi,(%esp)
  801b84:	e8 cf 02 00 00       	call   801e58 <strnlen>
  801b89:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801b8c:	29 c2                	sub    %eax,%edx
  801b8e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  801b91:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801b95:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801b98:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801b9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801ba1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ba3:	eb 0f                	jmp    801bb4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801ba5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ba9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bac:	89 04 24             	mov    %eax,(%esp)
  801baf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bb1:	83 eb 01             	sub    $0x1,%ebx
  801bb4:	85 db                	test   %ebx,%ebx
  801bb6:	7f ed                	jg     801ba5 <vprintfmt+0x1c7>
  801bb8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801bbb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801bbe:	85 d2                	test   %edx,%edx
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	0f 49 c2             	cmovns %edx,%eax
  801bc8:	29 c2                	sub    %eax,%edx
  801bca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801bcd:	89 d7                	mov    %edx,%edi
  801bcf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801bd2:	eb 50                	jmp    801c24 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801bd4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bd8:	74 1e                	je     801bf8 <vprintfmt+0x21a>
  801bda:	0f be d2             	movsbl %dl,%edx
  801bdd:	83 ea 20             	sub    $0x20,%edx
  801be0:	83 fa 5e             	cmp    $0x5e,%edx
  801be3:	76 13                	jbe    801bf8 <vprintfmt+0x21a>
					putch('?', putdat);
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801bf3:	ff 55 08             	call   *0x8(%ebp)
  801bf6:	eb 0d                	jmp    801c05 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bff:	89 04 24             	mov    %eax,(%esp)
  801c02:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801c05:	83 ef 01             	sub    $0x1,%edi
  801c08:	eb 1a                	jmp    801c24 <vprintfmt+0x246>
  801c0a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c0d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c10:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c16:	eb 0c                	jmp    801c24 <vprintfmt+0x246>
  801c18:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801c1b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801c1e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801c21:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801c24:	83 c6 01             	add    $0x1,%esi
  801c27:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801c2b:	0f be c2             	movsbl %dl,%eax
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	74 27                	je     801c59 <vprintfmt+0x27b>
  801c32:	85 db                	test   %ebx,%ebx
  801c34:	78 9e                	js     801bd4 <vprintfmt+0x1f6>
  801c36:	83 eb 01             	sub    $0x1,%ebx
  801c39:	79 99                	jns    801bd4 <vprintfmt+0x1f6>
  801c3b:	89 f8                	mov    %edi,%eax
  801c3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c40:	8b 75 08             	mov    0x8(%ebp),%esi
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	eb 1a                	jmp    801c61 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c4b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801c52:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c54:	83 eb 01             	sub    $0x1,%ebx
  801c57:	eb 08                	jmp    801c61 <vprintfmt+0x283>
  801c59:	89 fb                	mov    %edi,%ebx
  801c5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c61:	85 db                	test   %ebx,%ebx
  801c63:	7f e2                	jg     801c47 <vprintfmt+0x269>
  801c65:	89 75 08             	mov    %esi,0x8(%ebp)
  801c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c6b:	e9 93 fd ff ff       	jmp    801a03 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801c70:	83 fa 01             	cmp    $0x1,%edx
  801c73:	7e 16                	jle    801c8b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  801c75:	8b 45 14             	mov    0x14(%ebp),%eax
  801c78:	8d 50 08             	lea    0x8(%eax),%edx
  801c7b:	89 55 14             	mov    %edx,0x14(%ebp)
  801c7e:	8b 50 04             	mov    0x4(%eax),%edx
  801c81:	8b 00                	mov    (%eax),%eax
  801c83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c89:	eb 32                	jmp    801cbd <vprintfmt+0x2df>
	else if (lflag)
  801c8b:	85 d2                	test   %edx,%edx
  801c8d:	74 18                	je     801ca7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  801c8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c92:	8d 50 04             	lea    0x4(%eax),%edx
  801c95:	89 55 14             	mov    %edx,0x14(%ebp)
  801c98:	8b 30                	mov    (%eax),%esi
  801c9a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801c9d:	89 f0                	mov    %esi,%eax
  801c9f:	c1 f8 1f             	sar    $0x1f,%eax
  801ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ca5:	eb 16                	jmp    801cbd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  801ca7:	8b 45 14             	mov    0x14(%ebp),%eax
  801caa:	8d 50 04             	lea    0x4(%eax),%edx
  801cad:	89 55 14             	mov    %edx,0x14(%ebp)
  801cb0:	8b 30                	mov    (%eax),%esi
  801cb2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801cb5:	89 f0                	mov    %esi,%eax
  801cb7:	c1 f8 1f             	sar    $0x1f,%eax
  801cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801cbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801cc3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801cc8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801ccc:	0f 89 80 00 00 00    	jns    801d52 <vprintfmt+0x374>
				putch('-', putdat);
  801cd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cd6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801cdd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801ce0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ce3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ce6:	f7 d8                	neg    %eax
  801ce8:	83 d2 00             	adc    $0x0,%edx
  801ceb:	f7 da                	neg    %edx
			}
			base = 10;
  801ced:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801cf2:	eb 5e                	jmp    801d52 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801cf4:	8d 45 14             	lea    0x14(%ebp),%eax
  801cf7:	e8 63 fc ff ff       	call   80195f <getuint>
			base = 10;
  801cfc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801d01:	eb 4f                	jmp    801d52 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801d03:	8d 45 14             	lea    0x14(%ebp),%eax
  801d06:	e8 54 fc ff ff       	call   80195f <getuint>
			base = 8;
  801d0b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801d10:	eb 40                	jmp    801d52 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801d12:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d16:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801d1d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801d20:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d24:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801d2b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801d2e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d31:	8d 50 04             	lea    0x4(%eax),%edx
  801d34:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801d37:	8b 00                	mov    (%eax),%eax
  801d39:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d3e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d43:	eb 0d                	jmp    801d52 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d45:	8d 45 14             	lea    0x14(%ebp),%eax
  801d48:	e8 12 fc ff ff       	call   80195f <getuint>
			base = 16;
  801d4d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d52:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801d56:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d5a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801d5d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d61:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d65:	89 04 24             	mov    %eax,(%esp)
  801d68:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d6c:	89 fa                	mov    %edi,%edx
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	e8 fa fa ff ff       	call   801870 <printnum>
			break;
  801d76:	e9 88 fc ff ff       	jmp    801a03 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d7b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d7f:	89 04 24             	mov    %eax,(%esp)
  801d82:	ff 55 08             	call   *0x8(%ebp)
			break;
  801d85:	e9 79 fc ff ff       	jmp    801a03 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801d8a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d8e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801d95:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801d98:	89 f3                	mov    %esi,%ebx
  801d9a:	eb 03                	jmp    801d9f <vprintfmt+0x3c1>
  801d9c:	83 eb 01             	sub    $0x1,%ebx
  801d9f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801da3:	75 f7                	jne    801d9c <vprintfmt+0x3be>
  801da5:	e9 59 fc ff ff       	jmp    801a03 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801daa:	83 c4 3c             	add    $0x3c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 28             	sub    $0x28,%esp
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801dbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801dc1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801dc5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	74 30                	je     801e03 <vsnprintf+0x51>
  801dd3:	85 d2                	test   %edx,%edx
  801dd5:	7e 2c                	jle    801e03 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801dd7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dde:	8b 45 10             	mov    0x10(%ebp),%eax
  801de1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	c7 04 24 99 19 80 00 	movl   $0x801999,(%esp)
  801df3:	e8 e6 fb ff ff       	call   8019de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801df8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dfb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	eb 05                	jmp    801e08 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801e03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801e10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801e13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e17:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e25:	8b 45 08             	mov    0x8(%ebp),%eax
  801e28:	89 04 24             	mov    %eax,(%esp)
  801e2b:	e8 82 ff ff ff       	call   801db2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    
  801e32:	66 90                	xchg   %ax,%ax
  801e34:	66 90                	xchg   %ax,%ax
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4b:	eb 03                	jmp    801e50 <strlen+0x10>
		n++;
  801e4d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801e50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801e54:	75 f7                	jne    801e4d <strlen+0xd>
		n++;
	return n;
}
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
  801e66:	eb 03                	jmp    801e6b <strnlen+0x13>
		n++;
  801e68:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801e6b:	39 d0                	cmp    %edx,%eax
  801e6d:	74 06                	je     801e75 <strnlen+0x1d>
  801e6f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801e73:	75 f3                	jne    801e68 <strnlen+0x10>
		n++;
	return n;
}
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	53                   	push   %ebx
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801e81:	89 c2                	mov    %eax,%edx
  801e83:	83 c2 01             	add    $0x1,%edx
  801e86:	83 c1 01             	add    $0x1,%ecx
  801e89:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801e8d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801e90:	84 db                	test   %bl,%bl
  801e92:	75 ef                	jne    801e83 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801e94:	5b                   	pop    %ebx
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 08             	sub    $0x8,%esp
  801e9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ea1:	89 1c 24             	mov    %ebx,(%esp)
  801ea4:	e8 97 ff ff ff       	call   801e40 <strlen>
	strcpy(dst + len, src);
  801ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eac:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eb0:	01 d8                	add    %ebx,%eax
  801eb2:	89 04 24             	mov    %eax,(%esp)
  801eb5:	e8 bd ff ff ff       	call   801e77 <strcpy>
	return dst;
}
  801eba:	89 d8                	mov    %ebx,%eax
  801ebc:	83 c4 08             	add    $0x8,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ecd:	89 f3                	mov    %esi,%ebx
  801ecf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ed2:	89 f2                	mov    %esi,%edx
  801ed4:	eb 0f                	jmp    801ee5 <strncpy+0x23>
		*dst++ = *src;
  801ed6:	83 c2 01             	add    $0x1,%edx
  801ed9:	0f b6 01             	movzbl (%ecx),%eax
  801edc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801edf:	80 39 01             	cmpb   $0x1,(%ecx)
  801ee2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ee5:	39 da                	cmp    %ebx,%edx
  801ee7:	75 ed                	jne    801ed6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ee9:	89 f0                	mov    %esi,%eax
  801eeb:	5b                   	pop    %ebx
  801eec:	5e                   	pop    %esi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801efd:	89 f0                	mov    %esi,%eax
  801eff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801f03:	85 c9                	test   %ecx,%ecx
  801f05:	75 0b                	jne    801f12 <strlcpy+0x23>
  801f07:	eb 1d                	jmp    801f26 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801f09:	83 c0 01             	add    $0x1,%eax
  801f0c:	83 c2 01             	add    $0x1,%edx
  801f0f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801f12:	39 d8                	cmp    %ebx,%eax
  801f14:	74 0b                	je     801f21 <strlcpy+0x32>
  801f16:	0f b6 0a             	movzbl (%edx),%ecx
  801f19:	84 c9                	test   %cl,%cl
  801f1b:	75 ec                	jne    801f09 <strlcpy+0x1a>
  801f1d:	89 c2                	mov    %eax,%edx
  801f1f:	eb 02                	jmp    801f23 <strlcpy+0x34>
  801f21:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801f23:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801f26:	29 f0                	sub    %esi,%eax
}
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801f35:	eb 06                	jmp    801f3d <strcmp+0x11>
		p++, q++;
  801f37:	83 c1 01             	add    $0x1,%ecx
  801f3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801f3d:	0f b6 01             	movzbl (%ecx),%eax
  801f40:	84 c0                	test   %al,%al
  801f42:	74 04                	je     801f48 <strcmp+0x1c>
  801f44:	3a 02                	cmp    (%edx),%al
  801f46:	74 ef                	je     801f37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801f48:	0f b6 c0             	movzbl %al,%eax
  801f4b:	0f b6 12             	movzbl (%edx),%edx
  801f4e:	29 d0                	sub    %edx,%eax
}
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	53                   	push   %ebx
  801f56:	8b 45 08             	mov    0x8(%ebp),%eax
  801f59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5c:	89 c3                	mov    %eax,%ebx
  801f5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801f61:	eb 06                	jmp    801f69 <strncmp+0x17>
		n--, p++, q++;
  801f63:	83 c0 01             	add    $0x1,%eax
  801f66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801f69:	39 d8                	cmp    %ebx,%eax
  801f6b:	74 15                	je     801f82 <strncmp+0x30>
  801f6d:	0f b6 08             	movzbl (%eax),%ecx
  801f70:	84 c9                	test   %cl,%cl
  801f72:	74 04                	je     801f78 <strncmp+0x26>
  801f74:	3a 0a                	cmp    (%edx),%cl
  801f76:	74 eb                	je     801f63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801f78:	0f b6 00             	movzbl (%eax),%eax
  801f7b:	0f b6 12             	movzbl (%edx),%edx
  801f7e:	29 d0                	sub    %edx,%eax
  801f80:	eb 05                	jmp    801f87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801f87:	5b                   	pop    %ebx
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801f94:	eb 07                	jmp    801f9d <strchr+0x13>
		if (*s == c)
  801f96:	38 ca                	cmp    %cl,%dl
  801f98:	74 0f                	je     801fa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801f9a:	83 c0 01             	add    $0x1,%eax
  801f9d:	0f b6 10             	movzbl (%eax),%edx
  801fa0:	84 d2                	test   %dl,%dl
  801fa2:	75 f2                	jne    801f96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801fb5:	eb 07                	jmp    801fbe <strfind+0x13>
		if (*s == c)
  801fb7:	38 ca                	cmp    %cl,%dl
  801fb9:	74 0a                	je     801fc5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801fbb:	83 c0 01             	add    $0x1,%eax
  801fbe:	0f b6 10             	movzbl (%eax),%edx
  801fc1:	84 d2                	test   %dl,%dl
  801fc3:	75 f2                	jne    801fb7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    

00801fc7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801fd3:	85 c9                	test   %ecx,%ecx
  801fd5:	74 36                	je     80200d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801fd7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801fdd:	75 28                	jne    802007 <memset+0x40>
  801fdf:	f6 c1 03             	test   $0x3,%cl
  801fe2:	75 23                	jne    802007 <memset+0x40>
		c &= 0xFF;
  801fe4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801fe8:	89 d3                	mov    %edx,%ebx
  801fea:	c1 e3 08             	shl    $0x8,%ebx
  801fed:	89 d6                	mov    %edx,%esi
  801fef:	c1 e6 18             	shl    $0x18,%esi
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	c1 e0 10             	shl    $0x10,%eax
  801ff7:	09 f0                	or     %esi,%eax
  801ff9:	09 c2                	or     %eax,%edx
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801fff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802002:	fc                   	cld    
  802003:	f3 ab                	rep stos %eax,%es:(%edi)
  802005:	eb 06                	jmp    80200d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200a:	fc                   	cld    
  80200b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80200d:	89 f8                	mov    %edi,%eax
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	57                   	push   %edi
  802018:	56                   	push   %esi
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802022:	39 c6                	cmp    %eax,%esi
  802024:	73 35                	jae    80205b <memmove+0x47>
  802026:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802029:	39 d0                	cmp    %edx,%eax
  80202b:	73 2e                	jae    80205b <memmove+0x47>
		s += n;
		d += n;
  80202d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802030:	89 d6                	mov    %edx,%esi
  802032:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802034:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80203a:	75 13                	jne    80204f <memmove+0x3b>
  80203c:	f6 c1 03             	test   $0x3,%cl
  80203f:	75 0e                	jne    80204f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802041:	83 ef 04             	sub    $0x4,%edi
  802044:	8d 72 fc             	lea    -0x4(%edx),%esi
  802047:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80204a:	fd                   	std    
  80204b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80204d:	eb 09                	jmp    802058 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80204f:	83 ef 01             	sub    $0x1,%edi
  802052:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802055:	fd                   	std    
  802056:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802058:	fc                   	cld    
  802059:	eb 1d                	jmp    802078 <memmove+0x64>
  80205b:	89 f2                	mov    %esi,%edx
  80205d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80205f:	f6 c2 03             	test   $0x3,%dl
  802062:	75 0f                	jne    802073 <memmove+0x5f>
  802064:	f6 c1 03             	test   $0x3,%cl
  802067:	75 0a                	jne    802073 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802069:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80206c:	89 c7                	mov    %eax,%edi
  80206e:	fc                   	cld    
  80206f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802071:	eb 05                	jmp    802078 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802073:	89 c7                	mov    %eax,%edi
  802075:	fc                   	cld    
  802076:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802078:	5e                   	pop    %esi
  802079:	5f                   	pop    %edi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    

0080207c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802082:	8b 45 10             	mov    0x10(%ebp),%eax
  802085:	89 44 24 08          	mov    %eax,0x8(%esp)
  802089:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802090:	8b 45 08             	mov    0x8(%ebp),%eax
  802093:	89 04 24             	mov    %eax,(%esp)
  802096:	e8 79 ff ff ff       	call   802014 <memmove>
}
  80209b:	c9                   	leave  
  80209c:	c3                   	ret    

0080209d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8020a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a8:	89 d6                	mov    %edx,%esi
  8020aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020ad:	eb 1a                	jmp    8020c9 <memcmp+0x2c>
		if (*s1 != *s2)
  8020af:	0f b6 02             	movzbl (%edx),%eax
  8020b2:	0f b6 19             	movzbl (%ecx),%ebx
  8020b5:	38 d8                	cmp    %bl,%al
  8020b7:	74 0a                	je     8020c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8020b9:	0f b6 c0             	movzbl %al,%eax
  8020bc:	0f b6 db             	movzbl %bl,%ebx
  8020bf:	29 d8                	sub    %ebx,%eax
  8020c1:	eb 0f                	jmp    8020d2 <memcmp+0x35>
		s1++, s2++;
  8020c3:	83 c2 01             	add    $0x1,%edx
  8020c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020c9:	39 f2                	cmp    %esi,%edx
  8020cb:	75 e2                	jne    8020af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d2:	5b                   	pop    %ebx
  8020d3:	5e                   	pop    %esi
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    

008020d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8020df:	89 c2                	mov    %eax,%edx
  8020e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8020e4:	eb 07                	jmp    8020ed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8020e6:	38 08                	cmp    %cl,(%eax)
  8020e8:	74 07                	je     8020f1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8020ea:	83 c0 01             	add    $0x1,%eax
  8020ed:	39 d0                	cmp    %edx,%eax
  8020ef:	72 f5                	jb     8020e6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	57                   	push   %edi
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8020fc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8020ff:	eb 03                	jmp    802104 <strtol+0x11>
		s++;
  802101:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802104:	0f b6 0a             	movzbl (%edx),%ecx
  802107:	80 f9 09             	cmp    $0x9,%cl
  80210a:	74 f5                	je     802101 <strtol+0xe>
  80210c:	80 f9 20             	cmp    $0x20,%cl
  80210f:	74 f0                	je     802101 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802111:	80 f9 2b             	cmp    $0x2b,%cl
  802114:	75 0a                	jne    802120 <strtol+0x2d>
		s++;
  802116:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802119:	bf 00 00 00 00       	mov    $0x0,%edi
  80211e:	eb 11                	jmp    802131 <strtol+0x3e>
  802120:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802125:	80 f9 2d             	cmp    $0x2d,%cl
  802128:	75 07                	jne    802131 <strtol+0x3e>
		s++, neg = 1;
  80212a:	8d 52 01             	lea    0x1(%edx),%edx
  80212d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802131:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802136:	75 15                	jne    80214d <strtol+0x5a>
  802138:	80 3a 30             	cmpb   $0x30,(%edx)
  80213b:	75 10                	jne    80214d <strtol+0x5a>
  80213d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802141:	75 0a                	jne    80214d <strtol+0x5a>
		s += 2, base = 16;
  802143:	83 c2 02             	add    $0x2,%edx
  802146:	b8 10 00 00 00       	mov    $0x10,%eax
  80214b:	eb 10                	jmp    80215d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80214d:	85 c0                	test   %eax,%eax
  80214f:	75 0c                	jne    80215d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802151:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802153:	80 3a 30             	cmpb   $0x30,(%edx)
  802156:	75 05                	jne    80215d <strtol+0x6a>
		s++, base = 8;
  802158:	83 c2 01             	add    $0x1,%edx
  80215b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80215d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802162:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802165:	0f b6 0a             	movzbl (%edx),%ecx
  802168:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	3c 09                	cmp    $0x9,%al
  80216f:	77 08                	ja     802179 <strtol+0x86>
			dig = *s - '0';
  802171:	0f be c9             	movsbl %cl,%ecx
  802174:	83 e9 30             	sub    $0x30,%ecx
  802177:	eb 20                	jmp    802199 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  802179:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80217c:	89 f0                	mov    %esi,%eax
  80217e:	3c 19                	cmp    $0x19,%al
  802180:	77 08                	ja     80218a <strtol+0x97>
			dig = *s - 'a' + 10;
  802182:	0f be c9             	movsbl %cl,%ecx
  802185:	83 e9 57             	sub    $0x57,%ecx
  802188:	eb 0f                	jmp    802199 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80218a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80218d:	89 f0                	mov    %esi,%eax
  80218f:	3c 19                	cmp    $0x19,%al
  802191:	77 16                	ja     8021a9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  802193:	0f be c9             	movsbl %cl,%ecx
  802196:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802199:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80219c:	7d 0f                	jge    8021ad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80219e:	83 c2 01             	add    $0x1,%edx
  8021a1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8021a5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8021a7:	eb bc                	jmp    802165 <strtol+0x72>
  8021a9:	89 d8                	mov    %ebx,%eax
  8021ab:	eb 02                	jmp    8021af <strtol+0xbc>
  8021ad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8021af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021b3:	74 05                	je     8021ba <strtol+0xc7>
		*endptr = (char *) s;
  8021b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8021ba:	f7 d8                	neg    %eax
  8021bc:	85 ff                	test   %edi,%edi
  8021be:	0f 44 c3             	cmove  %ebx,%eax
}
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5f                   	pop    %edi
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	83 ec 10             	sub    $0x10,%esp
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021e8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8021eb:	89 04 24             	mov    %eax,(%esp)
  8021ee:	e8 93 e1 ff ff       	call   800386 <sys_ipc_recv>

	if(ret < 0) {
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	79 16                	jns    80220d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	74 06                	je     802201 <ipc_recv+0x31>
  8021fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802201:	85 db                	test   %ebx,%ebx
  802203:	74 3e                	je     802243 <ipc_recv+0x73>
  802205:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80220b:	eb 36                	jmp    802243 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80220d:	e8 20 df ff ff       	call   800132 <sys_getenvid>
  802212:	25 ff 03 00 00       	and    $0x3ff,%eax
  802217:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80221a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80221f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802224:	85 f6                	test   %esi,%esi
  802226:	74 05                	je     80222d <ipc_recv+0x5d>
  802228:	8b 40 74             	mov    0x74(%eax),%eax
  80222b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80222d:	85 db                	test   %ebx,%ebx
  80222f:	74 0a                	je     80223b <ipc_recv+0x6b>
  802231:	a1 08 40 80 00       	mov    0x804008,%eax
  802236:	8b 40 78             	mov    0x78(%eax),%eax
  802239:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80223b:	a1 08 40 80 00       	mov    0x804008,%eax
  802240:	8b 40 70             	mov    0x70(%eax),%eax
}
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	5b                   	pop    %ebx
  802247:	5e                   	pop    %esi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	83 ec 1c             	sub    $0x1c,%esp
  802253:	8b 7d 08             	mov    0x8(%ebp),%edi
  802256:	8b 75 0c             	mov    0xc(%ebp),%esi
  802259:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80225c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80225e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802263:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802266:	8b 45 14             	mov    0x14(%ebp),%eax
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802271:	89 74 24 04          	mov    %esi,0x4(%esp)
  802275:	89 3c 24             	mov    %edi,(%esp)
  802278:	e8 e6 e0 ff ff       	call   800363 <sys_ipc_try_send>

		if(ret >= 0) break;
  80227d:	85 c0                	test   %eax,%eax
  80227f:	79 2c                	jns    8022ad <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802281:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802284:	74 20                	je     8022a6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802286:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228a:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  802291:	00 
  802292:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802299:	00 
  80229a:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  8022a1:	e8 b0 f4 ff ff       	call   801756 <_panic>
		}
		sys_yield();
  8022a6:	e8 a6 de ff ff       	call   800151 <sys_yield>
	}
  8022ab:	eb b9                	jmp    802266 <ipc_send+0x1c>
}
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    

008022b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c9:	8b 52 50             	mov    0x50(%edx),%edx
  8022cc:	39 ca                	cmp    %ecx,%edx
  8022ce:	75 0d                	jne    8022dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8022d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022d8:	8b 40 40             	mov    0x40(%eax),%eax
  8022db:	eb 0e                	jmp    8022eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022dd:	83 c0 01             	add    $0x1,%eax
  8022e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e5:	75 d9                	jne    8022c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e7:	66 b8 00 00          	mov    $0x0,%ax
}
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    

008022ed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f3:	89 d0                	mov    %edx,%eax
  8022f5:	c1 e8 16             	shr    $0x16,%eax
  8022f8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802304:	f6 c1 01             	test   $0x1,%cl
  802307:	74 1d                	je     802326 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802309:	c1 ea 0c             	shr    $0xc,%edx
  80230c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802313:	f6 c2 01             	test   $0x1,%dl
  802316:	74 0e                	je     802326 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802318:	c1 ea 0c             	shr    $0xc,%edx
  80231b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802322:	ef 
  802323:	0f b7 c0             	movzwl %ax,%eax
}
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80233a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80233e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802342:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802346:	85 c0                	test   %eax,%eax
  802348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234c:	89 ea                	mov    %ebp,%edx
  80234e:	89 0c 24             	mov    %ecx,(%esp)
  802351:	75 2d                	jne    802380 <__udivdi3+0x50>
  802353:	39 e9                	cmp    %ebp,%ecx
  802355:	77 61                	ja     8023b8 <__udivdi3+0x88>
  802357:	85 c9                	test   %ecx,%ecx
  802359:	89 ce                	mov    %ecx,%esi
  80235b:	75 0b                	jne    802368 <__udivdi3+0x38>
  80235d:	b8 01 00 00 00       	mov    $0x1,%eax
  802362:	31 d2                	xor    %edx,%edx
  802364:	f7 f1                	div    %ecx
  802366:	89 c6                	mov    %eax,%esi
  802368:	31 d2                	xor    %edx,%edx
  80236a:	89 e8                	mov    %ebp,%eax
  80236c:	f7 f6                	div    %esi
  80236e:	89 c5                	mov    %eax,%ebp
  802370:	89 f8                	mov    %edi,%eax
  802372:	f7 f6                	div    %esi
  802374:	89 ea                	mov    %ebp,%edx
  802376:	83 c4 0c             	add    $0xc,%esp
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	39 e8                	cmp    %ebp,%eax
  802382:	77 24                	ja     8023a8 <__udivdi3+0x78>
  802384:	0f bd e8             	bsr    %eax,%ebp
  802387:	83 f5 1f             	xor    $0x1f,%ebp
  80238a:	75 3c                	jne    8023c8 <__udivdi3+0x98>
  80238c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802390:	39 34 24             	cmp    %esi,(%esp)
  802393:	0f 86 9f 00 00 00    	jbe    802438 <__udivdi3+0x108>
  802399:	39 d0                	cmp    %edx,%eax
  80239b:	0f 82 97 00 00 00    	jb     802438 <__udivdi3+0x108>
  8023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	31 c0                	xor    %eax,%eax
  8023ac:	83 c4 0c             	add    $0xc,%esp
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	89 f8                	mov    %edi,%eax
  8023ba:	f7 f1                	div    %ecx
  8023bc:	31 d2                	xor    %edx,%edx
  8023be:	83 c4 0c             	add    $0xc,%esp
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	8b 3c 24             	mov    (%esp),%edi
  8023cd:	d3 e0                	shl    %cl,%eax
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023d6:	29 e8                	sub    %ebp,%eax
  8023d8:	89 c1                	mov    %eax,%ecx
  8023da:	d3 ef                	shr    %cl,%edi
  8023dc:	89 e9                	mov    %ebp,%ecx
  8023de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023e2:	8b 3c 24             	mov    (%esp),%edi
  8023e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	d3 e7                	shl    %cl,%edi
  8023ed:	89 c1                	mov    %eax,%ecx
  8023ef:	89 3c 24             	mov    %edi,(%esp)
  8023f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023f6:	d3 ee                	shr    %cl,%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	d3 e2                	shl    %cl,%edx
  8023fc:	89 c1                	mov    %eax,%ecx
  8023fe:	d3 ef                	shr    %cl,%edi
  802400:	09 d7                	or     %edx,%edi
  802402:	89 f2                	mov    %esi,%edx
  802404:	89 f8                	mov    %edi,%eax
  802406:	f7 74 24 08          	divl   0x8(%esp)
  80240a:	89 d6                	mov    %edx,%esi
  80240c:	89 c7                	mov    %eax,%edi
  80240e:	f7 24 24             	mull   (%esp)
  802411:	39 d6                	cmp    %edx,%esi
  802413:	89 14 24             	mov    %edx,(%esp)
  802416:	72 30                	jb     802448 <__udivdi3+0x118>
  802418:	8b 54 24 04          	mov    0x4(%esp),%edx
  80241c:	89 e9                	mov    %ebp,%ecx
  80241e:	d3 e2                	shl    %cl,%edx
  802420:	39 c2                	cmp    %eax,%edx
  802422:	73 05                	jae    802429 <__udivdi3+0xf9>
  802424:	3b 34 24             	cmp    (%esp),%esi
  802427:	74 1f                	je     802448 <__udivdi3+0x118>
  802429:	89 f8                	mov    %edi,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	e9 7a ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 d2                	xor    %edx,%edx
  80243a:	b8 01 00 00 00       	mov    $0x1,%eax
  80243f:	e9 68 ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	8d 47 ff             	lea    -0x1(%edi),%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	83 c4 0c             	add    $0xc,%esp
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 14             	sub    $0x14,%esp
  802466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80246a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80246e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802472:	89 c7                	mov    %eax,%edi
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	8b 44 24 30          	mov    0x30(%esp),%eax
  80247c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802480:	89 34 24             	mov    %esi,(%esp)
  802483:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802487:	85 c0                	test   %eax,%eax
  802489:	89 c2                	mov    %eax,%edx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	75 17                	jne    8024a8 <__umoddi3+0x48>
  802491:	39 fe                	cmp    %edi,%esi
  802493:	76 4b                	jbe    8024e0 <__umoddi3+0x80>
  802495:	89 c8                	mov    %ecx,%eax
  802497:	89 fa                	mov    %edi,%edx
  802499:	f7 f6                	div    %esi
  80249b:	89 d0                	mov    %edx,%eax
  80249d:	31 d2                	xor    %edx,%edx
  80249f:	83 c4 14             	add    $0x14,%esp
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	39 f8                	cmp    %edi,%eax
  8024aa:	77 54                	ja     802500 <__umoddi3+0xa0>
  8024ac:	0f bd e8             	bsr    %eax,%ebp
  8024af:	83 f5 1f             	xor    $0x1f,%ebp
  8024b2:	75 5c                	jne    802510 <__umoddi3+0xb0>
  8024b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024b8:	39 3c 24             	cmp    %edi,(%esp)
  8024bb:	0f 87 e7 00 00 00    	ja     8025a8 <__umoddi3+0x148>
  8024c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024c5:	29 f1                	sub    %esi,%ecx
  8024c7:	19 c7                	sbb    %eax,%edi
  8024c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
  8024e0:	85 f6                	test   %esi,%esi
  8024e2:	89 f5                	mov    %esi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f6                	div    %esi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024f5:	31 d2                	xor    %edx,%edx
  8024f7:	f7 f5                	div    %ebp
  8024f9:	89 c8                	mov    %ecx,%eax
  8024fb:	f7 f5                	div    %ebp
  8024fd:	eb 9c                	jmp    80249b <__umoddi3+0x3b>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 fa                	mov    %edi,%edx
  802504:	83 c4 14             	add    $0x14,%esp
  802507:	5e                   	pop    %esi
  802508:	5f                   	pop    %edi
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    
  80250b:	90                   	nop
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 04 24             	mov    (%esp),%eax
  802513:	be 20 00 00 00       	mov    $0x20,%esi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ee                	sub    %ebp,%esi
  80251c:	d3 e2                	shl    %cl,%edx
  80251e:	89 f1                	mov    %esi,%ecx
  802520:	d3 e8                	shr    %cl,%eax
  802522:	89 e9                	mov    %ebp,%ecx
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 04 24             	mov    (%esp),%eax
  80252b:	09 54 24 04          	or     %edx,0x4(%esp)
  80252f:	89 fa                	mov    %edi,%edx
  802531:	d3 e0                	shl    %cl,%eax
  802533:	89 f1                	mov    %esi,%ecx
  802535:	89 44 24 08          	mov    %eax,0x8(%esp)
  802539:	8b 44 24 10          	mov    0x10(%esp),%eax
  80253d:	d3 ea                	shr    %cl,%edx
  80253f:	89 e9                	mov    %ebp,%ecx
  802541:	d3 e7                	shl    %cl,%edi
  802543:	89 f1                	mov    %esi,%ecx
  802545:	d3 e8                	shr    %cl,%eax
  802547:	89 e9                	mov    %ebp,%ecx
  802549:	09 f8                	or     %edi,%eax
  80254b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80254f:	f7 74 24 04          	divl   0x4(%esp)
  802553:	d3 e7                	shl    %cl,%edi
  802555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802559:	89 d7                	mov    %edx,%edi
  80255b:	f7 64 24 08          	mull   0x8(%esp)
  80255f:	39 d7                	cmp    %edx,%edi
  802561:	89 c1                	mov    %eax,%ecx
  802563:	89 14 24             	mov    %edx,(%esp)
  802566:	72 2c                	jb     802594 <__umoddi3+0x134>
  802568:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80256c:	72 22                	jb     802590 <__umoddi3+0x130>
  80256e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802572:	29 c8                	sub    %ecx,%eax
  802574:	19 d7                	sbb    %edx,%edi
  802576:	89 e9                	mov    %ebp,%ecx
  802578:	89 fa                	mov    %edi,%edx
  80257a:	d3 e8                	shr    %cl,%eax
  80257c:	89 f1                	mov    %esi,%ecx
  80257e:	d3 e2                	shl    %cl,%edx
  802580:	89 e9                	mov    %ebp,%ecx
  802582:	d3 ef                	shr    %cl,%edi
  802584:	09 d0                	or     %edx,%eax
  802586:	89 fa                	mov    %edi,%edx
  802588:	83 c4 14             	add    $0x14,%esp
  80258b:	5e                   	pop    %esi
  80258c:	5f                   	pop    %edi
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    
  80258f:	90                   	nop
  802590:	39 d7                	cmp    %edx,%edi
  802592:	75 da                	jne    80256e <__umoddi3+0x10e>
  802594:	8b 14 24             	mov    (%esp),%edx
  802597:	89 c1                	mov    %eax,%ecx
  802599:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80259d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025a1:	eb cb                	jmp    80256e <__umoddi3+0x10e>
  8025a3:	90                   	nop
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025ac:	0f 82 0f ff ff ff    	jb     8024c1 <__umoddi3+0x61>
  8025b2:	e9 1a ff ff ff       	jmp    8024d1 <__umoddi3+0x71>
