
all: objc_code

objc_code:
	flex -i objc.lex 
	gcc -g lex.yy.c -o run.objc scan_objc_dir/scan.o -lfl -L/usr/local/opt/flex/lib

help:
	echo make clean
	echo make objc_code
	echo ./run.objc > html.html 

clean:
	rm run.objc
	rm lex.yy.c

