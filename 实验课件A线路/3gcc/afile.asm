BITS 16
extern myUpper
extern myMessage
global _start
_start:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
Load:
    mov bx,7e00h
    mov ah,2                 ; 功能号
    mov al,10                 ;扇区数
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,0                 ;柱面号 ; 起始编号为0
    mov cl,2                 ;起始扇区号 ; 起始编号为1
    int 13H                  ;调用读磁盘BIOS的13h功能
_call:
    push cs    
    call myUpper
    mov bp,myMessage
    mov ax,ds
    mov es,ax
    mov cx,10
    mov ax,1301h
    mov bx,0007h
    mov dh,10
    mov dl,10
    int 10h
_end:
    jmp $