	.file	"cfile.c"
	.text
	.globl	buffer
	.data
	.align 32
	.type	buffer, @object
	.size	buffer, 50
buffer:
	.string	"HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH\n"
	.zero	14
	.globl	ccch
	.type	ccch, @object
	.size	ccch, 1
ccch:
	.byte	84
	.globl	disp_pos
	.bss
	.align 4
	.type	disp_pos, @object
	.size	disp_pos, 4
disp_pos:
	.zero	4
	.globl	buffer1
	.data
	.align 32
	.type	buffer1, @object
	.size	buffer1, 50
buffer1:
	.string	"LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL\n"
	.zero	14
	.text
	.globl	cmain
	.type	cmain, @function
cmain:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, %eax
	call	cls@PLT
	movzbl	ccch(%rip), %eax
	movsbl	%al, %eax
	movl	%eax, %edi
	movl	$0, %eax
	call	printChar@PLT
	movl	$82, %edi
	movl	$0, %eax
	call	printChar@PLT
	movl	$230, %esi
	leaq	buffer1(%rip), %rdi
	movl	$0, %eax
	call	cprintf@PLT
	leaq	buffer(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	cmain, .-cmain
	.ident	"GCC: (Ubuntu 8.2.0-7ubuntu1) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
