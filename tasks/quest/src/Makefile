CC=gcc
CFLAGS=-m32 -Wno-unused-result
LDFLAGS=-m32 -s -Wl,--gc-sections
OBJFILES=libtelnet.o logging.o level.o player.o quest.o

all: quest lock

debug: CFLAGS=-m32 -g -DDEBUG
debug: LDFLAGS=-m32 -g -DDEBUG
debug: all

quest: $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o quest

lock: lock.o
	$(CC) $(LDFLAGS) lock.o -o lock

clean:
	rm -f *.o quest lock