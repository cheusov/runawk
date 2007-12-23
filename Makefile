##################################################

PREFIX?=/usr/local
BINDIR?=${PREFIX}/bin
MANDIR?=${PREFIX}/man
MODULESDIR?=${PREFIX}/share/runawk

AWK_PROG?=		/usr/bin/awk
STDIN_FILENAME?=	/dev/stdin

POD2MAN?=		pod2man
POD2HTML?=		pod2html

INSTALL_MODULE?=	${INSTALL} -o ${BINOWN} -g ${BINGRP} -m ${NONBINMODE}

##################################################

PROG=			runawk
SRCS=			runawk.c

##################################################

CPPFLAGS+=		-DAWK_PROG='"${AWK_PROG}"'
CPPFLAGS+=		-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CPPFLAGS+=		-DMODULESDIR='"${MODULESDIR}"'

MODULES=		alt_assert.awk abs.awk min.awk max.awk

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' runawk.pod > $@
runawk.html : runawk.pod
	$(POD2HTML) --infile=runawk.pod --outfile=$@

.PHONY: clean-my
clean: clean-my
clean-my:
	rm -f *~ core* runawk.1 runawk.cat1 ktrace* ChangeLog *.tmp
	rm -f runawk.html tests/_*

.PHONY: install-modules
install: install-modules
install-modules:
	${INSTALL_DIR} ${DESTDIR}${MODULESDIR}; \
	for m in ${MODULES}; do \
	   ${INSTALL_MODULE} modules/$${m} ${DESTDIR}${MODULESDIR}/$${m}; \
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
	$(MAKE) runawk.1 && \
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

.PHONY : test
test : runawk
	set -e; cd tests; \
	./test.sh > _test.res; \
	diff -u test.out _test.res

.include <bsd.prog.mk>
