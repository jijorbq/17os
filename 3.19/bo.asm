org 0x7c00

OffSetOfUserPrg1 equ 0xA100
; OffSetOfUserPrg2 equ 0xA500
mov ax,cs
mov ss,ax
mov sp,0x7c00  ;set stack and sp
mov ax,0x0003
int 0x10
Load1:
	mov ax, cs
	mov es, ax
	mov bx, OffSetOfUserPrg1
	mov ah, 2
	mov al, 1
	mov dl, 0
	mov dh, 0
	mov ch, 0
	mov cl, 2
	int 13h

	call OffSetOfUserPrg1

times 510-($-$$) db 0
dw 0x55aa