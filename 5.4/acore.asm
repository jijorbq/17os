         flat_4gb_code_seg_sel  equ  0x0008      ;4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0018      ;4GB数据段选择子 
         idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
         VideoSite                equ 0x800b8000
         User0Start                equ 0x80040508
global simple_puts
global _start
extern cmain
                     [bits 32]
_start:
	call flat_4gb_code_seg_sel:cmain
	jmp $
;-------------------------------------------------------------------------------

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
		
		popad
		ret
       