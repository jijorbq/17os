
extern void ClearScreen();  // 
extern void putchar(char c, int r, int c);  // used for 
extern char getchar();
extern void puts(char *s, int len, int r, int c); // print a string at the (r,c), used for terminal 
extern char *readItem(int k);
extern void Scrolldown();

char s[N], t[N], parm[10][20]; // common used order , parameters

int strnlen(char *s,int n){
	int len=0;
	while ( s[len] && len<n)++len;
	return len;
}
void shell(){
	while ( true){
		if( r==79) Scrolldown();
		++r;
		p= "fuchang@1038 $\0";
		int len =strnlen(p, MAXLEN);
		puts(p, len, r,c);
		Setcursor(r,c+=len);  // ignore the case that r >= 80;
		memset(s, 0, sizeof(s));len=0;

		// input the order....
		for (char ch ; (ch=getchar())!= 10; ){
			if ( len =='' ){
				if ( len ) putchar(' ', r,--c), s[--len] = 0;
			}else{
				putchar(ch, r,c++);s[len++] = ch;
			}
		}
		
		//parser the order...
		
	}

}
void dir();


// and rest of 10000