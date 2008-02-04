##################################################

PREFIX?=/usr/local
BINDIR?=${PREFIX}/bin
MANDIR?=${PREFIX}/man
MODULESDIR?=${PREFIX}/share/runawk

AWK_PROG?=		/usr/bin/awk
STDIN_FILENAME?=	/dev/stdin

POD2MAN?=		pod2man
POD2HTML?=		pod2html

INST_DIR?=		${INSTALL} -d

# directory with runawk sources
SRCROOT?=		${.PARSEDIR}

##################################################

VERSION=		0.10.test

PROG=			runawk
SRCS=			runawk.c

MODULES!=		echo ${SRCROOT}/modules/*.awk

FILES=			${MODULES}
FILESDIR=		${MODULESDIR}

CPPFLAGS+=		-DAWK_PROG='"${AWK_PROG}"'
CPPFLAGS+=		-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CPPFLAGS+=		-DMODULESDIR='"${MODULESDIR}"'
CPPFLAGS+=		-DRUNAWK_VERSION='"${VERSION}"'

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' ${.ALLSRC} > ${.TARGET}
runawk.html : runawk.pod
	$(POD2HTML) --infile=${.ALLSRC} --outfile=${.TARGET}

.PHONY: clean-my
clean: clean-my
clean-my:
	rm -f *~ core* runawk.1 runawk.cat1 ktrace* ChangeLog *.tmp
	rm -f runawk.html tests/_*

##################################################
.PHONY: install-dirs
install-dirs:
	$(INST_DIR) ${DESTDIR}${BINDIR}
	$(INST_DIR) ${DESTDIR}${MODULESDIR}
.if "$(MKMAN)" != "no"
	$(INST_DIR) ${DESTDIR}${MANDIR}/man1
.if "$(MKCATPAGES)" != "no"
	$(INST_DIR) ${DESTDIR}${MANDIR}/cat1
.endif
.endif

##################################################

.PHONY : test
test : runawk
	echo 'running tests...'; \
	if cd tests && ./test.sh > _test.res && diff -u test.out _test.res; \
	then echo '   succeeded'; \
	else echo '   failed'; \
	fi

##################################################
.PATH : ${SRCROOT}

.sinclude "Makefile.cvsdist"

.include <bsd.prog.mk>
