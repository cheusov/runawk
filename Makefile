##################################################

# example of redefining defaults
#CPPFLAGS+=	-DSTDIN_FILENAME='"/path/to/stdin/file"'    # /dev/stdin
#CPPFLAGS+=	-DAWK_PROG='"/path/to/your/favourite/awk"'  # awk

# where to install
#PREFIX=/usr
PREFIX=/usr/local
BINDIR=${PREFIX}/bin
DATADIR=${PREFIX}/share/runawk

# you should not set this here
#DESTDIR=

# BSD install
INSTALL_PROGRAM=	install -s -m 0755
INSTALL_DIR=		install -d -m 0755
INSTALL_DATA=		install -m 0644
INSTALL_MAN=		$(INSTALL_DATA)

POD2MAN=		pod2man

##################################################

WARFLAGS=		-Wall -Werror

MODULES=		alt_assert.awk

.PHONY : all
all: runawk runawk.1

runawk : runawk.c fgetln.c
	$(CC) -o runawk $(CPPFLAGS) $(CFLAGS) $(WARFLAGS) runawk.c $(LDFLAGS)

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' runawk.pod > $@

.PHONY : clean
clean:
	rm -f *.o *~ core* *.core runawk

.PHONY : install
install: runawk
	${INSTALL_DIR} ${DESTDIR}${BINDIR} && \
	${INSTALL_PROGRAM} runawk ${DESTDIR}${BINDIR} && \
	${INSTALL_DIR} ${DESTDIR}${DATADIR} && \
	for m in ${MODULES}; do \
	   ${INSTALL_DATA} modules/$${m} ${DESTDIR}${DATADIR}; \
	done

.PHONY : uninstall
uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/runawk
	for m in ${MODULES}; do \
	   rm -f ${DESTDIR}${DATADIR}/$${m}; \
	done

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
