#include "syscall.h"

extern void cstart(){
	while ( 1) c_snakerand(0,10, 0xe);
}