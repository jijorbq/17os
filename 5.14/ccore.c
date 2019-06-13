typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#define BUFLEN 20
#include "keymp.h"
#define AVAILTCB 10
#define tss_linear_address 0x80010000

static u32 cnttcb=0,TSS_array;

struct TCB{
	struct TCB *pre;		// linked list 
	u32 next_bas;u16 state,LDT_lim;
	u32 LDT_bas;u16 LDT_sel,TSS_lim;
	u32 TSS_bas;u16 TSS_sel;
	// u32 Stack0_4kblen,Stack0_bas; u16 Stack0_sel; u32 Stack0_initesp;
	// u32 Stack1_4kblen,Stack1_bas; u16 Stack1_sel; u32 Stack1_initesp;
	// u32 Stack2_4kblen,Stack2_bas; u16 Stack2_sel; u32 Stack2_initesp;
	// u16	head_sel;
}tottcb[AVAILTCB], *TCBHeader=0;

struct TSS{
	struct TSS *preTSS;
	u32 ESP0, SS0, ESP1, SS1, ESP2, SS2;
	u32 CR3, EIP,EFLAG;
	u32 EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI;
	u32 ES, CS, SS, DS,FS, GS, LDTsel;
	u16 T, IOmap;
};

extern void simple_puts(u8 *s, u32 color_site);
extern void simple_putchar(u8 ch, u32 color_site);
extern void cmain();
extern void roll_screen();
extern void Out(u16, u8);
extern u8 In(u16);
extern void Init8259A();
extern void flush_to_keyb(u8 );
extern u8 getchar();
extern u32 curr_clock();
extern u32 allocate_a_4k_page();
extern u32 getCR3();
extern u32 getEFLAGS();
extern void alloc_inst_a_page(u32 addr);
extern u16 AddDescri_2_gdt(u32 bas,u32 lim ,u32 attr);
extern u16 AddDescri_2_ldt(u32 bas,u32 lim ,u32 attr, struct TCB *t);
extern void memcpy(u32 dest, u32 src, u32 len);
extern u32 Phyaddr(u32 linear_addr);
extern void read_hard_disk_1(u32 srcsec, u32 destaddr);
extern void Clean_partial_PDE();


char buf[BUFLEN+1],c_buf[1025];

//
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
		simple_putchar(c, (pos<<16)+0x7);	//其他可视字符，直接在该位置打印
		++pos;
	}
	while ( pos>=24*80)roll_screen(), pos-=80;	//处理光标越位而滚屏的操作
	Out(0x3d4, 0x0e);
	Out(0x3d5, pos>>8);						//将新的坐标位置写回端口
	Out(0x3d4, 0x0f);
	Out(0x3d5, pos&255);
	return ;
}
void puts(u8 *s){for (; *s; ++s) putchar(*s);}
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
u32 curcyc=0;
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

extern u32 c_rtm_0x70_interrupt_handle(){
	// Out(0xa0, 0x20); Out(0x20, 0x20);
	// Out(0x70, 0x0c); In(0x71);

	buf[0] = message_cyc[curcyc++];buf[1]=0;
	curcyc&=3;
	simple_puts(buf, (24*80+79<<16) + 4);
	show_current_clock();
	if ( TCBHeader->pre ==0)return -1;
	struct TCB *curact=TCBHeader;
	while ( curact->pre) curact= curact->pre;
	curact->state=0;
	curact->pre=TCBHeader;TCBHeader=TCBHeader->pre;
	curact=curact->pre;
	curact->pre=0;curact->state=0xffFF;
	return curact;
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

void append_to_tcb_link(struct TCB *t){
	t->pre=TCBHeader;TCBHeader=t;
}

extern u16 Load_coreself(){			//返回TSS选择子
	TSS_array=tss_linear_address;
	struct TCB *t= &tottcb[cnttcb++];
	t->pre=0; t->state= 0xffff;t->next_bas=0x80100000;
	t->LDT_lim=0xffff;
	struct TSS *tssp=t->TSS_bas=TSS_array;
	t->TSS_lim= 103;
	// alloc_inst_a_page(t->TSS_bas);
	TSS_array+=0x1000;
	tssp->preTSS=0x0;tssp->CR3=getCR3();
	tssp->LDTsel=tssp->T=0;tssp->IOmap=103;

	t->TSS_sel=AddDescri_2_gdt(
		t->TSS_bas, t->TSS_lim, 0x00408900
	);
	append_to_tcb_link(t);
	return t->TSS_sel;
}
extern void Load_program(int sectors){
	Clean_partial_PDE();
	read_hard_disk_1(sectors,c_buf);
	u32 siz = *((u32*)c_buf); 
	u32 totsec=((siz+0x0fff)>>12)<<3;
	struct TCB *t = &tottcb[cnttcb++];
	u32 prog_addr=0;  						//用户程序的起始线性地址为0
	for (u32 i=0; i<totsec || i<80; ++i,prog_addr+=512){   // 至少分配10页给代码和GCC数据段
		alloc_inst_a_page(prog_addr);
		if ( i<totsec) read_hard_disk_1(sectors+i, prog_addr);
	}

	t->TSS_bas=TSS_array; TSS_array+=0x1000; // allocate 4KB/per tss，TSSarray指向全局的地址空间
	t->TSS_lim=103;

	alloc_inst_a_page(t->LDT_bas=prog_addr);			//分配一个页作LDT
	t->LDT_lim=-1;prog_addr+=0x1000;

	struct TSS *tssp = t->TSS_bas;
	tssp->CS=AddDescri_2_ldt(
		0x00000000,0x00000009,0x00c0f800, t
	)|0x3; // 建立代码段描述符并放入ldt中，返回段选择子,特权级设为3， 长度10页
	tssp->DS=tssp->ES=tssp->FS=tssp->GS=AddDescri_2_ldt(
		0x00000000,0x0000001A,0x00c0f200,t
	)|0x3;// 建立数据段描述符并放入ldt中，返回段选择子。特权级设为3 , 长度27页

	//将数据段作为用户任务的3特权级固有堆栈
	tssp->SS=tssp->DS;tssp->ESP=0x1b*0x1000;					//能不能不减4？
	
	//在用户任务的局部地址空间内创建0特权级堆栈，长度1页
	alloc_inst_a_page(prog_addr);
	tssp->SS0=AddDescri_2_ldt(
		prog_addr, 0x00000fff, 0x00409200,t					
	)|0x0; // ;设置选择子的特权级为0
	prog_addr+=0x1000;
	tssp->ESP0=0x00001000;							// bug, 真实地址==esp+ssbase!!!!!! esp0=0xfff!!!!而不是prog_addr

	//在用户任务的局部地址空间内创建1特权级堆栈，长度1页
	alloc_inst_a_page(prog_addr);
	tssp->SS1=AddDescri_2_ldt(
		prog_addr, 0x00000fff, 0x0040b200,t			// why ???????
	)|0x1; // ;设置选择子的特权级为1
	prog_addr+=0x1000;
	tssp->ESP1=0x00001000;

	//在用户任务的局部地址空间内创建2特权级堆栈，长度1页
	alloc_inst_a_page(prog_addr);
	tssp->SS2=AddDescri_2_ldt(
		0x0, 0x00000fff, 0x0040d200,t
	)|0x2; // ;设置选择子的特权级为2
	prog_addr+=0x1000;
	tssp->ESP2=0x00001000;

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
	
	//总共27页，全部分配完	多分配一页？
	for (;prog_addr<(0x1C<<12); prog_addr+=0x1000)
		alloc_inst_a_page(prog_addr);
	

	alloc_inst_a_page(0xffffe000);//分配一个页作页目录,由于还没有切换页表，对新页表的操作还需要在内核页表中进行,反正页目录和页表的US位为0，也不需要在用户空间里
	memcpy(0xffffe000,0xfffff000,0x1000);
	tssp->CR3 = Phyaddr(0xffffe000);
	tssp->EFLAG= getEFLAGS();
	tssp->EIP= *((u32*)(0x4));
//	*((*u32)(tssp->CR3+0x4*0x3ff)) =   prog_addr// 这一步不需要获取实际物理地址
	t->next_bas=prog_addr;
	t->state=0;
	

	append_to_tcb_link(t);
	// alloc_inst_a_page(prog_addr);	//分配一个页作页表
	// for (int i=0; i<1024; ++i)
	// 	*((u32*)(prog_addr+i*4))= start_addr+i*4096;  // 低端12位信息待定

}

//-------------------------------------------------------------------
// paging func
#define page_map_len 64
u8 page_bit_map[page_map_len]=
				{0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,			//低端都是土狼驻地地方
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

