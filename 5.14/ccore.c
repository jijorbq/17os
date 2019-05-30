typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#define BUFLEN 20
#include "keymp.h"
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
extern void flush_to_keyb(u8 );
extern u8 getchar();
extern u32 curr_clock();
extern u32 allocate_a_4k_page();

char buf[BUFLEN+1];
// StructTest a= (StructTest){1,2,3}, b=(StructTest){4,5,6};
// StructTest StructFunc(StructTest x, StructTest y){
// 	return (StructTest){x.a-y.a, x.b>y.b ? x.b: y.b , x.c*y.c};
// }
//------------------------------------------------------------------
// STL
void reverse(u8 *fro, u8 *rea){
	u8 t;
	while ( fro < rea){
		t=*fro; *(fro++) = *(--rea); *rea=t;
	}
}
void cmain(){
	// StructTest c= StructFunc(a,b);
	
	// u64 tmp = (1ll<<33)+7;
	simple_puts("Hello world!",0x7);
	simple_puts("I'm from C language",(1*80+0<<16)+6);
	// for (int i=0; i<10; ++i)putchar(getchar());
	return ;
}
//------------------------------------------------------------------
// stdio

void putchar(u8 c){
	Out(0x3d4, 0x0e);		
	int pos=In(0x3d5)<<8;		//两次读取光标位置的低字和高字，
	Out(0x3d4, 0x0f);
	pos|= In(0x3d5);
	if ( c==0x0d) pos=(pos/80+1)*80;else	//判断换行和回车
	if (c==0x0a)pos+=80;else{
		buf[0] = c; buf[1]=0;
		simple_puts(buf, (pos<<16)+0x7);	//其他可视字符，直接在该位置打印
		++pos;
	}
	while ( pos>=25*80)roll_screen(), pos-=80;	//处理光标越位而滚屏的操作
	Out(0x3d4, 0x0e);
	Out(0x3d5, pos>>8);						//将新的坐标位置写回端口
	Out(0x3d4, 0x0f);
	Out(0x3d5, pos&255);
	return ;
}
void putnum(u32 num){
	int len=0;u8 *_buf=buf+10;
	for (;num; num/=10) _buf[len++] = num%10+'0';
	if (len==0) _buf[len++]='0';
	reverse(buf, buf+len);
	_buf[len++] = ' '; _buf[len]=0;
	for (int i=0; i<len; ++i) putchar(_buf[i]);
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

u8 keybuf=0, boolkeybuf=0;
void flush_to_keyb(u8 keyval){
	if ( keyval>=0x080) return ;
	u8 ch=0;
	for (int i=0; i<KEYNUMS; ++i)
		if ( keyval == keymp[3*i+1])ch=keymp[3*i];
	keybuf=ch; boolkeybuf=1;
}
u8 getchar(){
	while (!boolkeybuf);
	boolkeybuf=0;
	return keybuf;
}
//------------------------------------------------------------------
//clock interruption
const char message_cyc[4]="\\|/-";
int curcyc=0;
void c_rtm_0x70_interrupt_handle(){
	// Out(0xa0, 0x20); Out(0x20, 0x20);
	// Out(0x70, 0x0c); In(0x71);

	buf[0] = message_cyc[curcyc++];buf[1]=0;
	curcyc&=3;
	simple_puts(buf, (24*80+79<<16) + 4);
	show_current_clock();
}
u32 curr_clock(){	// BCD code ,total 3 byte 12:34:56 <---> 0x00123456
	u32 res=0;
	Out(0x70, 0x84);	res=In(0x71);
	Out(0x70, 0x82);	res=(res<<8)|In(0x71);
	Out(0x70, 0x80);	res=(res<<8)|In(0x71);
	return res;
}
void show_current_clock(){ 
	u32 clk= curr_clock(), len=0;
	for (int i=0; i<6; ++i, clk>>=4){
		buf[len++] = (clk&0x0f)+'0';
		if ( i<5 && i%2==1) buf[len++]=':';
	}
	reverse(buf, buf+len); buf[len]=0;
	simple_puts(buf, (24*80+70<<16)|8);
}

//------------------------------------------------------------------
// strone_block
const int dx[4]={1, 1, -1,-1}, dy[4]={1,-1,1,-1}, Limx=12, Limy=40;
int curx, cury=0,curd=0;
void c_block_stone(u32 BaseX, u32 BaseY){
	curx=0;cury=0;
	for (int i=0; i<100; ++i){
		buf[0] = '*'; buf[1]=0;
		simple_puts(buf, ((curx+BaseX)*80+cury+BaseY<<16)+0x5);
		for (int delay=10000; delay--;);

		int nx=curx+dx[curd], ny=cury+dy[curd];
		if ( nx<0 || nx>=Limx) curd^=2;
		if ( ny<0 || ny>=Limy) curd^=1;
		curx+=dx[curd]; cury+= dy[curd];
	}
}

//------------------------------------------------------------------
struct TCB{
	struct PCB *pre;		// linked list 
	u16 state;u32 prog_bas;
	u16 LDT_lim;u32 LDT_bas; u16 LDT_sel;
	u16 TSS_lim;u32 TSS_bas; u16 TSS_sel;
	u32 Stack0_4kblen,Stack0_bas; u16 Stack0_sel; u32 Stack0_initesp;
	u32 Stack1_4kblen,Stack1_bas; u16 Stack1_sel; u32 Stack1_initesp;
	u32 Stack2_4kblen,Stack2_bas; u16 Stack2_sel; u32 Stack2_initesp;
	u16	head_sel;
};
struct TSS{
	u32 preTSS;
	u32 ESP0, SS0, ESP1, SS1, ESP2, SS2;
	u32 CR3, EIP,EFLAG;
	u32 EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI;
	u32 ES, CS, SS, DS,FS, GS, LDTsel;
	u16 T, IOmap;
};

void Load_program(int sectors, TCB *t){
	read_hard_disk_1(sectors,c_buf);
	u32 siz = *((*u32)c_buf); 
	u32 totsec=((siz+0x0fff)>>12)<<3;
	u32 prog_addr=t->prog_bas;
	for (u32 i=0=t->prog_bas; i<totsec; ++i,prog_addr+=512){
		alloc_inst_a_page(prog_addr);
		read_hard_disk_1(sectors+i, prog_addr);
	}

	t->TSS_bas=TSS_array; TSS_array+=4096; // allocate 4KB/per tss
	t->TSS_lim=103;

	allloc_inst_a_page(prog_addr);
	t->LDT_bas=prog_addr;prog_addr+=512;

	TSS *tssp = t->TSS_bas;
	tssp->CS=AddDescri(
		0x00000000,0x000fffff,0x00c0f800, t
	)|0x3; // 建立代码段描述符并放入ldt中，返回段选择子,特权级设为3
	tssp->DS=tssp->ES=tssp->FS=tssp->gs=Adddescri(
		0x00000000,0x000fffff,0x00c0f200,t
	)|0x3;// 建立数据段描述符并放入ldt中，返回段选择子。特权级设为3

	alloc_inst_a_page(prog_addr);prog_addr+=512;
	tssp->SS=tssp->DS;tssp->ESP=prog_addr;
	
	//在用户任务的局部地址空间内创建0特权级堆栈
	alloc_inst_a_page(prog_addr);prog_addr+=512;
	tssp->ESP0=prog_addr;
	tssp->SS0=AddDescri(
		0x0, 0x000fffff, 0x00c09200,t
	)|0x0; // ;设置选择子的特权级为0

	//在用户任务的局部地址空间内创建1特权级堆栈
	alloc_inst_a_page(prog_addr);prog_addr+=512;
	tssp->ESP1=prog_addr;
	tssp->SS1=AddDescri(
		0x0, 0x000fffff, 0x00c0b200,t
	)|0x1; // ;设置选择子的特权级为1

	//在用户任务的局部地址空间内创建2特权级堆栈
	alloc_inst_a_page(prog_addr);prog_addr+=512;
	tssp->ESP2=prog_addr;
	tssp->SS2=AddDescri(
		0x0, 0x000fffff, 0x00c0d200,t
	)|0x2; // ;设置选择子的特权级为1

	//;在GDT中登记LDT描述符,并填写到TCB，TSS中
	t->LDT_sel=tssp->LDTsel=AddDescri_2_gdt(
		t->LDT_bas, t->LDT_lim, 0x00408200
	);
	
	tssp->preTSS=0x0;tssp->IOmap=t->TSS_lim;
	tssp->T=0;

	//;在GDT中登记TSS描述符,并填写到TCB，
	t->TSS_sel=AddDescri_2_gdt(
		t->TSS_bas, t->TSS_lim, 0x00408900
	);

	tssp->CR3=create_copy_cur_pdir();
}

//-------------------------------------------------------------------
// paging func
#define page_map_len 64
u8 page_bit_map[page_map_len]=
				{0xff,0xff,0xff,0xff,0xff,0xff,0x55,0x55,
           	    0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
            	0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
            	0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
            	0x55,0x55,0x55,0x55,0x55,0x55,0x55,0x55,
            	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

u32 allocate_a_4k_page(){
	for (int i=0; i<page_map_len<<3; ++i){
		if ( (page_bit_map[i>>3]&(1<<(i&0x7)))==0){
			page_bit_map[i>>3]^=1<<(i&0x7);
			return i<<12;
		}
	}
	simple_puts("Wrong On allocated page!", (3*80<<16)+0x8);
	return -1;
}


//