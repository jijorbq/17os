[section .table, vstart=0x7e00] ; document table
Itemeach equ 16
item0:
	db "kernel",0x0,0x0
	dw 2
	dw LengthOfKernel
	dw CreattimeOfKernel
	dw 0x0 ; exe
item1:
	db "prog1", 0x0,0x0,0x0
	dw 0x2
	dw LengthOfProg1
	dw CreattimeOfProg1
	dw 0x0 ; exe
item2:
	db "prog2", 0x0,0x0,0x0
	dw 0x3
	dw LengthOfProg2
	dw CreattimeOfProg2
	dw 0x0 ; exe
item3:
	db "prog3", 0x0,0x0,0x0
	dw 0x4
	dw LengthOfProg3
	dw CreattimeOfProg3
	dw 0x0 ; exe
item4:
	db "init.cmd"
	dw 0x5
	dw LengthOfcmd
	dw CreattimeOfcmd
	dw 0x1	; cmd

times 512-($-$$) db 0