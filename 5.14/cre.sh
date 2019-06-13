fil=h.img
make
cat mbr.bin > $fil # clear and cat in

cat core.bin >> $fil

len=$[50*512-$(stat -c %s "$fil")]
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil
cat user0.bin >> h.img

len=$[70*512-$(stat -c %s "$fil")] 
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil
cat user1.bin >> h.img

len=$[90*512-$(stat -c %s "$fil")] 
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil
cat user2.bin >> h.img

len=$[110*512-$(stat -c %s "$fil")] 
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil
cat user3.bin >> h.img

len=$[2*16*63*512-$(stat -c %s "$fil")]
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> $fil

#echo -n -e "\x55\xaa" >> $fil
