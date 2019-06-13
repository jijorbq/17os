#ifndef STDCALL
#define STDCALL

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#define DelayTime 200000

extern void simple_putchar(u32 , u32);
extern u32 clock();

const int dx[4]={1, 1, -1,-1}, dy[4]={1,-1,1,-1};
int curx, cury=0,curd=0;
u32 randseed;

int Delay(int delayt){int j=0;for (int i=delayt; i--;)j+=i;return j;}
u32 rand(){return randseed=randseed*16807%0xffff;}

void c_block_stone(u32 BaseX, u32 BaseY, u32 Limx,u32 Limy,u32 color){
	curx=0;cury=0;
	for (int i=0; i<10000; ++i){
		simple_putchar('*', ((curx+BaseX)*80+cury+BaseY<<16)+color);
		Delay(DelayTime);
		simple_putchar(' ', ((curx+BaseX)*80+cury+BaseY<<16)+color);
		int nx=curx+dx[curd], ny=cury+dy[curd];
		if ( nx<0 || nx>=Limx) curd^=2;
		if ( ny<0 || ny>=Limy) curd^=1;
		curx+=dx[curd]; cury+= dy[curd];
	}
}

void c_snakewind(u32 BaseX, u32 BaseY, u32 Limx, u32 Limy){
	
	for (int step=(Limx<Limy ? Limx:Limy)>>1, i=0,cnt=0; i<step; ++i){
	// for (int i=0; i<2; ++i){
		for (int j=BaseY+i;j<(int)BaseY+Limy-i; ++j, cnt=(cnt+1)%15){
			simple_putchar('+',((BaseX+i)*80+j<<16)+4);
			Delay(DelayTime/10);
		}
		for (int j=BaseX+i; j<(int)(BaseX+Limx-i); ++j,cnt=(cnt+1)%15){
			simple_putchar('+',(j*80+BaseY+Limy-1-i<<16)+1);
			Delay(DelayTime/10);
		}
		for (int j=BaseY+Limy-i-1;j>=(int)(BaseY+i); --j,cnt=(cnt+1)%15){
			simple_putchar('+',((BaseX+Limx-1-i)*80+j<<16)+4);
			Delay(DelayTime/10);
		}
		for (int j=BaseX+Limx-i-1; j>=(int)(BaseX+i); --j,cnt=(cnt+1)%15){   // bugs, lack of int and -1 will >=0
			simple_putchar('+',(j*80+BaseY+i<<16)+1);
			Delay(DelayTime/10);
		}
	}
	for (int i=0; i<Limx; ++i)
		for (int j=0; j<Limy; ++j){
			simple_putchar(' ', ((i+BaseX)*80+j+BaseY<<16)+0x0);
			Delay(DelayTime/20);
		}
}

#define SNAKELEN 20
const int vdx[4]={0,1,0,-1}, vdy[4]={1,0,-1,0};
void c_snakerand(u32 BaseX, u32 BaseY, u32 color){
	randseed=clock()|1;
	u8 x[SNAKELEN+1], y[SNAKELEN+1];
	for (int i=1; i<=SNAKELEN; ++i)x[i]=BaseX, y[i]=BaseY+i;
	for (int i=SNAKELEN;i; --i)
		simple_putchar('o', (x[i]*80+y[i]<<16)+color);
	for (u8 cnt=0,d=rand()%4;;++cnt){
		if ( cnt%6==0) d=rand()%4;
		for(x[0]=x[1]+vdx[d], y[0]= y[1]+vdy[d]; x[0]>=25 || y[0]>=80; x[0]=x[1]+vdx[d], y[0]= y[1]+vdy[d])
			d=(d+1)%4;
		simple_putchar(' ',(x[SNAKELEN]*80+y[SNAKELEN]<<16));
		for (int i=SNAKELEN;i; --i){
			x[i]=x[i-1]; y[i]=y[i-1];
			simple_putchar('~', (x[i]*80+y[i]<<16)+color);
		}
		Delay(DelayTime/3);
	}
}
#endif

/*
blue 1
red 4
yellow 6
green 2
purple 5
grey 8
qingse : 3
white 7
lightblue ; 9
light green: 0xa
light qingse: 0xb
light red 0xc
pink 0xd
light yellow 0xe
light white 0xf
*/