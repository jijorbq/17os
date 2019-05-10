typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#define BUFLEN 20

typedef struct{
	int a,b,c;	
} StructTest;

extern void simple_puts(u8 *s, u32 color_site);
extern void cmain();
extern void roll_screen();
extern void Out(u16, u8);
extern u8 In(u16);
extern void c_rtm_0x70_interrupt_handle();
extern void Init8259A();

char buf[BUFLEN+1];
// StructTest a= (StructTest){1,2,3}, b=(StructTest){4,5,6};
// StructTest StructFunc(StructTest x, StructTest y){
// 	return (StructTest){x.a-y.a, x.b>y.b ? x.b: y.b , x.c*y.c};
// }
void cmain(){
	// StructTest c= StructFunc(a,b);
	
	// u64 tmp = (1ll<<33)+7;
	simple_puts("Hello world!",0x7);
	simple_puts("I'm from C language",(1*80+0<<16)+6);
	return ;
}
void putchar(u8 c){
	Out(0x3d4, 0x0e);
	int pos=In(0x3d5)<<8;
	Out(0x3d4, 0x0f);
	pos|= In(0x3d5);
	if ( c==0x0d) pos=(pos/80+1)*80;else
	if (c==0x0a)pos+=80;else{
		buf[0] = c; buf[1]=0;
		simple_puts(buf, (pos<<16)+0x7);
		++pos;
	}
	while ( pos>=25*80)roll_screen(), pos-=80;
	Out(0x3d4, 0x0e);
	Out(0x3d5, pos>>8);
	Out(0x3d4, 0x0f);
	Out(0x3d5, pos&255);
	return ;
}

void Init8259A(){
	Out(0x20, 0x11);	Out(0x21, 0x20);
	Out(0x21, 0x04);	Out(0x21, 0x01);

	Out(0xa0, 0x11);	Out(0xa1, 0x70);
	Out(0xa1, 0x04);	Out(0xa1, 0x01);

	Out(0x70, 0x0b|0x80);//NMI
	Out(0x71, 0x12);

	Out(0xal, In(0xa1) & 0xfe);

	Out(0x70, 0x0c); In(0x71);
}

const char message_cyc[4]="\\|/-";
int curcyc=0;
void c_rtm_0x70_interrupt_handle(){
	// Out(0xa0, 0x20); Out(0x20, 0x20);
	// Out(0x70, 0x0c); In(0x71);

	buf[0] = message_cyc[curcyc++];buf[1]=0;
	curcyc&=3;
	simple_puts(buf, (24*80+79<<16) + 4);

}

const int dx[4]={1, 1, -1,-1}, dy[4]={1,-1,1,-1}, Limx=12, Limy=40;
int curx, cury=0,curd=0;
void c_block_stone(u32 BaseX, u32 BaseY){
	curx=0;cury=0;
	while (1){
		buf[0] = '*'; buf[1]=0;
		simple_puts(buf, ((curx+BaseX)*80+cury+BaseY<<16)+0x5);
		for (int delay=1000000; delay--;);

		int nx=curx+dx[curd], ny=cury+dy[curd];
		if ( nx<0 || nx>=Limx) curd^=2;
		if ( ny<0 || ny>=Limy) curd^=1;
		curx+=dx[curd]; cury+= dy[curd];
	}
}