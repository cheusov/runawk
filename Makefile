##################################################

# example of redefining defaults
#CPPFLAGS+=	-DSTDIN_FILENAME='"/path/to/stdin/file"'    # /dev/stdin
#CPPFLAGS+=	-DAWK_PROG='"/path/to/your/favourite/awk"'  # awk

PREFIX?=/usr/local
BINDIR?=${PREFIX}/bin
MANDIR?=${PREFIX}/man
DATADIR?=${PREFIX}/share/runawk

PROG=			runawk
SRCS=			runawk.c

POD2MAN?=		pod2man

INSTALL_MODULE?=	${INSTALL_FILE} -o ${BINOWN} -g ${BINGRP} -m ${NONBINMODE}

##################################################

MODULES=		alt_assert.awk

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' runawk.pod > $@

.PHONY: clean-my
clean: clean-my
clean-my:
	rm -f *~ core* runawk.1

.PHONY: install-modules
install: install-modules
install-modules:
	${INSTALL_DIR} ${DESTDIR}${DATADIR}; \
	for m in ${MODULES}; do \
	   ${INSTALL_MODULE} modules/$${m} ${DESTDIR}${DATADIR}; \
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

.include <bsd.prog.mk>
