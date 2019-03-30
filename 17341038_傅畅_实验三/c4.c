__asm__(".code16gcc\n");
extern void myprint(char *msg, int len );

int choose(int a, int b){
	if ( a>=b) myprint("this 1st one\n",13);
		else	myprint("this 2nd one\n",13);
	return 0;
	// if ( sizeof(a)==4) myprint("32",2);
	// 	else myprint("16",2);
}
