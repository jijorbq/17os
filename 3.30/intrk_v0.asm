org 0x7c00
sti
mov ax,0x0003  ;03H: 80Ã—25 16è‰² æ–‡æœ¬
int 0x10
	mov ax, 0B800h
	mov gs, ax
	xor ax, ax
	mov es, ax

	mov word [es:20h],Timer
	mov word [es:24h],Oucher
	mov ax, cs
	mov word[es:22h],ax
	mov word[es:26h],ax
	mov ds,ax
	mov es,ax


	jmp $
;---------------------	
	delay equ 0xf
	i dw delay
	chara db "-\|/"
	cnt dw 0
	
Timer:
	dec word [i]	;	
	jnz end

	mov ax, [cnt]
	inc ax
	and ax, 0x3
	mov [cnt], ax
	mov bx, chara
	add bx, ax
	mov byte al, [bx]
	mov [ gs:((50*12+39))*2], al
	mov word [i], delay

;-----------------------------
	delay2 equ 0xffff
	j dw delay2
Oucher:
	mov ah, 0x07

	mov al,'O'
	mov [gs : ((24*0+0))*2],ax
	mov al,'u'
	mov [gs : ((24*0+1))*2],ax
	mov al,'c'
	mov [gs : ((24*0+2))*2],ax
	mov al,'h'
	mov [gs : ((24*0+3))*2],ax
	mov al,'!'
	mov [gs : ((24*0+4))*2],ax
	
	in al, 60h

end:
	mov al, 0x0
	mov [gs : ((24*0+0))*2],ax	
	mov [gs : ((24*0+1))*2],ax	
	mov [gs : ((24*0+2))*2],ax	
	mov [gs : ((24*0+3))*2],ax	
	mov [gs : ((24*0+4))*2],ax

	mov al, 20h
	out 20h, al,
	out 0A0H, al
iret

times 510-($-$$) db 0
dw 0xAA55