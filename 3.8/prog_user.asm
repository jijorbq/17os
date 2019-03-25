org 0xA100
mov ax, 0xb800
mov es, ax
mov byte [es:0x100], '+'
mov byte [es:0x101], 0x06

times 512-($-$$) db 0