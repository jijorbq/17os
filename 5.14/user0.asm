
global putchar
global getchar
global get_curr_time
global _start
extern user_main
VideoSite                equ 0x800b8000
			program_length dd prog_end-$$
			entry_point dd _start
_start:
		; mov al, 4			; clear _screen
		; int 0x11
		; call user_main
		mov word [VideoSite+0x0],  0x0
		mov word [VideoSite+0x0],  ax

		jmp _start
putchar:
		push eax
		push ecx
		mov al, 0
		mov cl, [esp+0xc]
		int 0x11
		pop ecx
		pop eax
		ret
getchar:
		xor eax, eax
		mov al, 1
		int 0x11
		ret 
get_curr_time:
		xor eax, eax
		mov al, 3
		int 0x11
		ret


;---------------
[section .data]
	sign db 'this is data end'
	prog_end:
