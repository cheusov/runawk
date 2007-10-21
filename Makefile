##################################################

# example of redefining defaults
#CPPFLAGS+=	-DSTDIN_FILENAME='"/path/to/stdin/file"'    # /dev/stdin
#CPPFLAGS+=	-DAWK_PROG='"/path/to/your/favourite/awk"'  # awk

# where to install
#PREFIX=/usr
PREFIX=/usr/local

# you should not set this here
#DESTDIR=

# BSD install
INSTALL=install -s -m 0755

##################################################

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
	mkdir -p ${DESTDIR}${PREFIX}/bin && ${INSTALL} runawk ${DESTDIR}${PREFIX}/bin

.PHONY : uninstall
uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/runawk

.PHONY : cvsdist
cvsdist:
	@( CVSROOT=`cat CVS/Root` && \
	export CVSROOT && \
	VERSION="`grep 'runawk_version = ' runawk.c | \
	   sed 's/^.*\"\\(.*\\)\".*/\\1/'`" && \
	VERSION_CVS=`echo $${VERSION} | tr . -` && \
	export VERSION VERSION_CVS && \
	$(MAKE) ChangeLog && \
	cp ChangeLog /tmp/runawk.ChangeLog.$${VERSION} && \
	echo "***** Exporting files for runawk-$${VERSION}..." && \
	cd /tmp && \
	rm -rf /tmp/runawk-$${VERSION} && \
	cvs export -fd runawk-$${VERSION} -r runawk-$${VERSION_CVS} runawk && \
	cd runawk-$${VERSION} && \
	mv /tmp/runawk.ChangeLog.$${VERSION} ChangeLog && \
	chmod -R a+rX,g-w . && \
	cd .. && \
	echo "***** Taring and zipping runawk-$${VERSION}.tar.gz..." && \
	tar cvvf runawk-$${VERSION}.tar runawk-$${VERSION} && \
	gzip -9f runawk-$${VERSION}.tar && \
	echo "***** Done making /tmp/runawk-$${VERSION}.tar.gz")

.PHONY: ChangeLog
ChangeLog:
	@(echo "***** Making new ChangeLog..."; \
	rm -f ChangeLog; \
	AWK=gawk rcs2log -i 2 -r -d'2007-09-24<' . \
	| sed -e 's,/cvsroot/runawk/,,g' \
	      -e 's,cheusov@[^>]*,vle@gmx.net,g' \
	      -e 's,author  <[^>]*,Aleksey Cheusov <vle@gmx.net,g' \
              -e 's,\(.*\)<\([^@<>]\+\)@\([^@<>]\+\)>\(.*\),\1<\2 at \3}\4,g' \
	> ChangeLog;)
