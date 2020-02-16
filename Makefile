all: clean pidman

pidman:
	gcc -c -o ./pidman.o ./pidman.c
	crystal build ./pidman.cr --release --static -o pidman

clean:
	-rm ./pidman
	-rm ./pidman.o
