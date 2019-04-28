[bits 32]
	user0_length dd user0_end-user0_start
	user0_entry  dd user0_start
[section user0 vstart=0x80040500]
user0_start:
	int 0x12                                ; 依次调用自定义的软中断
	int 0x13
	int 0x14
	int 0x11

	mov cl, '#'
	mov ch, 0x07
userloop:
	mov ebx, 0x800b8004
	mov [ebx],cx                       ; 主过程不断反色地显示一个‘#’字符，
										; 观察其与时钟中断的并行程度
	xor ch, 0x1
	jmp userloop
user0_end: