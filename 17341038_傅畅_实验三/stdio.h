extern void ClearScreen();  // 
extern char *readItem(int k);
extern char getchar();

char tmp[20];int tmplen;
void putchar(char ch, int *r, int *c){  // used for
	asm_putchar(ch, *r, *c);
	++(*c);
}

void puts(char *s, int len, int *r, int *c){
	for (volatile int i=0; i<len && s[i]; ++i,++(*c))
		asm_putchar(s[i], *r,*c);
} // print a string at the (r,c), used for terminal 

extern void Enterline(int *r, int *c){
	for (;(*r)>=24; --(*r))ScrollDown();
	++(*r);*c=0;
}
void putnum(int num,int *r, int *c){
	tmplen=0;
	if ( num==0) putchar('0', r, c);	else{
		for (; num ;num/=10) tmp[tmplen++] = num%10;
		for (volatile int i=tmplen-1; ~i; --i)
			putchar(tmp[i]+'0',r, c);
	}
}