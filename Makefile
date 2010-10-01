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

VERSION=		1.0.0

#WARNS?=			4

BIRTHDATE=		2007-09-24

PROG=			runawk
SRCS=			runawk.c

MAN=			runawk.1

MKCATPAGES?=		no

MODULES!=		echo modules/*.awk modules/gawk/*.awk

FILES=			${MODULES}
FILESDIR=		${MODULESDIR}
FILESNAME_modules/gawk/ord.awk=	gawk/ord.awk

CFLAGS+=		-DAWK_PROG='"${AWK_PROG}"'
CFLAGS+=		-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CFLAGS+=		-DMODULESDIR='"${MODULESDIR}"'
CFLAGS+=		-DRUNAWK_VERSION='"${VERSION}"'
CFLAGS+=		-DTEMPDIR='"${TEMPDIR}"'

WITH_ALT_GETOPT?=	yes
.if ${WITH_ALT_GETOPT} == "yes"
SCRIPTS+=			alt_getopt
MAN+=				alt_getopt.1
FILES+=				alt_getopt_sh
FILESDIR_alt_getopt_sh=		${BINDIR}
FILESNAME_alt_getopt_sh=	alt_getopt.sh
CLEANFILES+=			alt_getopt.sh
.endif

all: alt_getopt.sh
alt_getopt.sh: alt_getopt_sh
	ln -f alt_getopt_sh alt_getopt.sh

runawk.1 : runawk.pod
	$(POD2MAN) -s 1 -r 'AWK Wrapper' -n runawk \
	   -c 'RUNAWK manual page' ${.ALLSRC} > ${.TARGET}
alt_getopt.1 : alt_getopt.pod
	$(POD2MAN) -s 1 -r '' -n alt_getopt \
	   -c 'ALT_GETOPT manual page' ${.ALLSRC} > ${.TARGET}

pod2html_rule: .USE
	$(POD2HTML) --infile=${.ALLSRC} --outfile=${.TARGET}
runawk.html alt_getopt.html : pod2html_rule

CLEANFILES+=   *~ core* *.core ktrace* *.tmp tests/_* *.html1 *.cat1 *.1
CLEANFILES+=  ChangeLog runawk.html 

REALOWN!=	id -un
REALGRP!=	id -gn
BINOWN?=	${REALOWN}
BINGRP?=	${REALGRP}
MANOWN?=	${BINOWN}
MANGRP?=	${BINGRP}

##################################################
.PHONY: installdirs
installdirs:
	$(INST_DIR) ${DESTDIR}${BINDIR}
	$(INST_DIR) ${DESTDIR}${MODULESDIR} ${DESTDIR}${MODULESDIR}/gawk
.if !defined(MKMAN) || empty(MKMAN:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/man1
.if !defined(MKCATPAGES) || empty(MKCATPAGES:M[Nn][Oo])
	$(INST_DIR) ${DESTDIR}${MANDIR}/cat1
.endif
.endif

##################################################

.include "test.mk"
.include <bsd.prog.mk>
