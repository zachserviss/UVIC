CC=gcc
all: SFS

SFS: 
	gcc -Wall functions.c diskinfo.c -o diskinfo
	gcc -Wall functions.c disklist.c -o disklist
	gcc -Wall functions.c diskget.c -o diskget
	gcc -Wall functions.c diskput.c -o diskput

clean:
	-rm -rf *.o *.exe