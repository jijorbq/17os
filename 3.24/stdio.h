extern void ClearScreen();  // 
extern char *readItem(int k);
extern char getchar();

void putchar(char c, int *r, int *c){  // used for
	asm_putchar(c, *r, *c);
	++(*c);
}

void puts(char *s, int len, int *r, int *c){
	for (volatile int i=0; i<len; ++i,++(*c))
		asm_putchar(s[i], *r,*c);
} // print a string at the (r,c), used for terminal 

extern void Enterline(int *r, int *c){
	for (;(*r)>=24; --(*r))asm_ScrollDown();
	++(*r);*c=0;
}