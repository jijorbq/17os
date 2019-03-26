extern void ClearScreen();  // 
extern void putchar(char c, int r, int c);  // used for 
extern char getchar();
extern void puts(char *s, int len, int r, int c); // print a string at the (r,c), used for terminal 
extern char *readItem(int k);
extern void Scrolldown();
extern void Enterline(int *r, int *c);