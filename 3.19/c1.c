#include "stdio.h"  
#include "string.h"  
extern char *string;  
extern void print_hello();  
extern cpy_mem (void *dest, int len);  
char *strhello = "Hello,world!\n";  
char *str = NULL;  
int  
main ()  
{  
        printf ("%x\n",&string);  
        str = &string;  
        printf ("%s", str);  
         
        print_hello ();  
        return 0;  
}  