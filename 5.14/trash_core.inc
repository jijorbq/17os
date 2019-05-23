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
