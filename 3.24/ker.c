#define N 1001
#define MAXLEN 1000
__asm__(".code16gcc\n");
char s[N], t[N], parm[10][20]; // common used order , parameters
extern void ClearScreen();  // 
extern char *readItem(int k);
extern char getchar();

void putchar(char ch, int *r, int *c){  // used for
	asm_putchar(ch, *r, *c);
	++(*c);
}
void Enterline(int *r, int *c){
	for (;(*r)>=24; --(*r))ScrollDown();
	++(*r);*c=0;
}
void memclr(char *s, int len){
	for (int i=0; i<len; ++i) s[i] = 0;
}

int strnlen(char *s,int n){
	int len=0;
	while ( s[len] && len<n)++len;
	return len;
}
int strncmp(char *s, char *t, int n){ // string  , template
	for (int i=0 ; i<n; ++i)
		if (s[i] != t[i]) return s[i]-t[i];
	return 0;
}
void puts(char *s, int len, int *r, int *c){
	for (volatile int i=0; i<len; ++i,++(*c))
		asm_putchar(s[i], *r,*c);
} // print a string at the (r,c), used for terminal 

extern void shell(){
	int r=0, c=0;
	for(;;){
		char p[]= "fuchang@1038 $";
		int len =strnlen(p, MAXLEN),i;
		puts(p, len, &r,&c);
		//Setcursor(r,c+=len);  // ignore the case that r >= 80;
		memclr(s, sizeof(s));len=0;

		// input the order....
		for (char ch=getchar(); ch!= '\r' && ch!='\n'; ch=getchar()){
			if ( ch==0x8 ){
				if ( len ){
					--c;
					putchar(' ', &r,&c), s[--len] = 0;
					--c;
				}
			}else{
				putchar(ch, &r,&c);s[len++] = ch;
			}
		}
		Enterline(&r, &c);
	}

}