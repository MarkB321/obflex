
scan: scan.c
	gcc -c scan.c

test: test.o scan.o
	gcc -c test.c
	gcc -o test test.o scan.o -I.

