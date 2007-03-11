##################################################
# defaults

# default awk program
AWK_PROG=awk
# stdin filename
STDIN_FILENAME=/dev/stdin

##################################################

CPPFLAGS=-DSTDIN_FILENAME='"${STDIN_FILENAME}"' -DAWK_PROG='"${AWK_PROG}"'
WARFLAGS=-Wall -Werror

.PHONY : all
all: runawk

runawk : runawk.c fgetln.c
	$(CC) -o runawk -O $(CPPFLAGS) $(CFLAGS) $(WARFLAGS) runawk.c $(LDFLAGS)

.PHONY : clean
clean:
	rm -f *.o *~ core* *.core runawk
