#define N 1001
#define MAXLEN 1000

typedef char* itemPtr;
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
void dir(int showall);
void exec_batch(char *batchs, int len);


int sectionLoc(itemPtr p){return (((int)p[9])<<8) + p[8];}
int fileSiz(itemPtr p){ return (((int)p[11])<<8)+p[10];}
int createTim(itemPtr p){return ((  (int)p[13])<<8)+p[12];}
int fileTyp(itemPtr p){return (((int)p[15])<<8)+p[14];}
int row=0, col=0;
void shell(){
//	exec_batch("./prog2\r./prog1\r",16);
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
	if ( strncmp(cmd, "./",2)==0){
		int i=2,j,k;
		for (; i<len && cmd[i]==' ';++i);
		for (j=i; cmd[j]!=' ' && j<len; ++j);
		int exist=0;
		itemPtr t=readItem(k);
		for (k=0; k<32; ++k,t+=16) if ( strncmp(cmd+i,t, j-i)==0){ // bug ,t+=16?
			// 
			
			// puts("k=",2, &row, &col);putchar(k+'0', &row, &col);
			// puts(" type=",6, &row, &col); putchar(fileTyp(t)+'0', &row, &col);
			//Enterline(&row, &col);
			if ( fileTyp(t) ==1)run_user_prog(k);
			else
			if ( fileTyp(t) ==2)exec_batch(get_user_bat(k),fileSiz(t)<<9);
			exist = 1;
		}
		if ( !exist) puts("file not found!",15, &row,&col);
		
	}	else
	if ( strncmp(cmd, "ls",2)==0){
		int i=2, j;
		for (; i<len && cmd[i]==' '; ++i);
		for (j=i; cmd[j]!=' '&& j<len; ++j);
		if ( j-i>0){
			if (j-i==3  && strncmp(cmd+i, "-al",3)==0)
				dir(1);
			else puts("paramenter not found!",21, &row, &col);
		}else dir(0);
	}	else
		puts("command not found!",18, &row, &col);
//	Enterline(&row,&col);
}

void dir(int showall){
	char *p;
	for (volatile int i=0; i<32; ++i){
		p=readItem(i);
		if (p[0]==0) break;
		volatile int len = p[7]=='\0'?strnlen(p,8):8,num=0;
		if ( !showall){
			if ( i) {putchar(' ', &row,&col);}
			puts(p, len, &row, &col);
		}else{
			puts(p,len, &row, &col);
			puts(" section:",9, &row, &col);putnum(sectionLoc(p), &row,&col);
			puts(" size:",6,&row, &col); putnum(fileSiz(p)<<9, &row, &col);
			num=createTim(p);
			puts(" crtime:",8, &row, &col);
			putnum(num/60,&row,&col);putchar(':',&row,&col);putnum(num%60, &row,&col);
			puts(" filetype:",10,&row, &col);
			num=fileTyp(p);
			if ( num==1) puts("bin",3, &row, &col);	else
			if ( num==2) puts("bat",3, &row, &col);	else
			if ( num==0) puts("ker",3, &row, &col);
			
			Enterline(&row, &col);
		}
	}
	if ( !showall)Enterline(&row,&col);
}
void exec_batch(char *batchs, int len){

	for (volatile int i=0,j; batchs[i] && i<len; i=j){
		for (; batchs[i]==' ' && i<len; ++i);
		for (j=i; batchs[j]!='\r'&&batchs[j]!='\n' && batchs[j] && j<len; ++j);
		if (i==j){ ++j;continue;}
		exec_single(batchs+i, j-i);
	}
}