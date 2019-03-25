org 0x7c00

OffSetOfUserPrg1 equ 0xA100
; OffSetOfUserPrg2 equ 0xA500
mov ax,cs
mov ss,ax
mov sp,0x7c00  ;set stack and sp
mov ax,0x0003  ;03H: 80×25 16色 文本
int 0x10
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
Input:
	mov ax, 0x0100
	int 16h
	je Input
		mov ax, 0x0
		mov [Choose],0x0
		int 16h
		cmp al,'1'
		je LoadnEx
		inc [Choose]
		cmp al,'2'
		je LoadnEx
		inc[Choose]
		cmp al,'3'
		je LoadnEx
		inc[Choose]
		cmp al,'4'
		je LoadnEx
	jmp Input
LoadnEx:
	mov ax, cs
	mov es, ax
	mov ax, OffSetOfUserPrg
	add bx, [Choose]
	add bx, [Choose]
	mov ah, 2
	mov al, 1
	mov dl, 0
	mov dh, 0
	mov ch, 0
	mov cl, 2
	int 13h

	call OffSetOfUserPrg1
	jmp Start
; LoadnEx2:
; 	mov ax, cs
; 	mov es, ax
; 	mov bx, OffSetOfUserPrg2
; 	mov ah, 2
; 	mov al, 1
; 	mov dl, 0
; 	mov dh, 0
; 	mov ch, 0
; 	mov cl, 3
; 	int 13h

; 	jmp OffSetOfUserPrg2

AfterRun:
	jmp $
Message:
	db 'Hello, MyOs is loading user program A.COM...'
MessageLength equ ($-Message)
Choose db 0x0
times 510-($-$$) db 0
db 0x55, 0xaa
times 1024-($-$$) db 0
