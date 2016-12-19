#include <kern/e1000.h>
#include <kern/pci.h>
#include <kern/pmap.h>
#include <kern/env.h>
#include <inc/stdio.h>
#include <inc/string.h>
// LAB 6: Your driver code here
volatile uint32_t *base;
#define NMEM(off) base[off>>2]

long double pad; // for alignment
struct tx_desc tx_ring[NTD] __attribute__((aligned(4096)));
struct rx_desc rx_ring[NRD] __attribute__((aligned(4096)));

struct packet_buf tx_bufs[NTD] __attribute__((aligned(4096)));
struct packet_buf rx_bufs[NRD] __attribute__((aligned(4096)));

int va2pa(void* packet, uint32_t* pa_store) {
	pte_t *pte = pgdir_walk(curenv->env_pgdir, packet, 0);
	if( !pte || !(*pte & PTE_P)) {
		cprintf("mappign doesn't exist\n");
		return -1;
	}
	*pa_store = ((PGNUM(*pte))<<PTXSHIFT) + (PGOFF(packet));
	return 0;
}


int e1000_attach(struct pci_func *pcif) {
	pci_func_enable(pcif);
	base = mmio_map_region((physaddr_t) pcif->reg_base[0], pcif->reg_size[0]);

	//print device status just to check

	NMEM(E1000_TDBAL) = PADDR(tx_ring);
	NMEM(E1000_TDLEN) = sizeof(struct tx_desc) * NTD;
	NMEM(E1000_TDH)   = 0;
	NMEM(E1000_TDT)   = 0;

	NMEM(E1000_TCTL) |= E1000_TCTL_EN;
	NMEM(E1000_TCTL) |= E1000_TCTL_PSP;
	NMEM(E1000_TCTL) |= E1000_TCTL_CT;
	NMEM(E1000_TCTL) |= E1000_TCTL_COLD;

	NMEM(E1000_TIPG)  = 0;
	NMEM(E1000_TIPG) |= 10;
	NMEM(E1000_TIPG) |= 8  << 10;
	NMEM(E1000_TIPG) |= 12 << 20;

	for(int i = 0; i < NTD; i++ ) {
		tx_ring[i].status |= E1000_TXD_STAT_DD;
	}

	NMEM(E1000_RAL)  = 0x52 + (0x54 << 8) + (0x12 << 24);
	NMEM(E1000_RAH)  = 0x34 + (0x56 << 8);
	NMEM(E1000_RAH) |= (0x1 << 31);

	for(int i = 0; i < 127; i++) {
		NMEM((E1000_MTA + (i*4))) = 0;
	}

	NMEM(E1000_IMS) = 0; //add interrupts later

	NMEM(E1000_RDBAL) = PADDR(rx_ring);
	NMEM(E1000_RDLEN) = sizeof(struct rx_desc) * NRD;
	NMEM(E1000_RDH)   = 0;
	NMEM(E1000_RDT)   = NRD - 1;

	for(int i = 0; i < NRD; i++ ) {
		memset(&rx_ring[i], 0, sizeof(struct rx_desc));
		rx_ring[i].buffer_addr = PADDR(&rx_bufs[i]);
	}

	NMEM(E1000_RCTL) &= ~E1000_RCTL_LPE;
	NMEM(E1000_RCTL) |= E1000_RCTL_LBM_NO;
	NMEM(E1000_RCTL) |= E1000_RCTL_SECRC;
	NMEM(E1000_RCTL) |= E1000_RCTL_SZ_2048;

	NMEM(E1000_RCTL) |= E1000_RCTL_EN; // enable at the end

	return 0;
}

int e1000_transmit(void* packet, int size) {
	int next = NMEM(E1000_TDT);

	if(!(tx_ring[next].status & E1000_TXD_STAT_DD)) {
		// cannot send more packets rn
		// just drop for now
		return -1;
	}

	uint32_t pa;
	if(va2pa(packet, &pa) < 0) {
		return -1;
	}
	
	memset(&tx_ring[next], 0, sizeof(struct tx_desc));
	tx_ring[next].addr   = pa;
	tx_ring[next].length = size;
	tx_ring[next].cmd   |= E1000_TXD_CMD_RS;
	tx_ring[next].cmd   |= E1000_TXD_CMD_EOP;
	tx_ring[next].cmd   &= ~E1000_TXD_CMD_DEXT;

	NMEM(E1000_TDT) = (next + 1) % NTD;
	return 0;
}

int e1000_receive(void** packet_dst, int *size_store) {
	int next = (NMEM(E1000_RDT) + 1) % NRD; 

	//cprintf("TRYING PACKET AT %d\n", next);
	if(!(rx_ring[next].status & E1000_RXD_STAT_DD)) {
		// cannot receive more packets rn
		return -1;
	}

	struct PageInfo* pp = page_lookup(kern_pgdir, &rx_bufs[next], 0);
	page_insert(curenv->env_pgdir, pp, *packet_dst, PTE_U|PTE_W|PTE_P);
	*packet_dst = (*packet_dst) - (PGOFF(*packet_dst)) + (PGOFF(&rx_bufs[next]));

	*size_store = rx_ring[next].length;
	memset(&rx_ring[next], 0, sizeof(struct rx_desc));
	rx_ring[next].buffer_addr = PADDR(&rx_bufs[next]);

	NMEM(E1000_RDT) = next;
	return 0;
}
