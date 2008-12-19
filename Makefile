##################################################

PREFIX?=/usr/local
BINDIR?=${PREFIX}/bin
MANDIR?=${PREFIX}/man
MODULESDIR?=${PREFIX}/share/runawk

AWK_PROG?=		/usr/bin/awk
STDIN_FILENAME?=	- #/dev/stdin

POD2MAN?=		pod2man
POD2HTML?=		pod2html

INST_DIR?=		${INSTALL} -d

# directory with runawk sources
SRCROOT?=		${.PARSEDIR}

##################################################

VERSION=		0.14.3

WARNS?=			4

BIRTHDATE=		2007-09-24

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
.if !defined(MKMAN) || empty(MKMAN:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/man1
.if !defined(MKCATPAGES) || empty(MKCATPAGES:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/cat1
.endif
.endif

##################################################

.PHONY : test
test : runawk
	@echo 'running tests...'; \
	if cd tests && ./test.sh > _test.res && diff -u test.out _test.res; \
	then echo '   succeeded'; \
	else echo '   failed'; false; \
	fi

# test using all available awk version except mawk which
# is definitely buggy, oawk is also NOT supported

AWK_PROGS=/usr/bin/awk /usr/bin/nawk /usr/bin/gawk /usr/bin/original-awk \
   /usr/pkg/bin/nawk /usr/pkg/bin/gawk /usr/pkg/bin/nbawk \
   /usr/pkg/heirloom/bin/posix/awk /usr/pkg/heirloom/bin/posix2001/awk
#   /usr/pkg/heirloom/bin/nawk
#   /usr/bin/mawk /usr/pkg/bin/mawk /usr/pkg/bin/mawk-uxre

.PHOMY: test_all
test_all:
.for awk in ${AWK_PROGS}
	@if test -x ${awk}; then \
		echo testing ${awk}; \
		export RUNAWK_AWKPROG=${awk}; ${MAKE} test; \
		echo ''; \
	fi
.endfor

##################################################
.PATH : ${SRCROOT}

.include <bsd.prog.mk>
