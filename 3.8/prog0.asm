org 0x7c00

OffSetOfUserPrg1 equ 0xA100
OffSetOfUserPrg2 equ 0xA500
Start:
	mov ax, cs
	mov ds, ax
	mov bp, Message
	mov ax, ds
	mov es, ax
	mov cx, MessageLength
	mov ax, 0x1301
	mov bx, 0x07
	mov dh, 0
	mov dl, 0
	int 10h
LoadnEx2:
	mov ax, cs
	mov es, ax
	mov bx, OffSetOfUserPrg2
	mov ah, 2
	mov al, 1
	mov dl, 0
	mov dh, 0
	mov ch, 0
	mov cl, 2
	int 13h

	jmp OffSetOfUserPrg2

LoadnEx1:
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

	jmp OffSetOfUserPrg1

AfterRun:
	jmp $
Message:
	db 'Hello, MyOs is loading user program A.COM...'
MessageLength equ ($-Message)
times 510-($-$$) db 0
db 0x55, 0xaa
times 1024-($-$$) db 0
