    org 0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    call    DispStr

    jmp $
DispStr:
    mov ax, Str
    mov bp, ax
    mov cx, 13
    mov ax, 01301h
    mov bx, 000ch
    mov dl, 0
    int 10h
    ret
Str:        db  "Hello, world!"
times   510-($-$$)   db  0
dw  0xaa55