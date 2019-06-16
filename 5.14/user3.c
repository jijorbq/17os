#include "syscall.h"

const u8 info[SNAKELEN+1]="17341038 fuchang's***";
extern void cstart(){
	while (1)	c_snakerand(13, 40, 12,40, info, 0xa);
}