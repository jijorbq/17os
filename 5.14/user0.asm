			[bits 32]
			program_length dd prog_end-$$
			entry_point dd cstart

extern cstart
%include "trash_syscall.inc"
global _start
_start:
	jmp _start

		; mov al, 4			; clear _screen
		; int 0x11
		; call user_main


;---------------
[section .data]
	sign db 'this is data end'
	prog_end:
