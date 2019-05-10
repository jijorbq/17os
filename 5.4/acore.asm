         flat_4gb_code_seg_sel  equ  0x0008      ;4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0018      ;4GB数据段选择子 
       ;   idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
       ;   VideoSite                equ 0x800b8000
       ;   User0Start                equ 0x80040508
         idt_linear_address     equ  0x0001f000  ;IDT线性基地址 
         VideoSite                equ 0x000b8000
         User0Start                equ 0x00040508

global simple_puts
global _start
global In
global Out
global roll_screen
extern c_rtm_0x70_interrupt_handle
extern Init8259A
extern cmain
extern c_block_stone
                     [bits 32]
_start:
              call cmain
			mov eax , 0
			push eax
			push eax
			call c_block_stone

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
              mov eax, rtm_0x70_interrupt_handle
              mov bx, flat_4gb_code_seg_sel
              mov cx, 0x8e00
              call flat_4gb_code_seg_sel:make_gate_descriptor

              mov ebx, idt_linear_address
              mov [ebx+0x70*8], eax
              mov [ebx+0x70*8+4], edx

			  mov word[pidt] , 256*8-1
			  mov dword[pidt+2] , idt_linear_address
			  lidt [pidt]

              call Init8259A
              sti

			  int 0x70

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
rtm_0x70_interrupt_handle:
		push eax
		 mov al,0x20                        ;中断结束命令EOI
         out 0xa0,al                        ;向8259A从片发送
         out 0x20,al                        ;向8259A主片发送

         mov al,0x0c                        ;寄存器C的索引。且开放NMI
         out 0x70,al
         in al,0x71                         ;读一下RTC的寄存器C，否则只发生一次中断
                                            ;此处不考虑闹钟和周期性中断的情况
		pop eax
		call c_rtm_0x70_interrupt_handle
		iretd
;-------------------------------------------------------------------------------
;following function for C
simple_puts:
       pushad               ; 简单的输出字符串，不涉及光标移动
                            ; arg1 is string pointer
                            ; arg2 的低16位表示颜色，高16为表示显示的启示位置，即x*80+y (col,xy)
				; simple_puts(string pointer , color_and_site)
                            ; C function call is near call, only push cs
       mov ebx , [esp+0x28] ;from 44
       xor eax , eax
       mov ax  , bx
       shr ebx , 15         ; shr 16  ,, shl 1

       mov ebp , [esp+0x24]  ; from 40
       .enumchar:
              mov cl,[ebp]
              cmp cl, 0x0   ; 字符串默认以0结尾，
              je .endenum
              mov [VideoSite+ebx], cl
              inc ebx
              mov [VideoSite+ebx], al
              inc ebx
              inc ebp
              jmp .enumchar
       .endenum:
       popad
       ret
Out:
                            ;Out(port, val)
       push eax
       push edx
       mov dx, [esp+0xc]
       mov al, [esp+0x10]
       out dx, al
       pop edx
       pop eax
       ret
In:
                            ;int In(port)
       push edx
       xor eax, eax
       mov dx , [esp +8]
       in al, dx
       pop edx
       ret 

roll_screen:
		pushad

		cld
		mov esi, VideoSite+0xa0
		mov edi, VideoSite
		mov ecx, 1920
		rep movsd
		mov bx, 3840
		mov ecx, 80
	.cls:
		mov word [VideoSite+ebx], 0x0720
		add bx, 2
		loop .cls

		popad
		ret
;-------------------------------------------------------------------------------
		pidt 		dw 0
					dd 0
		pgdt		dw 0
					dd 0
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
