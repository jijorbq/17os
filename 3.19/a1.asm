global string  
extern strhello  
[section .data]  
string:  
    db 'I am Chinese.',0x0A,0x0  
[section .text]  
    global print_hello  
    global cpy_mem  
print_hello:      
    mov edx, 13  
    mov ecx,[strhello]  
    mov ebx,1  
    mov eax,4  
    int 0x80  