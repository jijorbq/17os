extern choose
ProgramOffset		dd		0x7c00
ProgramLength		dd		coreEnd-0x7c00
[section .data]
num1st		dd	3
num2nd		dd	4
[section .text]
global _start
global myputs
_start:
	push dword	[num2nd]
	push dword	[num1st]
	call dword choose
	add esp , 8

	hlt
myputs:
	pushad
	mov ebx , [esp+0x28]
	mov ax , 0xb800
	mov es , ax
	xor ebp, ebp
	.loop1:
		mov al, [ebx]
		cmp al, 0x0
		je .endloop1
		mov byte [es:bp], al
		inc bp
		mov byte [es:bp], 0x7
		inc bp
		jmp .loop1
	.endloop1
	popad
	retf
[section .coreEnd]
coreEnd:
; times 510 - ($-$$)  db 0
; db 0x55 , 0xaa