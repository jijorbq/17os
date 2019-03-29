#define N 1001
#define MAXLEN 1000
#include "stdio.h"
#include "string.h"
__asm__(".code16gcc\n");
char s[N], t[N], parm[10][20]; // common used order , parameters
extern void ClearScreen();  // 
extern char *readItem(int k);
extern char getchar();
extern void setCursor(int r, int c);
void exec_single(char *cmd, int len);
void run_user_prog(int k);

int row=0, col=0;
void shell(){
	run_user_prog(0);
	for (;;){
		char p[15]= "fuchang@1038 $\0";
		int len =strnlen(p, MAXLEN),i;
		puts(p, len, &row,&col);
		len=0;
		for (char ch=getchar(); ch!= '\r' && ch!='\n'; ch=getchar()){
			if ( ch==0x8 ){
				if ( len){
					--col;
					putchar(' ', &row,&col), s[--len] = 0;
					--col;setCursor(row, col);
				}
			}else{
				putchar(ch, &row,&col);s[len++] = ch;
			}
		}
		Enterline(&row, &col);
		//parser the order...
		for (i=0; s[i]==' ' && i<len;++i);
		if (i<len)exec_single(s+i, len-i);
	}
}
void exec_single(char *cmd, int len){
	// puts("Enter single exec:",18,&row, &col);
	// puts(cmd , len ,&row, &col);
	// Enterline(&row, &col);
	if ( strncmp(cmd, "./",2)==0){
		int i=2,j,k;
		for (; i<len && cmd[i]==' ';++i);
		for (j=i; cmd[j]!=' ' && j<len; ++j);
		int exist=0;
		for (k=0; k<32; ++k) if ( strncmp(cmd+i, readItem(k), j-i)==0){
			// 
			//puts("k=",2, &row, &col);putchar(k+'0', &row, &col);
			run_user_prog(k);
			exist = 1;
		}
		if ( !exist) puts("file not found!",15, &row,&col);
		
	}	else
	if ( strncmp(cmd, "ls",2)==0){
		int i=2, j;
		for (; i<len && cmd[i]==' '; ++i);
		for (j=i; cmd[j]!=' '&& j<len; ++j);
		if ( j-i>0){
			if (j-i==3  && strncmp(cmd+i, "-al",3)==0) puts("get the paramenter -al",22, &row, &col);
			else puts("paramenter not found!",21, &row, &col);
		}else puts("ls!!!!",6, &row, &col);
	}	else
		puts("command not found!",18, &row, &col);
	Enterline(&row,&col);
}