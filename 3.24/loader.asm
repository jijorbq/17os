BITS 16
Program_start equ 0xA000
table_head	equ 0x7e00;table head of the documents
				extern shell
				global asm_putchar
				global getchar
				global ClearScreen
				global readItem
				global ScrollDown
				global _start
SECTION booter align=16 vstart=0x7c00


_start:
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

	push 0x1
	call dword Load_prog
	add sp, 4
	call dword shell

asm_putchar:
		mov  ax, cs           ; 置其他段寄存器值与CS相同
		mov  ds, ax           ; 数据段
		mov  bx, bp
		add  bx, 0x4
		mov  bp, [bx]      ; BP=当前串的偏移地址
		mov  ax, ds           ; ES:BP = 串地址
		mov  es, ax           ; 置ES=DS
		mov  cx,1 ; CX=串长
		mov  ax, 1301h        ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
		mov  bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
		add  bx, 0x4
		mov  dh, [bx]            ; 行号=0
		add	 bx, 0x4
		mov  dl, [bx]            ; 列号=0
		int  10h              ; BIOS的10h功能：显示一行字符
o32	ret
	;;

getchar:
	mov ax,0x0
	int 16h
o32 ret
	;;


ClearScreen:
	mov ax,0x0003  ;03H: 80Ã—25 16è‰² æ–‡æœ¬
	int 0x10
o32 ret
	;;

readItem:
	xor eax, eax
	mov bx, bp
	add bx, 0x4
	mov ax, [bx]
	mov cx, 0x10
	mul cx ;???
	add ax, table_head
o32 ret
	;;

ScrollDown:
	mov    ah,6    ;6=屏幕初始化或上卷 ， 7=屏幕初始化或下卷
	mov    al,1;   AL = 上卷行数AL =0全屏幕为空白 
	mov    bh,0;   BH = 卷入行属性
	mov    cx,0; CH = 左上角行号 CL = 左上角列号 
	mov    dx,0x184f    ;DH = 右下角行号 DL = 右下角列号(24,79)
	int 10h
o32 ret

Load_prog:
		mov bx, bp
		add bx, 0x4
		mov ax, [bx]
		mov cx, 16
		mul cx
		add ax, table_head
		
		mov bp, ax
		mov byte cl, [bp+8]
		mov ax, 0
		mov al, cl
		mov cx, 512
		mul cx
		mov bx, ax
		add bx, Program_start

		;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		mov ax,cs                ;段地址 ; 存放数据的内存基地址
		mov es,ax                ;设置段地址（不能直接mov es,段地址）
	;	mov bx,   ;偏移地址; 存放数据的内存偏移地址
		mov ah,2                 ; 功能号
		mov al,[bp+0xe]                ;扇区数
		mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
		mov dh,0                 ;磁头号 ; 起始编号为0
		mov ch,0                 ;柱面号 ; 起始编号为0
	;	mov cl,2                 ;起始扇区号 ; 起始编号为1
		int 13H ;                调用读磁盘BIOS的13h功能
		; 用户程序a.com已加载到指定内存区域中
		
		mov ax, bx

o32		ret

run_user_porg:
		push ax
		push bx
		push cx
		push dx
		push ds
		push cs
		
		call Load_prog
		mov bx, ax
		call [bx]

		pop cs
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
		
o32 ret
times 510-($-$$) db 0
db 0x55 , 0xaa

SECTION table align=16 vstart=0x7e00 ; document table
Itemeach equ 16
item0:
	db "prog1", 0x0,0x0,0x0
	dw 0x2
	dw 0x200
	dw 0x400
	dw 0x1 ; exe
item1:
	db "kernel",0x0,0x0
	dw 0xa
	dw 0xff
	dw 0x401
	dw 0x10 ; exe let it be the number of sections
times 512-($-$$) db 0

[SECTION prog1 align=16 vstart=0]
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
Message db "a user program."
	MessageLength equ $-Message
times 512-($-$$)+MessageLength db 0
; ;---------------
