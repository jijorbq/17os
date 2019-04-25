         flat_4gb_code_seg_sel  equ  0x0008      ;4GB代码段选择子 
         flat_4gb_data_seg_sel  equ  0x0018      ;4GB数据段选择子 
         idt_linear_address     equ  0x8001f000  ;IDT线性基地址 
         VideoSite                equ 0x800b8000
SECTION  core  vstart=0x80040000

         ;系统核心的头部，用于加载核心程序 
         core_length      dd core_end       ;核心程序总长度#00

         core_entry       dd start          ;核心代码段入口点#04

;-------------------------------------------------------------------------------
         [bits 32]
simple_puts:
       pushad               ; 简单的输出字符串，不涉及光标移动
                            ; arg1 is string pointer
                            ; arg2 的低16位表示颜色，高16为表示显示的启示位置，即x*80+y (col,xy)

       mov ebx , [esp+0x28] ;from 40
       xor eax , eax
       mov ax  , bx
       shr ebx , 15         ; shr 16  ,, shl 1

       mov ebp , [esp+0x2c]  ; from 44
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
       retf
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

         mov al,0x20                        ;中断结束命令EOI 
         out 0xa0,al                        ;向从片发送 
         out 0x20,al                        ;向主片发送

         pop eax
          
         iretd

;-------------------------------------------------------------------------------
general_exception_handler:                  ;通用的异常处理过程
         hlt
;-------------------------------------------------------------------------------
personal1_interrupt_handle:               ; 第一个自定义中断例程， 放在0x11处， 用于显示
       pushad
       mov al, 0x20                       ; 发送EOI
       out 0xa0, al
       out 0x20, al
       
       push id_info
       xor eax, eax
       mov ax, 1*80+0                     ; 先压入字符串地址，再压入坐标颜色
       shl eax, 16
       mov ax, 0x09
       push eax
       call flat_4gb_code_seg_sel:simple_puts
       add esp , 8

       popad
       iretd
personal2_interrupt_handle:               ; 第二个中断历程，在程序起始时持续显示弹跳小球
       push eax
       mov al, 0x20
       out 0xa0, al
       out 0x20, al


       push 0x0             
       push 0x0             ; BaseX Y     该历程只需要压入弹跳框的左上角基地址
       call flat_4gb_code_seg_sel:block_stone
       add esp, 8
       pop eax
       iretd

block_stone:
       pushad
       mov eax, [esp+44]
       mov [BaseX], al
       mov eax, [esp+40]
       mov [BaseY], al
       mov ecx , ShowTime                 ; 限定运动次数
                                          ; 以下过程同实验一
       .show:
              push ecx

              mov eax, 0x0
              mov ebx, 0x0
              mov ecx, 0x0
              mov edx, 0x0
              mov al, [posx]
              mov cl, [BaseX]
              add al, cl
              mov bl, [posy]

              mov cl, [BaseY]
              add bl, cl
              mov cx, 0x50
              mul cx


              add ax, bx
              shl eax, 1
              mov ebx, VideoSite
              add ebx, eax

              mov byte [ebx], '*'
              mov cl, [esp]
              and cl, 0x7
              inc cl
              mov byte [ebx+0x1], cl

              mov ecx, [delay]
       .sleeploop:
              loop .sleeploop

              mov byte[ebx],0x0
              mov byte[ebx+0x1],0x0
       .slide:
              mov dl, [posx]
              mov dh, [posy]
              mov al, [dir]
              xor ebx, ebx
              mov bl, al
              mov al, [delx+ebx]
              mov ah, [dely+ebx]

              add dl, al
              add dh, ah
; add bl, '0'
; mov [VideoSite+4], bl
; mov byte [VideoSite+5], 0x07
; sub bl, '0'

; add al, '0'
; mov [VideoSite+6], al
; mov byte [VideoSite+7], 0x07
; sub al, '0'
              mov cl, bl
              cmp dl, 0xff
              jne .Endjudge1
                     xor cl, 0x02
                     mov [dir], cl
                     jmp near .slide
              .Endjudge1:

              cmp dl, LimX
              jne .Endjudge2
                     xor cl, 0x02
                     mov [dir], cl
                     jmp near .slide
              .Endjudge2:

              cmp dh, 0xff
              jne .Endjudge3
                     xor cl, 0x01
                     mov [dir], cl
                     jmp near .slide
              .Endjudge3:

              cmp dh, LimY
              jne .Endjudge4
                     xor cl, 0x01
                     mov [dir], cl
                     jmp near .slide
              .Endjudge4:

              mov [dir],cl
              mov [posx], dl
              mov [posy], dh

              pop ecx
              dec ecx
              cmp ecx , 0x0
              jne .show
       
       popad
       retf

personal3_interrupt_handle:               ;中断例程3 4 同2，改换基地址再运行几次
       push eax
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       push 0             
       push 40             ; BaseX Y
       call flat_4gb_code_seg_sel:block_stone
       add esp, 8
       pop eax
       iretd
personal4_interrupt_handle:
              push eax
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       push 12             
       push 40             ; BaseX Y
       call flat_4gb_code_seg_sel:block_stone
       add esp, 8
       pop eax
       iretd
;-------------------------------------------------------------------------------
keyboard_interrupt_handle:         ;键盘中断处理例程
                                   ;通过判断Scan Set 1 code的最高位，判断这次中断是按下还是弹起
       pushad
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       in al, 0x60                 ; 一定要把端口里的数给读出来，不然下次中断不会被触发

       mov ch, al
       xor ch , 0x80
       shr ch , 7                  ; 最高位为0时按下，此时颜色代码为0x4
                                   ; 最高位为1时弹起，此时颜色代码0x0
       shl ch , 2
       mov cl, 'O'
       mov [VideoSite+1998], cx    ; (12*8+39)*2
       mov cl, 'u'
       mov [VideoSite+2000], cx
       mov cl, 'c'
       mov [VideoSite+2002], cx
       mov cl, 'h'
       mov [VideoSite+2004], cx
       mov cl, '!'
       mov [VideoSite+2006], cx
       
       popad
       iretd
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
         ;转动风火轮 ，并在右下角显示
         
         xor ebx, ebx
         mov bx , [curcyc]
       ; shr bx , 10
         and bx , 0x3
         add ebx , message_cyc
         mov cl , [ebx]
         mov ch , 0x7
         mov [VideoSite+0x0f9e],cx        ; (24*80+79)*2

         mov bx , [curcyc]
         inc bx
         mov [curcyc], bx

       
       mov ebx, timestrLim ; timestr+len-1, the last is '\0'
       mov byte [ebx],0
                            ;      显示当前时间
                            ;      按照秒、分、时的顺序从后往前，从低到高位构造时间字符串

       xor al, al                  
       or al, 0x80
       out 0x70, al
       in al, 0x71
       mov cl, al
       and cl, 0x0f
       add cl, '0'
       dec ebx
       mov [ebx], cl
       shr al, 4
       add al, '0'
       dec ebx
       mov [ebx], al
       dec ebx
       mov byte [ebx], ':'

       mov al, 2
       or al, 0x80
       out 0x70, al
       in al, 0x71
       mov cl, al
       and cl, 0x0f
       add cl, '0'
       dec ebx
       mov [ebx], cl
       shr al, 4
       add al, '0'
       dec ebx
       mov [ebx], al
       dec ebx
       mov byte [ebx], ':'

       mov al, 4
       or al, 0x80
       out 0x70, al
       in al, 0x71
       mov cl, al
       and cl, 0x0f
       add cl, '0'
       dec ebx
       mov [ebx], cl
       shr al, 4
       add al, '0'
       dec ebx
       mov [ebx], al

       push ebx
       mov ax , 0x7c6 ;     显示位置定位(24, 70)
       shl eax, 16
       mov ax , 0x2
       push eax
       call flat_4gb_code_seg_sel:simple_puts
       add esp ,8
         popad

         iretd


;------------------------------------------------------------------------------- 
;以下是通用数据段
         pgdt             dw  0             ;用于设置和修改GDT 
                          dd  0

         pidt             dw  0
                          dd  0
                          

         message_cyc      db '\|/-'
         curcyc           dw 0
         id_info            db '17341038 fuchang os in protectMODE.',0
         BaseX       db 0
         BaseY       db 0
         posx        db 0
         posy        db 0
         dir         db 0
         delx        db 0x01, 0x01, 0xff, 0xff
         dely        db 0x01, 0xff, 0x01, 0xff
         delay       dd 0x003ffff
         timestr     times 0x10 db 0
              timestrLim dd $-timestr-1
         LimX        equ 12
         LimY        equ 40
         ShowTime    equ 0x80
         
;-------------------------------------------------------------------------------

start:
         ;创建中断描述符表IDT
         ;在此之前，禁止调用put_string，以及任何含有sti指令的过程。
          
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

        ; set the keyboard interruption
         mov eax, keyboard_interrupt_handle
         mov bx, flat_4gb_code_seg_sel
         mov cx, 0x8e00
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx, idt_linear_address
         mov [ebx+0x21*8], eax
         mov [ebx+0x21*8+4], edx

         ; set personal interrupt1
         mov eax, personal1_interrupt_handle
         mov bx, flat_4gb_code_seg_sel
         mov cx, 0x8e00
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx, idt_linear_address
         mov [ebx+0x11*8], eax
         mov [ebx+0x11*8+4] , edx

         ; set personal interrupt2
         mov eax, personal2_interrupt_handle
         mov bx, flat_4gb_code_seg_sel
         mov cx, 0x8e00
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx, idt_linear_address
         mov [ebx+0x12*8], eax
         mov [ebx+0x12*8+4] , edx
         ; set personal interrupt3
         mov eax, personal3_interrupt_handle
         mov bx, flat_4gb_code_seg_sel
         mov cx, 0x8e00
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx, idt_linear_address
         mov [ebx+0x13*8], eax
         mov [ebx+0x13*8+4] , edx
         ; set personal interrupt4
         mov eax, personal4_interrupt_handle
         mov bx, flat_4gb_code_seg_sel
         mov cx, 0x8e00
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx, idt_linear_address
         mov [ebx+0x14*8], eax
         mov [ebx+0x14*8+4] , edx
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

         int 0x12                                ; 依次调用自定义的软中断
         int 0x13
         int 0x14
         int 0x11

         mov cl, '#'
         mov ch, 0x07
  .core:
       mov [0x800b8004],cx                       ; 主过程不断反色地显示一个‘#’字符，
                                                 ; 观察其与时钟中断的并行程度
       xor ch, 0x1
         jmp .core
            
core_code_end:

;-------------------------------------------------------------------------------
SECTION core_trail
;-------------------------------------------------------------------------------
core_end: