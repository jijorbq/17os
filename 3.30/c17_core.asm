         ;�����嵥17-2
         ;�ļ�����c17_core.asm
         ;�ļ�˵��������ģʽ΢�ͺ��ĳ��� 
         ;�������ڣ�2012-07-12 23:15
;-------------------------------------------------------------------------------
         ;���¶��峣��
         flat_4gb_code_seg_sel  equ  0x0008      ;ƽ̹ģ���µ�4GB�����ѡ���� 
         flat_4gb_data_seg_sel  equ  0x0018      ;ƽ̹ģ���µ�4GB���ݶ�ѡ���� 
         idt_linear_address     equ  0x8001f000  ;�ж�������������Ի���ַ 
         VideoSite                equ 0x800b8000
;-------------------------------------------------------------------------------          
         ;���¶����
;-------------------------------------------------------------------------------
         
;===============================================================================
SECTION  core  vstart=0x80040000

         ;������ϵͳ���ĵ�ͷ�������ڼ��غ��ĳ��� 
         core_length      dd core_end       ;���ĳ����ܳ���#00

         core_entry       dd start          ;���Ĵ������ڵ�#04

;-------------------------------------------------------------------------------
         [bits 32]

      
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
make_gate_descriptor:                       ;�����ŵ��������������ŵȣ�
                                            ;���룺EAX=�Ŵ����ڶ���ƫ�Ƶ�ַ
                                            ;       BX=�Ŵ������ڶε�ѡ���� 
                                            ;       CX=�����ͼ����Եȣ�����
                                            ;          ��λ����ԭʼλ�ã�
                                            ;���أ�EDX:EAX=������������
         push ebx
         push ecx
      
         mov edx,eax
         and edx,0xffff0000                 ;�õ�ƫ�Ƶ�ַ��16λ 
         or dx,cx                           ;��װ���Բ��ֵ�EDX
       
         and eax,0x0000ffff                 ;�õ�ƫ�Ƶ�ַ��16λ 
         shl ebx,16                          
         or eax,ebx                         ;��װ��ѡ���Ӳ���
      
         pop ecx
         pop ebx
      
         retf                                   
                             

         
;-------------------------------------------------------------------------------
general_interrupt_handler:                  ;ͨ�õ��жϴ������
         push eax

         mov al,0x20                        ;�жϽ�������EOI 
         out 0xa0,al                        ;���Ƭ���� 
         out 0x20,al                        ;����Ƭ����

         pop eax
          
         iretd

;-------------------------------------------------------------------------------
general_exception_handler:                  ;ͨ�õ��쳣�������
         hlt
;-------------------------------------------------------------------------------
personal1_interrupt_handle:
       pushad
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       mov ch, 0x5
       mov cl, 'A'
       mov [VideoSite+0xa0], cx

       popad
       iretd
personal2_interrupt_handle:
       push eax
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       push 0x0             
       push 0x0             ; BaseX Y
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
       mov ecx , ShowTime
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

personal3_interrupt_handle:
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
keyboard_interrupt_handle:
       pushad
       mov al, 0x20
       out 0xa0, al
       out 0x20, al

       in al, 0x60

       mov ch, al
       xor ch , 0x80
       shr ch , 7
       shl ch , 2
       mov cl, 'O'
       mov [0x800b8006], cx
       mov cl, 'u'
       mov [0x800b8008], cx
       mov cl, 'c'
       mov [0x800b800a], cx
       mov cl, 'h'
       mov [0x800b800c], cx
       mov cl, '!'
       mov [0x800b800e], cx
       
       popad
       iretd
;-------------------------------------------------------------------------------
rtm_0x70_interrupt_handle:                  ;ʵʱʱ���жϴ������

         pushad

         mov al,0x20                        ;�жϽ�������EOI
         out 0xa0,al                        ;��8259A��Ƭ����
         out 0x20,al                        ;��8259A��Ƭ����

         mov al,0x0c                        ;�Ĵ���C���������ҿ���NMI
         out 0x70,al
         in al,0x71                         ;��һ��RTC�ļĴ���C������ֻ����һ���ж�
                                            ;�˴����������Ӻ��������жϵ����
         ;����� by me
         
         xor ebx, ebx
         mov bx , [curcyc]
       ; shr bx , 10
         and bx , 0x3
         add ebx , message_cyc
         mov cl , [ebx]
         mov ch , 0x7
         mov [VideoSite+0x0f9e],cx

         mov bx , [curcyc]
         inc bx
         mov [curcyc], bx

  .irtn:
         popad

         iretd

;-------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
         pgdt             dw  0             ;�������ú��޸�GDT 
                          dd  0

         pidt             dw  0
                          dd  0
                          

         message_cyc      db '\|/-'
         curcyc           dw 0
         BaseX       db 0
         BaseY       db 0
         posx        db 0
         posy        db 0
         dir         db 0
         delx        db 0x01, 0x01, 0xff, 0xff
         dely        db 0x01, 0xff, 0x01, 0xff
         delay       dd 0x007ffff
         LimX        equ 12
         LimY        equ 40
         ShowTime    equ 0x80
         
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
start:
         ;�����ж���������IDT
         ;�ڴ�֮ǰ����ֹ����put_string���̣��Լ��κκ���stiָ��Ĺ��̡�
          
         ;ǰ20�������Ǵ������쳣ʹ�õ�
         mov eax,general_exception_handler  ;�Ŵ����ڶ���ƫ�Ƶ�ַ
         mov bx,flat_4gb_code_seg_sel       ;�Ŵ������ڶε�ѡ����
         mov cx,0x8e00                      ;32λ�ж��ţ�0��Ȩ��
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;�ж�������������Ե�ַ
         xor esi,esi
  .idt0:
         mov [ebx+esi*8],eax
         mov [ebx+esi*8+4],edx
         inc esi
         cmp esi,19                         ;��װǰ20���쳣�жϴ������
         jle .idt0

         ;����Ϊ������Ӳ��ʹ�õ��ж�����
         mov eax,general_interrupt_handler  ;�Ŵ����ڶ���ƫ�Ƶ�ַ
         mov bx,flat_4gb_code_seg_sel       ;�Ŵ������ڶε�ѡ����
         mov cx,0x8e00                      ;32λ�ж��ţ�0��Ȩ��
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;�ж�������������Ե�ַ
  .idt1:
         mov [ebx+esi*8],eax
         mov [ebx+esi*8+4],edx
         inc esi
         cmp esi,255                        ;��װ��ͨ���жϴ������
         jle .idt1

         ;����ʵʱʱ���жϴ������
         mov eax,rtm_0x70_interrupt_handle  ;�Ŵ����ڶ���ƫ�Ƶ�ַ
         mov bx,flat_4gb_code_seg_sel       ;�Ŵ������ڶε�ѡ����
         mov cx,0x8e00                      ;32λ�ж��ţ�0��Ȩ��
         call flat_4gb_code_seg_sel:make_gate_descriptor

         mov ebx,idt_linear_address         ;�ж�������������Ե�ַ
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
         ;׼�������ж�
         mov word [pidt],256*8-1            ;IDT�Ľ���
         mov dword [pidt+2],idt_linear_address
         lidt [pidt]                        ;�����ж���������Ĵ���IDTR

         ;����8259A�жϿ�����
         mov al,0x11
         out 0x20,al                        ;ICW1�����ش���/������ʽ
         mov al,0x20
         out 0x21,al                        ;ICW2:��ʼ�ж�����
         mov al,0x04
         out 0x21,al                        ;ICW3:��Ƭ������IR2
         mov al,0x01
         out 0x21,al                        ;ICW4:�����߻��壬ȫǶ�ף�����EOI
              ; mov al, 0xfd
              ; out 0x21, al                ;ocw1

         mov al,0x11
         out 0xa0,al                        ;ICW1�����ش���/������ʽ
         mov al,0x70
         out 0xa1,al                        ;ICW2:��ʼ�ж�����
         mov al,0x04
         out 0xa1,al                        ;ICW3:��Ƭ������IR2
         mov al,0x01
         out 0xa1,al                        ;ICW4:�����߻��壬ȫǶ�ף�����EOI
              ; mov al, 0xff
              ; out 0xa1, al

         ;���ú�ʱ���ж���ص�Ӳ�� 
         mov al,0x0b                        ;RTC�Ĵ���B
         or al,0x80                         ;���NMI
         out 0x70,al
         mov al,0x12                        ;���üĴ���B����ֹ�������жϣ����Ÿ�
         out 0x71,al                        ;�½������жϣ�BCD�룬24Сʱ��

         in al,0xa1                         ;��8259��Ƭ��IMR�Ĵ���
         and al,0xfe                        ;���bit 0(��λ����RTC)
         out 0xa1,al                        ;д�ش˼Ĵ���

         mov al,0x0c
         out 0x70,al
         in al,0x71                         ;��RTC�Ĵ���C����λδ�����ж�״̬

         sti                                ;����Ӳ���ж�

         int 0x12
         int 0x13
         int 0x14
         int 0x11

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