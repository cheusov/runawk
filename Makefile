.PHONY : all
all: runawk

runawk : runawk.c fgetln.c
	$(CC) -o runawk -Wall -O0 -g $(CFLAGS) runawk.c $(LDFLAGS)

.PHONY : clean
clean:
	rm -f *.o *~ core* *.core runawk
