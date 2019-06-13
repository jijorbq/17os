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

       mov esi , [esp+0x24]  ; from 40
       .enumchar:
              mov cl,[esi]
              cmp cl, 0x0   ; 字符串默认以0结尾，
              je .endenum
              mov [VideoSite+ebx], cl
              inc ebx
              mov [VideoSite+ebx], al
              inc ebx
              inc esi
              jmp .enumchar
       .endenum:
       popad
       ret
global simple_putchar
simple_putchar:             ; simple_puts(char ch , color_and_site)
		pushad

		mov ebx, [esp+0x28]
		xor eax, eax
		mov ax, bx
		shr ebx , 15
		mov ecx, [esp+0x24]
		mov [VideoSite+ebx], cl
		inc ebx
		mov [VideoSite+ebx], al

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
              push es
              mov ax, ds
              mov es, ax
		cld
		mov esi, VideoSite+0xa0
		mov edi, VideoSite
		mov ecx, 1840
		rep movsd
		mov bx, 3680
		mov ecx, 80
	.cls:
		mov word [VideoSite+ebx], 0x0720
		add bx, 2
		loop .cls
		
              pop eax                            ;not pop ax, because the esp only +=2
              mov es, ax
		popad
		ret
clear_screen:
		pushad
		mov ecx, 2000
		mov ebx, 0
	.clall:
		mov word [VideoSite+ebx], 0x0720
		add bx, 2
		loop .clall

		xor eax, eax
		mov al, 0x0e
		mov dx, 0x3d4
		out dx, al
		mov al, 0
		inc dx
		out dx, al
		mov al ,0x0f
		dec dx
		out dx, al
		mov al, 0
		inc dx
		out dx, al

		popad
		ret


; Load_user_program:							;加载并重定位用户程序
; 											;输入: (prog_section, TCB *pointer)
;                                             ;输出：无 
; 		pushad
; 		mov ebp, esp

; 		 ;清空当前页目录的前半部分（对应低2GB的局部地址空间） 
; 		mov ebx, 0xfffff000
; 		xor esi, esi
; 	.b1:
; 		mov dword [ebx+esi*4], 0x00000000
; 		inc esi
; 		cmp esi, 512
; 		jl .b1

; 		mov eax, cr3
; 		mov cr3, eax						;reflash TLB

; 	; 	mov eax, [ ebp+36]					; get the sector of program
; 	; 	mov ebx, core_buf
; 	; 	call flat_4gb_code_seg_sel:read_hard_disk_0

; 	; 	; calc the size of program
; 	; 	mov eax, [core_buf]
; 	; 	add eax, 0x0fff						;4kb compensate
; 	; 	shr eax, 12
; 	; 	mov ecx, eax
; 	; 	shl ecx, 3

; 	; 	mov eax, [ebp+36]
; 	; 	mov edi, [ebp+40]					;TCB
; 	; 	mov ebx, [edi+0x06]						;ebx<--TCB.start_addr
; 	; .b2:
; 	; 	push ebx
; 	; 	call flat_4gb_code_seg_sel:alloc_inst_a_page
; 	; 	pop ebx
; 	; 	call flat_4gb_code_seg_sel:read_hard_disk_0
; 	; 	inc eax
; 	; 	loop .b2

; 	; 	; mov ebx, [core_buf+4]				;ebx= entry_start
; 	; 	; mov [edi], ebx						;PCB[0]
; 	; 	mov esi , [ebp+40]


; 	; 	alloc_core_linear					;create TSS
; 	; 	mov [esi+0x14], ebx
; 	; 	mov word [esi+0x12],103

; 	; 	alloc_user_linear
; 		call c_load_prog
; 		pushfd
; 		pop edx
; 		mov [ebx+36], edx
		
; 	popad

; 	ret 8
