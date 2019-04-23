         ;代码清单17-2
         ;文件名：c17_core.asm
         ;文件说明：保护模式微型核心程序 
         ;创建日期：2012-07-12 23:15
;-------------------------------------------------------------------------------
         ;以下定义常量
         flat_4gb_code_seg_sel  equ  0x0008      ;平坦模型下的4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0018      ;平坦模型下的4GB数据段选择子 
         idt_linear_address     equ  0x8001f000  ;中断描述符表的线性基地址 
;-------------------------------------------------------------------------------          
         ;以下定义宏
;-------------------------------------------------------------------------------
         
;===============================================================================
SECTION  core  vstart=0x80040000

         ;以下是系统核心的头部，用于加载核心程序 
         core_length      dd core_end       ;核心程序总长度#00

         core_entry       dd start          ;核心代码段入口点#04

;-------------------------------------------------------------------------------
         [bits 32]

      
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
make_gate_descriptor:                       ;构造门的描述符（调用门等）
                                            ;输入：EAX=门代码在段内偏移地址
                                            ;       BX=门代码所在段的选择子 
                                            ;       CX=段类型及属性等（各属
                                            ;          性位都在原始位置）
                                            ;返回：EDX:EAX=完整的描述符
         push ebx
         push ecx
      
         mov edx,eax
         and edx,0xffff0000                 ;得到偏移地址高16位 
         or dx,cx                           ;组装属性部分到EDX
       
         and eax,0x0000ffff                 ;得到偏移地址低16位 
         shl ebx,16                          
         or eax,ebx                         ;组装段选择子部分
      
         pop ecx
         pop ebx
      
         retf                                   
                             

         
;-------------------------------------------------------------------------------
general_interrupt_handler:                  ;通用的中断处理过程
         push eax
         push ecx                  ; add some print by me

         mov al,0x20                        ;中断结束命令EOI 
         out 0xa0,al                        ;向从片发送 
         out 0x20,al                        ;向主片发送
         
         pop ecx
         pop eax
          
         iretd

;-------------------------------------------------------------------------------
general_exception_handler:                  ;通用的异常处理过程
         hlt

;-------------------------------------------------------------------------------
rtm_0x70_interrupt_handle:                  ;实时时钟中断处理过程

         pushad

         mov al,0x20                        ;中断结束命令EOI
         out 0xa0,al                        ;向8259A从片发送
         out 0x20,al                        ;向8259A主片发送

         mov al,0x0c                        ;寄存器C的索引。且开放NMI
         out 0x70,al
         in al,0x71                         ;读一下RTC的寄存器C，否则只发生一次中断
                                            ;此处不考虑闹钟和周期性中断的情况
         ;风火轮 by me
         
         xor ebx, ebx
         mov bx , [curcyc]
       ; shr bx , 10
         and bx , 0x3
         add ebx , message_cyc
         mov cl , [ebx]
         mov [0x800b8000],cl

         mov bx , [curcyc]
         inc bx
         mov [curcyc], bx

  .irtn:
         popad

         iretd

;-------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
         pgdt             dw  0             ;用于设置和修改GDT 
                          dd  0

         pidt             dw  0
                          dd  0
                          

         message_cyc      db '\|/-'
         curcyc           dw 0
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
start:
         ;创建中断描述符表IDT
         ;在此之前，禁止调用put_string过程，以及任何含有sti指令的过程。
          
         ;前20个向量是处理器异常使用的
         mov eax,general_exception_handler  ;门代码在段内偏移地址
         mov bx,flat_4gb_code_seg_sel       ;门代码所在段的选择子
         mov cx,0x8e00                      ;32位中断门，0特权级
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;中断描述符表的线性地址
         xor esi,esi
  .idt0:
         mov [ebx+esi*8],eax
         mov [ebx+esi*8+4],edx
         inc esi
         cmp esi,19                         ;安装前20个异常中断处理过程
         jle .idt0

         ;其余为保留或硬件使用的中断向量
         mov eax,general_interrupt_handler  ;门代码在段内偏移地址
         mov bx,flat_4gb_code_seg_sel       ;门代码所在段的选择子
         mov cx,0x8e00                      ;32位中断门，0特权级
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;中断描述符表的线性地址
  .idt1:
         mov [ebx+esi*8],eax
         mov [ebx+esi*8+4],edx
         inc esi
         cmp esi,255                        ;安装普通的中断处理过程
         jle .idt1

         ;设置实时时钟中断处理过程
         mov eax,rtm_0x70_interrupt_handle  ;门代码在段内偏移地址
         mov bx,flat_4gb_code_seg_sel       ;门代码所在段的选择子
         mov cx,0x8e00                      ;32位中断门，0特权级
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;中断描述符表的线性地址
         mov [ebx+0x70*8],eax
         mov [ebx+0x70*8+4],edx

         ;准备开放中断
         mov word [pidt],256*8-1            ;IDT的界限
         mov dword [pidt+2],idt_linear_address
         lidt [pidt]                        ;加载中断描述符表寄存器IDTR

         ;设置8259A中断控制器
         mov al,0x11
         out 0x20,al                        ;ICW1：边沿触发/级联方式
         mov al,0x20
         out 0x21,al                        ;ICW2:起始中断向量
         mov al,0x04
         out 0x21,al                        ;ICW3:从片级联到IR2
         mov al,0x01
         out 0x21,al                        ;ICW4:非总线缓冲，全嵌套，正常EOI

         mov al,0x11
         out 0xa0,al                        ;ICW1：边沿触发/级联方式
         mov al,0x70
         out 0xa1,al                        ;ICW2:起始中断向量
         mov al,0x04
         out 0xa1,al                        ;ICW3:从片级联到IR2
         mov al,0x01
         out 0xa1,al                        ;ICW4:非总线缓冲，全嵌套，正常EOI

         ;设置和时钟中断相关的硬件 
         mov al,0x0b                        ;RTC寄存器B
         or al,0x80                         ;阻断NMI
         out 0x70,al
         mov al,0x12                        ;设置寄存器B，禁止周期性中断，开放更
         out 0x71,al                        ;新结束后中断，BCD码，24小时制

         in al,0xa1                         ;读8259从片的IMR寄存器
         and al,0xfe                        ;清除bit 0(此位连接RTC)
         out 0xa1,al                        ;写回此寄存器

         mov al,0x0c
         out 0x70,al
         in al,0x71                         ;读RTC寄存器C，复位未决的中断状态

         sti                                ;开放硬件中断

         mov cl, '#'
         mov ch, 0x07
  .core:
       mov [0x800b8004],cx
       xor ch, 0x1
         jmp .core
            
core_code_end:

;-------------------------------------------------------------------------------
SECTION core_trail
;-------------------------------------------------------------------------------
core_end: