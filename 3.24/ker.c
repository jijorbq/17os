#include "stdio.h"
#include "stdlib.h"
#include "string.h"

char s[N], t[N], parm[10][20]; // common used order , parameters

void shell(){
	while ( true){
		while( r>=79) Scrolldown();
		++r;
		char p[]= "fuchang@1038 $\0";
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
		while ( r>=79 ) Scrolldown(),--r;
		++r;c=0;
		//parser the order...
		if ( (pos=match(s, "./",2))!=-1){

		}else
		if ( (pos=match(s, "ls",2))!=-1){

		}else puts("command not found!",);
	}

}
void dir(bool showall){
	volatile char *p;
	for (volatile int i=0; i<32; ++i){
		p=readItem(i);
		if (p[0]==0) break;
		if ( showall){
			int len = p[7]=='\0'?strnlen(p,8):8;
			if ( i) putchar(' ', r,c);
			puts(s, len, r, c); ++c;
		}else{
			
			Enterline(r, c);
		}
	}
	Enterline(r,c);
}


// and rest of 10000