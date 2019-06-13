# c1:a1.o c1.o
# 	gcc -o c1 c1.co a1.o
# c1.o:c1.c
# 	gcc -o c1.o c1.c -m32
# a1.o:a1.asm
# 	nasm -f elf a1.asm -o a1.o
all:
	nasm mbr.asm -f bin -o mbr.bin
	
	gcc -m32 -Og -c ccore.c -o ccore.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector -g
	nasm -f elf -g -F stabs  acore.asm -o acore.o
	nasm -f elf -g -F stabs  core_tail.asm -o coretail.o
#	gcc -o fd0  -m32 a.o c.o
	ld -m elf_i386 -N acore.o ccore.o coretail.o  -s -Ttext 0x80040000 --oformat binary -o core.bin --entry=_start -g

	gcc -m32 -O0 -c user0.c -o cuser0.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector -g
	nasm -f elf -g -F stabs user0.asm -o auser0.o
	ld -m elf_i386 -N auser0.o cuser0.o  -s -Ttext 0x00000000 --oformat binary -o user0.bin  --entry=cstart 

	gcc -m32 -O0 -c user1.c -o cuser1.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector -g
	nasm -f elf -g -F stabs user1.asm -o auser1.o
	ld -m elf_i386 -N auser1.o cuser1.o  -s -Ttext 0x0 --oformat binary -o user1.bin --entry=_start -g

	gcc -m32 -O0 -c user2.c -o cuser2.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector -g
	nasm -f elf -g -F stabs user2.asm -o auser2.o
	ld -m elf_i386 -N auser2.o cuser2.o  -s -Ttext 0x0 --oformat binary -o user2.bin --entry=_start -g

	gcc -m32 -O0 -c user3.c -o cuser3.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector -g
	nasm -f elf -g -F stabs user3.asm -o auser3.o
	ld -m elf_i386 -N auser3.o cuser3.o  -s -Ttext 0x0 --oformat binary -o user3.bin --entry=_start -g
user0:
	gcc -m32 -Og -c user0.c -o cuser0.o -fno-PIC -fno-builtin -nostdinc -fno-stack-protector
	nasm -f elf -g -F stabs user0.asm -o auser0.o
	ld -m elf_i386 -N auser0.o cuser0.o -s -Ttext 0x0 --oformat binary -o user0.bin --entry=_start

user1:
	nasm -f elf -g -F stabs user1.asm -o auser1.o
	ld -m elf_i386 -N auser1.o -s -Ttext 0x0 --oformat binary -o user1.bin --entry=_start

#fd0:loa.o ker.o
#	ld -m elf_i386 -N loa.o ker.o -s -Ttext 0x7c00 --oformat binary -o fd0
#ker.o:ker.c
#	gcc -m32 -O -c $< -o ker.o -fno-pic
#loa.o:loader.asm
#	nasm -f elf -g -F stabs $< -o loa.o

c17:
	nasm -f bin c17-1.asm -o user0.bin
	nasm -f bin c17-2.asm -o user1.bin
	nasm -f bin c17_mbr.asm -o mbr.bin
	nasm -f bin c17_core.asm -o core.bin


clean:
	rm *.o
