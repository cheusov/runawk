##################################################
# defaults

AWK_PROG=/usr/bin/awk

##################################################

.PHONY : all
all: runawk

runawk : runawk.c fgetln.c
	$(CC) -o runawk -DAWK_PROG='"${AWK_PROG}"' -Wall -O0 -g $(CFLAGS) runawk.c $(LDFLAGS)

.PHONY : clean
clean:
	rm -f *.o *~ core* *.core runawk
