CC=gcc
CFLAGS=-m32 -Wno-unused-result `pkg-config glib-2.0 --cflags`
LDFLAGS=-m32 -s -Wl,--gc-sections -lglib-2.0
OBJFILES=print.o parser.o stats.o aggregator.o

all: aggregator

debug: CFLAGS=-m32 -g -DDEBUG `pkg-config glib-2.0 --cflags`
debug: LDFLAGS=-m32 -g -DDEBUG -lglib-2.0
debug: all

aggregator: $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o aggregator

clean:
	rm -f *.o aggregator