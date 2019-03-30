#include "stdio.h"
#include "stdlib.h"
#include "string.h"

char s[N], t[N], parm[10][20]; // common used order , parameters

extern void shell(){
	while ( true){
		while( r>=79) Enterline();
		char p[]= "fuchang@1038 $\0";
		int len =strnlen(p, MAXLEN),i;
		puts(p, len, r,c);
		//Setcursor(r,c+=len);  // ignore the case that r >= 80;
		memset(s, 0, sizeof(s));len=0;

		// input the order....
		for (char ch=getchar; ch!= '\r' && ch!='\n'; ch=getchar()){
			if ( len =='' ){
				if ( len ) putchar(' ', r,--c), s[--len] = 0;
			}else{
				putchar(ch, &r,&c);s[len++] = ch;
			}
		}
		Enterline(&r, &c);
		//parser the order...
		for (i=0; s[i]==' ' && i<len;++i);
		if (i<len)exec_single(s+i, len-i);
	}

}

void dir(bool showall){
	volatile char *p;
	for (volatile int i=0; i<32; ++i){
		p=readItem(i);
		if (p[0]==0) break;
		volatile int len = p[7]=='\0'?strnlen(p,8):8,num=0;
		if ( !showall){
			if ( i) {putchar(' ', &r,&c);}
			puts(s, len, &r, &c);
		}else{
			puts(s,len, &r, &c);
			puts(" section:",9, &r, &c);putnum(((int(p[8]))<<8) + p[9], &r,&c);
			puts(" size:",6,&r, &c); putnum(((int(p[10]))<<8)+p[11], &r, &c);
			num= ((int(p[12]))<<8)+p[13];
			puts(" crtime:",8, &r, &c);
			putnum(num/60,&r,&c);putchar(':',&r,&c);putnum(num%60, &r,&c);
			puts(" filetype:",10,&r, &c);
			num=(((int)p[14])<<8)+p[15];
			if ( num==0) puts("");
				else puts("");
			
			Enterline(r, c);
		}
	}
	if ( !showall)Enterline(r,c);
}

void exec_single(char *cmd, int len){
	if ( strncmp(cmd, "./",2)){
		int i=2,j,k;
		for (; i<len && cmd[i]==' ';++i);
		for (j=i; cmd[j]!=' ' && j<len; ++j);
		bool exist=false;
		for (k=0; k<32; ++k) if ( strncmp(cmd+i, readItem(k), j-i)==0){
			// 
			run_user_prog(k);
			exist = true;
		}
		
	}	else
	if ( strncmp(cmd, "ls",2)){
		int i=2, j;
		for (; i<len && cmd[i]==' '; ++i);
		for (j=i; cmd[j]!=' '&& j<len; ++j);
		if ( j-i>0){
			if (j-i==3  && strncmp(cmd+i, "-al"))
				dir(true);
			else puts("paramenter not found!",21, &r, &c);
		}else dir(false);
	}	else
		puts("command not found!",18, &r, &c);
	Enterline(&r,&c);
}
void exec_batch(char *batchs, int len){
	for (volatile int i=0,j; batchs[i] && i<len; i=j){
		for (; batchs[i]==' ' && i<len; ++i);
		for (j=i; (batchs[j]!='\r'&&batchs[j]!='\n' && j<len; ++j);
		exec_single(batchs+i, j-i);
	}
}
// and rest of 10000exec_single(s, len);