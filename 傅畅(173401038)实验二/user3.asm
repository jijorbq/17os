
org 0xA900
BasesX equ 0
BasesY equ 0x28
LimitX equ 0xc; 
LimitY equ 0x28; 
Initial:
	mov ax,0x0003  ;03H: 80×25 16色 文本
	int 0x10
	mov ax, cs
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	mov ax,cs

show:
; debug
	mov ax, 0x0100
	int 16h
	je endpress
		mov ax,0x0
		int 16h
		mov byte [es:0x20],al
		mov byte [es:0x21],0x04
		cmp al, '#'
		je Return
	endpress:
;endebug
	mov word [counti], posx
	mov word [countj], posy
	mov word [countk], n
	mov word [countl], poss
	loop1:
		mov ax, 0x0
		mov bx, 0x0
		mov dx, 0x0
		mov bx, [counti]

		mov al, [bx]
		add al, BasesX

		mov cx, 0x50
		mul cx

		mov bx, [countj]
		mov dl, [bx]
		add ax,dx
		add ax,BasesY
		mov cx, 0x2
		mul cx

		mov bx, ax
		mov byte [es:bx],'*'
		mov byte [es:bx+0x01],0x07
		mov bx, [countl]
		mov [bx], ax

		inc word [counti]
		inc word [countj]
		inc word [countl]
		inc word [countl]
		dec word [countk]
	jnz loop1

	mov word[counti],delay
	mov word[countj],delay
sleeploop:
	dec word[counti]
	jnz sleeploop
	mov word[counti], delay
	dec word[countj]
	jnz sleeploop

	mov word [countl], poss
	mov word [countk], n
	loop2:
		mov bx, 0
		mov bx, [countl]
		mov ax, [bx]
		mov bx, ax

		mov byte [es:bx],'*'
		mov byte [es:bx+0x01],0x06
		inc word [countl]
		inc word [countl]
		dec word [countk]
	jnz loop2
	jmp near slide

slide:
	mov word [counti], posx
	mov word [countj], posy
	mov word [countl], dir
	mov word [countk], n
	loop3:
		mov bx,[counti]
		mov dl, [bx]
		mov bx,[countj]
		mov dh, [bx]

		mov bx, [countl]
		mov al, [bx]
		mov bx,0
		mov bl, al
		mov al, [delx+bx]
		mov ah, [dely+bx]

		add dl,al
		add dh,ah

		mov cl, bl
		cmp dl, 0xff
		jne Endjudge1
			xor cl,0x02
			mov bx,[countl]
			mov [bx],cl
			jmp near loop3
		Endjudge1:

		cmp dl, LimitX
		jne Endjudge2
			xor cl,0x2
			mov bx,[countl]
			mov [bx],cl
			jmp near loop3
		Endjudge2:

		cmp dh, 0xff
		jne Endjudge3
			xor cl,0x01
			mov bx,[countl]
			mov [bx],cl
			jmp near loop3
		Endjudge3:

		cmp dh,LimitY
		jne Endjudge4
			xor cl, 0x01
			mov bx,[countl]
			mov [bx],cl
			jmp near loop3
		Endjudge4:
		
		mov bx, [countl]
		mov [bx],cl
		mov bx, [counti]
		mov [bx], dl
		mov bx, [countj]
		mov [bx], dh

		inc word[counti]
		inc word [countj]
		inc word [countl]
		dec word [countk]
	jnz loop3

jmp near show
Return:
	ret
delx db 0x01,0x01,0xff,0xff
dely db 0x01,0xff,0x01,0xff  ; 00 01 10 11
posx db 0x00
posy db 0x00
poss dw 0x00
dir db 0x00
delay equ 400
n equ 1
counti dw 0
countj dw 0
countk dw 0
countl dw 0
times 512-($-$$) db 0

