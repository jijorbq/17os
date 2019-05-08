typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

extern void simple_puts(u8 *s, u32 color_site);
extern void cmain();

void cmain(){
	simple_puts("Hello world!",7);
	simple_puts("I'm from C language",(1*80+0<<16)+6);
	return ;
}
void putchar(u8 c){
	Out(0x3d4, 0x0e);
	int pos=In(0x3d5)<<8;
	Out(0x3d4, 0x0f);
	pos|= In(0x3d5);
	int x= pos/80, y=pos%80;
	if ( c==0x0d) {  // 回车
		pos=(pos/80+1)*80;
		// setcursor and break;
	}	else
	if (c==0x0a){
		++x; pos+=80;
		// roll_screen
	}else simple_puts(&c, (pos<<16)+0x7);
	while ( pos>=25*80)roll_screen(), pos-=80;
	Out(0x3d4, 0x0e);
	Out(0x3d5, pos>>8);
	Out(0x3d4, 0x0f);
	Out(0x3d5, pos&255);
	return ;
}

