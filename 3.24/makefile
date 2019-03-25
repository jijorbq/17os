# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
#all:
#	nasm -f elf -g -F stabs  a4.asm -o a.o
#	gcc -o fd0  -m32 a.o c.o
#	gcc -m32 -Og -c c4.c -o c.o -fno-pic
#	ld -m elf_i386 -N a.o c.o -Ttext 0x7c00 --oformat binary -o fd0
fd0:a.o c.o
	ld -m elf_i386 -N a.o c.o -Ttext 0x7c00 --oformat binary -o fd0
c.o:c4.c
	gcc -m32 -Og -c $< -o c.o -fno-pic
a.o:a4.asm
	nasm -f elf $< -o a.o

clean:
	rm *.o