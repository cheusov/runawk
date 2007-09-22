##################################################
# defaults

# default awk program
#AWK_PROG=/usr/bin/awk
AWK_PROG=awk

# stdin filename
#STDIN_FILENAME=/dev/stdin
STDIN_FILENAME=-

# where to install
#ROOT=/usr
ROOT=/usr/local

# you should not set this here
#DESTDIR=

##################################################

CPPFLAGS=-DSTDIN_FILENAME='"${STDIN_FILENAME}"' -DAWK_PROG='"${AWK_PROG}"'
WARFLAGS=-Wall -Werror

.PHONY : all
all: runawk

runawk : runawk.c fgetln.c
	$(CC) -o runawk $(CPPFLAGS) $(CFLAGS) $(WARFLAGS) runawk.c $(LDFLAGS)

.PHONY : clean
clean:
	rm -f *.o *~ core* *.core runawk

.PHONY : install
install: runawk
	mkdir -p ${DESTDIR}${ROOT}/bin && cp runawk ${DESTDIR}${ROOT}/bin

.PHONY : uninstall
uninstall:
	rm -f ${DESTDIR}${ROOT}/bin/runawk
