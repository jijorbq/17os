global _start
VideoSite                equ 0x000b8000
_start:
		; mov al, 4			; clear _screen
		; int 0x11
		; call user_main
		mov word [VideoSite+160],  0x0
		mov word [VideoSite+160],  ax
		jmp _start