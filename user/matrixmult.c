// Concurrent matrix multiplication as written in Hoare's paper

#include <inc/lib.h>

int A[3][3] = {{1,0,0}, {0,1,0}, {0,0,1}};
int ids[20];
int datastream[3][3] = {{1,2,3}, {4,5,6}, {7,8,9}};
void * pg;

int readId(int i, int j, int* ids) {
	return ids[i*5 +j];
}
void writeId(int i, int j, int* ids, int val) {
	ids[i*5 +j] = val;
}

void
matrix()
{
	int i = 1, j = 0, x=0, sumin = 0;
	envid_t envid;
	int id, *ids;
top:
	ids = (int*) ipc_recv(&envid, pg, 0);
	//cprintf("i think my id is %d %d: %d\n", i,j, readId(i,j,ids));
	if(j == 0 && i<3) {
		if((id = fork()) == 0) {
			i++;
			goto top;
		}
		cprintf("new id %d %d: %d\n", i+1,j, id);
		writeId(i+1,j,ids,id);
		ipc_send(id, (uint32_t)ids, pg, PTE_U | PTE_W |PTE_P);
	}

	if(j < 4) {
		if((id = fork()) == 0) {
			j++;
			goto top;
		}
		cprintf("new id %d %d: %d\n", i,j+1, id);
		writeId(i,j+1,ids,id);
		ipc_send(id, (uint32_t)ids, pg, PTE_U | PTE_W |PTE_P);
	}

	while(1) {
		if(j>=1) {
			x = ipc_recv(&envid, 0, 0);
		}
		if(j<4) {
			ipc_send(readId(i,j+1,ids), x, 0,0);
		}
		if(j==0) continue;
		sumin = 0;
		if(i>1) {
			sumin = ipc_recv(&envid,0,0);
		} 
		if(i<3) {
			ipc_send(readId(i+1,j,ids), A[i][j]*x+sumin, 0,0);
		} else {
			cprintf("col %d out %d \n", j, sumin+A[i][j]*x);
		}
	}
}

void
umain(int argc, char **argv)
{
	int i, id;
	pg = (void *)ROUNDDOWN((uintptr_t)ids, PGSIZE);
	cprintf("pg %d %d\n ",pg, (uint32_t)ids);

	if ((id = fork()) == 0) {
		cprintf("rightafter %d %d\n",thisenv->env_id, sys_getenvid());
		matrix();
	}

	writeId(1,0,ids,id);
	ipc_send(id, (uint32_t)ids, pg, PTE_U | PTE_W | PTE_P);
	for(int j=0;j<3;j++) {
			for(int i=1;i<=3;i++) {
				ipc_send(readId(i,0,ids), datastream[i-1][j], 0, 0);
			}
	}
}

