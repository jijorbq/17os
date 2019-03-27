			app_lba_start equ 100

SECTION mbr align =16 vstart= 0x7c00

		mov ax, 0
		mov ss, ax
		mov sp, ax

		mov ax, [cs:phy_base]
		mov dx, [cs:phy_base+0x02]
		mov bx, 16
		div bx
		mov ds,ax
		mov es,ax

		xor di,di
		mov si,app_lba_start
		xor bx,bx
		call read_hard_disk_0

		mov dx,[2]
		mov ax,[0]
		mov bx,512
		div bx
		cmp dx, 0
		jnz @1
		dec ax
	
	@1:
		cmp ax,0
		jz direct
		push ds
		mov cx, ax

	@2:
		mov ax, ds
		add ax, 0x20
		mov ds, ax

		xor bx, bx
		inc si
		call read_hard_disk_0
		loop @2

		pop ds
	
	direct:
		mov dx, [0x08]
		mov ax, [0x06]
		call calc_segment_base
		mov [0x06], ax

		mov cx,[0x0a]
		mov bx,[0x0c]

	realloc:
		mov dx,[bx+0x02];
		mov ax,[bx]
		call calc_segment_base
		mov [bx],ax
		add bx,4
		loop realloc

		jmp far [0x04]
;-------------------------------
read_hard_disk_0:

		push ax
		push bx
		push cx
		push dx

		mov dx, 0x1f2
		mov al,1
		out dx, al

		inc dx
		mov ax,si
		out dx, al

		inc dx
		mov al, ah
		out dx, al

		inc dx
		mov ax, di
		out dx, al

		inc dx
		mov ax, di
		out dx,al

		inc dx
		mov al, 0xe0
		or al, ah
		out dx, al

		inc dx
		mov al, 0x20
		out dx, al
.waits:
		in al, dx
		and al, 0x88
		cmp al, 0x08
		jnz .waits

		mov cx, 256
		mov dx, 0x1f0
.readw:

		in ax, dx
		mov [bx], ax
		add bx, 2
		loop .readw


		pop dx
		pop dx
		pop bx
		pop ax

		ret
calc_segment_base:

		push dx
		add ax,[cs:phy_base]
		adc dx,[cs:phy_base]
		shr ax,4
		ror ax,4
		and dx, 0xf000
		or ax, dx

		pop dx

		ret
;------------------------------
		phy_base dd 0x10000
times 510-($-$$)db 0
db 0x55, 0xaa
