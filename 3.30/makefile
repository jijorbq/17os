# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
all:
	nasm -f bin c17_mbr.asm -o cmbr.bin
	nasm -f bin c17_core.asm -o ccore.bin
	nasm -f bin c17-1.asm -o c1.bin
	nasm -f bin c17-2.asm -o c2.bin

clean:
	rm *.bin
