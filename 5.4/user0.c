#define N 20
const char input_info[]="Please input a char:", enter_info[]="Enter user program clock:";

char time_str[N];
extern void user_main(){
	for (int i=0; input_info[i]; ++i) putchar(input_info[i]);
	char ch= getchar();
	putchar(ch);
	putchar('\r');
	int clk = get_curr_time(),len=0;
	for (int i=0; enter_info[i]; ++i) putchar(enter_info[i]);
	for (int i=0; i<6; ++i , clk>>=4){
		time_str[len++] =(clk&0x0f)+'0';
		if ( i%2==1 && i<5) time_str[len++]=':';
	}
	for (int i=len ;i; --i) putchar(time_str[i-1]);
}