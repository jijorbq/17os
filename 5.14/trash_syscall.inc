; void simple_putchar(u8 ch, u32 color_site){

; }

global simple_putchar
simple_putchar:
	pushad
	mov al, 3
	mov ecx, [esp+0x24]
	mov ebx, [esp+0x28]
	int 0x11

	popad
	ret

global clock
clock:
	mov al, 4
	int 0x11
	ret
