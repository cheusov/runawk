##################################################

PREFIX?=		/usr/local
BINDIR?=		${PREFIX}/bin
MANDIR?=		${PREFIX}/man
MODULESDIR?=		${PREFIX}/share/runawk

# default directory for creating temp files and dirs
TEMPDIR=		/tmp

MKHTML?=		no

.if exists(/usr/xpg4/bin/awk)
# Solaris' /usr/bin/awk sucks so much... :-(
# /usr/xpg4/bin/awk sucks too but sucks less.
# I'd recommend you use GNU awk, nawk from NetBSD cvs tree
# or mawk-1.3.4 or later.
AWK_PROG?=		/usr/xpg4/bin/awk
.else
AWK_PROG?=		/usr/bin/awk
.endif

STDIN_FILENAME?=	- #/dev/stdin

POD2MAN?=		pod2man
POD2HTML?=		pod2html

INST_DIR?=		${INSTALL} -d

##################################################

VERSION=		0.20.0

#WARNS?=			4

BIRTHDATE=		2007-09-24

PROG=			runawk
SRCS=			runawk.c

MODULES!=		echo ${.CURDIR}/modules/*.awk

FILES=			${MODULES}
FILESDIR=		${MODULESDIR}

CFLAGS+=		-DAWK_PROG='"${AWK_PROG}"'
CFLAGS+=		-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CFLAGS+=		-DMODULESDIR='"${MODULESDIR}"'
CFLAGS+=		-DRUNAWK_VERSION='"${VERSION}"'
CFLAGS+=		-DTEMPDIR='"${TEMPDIR}"'

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' ${.ALLSRC} > ${.TARGET}
runawk.html : runawk.pod
	$(POD2HTML) --infile=${.ALLSRC} --outfile=${.TARGET}

CLEANFILES=   *~ core* *.core ktrace* *.tmp tests/_*
CLEANFILES+=  runawk.1 runawk.cat1 ChangeLog runawk.html 

##################################################
.PHONY: installdirs
installdirs:
	$(INST_DIR) ${DESTDIR}${BINDIR}
	$(INST_DIR) ${DESTDIR}${MODULESDIR}
.if !defined(MKMAN) || empty(MKMAN:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/man1
.if !defined(MKCATPAGES) || empty(MKCATPAGES:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/cat1
.endif
.endif

##################################################

.include "test.mk"
.include <bsd.prog.mk>
