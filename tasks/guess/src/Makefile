CC=gcc
CFLAGS=-m32 -Wno-unused-result
LDFLAGS=-m32 -s -Wl,--gc-sections
OBJFILES=print.o guess.o

all: guess

debug: CFLAGS=-m32 -g -DDEBUG
debug: LDFLAGS=-m32 -g -DDEBUG
debug: all

guess: $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o guess

clean:
	rm -f *.o guess