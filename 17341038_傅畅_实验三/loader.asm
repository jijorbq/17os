BITS 16
Program_start equ 0x7a00 ; to adapt to the section number that starting from 1
table_head	equ 0x7e00;table head of the documents
				extern shell
				global get_user_bat
				global asm_putchar
				global getchar
				global ClearScreen
				global readItem
				global ScrollDown
				global _start
				global setCursor
				global run_user_prog
_start:
	mov ax,0x0003  ;03H: 80×25 16色 文本
	int 0x10
	;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：

	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, table_head  ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ; 功能号
	mov al,1                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,2                 ;起始扇区号 ; 起始编号为1
	int 13H ;                调用读磁盘BIOS的13h功能
	; 用户程序a.com已加载到指定内存区域中

	push 0x4
	call dword Load_prog
	add sp, 2
	call dword shell
	jmp $

asm_putchar:			;debugged
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push bp   ; bug, every register used in the prog must be protected !!!
		
			mov  ax, cs           ; 置其他段寄存器值与CS相同
			mov  ds, ax           ; 数据段
			mov  bp, sp      ; BP=当前串的偏移地址
			add bp, 0x12
			mov  ax, ds           ; ES:BP = 串地址
			mov  es, ax           ; 置ES=DS
			mov  cx,1 ; CX=串长
			mov  ax, 1301h        ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
			mov  bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
			mov  dh, [bp+0x4]            ; 行号=0
			mov  dl, [bp+0x8]            ; bug , each is 64bit !!!
			int  10h              ; BIOS的10h功能：显示一行字符
		
		pop bp
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
o32	ret
	;;

getchar:			;debugged
	mov ax,0x0
	int 16h
o32 ret
	;;


ClearScreen:
	push ax
	mov ax,0x0003  ;03H: 80Ã—25 16è‰² æ–‡æœ¬
	int 0x10
	pop ax
o32 ret
	;;

readItem:  			;debugged
	push bx
	push cx

	xor eax, eax
	mov bx, sp
	mov ax, [bx+0x8]
	mov cx, 0x10
	mul cx ;???
	add ax, table_head

	pop cx
	pop bx

o32 ret
	;;

ScrollDown:			;debugged

	push ax
	push bx
	push cx
	push dx

	mov    ah,6    ;6=屏幕初始化或上卷 ， 7=屏幕初始化或下卷
	mov    al,1;   AL = 上卷行数AL =0全屏幕为空白 
	mov    bh,0;   BH = 卷入行属性
	mov    cx,0; CH = 左上角行号 CL = 左上角列号 
	mov    dx,0x184f    ;DH = 右下角行号 DL = 右下角列号(24,79)
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
o32 ret

Load_prog:			;debugged
		push bx
		push cx
		push dx
		push bp
		push es

		mov bx, sp
		add bx, 0xe
		mov ax, [bx]
		mov cx, 16
		mul cx
		add ax, table_head
		
		mov bp, ax
		mov byte cl, [bp+0x8]  ; initial should be 4
		mov ax, 0
		mov al, cl
		mov bx, 512
		mul bx
		mov bx, ax
		add bx, Program_start

		;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		mov ax,cs                ;段地址 ; 存放数据的内存基地址
		mov es,ax                ;设置段地址（不能直接mov es,段地址）
	;	mov bx,   ;偏移地址; 存放数据的内存偏移地址
		mov ah,2                 ; 功能号
		mov al,[bp+0xa]                ;扇区数
		mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
		mov dh,0                 ;磁头号 ; 起始编号为0
		mov ch,0                 ;柱面号 ; 起始编号为0
	;	mov cl,2                 ;起始扇区号 ; 起始编号为1
		int 13H ;                调用读磁盘BIOS的13h功能
		; 用户程序a.com已加载到指定内存区域中
		
		xor eax, eax
		mov ax, bx				; return the program start site

		pop es
		pop bp
		pop dx
		pop cx
		pop bx

		

o32		ret

run_user_prog:			;debug
						; run user's bin prog
		push ax
		push bx
		
		mov bx, sp
		push word [bx+0x8]
		call dword Load_prog	
		xor ebx, ebx
		mov bx, ax
		call dword ebx

		add sp, 0x2  		;bug , fail to match the push--pop bracket 
		pop bx
		pop ax
		
o32 ret
get_user_bat:
						;run user's bat order

		push bx			;each take 2 units of stack memo

		mov bx, sp
		push word [bx+0x6]
		call dword Load_prog
		add sp,0x2

		pop bx

o32	ret


setCursor: ; debugged
	push dx
	push bx
	push bp
	push ax

	xor ax, ax
	xor bx, bx
	mov ah, 2h
	mov bp,sp
	mov dh, [bp+0xc]  ; mad to calc the real site in stack
	mov dl, [bp+0x10]
	int 10h

	pop ax
	pop bp
	pop bx
	pop dx
o32 ret
times 510-($-$$) db 0
db 0x55 , 0xaa

item_start:
Itemeach equ 16
item0:
	db "prog1", 0x0,0x0,0x0		;progname
	dw 0x3				; section location
	dw 0x1				; length of section
	dw 0x400			; time
	dw 0x1 				; file type:exe		
item1:
	db "prog2", 0x0,0x0,0x0		;progname
	dw 0x4				; section location
	dw 0x1				; length of section
	dw 0x400			; time
	dw 0x1 	
item4:
	db "prog3", 0x0,0x0,0x0		;progname
	dw 0x5				; section location
	dw 0x1				; length of section
	dw 0x400			; time
	dw 0x1 
item2:
	db "bat.sh",0x0,0x0	;bugs...
	dw 0x6
	dw 0x1
	dw 0x402
	dw 0x2				; file type:batch
item3:
	db "kernel",0x0,0x0
	dw 0x7
	dw 0xa
	dw 0x401
	dw 0x0				; file type :kernel

times 512-($-item_start) db 0

prog1_start:
	push ax
	push bx
	push cx
	push dx
	push ds
	push es
	push bp       ;each take 2 units of stack memo

		mov ax, 0x0501
		int 10h
		mov  ax, cs           ; 置其他段寄存器值与CS相同
		mov  ds, ax           ; 数据段
		mov  bp, Message      ; BP=当前串的偏移地址
		mov  ax, ds           ; ES:BP = 串地址
		mov  es, ax           ; 置ES=DS
		mov  cx,MessageLength ; CX=串长
		mov  ax, 1301h        ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
		mov  bx, 0107h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
		mov  dh, 0            ; 行号=0
		mov  dl, 0            ; 列号=0
		int  10h              ; BIOS的10h功能：显示一行字符

		mov ax, 0x0
		int 16h

		mov ax, 0x0500
		int 10h
	pop bp
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
		
		
o32 ret 
Message db "a user program."
	MessageLength equ $-Message
times 512-($-prog1_start) db 0
; ;---------------
prog2_start:
	push ax
	push bx
	push cx
	push dx
	push ds
	push es
	push bp       ;each take 2 units of stack memo

		mov ax, 0x0502
		int 10h
		mov  ax, cs           ; 置其他段寄存器值与CS相同
		mov  ds, ax           ; 数据段
		mov  bp, Message2      ; BP=当前串的偏移地址
		mov  ax, ds           ; ES:BP = 串地址
		mov  es, ax           ; 置ES=DS
		mov  cx,MessageLength2 ; CX=串长
		mov  ax, 1301h        ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
		mov  bx, 0207h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
		mov  dh, 0            ; 行号=0
		mov  dl, 0            ; 列号=0
		int  10h              ; BIOS的10h功能：显示一行字符

		mov ax, 0x0
		int 16h

		mov ax, 0x0500
		int 10h
	pop bp
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
		
		
o32 ret 
Message2 db "user program2."
	MessageLength2 equ $-Message2
times 512-($-prog2_start) db 0
;---------------------------------
prog3_start:
BasesX equ 0
BasesY equ 0x28
LimitX equ 0xc; 
LimitY equ 0x28; 
Initial:
	push ax
	push bx
	push cx
	push dx
	push ds
	push bp       ;each take 2 units of stack memo
	
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
	pop bp
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
o32	ret
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
times 512-($-prog3_start) db 0
;-----------------------------------
bat.sh_start:
	db "./prog2",0xa,"./prog1",0xa
times 512-($-bat.sh_start) db 0
