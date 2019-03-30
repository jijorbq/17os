
SECTION header vstart=0

	program_length dd program_end

	code_entry dw start
				dd section.code_1.start
	realloc_tbl_len dw (header_end-code_1_segment)/4

	code_1_segment dd section.code_1.start
	code_2_segment dd section.code_2.start
	data_1_segment dd section.data_1.start
	data_2_segment dd section.data_2.start
	stack_segment dd section.stack.start

	header_end:

[SECTION code_1 ,align=16 , vstart=0]

put_string:
		mov cl, [bx]
		or cl, cl
		jz .exit
		call put_char
		inc bx
		jmp put_string
	.exit:
		ret

put_char:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es

		mov dx, 0x3d4
		mov al, 0x0e
		out dx, al
		mov dx, 0x3d5
		in al, dx
		mov ah, al

		mov dx, 0x