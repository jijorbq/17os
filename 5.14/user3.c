#include "syscall.h"

extern void cstart(){
	while (1)	c_snakerand(10,1, 0xa);
}