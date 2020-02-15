all: clean pidman

pidman:
	gcc -c -o ./pidman.o ./pidman.c
	crystal build ./pidman.cr

clean:
	-rm ./pidman
	-rm ./pidman.o
