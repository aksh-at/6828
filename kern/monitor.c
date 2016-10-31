// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/mmu.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display backtrace of current executing function", mon_backtrace },
	{ "showmappings", "Display current page mappings for address or address range.", mon_showmappings },
	{ "changeperms", "Set or clear permission flags for page ranges. Usage: 0xaddr1 0xaddr2 [+-][PUW] to clear and set user, present and write flags", mon_changeperms },
	{ "dumpv", "Dump contents of memory for virtual address range", mon_dumpv },
	{ "dumpp", "Dump contents of memory for physical address range", mon_dumpp },
	{ "step", "Single step through current program ", mon_step },
	{ "continue", "Continue execution from current point ", mon_continue },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));

	while (ebp) 
	{
		debuginfo_eip(*(ebp+1),&info);
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, *(ebp+1), *(ebp+2), *(ebp+3), *(ebp+3), *(ebp+4), *(ebp+5));
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - (int)info.eip_fn_addr);
		ebp = (int*)(*ebp);
	}

	return 0;
}

// Used by both showmappings and changeperms to loop over page ranges 
// and perform operations on them
void traversePages(uintptr_t first, uintptr_t last, int print, int set, int clear) {

	//The first 20 bits of va specify the page, so we increment 0x1000
	for(uintptr_t i = first; i <= last; i += 0x1000) {
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) i, 0);

		if(!pte || !(*pte & PTE_P)) {
			//Page table or page doesn't exist
			if(print) cprintf("0x%x: --- \n", i);
			continue;
		}

		//Either changer perms, or print but not both
		if(print) {
			cprintf("0x%x: 0x%x - ", i, PTE_ADDR(i));

			if(*pte & PTE_U) cprintf("U ");
			else cprintf("S ");

			if(*pte & PTE_W) cprintf("RW\n");
			else cprintf("R\n");
		} else {
			*pte |= set;
			*pte &= clear;
		}
	}
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 2) {
		cprintf("Need to specify address or address range!");
		return -1;
	}
	
	//Get first and last page of address range
	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = first;
	if(argc == 3) last = (uintptr_t) strtol(argv[2], NULL, 0);

	traversePages(first, last, 1, 0, 0); // last two arguments are unused
	return 0;
}

int 
mon_changeperms(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 4) {
		cprintf("Need to specify address range and at least one change!");
		return -1;
	}

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);

	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
		int flag = 0;
		switch(argv[i][1]) {
			case 'P': 
				flag = PTE_P;
				break;
			case 'U': 
				flag = PTE_U;
				break;
			case 'W': 
				flag = PTE_W;
				break;
			default:
				cprintf("Illegal! See help for usage\n");
				return -1;
		}

		//Accumulate flag values in set and clear
		if(argv[i][0] == '+') set |= flag;
		else if(argv[i][0] == '-') clear |= flag;
		else {
			cprintf("Illegal! See help for usage\n");
			return -1;
		}
	}

	traversePages(first, last, 0, set, ~clear); 
	return 0;
}

int 
mon_dumpv(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 2) {
		cprintf("Need to specify address or address range!");
		return -1;
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
		cprintf("%x ",*i); //paging hardware just translates virtual address for us
	}
	cprintf("\n");
	return 0;
}

int 
mon_dumpp(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 2) {
		cprintf("Need to specify address or address range!");
		return -1;
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
		cprintf("%x ",*((int*)KADDR((physaddr_t)i))); 
	}
	cprintf("\n");
	return 0;
}

int
mon_step(int argc, char **argv, struct Trapframe *tf)
{
	//Set trap flag (bit 8). This adds an int1 after each step automatically
	tf->tf_eflags |= 0x100;
	cprintf("EIP 0x%x -> 0x%x\n", tf->tf_eip, *((uint32_t*)tf->tf_eip));
	return -1;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
	//Clear trap flag (bit 8). 
	tf->tf_eflags &= ~0x100;
	cprintf("Continuing... \n");
	return -1;
}
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
