         flat_4gb_code_seg_sel  equ  0x0008      ;4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0018      ;4GB数据段选择子 
       ;   idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
       ;   VideoSite                equ 0x800b8000
       ;   User0Start                equ 0x80040508
         idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
         VideoSite                equ 0x800b8000
		 user0_base_address equ 0xf0045000   ;常数，用户程序加载的起始内存地址 
		 user1_base_address equ 0xf0050000

		 %macro set_up_Idescriptor 2
		 mov eax, %1
		 mov bx, flat_4gb_code_seg_sel
		 mov cx, 0x8e00
		 call flat_4gb_code_seg_sel:make_gate_descriptor

		 mov ebx, idt_linear_address
		 mov [ebx+%2*8], eax
		 mov [ebx+%2*8+4], edx
		 %endmacro
		 %macro alloc_core_linear 0              ;在内核空间中分配虚拟内存 
               mov ebx,[core_tcb+0x06]
               add dword [core_tcb+0x06],0x1000
               call flat_4gb_code_seg_sel:alloc_inst_a_page
         %endmacro 
		%macro alloc_user_linear 0              ;在任务空间中分配虚拟内存 
               mov ebx,[esi+0x06]
               add dword [esi+0x06],0x1000
               call flat_4gb_code_seg_sel:alloc_inst_a_page
         %endmacro

global simple_puts
global _start
global In
global Out
global roll_screen
extern c_rtm_0x70_interrupt_handle
extern Init8259A
extern putnum
extern putchar
extern getchar
extern cmain
extern allocate_a_4k_page
extern c_block_stone
extern flush_to_keyb
extern curr_clock
                     [bits 32]
			program_length dd prog_end-$$
			entry_start	dd _start
			
_start:
			;尝试在内核中加载用户程序
			mov eax, PCB
			push eax
			mov eax, 50
			push eax
			call Load_user_program

			mov eax, PCB+0xc
			push eax
			mov eax, 75
			push eax
			call Load_user_program

			;安装中断
			mov eax , 0
			push eax
			push eax
			call c_block_stone
			add esp ,8

			mov eax, general_exeption_handler
			mov bx, flat_4gb_code_seg_sel
			mov cx, 0x8e00
			call flat_4gb_code_seg_sel:make_gate_descriptor

			mov ebx, idt_linear_address
			xor esi, esi
       
       .idt0:
			mov [ebx+esi*8], eax
			mov [ebx+esi*8+4], edx
			inc esi
			cmp esi, 19
			jle .idt0

			mov eax, general_interrupt_handler
			mov bx, flat_4gb_code_seg_sel
			mov cx, 0x8e00
			call flat_4gb_code_seg_sel:make_gate_descriptor

			mov ebx, idt_linear_address
       .idt1:
              mov [ebx+esi*8] , eax
              mov [ebx+esi*8+4] , edx
              inc esi
              cmp esi , 255
              jle .idt1
       
              ; set clock interrupt

			set_up_Idescriptor rtm_0x70_interrupt_handle, 0x70
			  ; set keyboard inter
			set_up_Idescriptor keyboard_interrupt_handle,0x21

			  ; set syscall 
			set_up_Idescriptor sys_call_handler, 0x11

			  mov word[pidt] , 256*8-1
			  mov dword[pidt+2] , idt_linear_address
			  lidt [pidt]

              call Init8259A
			
			sti
			  pushfd
			  mov eax , [esp]
			  mov [PCB+0x8], eax
			  mov [PCB+0x14], eax
			  popfd
			  mov eax, 0x0730

		; 	  call cmain
		; 	mov al, 0x01
		; 	int 0x11
		; 	mov cl, al
		; 	mov al, 0x0
		; 	int 0x11
		; hlt
		; 	mov al, 0x4
		; 	int 0x11
		; 	 mov ebx, selfMessage
		; 	 mov ecx, 0xf00003
		; 	 mov al, 2
		; 	 int 0x11

		jmp [PCB+0xc]
	.core_end:
			jmp $
;-------------------------------------------------------------------------------
make_gate_descriptor:
		push ebx
		push ecx
		
		mov edx, eax
		and edx, 0xffff0000
		or dx, cx

		and eax, 0x0000ffff
		shl ebx, 16
		or eax, ebx

		pop ecx
		pop ebx
		retf

general_exeption_handler:
		hlt
general_interrupt_handler:
		push eax

		mov al, 0x20		;EOI
		out 0xa0,al
		out 0x20, al

		pop eax

		iretd
sys_call_handler: 
									;5 system calls available
		cmp al, 0					;0  putchar , cl=char
		jne	.endhandle0
		push ecx
		call putchar
		add esp, 4
		jmp .endsyscall
	.endhandle0:

		cmp al, 1					;1	getchar , return al=getchar()
		jne	.endhandle1
		xor eax, eax
		sti							; ??? must be open to let keyboard handle to flush the keybuf
		call getchar
		cli
		jmp .endsyscall
		
	.endhandle1:
		cmp al, 2					;2	simple_puts , ebx=*str  , ecx=pos<<16+col
		jne	.endhandle2
		push ecx
		push ebx
		call simple_puts
		add esp , 8
		jmp .endsyscall
		
	.endhandle2:
		cmp al, 3					;3  clock() return BCD code 0x00HourMinSec
		jne	.endhandle3
		call curr_clock
		jmp .endsyscall
	.endhandle3:

		cmp al, 4					;4	clear screen()
		jne	.endsyscall

		call clear_screen

	.endsyscall:
		iretd

rtm_0x70_interrupt_handle:
		pushad
		mov al,0x20                        ;中断结束命令EOI
		out 0xa0,al                        ;向8259A从片发送
		out 0x20,al                        ;向8259A主片发送

		mov al,0x0c                        ;寄存器C的索引。且开放NMI
		out 0x70,al
		in al,0x71                         ;读一下RTC的寄存器C，否则只发生一次中断
										;此处不考虑闹钟和周期性中断的情况
		call c_rtm_0x70_interrupt_handle

											;  exchange the process
		xor ebx , ebx						; store the previous PCB
		mov al, [curpc]
		cmp al, 1
		mov ecx, 0xc
		cmovz ebx, ecx						; 4B*3
		add ebx , PCB
		xor al, 1
		mov [curpc] , al

		mov eax, [esp+0x20]
		mov [ebx], eax
		mov eax, [esp+0x24]
		mov [ebx+4], eax
		mov eax , [esp+0x28]
		mov [ebx+8], eax

		xor ebx, ebx						;release the opposite PCB
		mov al, [curpc]
		cmp al, 1
		cmove ebx, ecx
		add ebx , PCB

		mov eax, [ebx]
		mov [esp+0x20], eax
		mov eax, [ebx+4]
		mov [esp+0x24], eax
		mov eax, [ebx+8]
		mov [esp+0x28] , eax

		popad

		mov ax, [curti]
		inc ax
		and al, 0x037
		mov [curti], ax

		iretd

keyboard_interrupt_handle:
		pushad
		mov al, 0x20
		out 0xa0, al
		out 0x20, al

		xor eax, eax
		in al, 0x60
		push eax
		call flush_to_keyb
		pop eax


		popad
		iretd
;-------------------------------------------------------------------------------
;following function for C
%include "trash_core.inc"
;-------------------------------------------------------------------------------
		pidt 		dw 0
					dd 0
		pgdt		dw 0
					dd 0
		selfMessage db '17341038 fuchang OS in protectMODE', 0
		PCB			dd user0_base_address,flat_4gb_code_seg_sel,0,user1_base_address,flat_4gb_code_seg_sel,0
					; current_addr, cs, eflags
			; eip , cs , eflags
		core_tcb	times 32 db 0
		curpc		db 1
		curti		dw 0x0730
		
;-------------------------------------------------------------------------------
read_hard_disk_0:                           ;从硬盘读取一个逻辑扇区（平坦模型） 
                                            ;EAX=逻辑扇区号
                                            ;EBX=目标缓冲区线性地址
                                            ;返回：EBX=EBX+512
         cli
         
         push eax 
         push ecx
         push edx
      
         push eax
         
         mov dx,0x1f2
         mov al,1
         out dx,al                          ;读取的扇区数

         inc dx                             ;0x1f3
         pop eax
         out dx,al                          ;LBA地址7~0

         inc dx                             ;0x1f4
         mov cl,8
         shr eax,cl
         out dx,al                          ;LBA地址15~8

         inc dx                             ;0x1f5
         shr eax,cl
         out dx,al                          ;LBA地址23~16

         inc dx                             ;0x1f6
         shr eax,cl
         or al,0xe0                         ;第一硬盘  LBA地址27~24
         out dx,al

         inc dx                             ;0x1f7
         mov al,0x20                        ;读命令
         out dx,al

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08
         jnz .waits                         ;不忙，且硬盘已准备好数据传输 

         mov ecx,256                        ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [ebx],ax
         add ebx,2
         loop .readw

         pop edx
         pop ecx
         pop eax
      
        ;  sti
      
         retf                               ;远返回

Load_user_program:							;加载并重定位用户程序
											;输入: (prog_section, TCB *pointer)
                                            ;输出：无 
		pushad
		mov ebp, esp

		 ;清空当前页目录的前半部分（对应低2GB的局部地址空间） 
		mov ebx, 0xfffff000
		xor esi, esi
	.b1:
		mov dword [ebx+esi*4], 0x00000000
		inc esi
		cmp esi, 512
		jl .b1

		mov eax, cr3
		mov cr3, eax						;reflash TLB

	; 	mov eax, [ ebp+36]					; get the sector of program
	; 	mov ebx, core_buf
	; 	call flat_4gb_code_seg_sel:read_hard_disk_0

	; 	; calc the size of program
	; 	mov eax, [core_buf]
	; 	add eax, 0x0fff						;4kb compensate
	; 	shr eax, 12
	; 	mov ecx, eax
	; 	shl ecx, 3

	; 	mov eax, [ebp+36]
	; 	mov edi, [ebp+40]					;TCB
	; 	mov ebx, [edi+0x06]						;ebx<--TCB.start_addr
	; .b2:
	; 	push ebx
	; 	call flat_4gb_code_seg_sel:alloc_inst_a_page
	; 	pop ebx
	; 	call flat_4gb_code_seg_sel:read_hard_disk_0
	; 	inc eax
	; 	loop .b2

	; 	; mov ebx, [core_buf+4]				;ebx= entry_start
	; 	; mov [edi], ebx						;PCB[0]
	; 	mov esi , [ebp+40]


	; 	alloc_core_linear					;create TSS
	; 	mov [esi+0x14], ebx
	; 	mov word [esi+0x12],103

	; 	alloc_user_linear
		call c_load_prog
		pushfd
		pop edx
		mov [ebx+36], edx
		
	popad

	ret 8

alloc_inst_a_page:							;分配一个页，并安装在当前活动的
                                            ;层级分页结构中
                                            ;alloc(页的线性地址)
											;如果存在就不分配了
		push eax
		push ebx
		push esi

		;check the exist of PageSheet
		mov esi, [esp+0x14]
		shr esi, 22
		shl esi, 2
		or esi, 0xfffff000
		test dword [esi], 0x01
		jnz .b1

		;创建该线性地址所对应的页表 
        call allocate_a_4k_page            ;分配一个页做为页表 
        or eax,0x00000007
        mov [esi],eax   
	.b1:

		mov esi, [esp+0x14]
		shr esi, 12
		shl esi, 2
		or esi, 0xffc00000

		test dword[esi], 0x01
		jnz .b2

		call allocate_a_4k_page
		or eax, 0x07
		mov [esi], eax
	.b2:
		pop esi
		pop ebx
		pop eax

		retf



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
[section .data]
	core_buf	times 512 db 0		;内核用的缓冲区

	progend_sgn db 'this is the end of program'
	prog_end: