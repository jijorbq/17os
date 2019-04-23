         ;�����嵥17-4
         ;�ļ�����c17_2.asm
         ;�ļ�˵�����û����� 
         ;�������ڣ�2012-07-16 12:27   

         program_length   dd program_end          ;�����ܳ���#0x00
         entry_point      dd start                ;������ڵ�#0x04
         salt_position    dd salt_begin           ;SALT����ʼƫ����#0x08 
         salt_items       dd (salt_end-salt_begin)/256 ;SALT��Ŀ��#0x0C

;-------------------------------------------------------------------------------

         ;���ŵ�ַ������
         salt_begin:
         PrintChar      db  '@PrintChar'
                     times 256-($-PrintChar) db 0
         PrintString      db  '@PrintString'
                     times 256-($-PrintString) db 0
                     
         TerminateProgram db  '@TerminateProgram'
                     times 256-($-TerminateProgram) db 0

         ReadDiskData     db  '@ReadDiskData'
                     times 256-($-ReadDiskData) db 0
         
         PrintDwordAsHex  db  '@PrintDwordAsHexString'
                     times 256-($-PrintDwordAsHex) db 0
         
         salt_end:

         message_0        db  '  User task B->$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
                          db  0x0d,0x0a,0
         message_1        db '\|/-'
         count            dw  0

;-------------------------------------------------------------------------------
      [bits 32]
;-------------------------------------------------------------------------------

start:
            xor ebx,ebx
            mov bx , [count]
            shr bx , 10
            and bx , 0x3
            add ebx, message_1
            mov cl , [ebx]
            call far [PrintChar