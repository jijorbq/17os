#include "syscall.h"

const u8 info[SNAKELEN+1]="OS in protect MODE---";
extern void cstart(){
	while ( 1) c_snakerand(13,0,12,40, info, 0xe);
}