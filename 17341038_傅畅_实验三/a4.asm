[BITS 16]
extern choose
[section .data]
num1st dd 3
num2nd dd 4
[section .text]

global _start
global myprint

_start:
	mov ax,0x0003  ;03H: 80×25 16色 文本
	int 0x10
	
	;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, 0x7e00  ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ; 功能号
	mov al,1                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,2                 ;起始扇区号 ; 起始编号为1
	int 13H ;                调用读磁盘BIOS的13h功能
	; 用户程序a.com已加载到指定内存区域中

	push dword[ num2nd]
	push dword[ num1st]
	call dword choose
	add esp ,8

	; mov ebx, 0
	; mov eax, 1
	; int 80h
	; mov eax,[num2nd]
	; push eax
	; mov eax,[num1st]
	; push eax
	; call choose
	; add esp,8

	; mov ax,[num1st]
	; push ax
	; mov ax,[num2nd]
	; push ax
	; call choose
	; add sp,8
	mov bx,0
	mov ax,1
	int 0x80

myprint:
;		push ax
;		push cx
;		push cs
		; push bx
		mov  ax, cs           ; 置其他段寄存器值与CS相同
		mov  ds, ax           ; 数据段
		mov  bx, sp
		add  bx, 0x6 
		mov  bp, [bx]      ; BP=当前串的偏移地址
		mov  ax, ds           ; ES:BP = 串地址
		mov  es, ax           ; 置ES=DS
		add  bx, 0x4
		mov  cx, [bx] ; CX=串长
		mov  ax, 1301h        ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
		mov  bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
		mov  dh, 0            ; 行号=0
		mov  dl, 0            ; 列号=0
		int  10h              ; BIOS的10h功能：显示一行字符
		; pop bx
		;pop cs 
;		pop cx
;		pop ax
o32		ret

times 510-($-$$) db 0
db 0x55 , 0xaa