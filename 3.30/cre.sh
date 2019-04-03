make
len=$[1024-$(stat -c %s "fd0")]
echo len=$len
dd if=/dev/zero count=$len bs=1 | cat>> fd0
echo -n -e "\x55\xaa" >> fd0
