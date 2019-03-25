org 0x7c00
mov ax,cs
mov ss,ax
mov sp,0x7c00  ;set stack and sp
mov ax,0x0003
int 0x10

mov ax, 0xb800
mov es, ax
; mov ah,0
; int 16H
; mov [es:0x00],al
; mov byte [es:0x01],0x07

; mov ah,0
; int 16H
; mov [es:0x02],al
; mov byte [es:0x03],0x08

; mov ah,0
; int 16H
; mov [es:0x04],al
; mov byte [es:0x05],0x06

loop:
mov ax,0x0100
int 16h
jne loop
mov ax,0x0000
int 16h
mov byte bl, [cnt]
mov bh,0
mov byte [es:bx],al
inc bl
mov byte [es:bx],0x07
inc bl
mov byte [cnt],bl
jmp loop

cnt db 0
times 510-($-$$) db 0
db 0x55, 0xaa
flu db 0