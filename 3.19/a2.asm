
[section .text,vstart=0xA100]
global _start
extern PrintStr
_start:
	mov ax, cs
	mov ds, ax
	mov bp, msg
	mov ax, ds
	mov es, ax
	mov cx, len
	mov ax, 0x1301
	mov bx, 0x07
	mov dh, 0
	mov dl, 0
	int 10h
jmp $

[section .data,vstart=0xA100+.data-.text]
msg db "hello world!",0xa
len equ $-msg