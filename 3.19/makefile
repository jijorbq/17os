# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
all:
	gcc -m32 -Og -c cfile.c -o c.o -fno-pic
	nasm -f elf -g -F stabs  afile.asm -o a.o
	ld -m elf_i386 -N c.o a.o -Ttext 0x7c00 --oformat binary -o fd0
