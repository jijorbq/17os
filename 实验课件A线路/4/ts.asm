org 100h			; ������ص�100h������������COM
; ����ʱ���ж�������08h������ʼ���μĴ���
	xor ax,ax			; AX = 0
	mov es,ax			; ES = 0
	mov word [es:20h],Timer	; ����ʱ���ж�������ƫ�Ƶ�ַ
	mov ax,cs 
	mov word [es:22h],ax		; ����ʱ���ж������Ķε�ַ=CS
	mov ds,ax			; DS = CS
	mov es,ax			; ES = CS
; ����Ļ���½���ʾ�ַ���!��	
	mov	ax,0B800h		; �ı������Դ���ʼ��ַ
	mov	gs,ax		; GS = B800h
	mov ah,0Fh		; 0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	mov al,'!'			; AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
	mov [gs:((80*12+39)*2)],ax	; ��Ļ�� 24 ��, �� 79 ��
	jmp $			; ��ѭ��
; ʱ���жϴ������
	delay equ 4		; ��ʱ���ӳټ���
	count db delay		; ��ʱ��������������ֵ=delay
Timer:
	dec byte [count]		; �ݼ���������
	jnz end			; >0����ת
	inc byte [gs:((80*12+39)*2)]	; =0��������ʾ�ַ���ASCII��ֵ
	mov byte[count],delay		; ���ü�������=��ֵdelay
end:
	mov al,20h			; AL = EOI
	out 20h,al			; ����EOI����8529A
	out 0A0h,al			; ����EOI����8529A
	iret			; ���жϷ���
