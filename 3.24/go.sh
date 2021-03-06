# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
all:
	gcc -m32 -O -c ker.c -o ker.o -fno-pic
	nasm -f elf -g -F stabs  loader.asm -o loa.o
#	gcc -o fd0  -m32 a.o c.o
	ld -m elf_i386 -N loa.o ker.o -s -Ttext 0x7c00 --oformat binary -o fd0

#fd0:loa.o ker.o
#	ld -m elf_i386 -N loa.o ker.o -s -Ttext 0x7c00 --oformat binary -o fd0
#ker.o:ker.c
#	gcc -m32 -O -c $< -o ker.o -fno-pic
#loa.o:loader.asm
#	nasm -f elf -g -F stabs $< -o loa.o

clean:
	rm *.o
