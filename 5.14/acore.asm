         flat_4gb_code_seg_sel  equ  0x0008      ;4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0010      ;4GB数据段选择子 
       ;   idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
       ;   VideoSite                equ 0x800b8000
       ;   User0Start                equ 0x80040508
         idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
         VideoSite                equ 0x800b8000
		 user0_base_address equ 0xf0045000   ;常数，用户程序加载的起始内存地址 
		 user1_base_address equ 0xf0050000
												;被C语言调用的函数一律近返回
		 %macro set_up_Idescriptor 3
		 mov eax, %1
		 mov bx, flat_4gb_code_seg_sel
		 mov cx, %3
		 call flat_4gb_code_seg_sel:make_gate_descriptor

		 mov ebx, idt_linear_address
		 mov [ebx+%2*8], eax
		 mov [ebx+%2*8+4], edx
		 %endmacro
		 %macro alloc_core_linear 0              ;在内核空间中分配虚拟内存 
               mov ebx,[core_tcb+0x06]
               add dword [core_tcb+0x06],0x1000
               call alloc_inst_a_page
         %endmacro 
		%macro alloc_user_linear 0              ;在任务空间中分配虚拟内存 
               mov ebx,[esi+0x06]
               add dword [esi+0x06],0x1000
               call alloc_inst_a_page
         %endmacro

global simple_puts
global _start
global In
global Out
global roll_screen
global getCR3
global alloc_inst_a_page
global AddDescri_2_gdt
global AddDescri_2_ldt
global memcpy
global Phyaddr
global read_hard_disk_1
global Clean_partial_PDE
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
extern Load_program
extern Load_coreself
extern prog_end
                     [bits 32]
		
			program_length dd prog_end-$$
			entry_start	dd _start
			
_start:
			call Load_coreself
			ltr ax 

			;尝试在内核中加载用户程序
			mov eax, 50
			push eax
			call Load_program
			pop eax

			mov eax, 75
			push eax
			call Load_program
			pop eax

			;安装中断
			mov eax , 0
			push eax
			push eax
			call c_block_stone
			add esp ,8

			mov eax, general_exeption_handler
			mov bx, flat_4gb_code_seg_sel
			mov cx, 0x8e00					;e表示中断，如果用任务门则0101B，且需要提供TSS选择子。
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

			set_up_Idescriptor rtm_0x70_interrupt_handle, 0x70 ,0xee00
			  ; set keyboard inter
			; set_up_Idescriptor keyboard_interrupt_handle,0x21 , 0xee00

			  ; set syscall 
			set_up_Idescriptor sys_call_handler, 0x11, 0xee00	;	dpl ->3 


			  mov word[pidt] , 256*8-1
			  mov dword[pidt+2] , idt_linear_address
			  lidt [pidt]

              call Init8259A
			
			;   pushfd
			;   mov eax , [esp]
			;   mov [PCB+0x8], eax
			;   mov [PCB+0x14], eax
			;   popfd
			;   mov eax, 0x0730
			
			  call cmain
			; mov al, 0x01
			; int 0x11
			mov al, 0x5
			int 0x11
			mov cl, al
			mov al, 0x0
			int 0x11
			mov al, 0x4
			int 0x11
			 mov ebx, selfMessage
			 mov ecx, 0xf00003
			 mov al, 2
			 int 0x11

			 mov ecx, '$'
			 mov ebx, 0x1000006
			 mov al, 3
			 int 0x11

			 sti

		
		; jmp [PCB+0xc]
	.core_end:
			jmp $
;-------------------------------------------------------------------------------
make_seg_descriptor:                        ;构造存储器和系统的段描述符
                                            ;输入：EAX=线性基地址
                                            ;      EBX=段界限
                                            ;      ECX=属性。各属性位都在原始
                                            ;          位置，无关的位清零 
                                            ;返回：EDX:EAX=描述符
         mov edx,eax
         shl eax,16
         or ax,bx                           ;描述符前32位(EAX)构造完毕

         and edx,0xffff0000                 ;清除基地址中无关的位
         rol edx,8
         bswap edx                          ;装配基址的31~24和23~16  (80486+)

         xor bx,bx
         or edx,ebx                         ;装配段界限的高4位

         or edx,ecx                         ;装配属性

         retf

make_gate_descriptor:						;构造门的描述符（调用门等）
                                            ;输入：EAX=门代码在段内偏移地址
                                            ;       BX=门代码所在段的选择子 
                                            ;       CX=段类型及属性等（各属
                                            ;          性位都在原始位置）
                                            ;返回：EDX:EAX=完整的描述符
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

AddDescri_2_ldt:				;AddDescri_2_ldt(bas, lim, attri, *tcb)
								; 返回选择子
		push ebx
		push ecx
		push edx
		push edi

		mov eax , [esp+0x14]
		mov ebx , [esp+0x18]
		mov ecx , [esp+0x1c]

		call flat_4gb_code_seg_sel:make_seg_descriptor

		mov edi , [esp+0x20]
											;gcc中的struct 会有对齐的情况，注意。
		mov ebx , [edi+0x0c]				;ldt base
		xor ecx, ecx
		mov cx , [edi+0x0a]					;ldt limit
		inc cx
		add ebx, ecx

		mov [ebx], eax						; bug ,swap of edx:eax
		mov [ebx+0x4], edx

		xor eax, eax
		mov ax, cx
		add cx, 7
		mov [edi+0xa], cx

		or ax ,0x4				;TI=1
		pop edi
		pop edx
		pop ecx
		pop ebx
		ret

AddDescri_2_gdt:				;AddDescri_2_gdt(bas,lim, attri)
								; 返回选择子

		push ebx
		push ecx
		push edx
		
		sgdt [pgdt]

		mov eax , [esp+0x10]
		mov ebx , [esp+0x14]
		mov ecx , [esp+0x18]
		call flat_4gb_code_seg_sel:make_seg_descriptor

		movzx ebx, word [pgdt]
		inc bx
		add ebx, [pgdt+2]
		
		mov [ebx], eax
		mov [ebx+4] , edx

		add word [pgdt] ,8
		
		lgdt [pgdt]
		xor eax, eax
		mov ax , [pgdt]
		shr ax , 3
		shl ax , 3

		pop edx
		pop ecx
		pop ebx
		ret

memcpy:
		push esi
		push edi
		push eax
		push ecx

		mov edi , [esp+0x14]
		mov esi , [esp+0x18]
		mov ecx , [esp+0x1c]

	.cpying:
		mov al, [esi]				; mov eax [esi] is error
		mov [edi] , al
		inc edi
		inc esi
		loop .cpying

		pop ecx
		pop eax
		pop edi
		pop esi
		ret

Phyaddr:
		push ebx
		mov ebx, [esp+0x8]
		shr ebx, 12
		shl ebx, 2
		or ebx, 0xffc00000
		mov eax, [ebx]
		and eax, 0xfffff000
		pop ebx

		ret 

getCR3:
		mov eax, cr3
		ret 
global getEFLAGS
getEFLAGS:
		pushfd
		pop eax
		or eax, 0x00000200					; IF must be on 
		; and eax, 0xfffffdff					; IF try to be off ?
		ret 

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
									; 切换ds
		push ds
		push eax
		mov ax , flat_4gb_data_seg_sel
		mov ds , ax
		pop eax

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

		cmp al, 3					;3  simple_putchar , ebx= color_site,  cl = ch
		jne	.endhandle4
		push ebx
		push ecx
		call simple_putchar
		add esp, 8
		jmp .endsyscall
	.endhandle3:

		cmp al, 4					;4  clock() return BCD code 0x00HourMinSec
		jne	.endhandle4
		call curr_clock
		jmp .endsyscall
	.endhandle4:

		cmp al, 5					;5	clear screen()
		jne	.endsyscall

		call clear_screen

	.endsyscall:
		push eax
		mov ax , [esp+4]
		mov ds , ax
		pop eax
		add esp, 4
		iretd

rtm_0x70_interrupt_handle:
		sti
		cli									;只是为了方便设断点
		push ds
		push eax
		mov ax , flat_4gb_data_seg_sel
		mov ds , ax
		pop eax

		pushad
		mov al,0x20                        ;中断结束命令EOI
		out 0xa0,al                        ;向8259A从片发送
		out 0x20,al                        ;向8259A主片发送

		mov al,0x0c                        ;寄存器C的索引。且开放NMI
		out 0x70,al
		in al,0x71                         ;读一下RTC的寄存器C，否则只发生一次中断
										;此处不考虑闹钟和周期性中断的情况
		call c_rtm_0x70_interrupt_handle
											; C语言完成任务切换， 并返回下一个任务TCB指针
		cmp eax, 0xffffffff
		je .noxchg
		jmp far  [eax+0x14]				; u32 TSS_bas ; u16 TSS_sel
	.noxchg:
		popad

		push eax
		mov ax , [esp+4]
		mov ds , ax
		pop eax
		add esp, 4
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
		; PCB			dd user0_base_address,flat_4gb_code_seg_sel,0,user1_base_address,flat_4gb_code_seg_sel,0
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

read_hard_disk_1:                           ;从硬盘读取一个逻辑扇区（平坦模型） 
                                            ;read_hard_disk_1(source sector, target addr)
		cli
         
         pushad
		 mov eax, [esp+36]
		 mov ebx, [esp+40]
      
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

         popad
      
        ;  sti
      
         ret                               

alloc_inst_a_page:							;分配一个页，并安装在当前活动的
                                            ;层级分页结构中
                                            ;void alloc(页的线性地址)
											;如果存在就不分配了
		push eax
		push ebx
		push esi

		;check the exist of PageSheet
		mov esi, [esp+0x10]
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

		mov esi, [esp+0x10]
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

		ret

global Clean_partial_PDE
Clean_partial_PDE:						;清空当前页目录的前半部分
										;（对应低2GB的局部地址空间） 
	pushad

		mov ebp, esp

		 
		mov ebx, 0xfffff000
		xor esi, esi
	.b1:
		mov dword [ebx+esi*4], 0x00000000
		inc esi
		cmp esi, 512
		jl .b1

		mov ebx, 0xfffffff8				;新页目录的缓存也要清掉
		mov dword [ebx], 0x00000000

		mov eax, cr3
		mov cr3, eax						;reflash TLB
	popad

	ret


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
	;.rel.text .data .bss .rodata
	core_buf	times 512 db 0		;内核用的缓冲区
