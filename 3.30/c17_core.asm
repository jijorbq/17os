         ;�����嵥17-2
         ;�ļ�����c17_core.asm
         ;�ļ�˵��������ģʽ΢�ͺ��ĳ��� 
         ;�������ڣ�2012-07-12 23:15
;-------------------------------------------------------------------------------
         ;���¶��峣��
         flat_4gb_code_seg_sel  equ  0x0008      ;ƽ̹ģ���µ�4GB�����ѡ���� 
         flat_4gb_data_seg_sel  equ  0x0018      ;ƽ̹ģ���µ�4GB���ݶ�ѡ���� 
         idt_linear_address     equ  0x8001f000  ;�ж�������������Ի���ַ 
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
         push ecx                  ; add some print by me

         mov al,0x20                        ;�жϽ�������EOI 
         out 0xa0,al                        ;���Ƭ���� 
         out 0x20,al                        ;����Ƭ����
         
         pop ecx
         pop eax
          
         iretd

;-------------------------------------------------------------------------------
general_exception_handler:                  ;ͨ�õ��쳣�������
         hlt

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
         mov [0x800b8000],cl

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

         mov al,0x11
         out 0xa0,al                        ;ICW1�����ش���/������ʽ
         mov al,0x70
         out 0xa1,al                        ;ICW2:��ʼ�ж�����
         mov al,0x04
         out 0xa1,al                        ;ICW3:��Ƭ������IR2
         mov al,0x01
         out 0xa1,al                        ;ICW4:�����߻��壬ȫǶ�ף�����EOI

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