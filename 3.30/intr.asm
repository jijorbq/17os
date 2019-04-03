org 0x7c00
sti
mov ax,0x0003  ;03H: 80×25 16色 文本
int 0x10
	xor ax, ax
	mov es, ax
	mov word [es:20h],Timer
	mov ax, cs
	mov word[es:22h],ax
	mov ds,ax
	mov es,ax

	mov ax, 0B800h
	mov gs, ax
	mov ah, 0Fh
	mov al, 'l'
	mov [gs:((50*12+39))*2],ax
	jmp $
;---------------------	
	delay equ 4
	count db delay
Timer:
	dec byte [count]
	jnz end
	inc byte[ gs:((50*12+39))*2]
	mov byte[count], delay
end:
	mov al, 20h
	out 20h, al,
	out 0A0H, al
	iret

times 510-($-$$) db 0
dw 0xAA55