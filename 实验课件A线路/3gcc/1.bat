nasm -f elf32 afile.asm -o afile.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c cfile.c -o cfile.o 
ld.exe -m i386pe -N afile.o cfile.o -Ttext 0x7c00 -o os.tmp
objcopy -O binary os_ex3.tmp os.bin