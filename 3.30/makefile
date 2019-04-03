# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
all:
#	nasm c09_2.asm -f bin -o h.img
#	nasm c08_mbr.asm -f bin -o fd0
	nasm intrk.asm -f bin -o fd0

clean:
	rm *.o
