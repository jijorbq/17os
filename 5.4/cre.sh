fil=h.img
make
cat cmbr.bin > $fil # clear and cat in

cat ccore.bin >> $fil
len=$[10*512-$(stat -c %s "$fil")]
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil

cat c1.bin >> h.img
# len=$[100*512-$(stat -c %s "$fil")] 
# echo len=$len
# dd if=/dev/zero count=$len bs=1 | cat>> $fil

# cat diskdata.txt >> h.img
# len=$[101*512-$(stat -c %s "$fil")]
# echo len=$len
# dd if=/dev/zero count=$len bs=1 | cat>> $fil

# cat c2.bin >> h.img
len=$[2*16*64*512-$(stat -c %s "$fil")]
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil

#echo -n -e "\x55\xaa" >> $fil
