typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
#define BUFLEN 20

typedef struct{
	int a,b,c;	
} StructTest;

extern void simple_puts(u8 *s, u32 color_site);
extern void cmain();
extern void roll_screen();

char buf[BUFLEN+1];
StructTest a= (StructTest){1,2,3}, b=(StructTest){4,5,6};
StructTest StructFunc(StructTest x, StructTest y){
	return (StructTest){x.a-y.a, x.b>y.b ? x.b: y.b , x.c*y.c};
}
void cmain(){
	StructTest c= StructFunc(a,b);
	
	simple_puts("Hello world!",7);
	simple_puts("I'm from C language",(1*80+0<<16)+6);
	for (int i=0; ; ++i)
		putchar('A'+i%26);
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

