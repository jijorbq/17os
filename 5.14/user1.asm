global _start
VideoSite                equ 0x800b8000
				program_length dd prog_end-$$
				entry_start dd _start
_start:
		; mov al, 4			; clear _screen
		; int 0x11
		; call user_main
		mov word [VideoSite+160],  0x0
		mov word [VideoSite+160],  ax
		jmp _start
[section .data]
	sign db 'this is data end'
	prog_end: