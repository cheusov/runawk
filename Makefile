##################################################

MODULESDIR?=		${PREFIX}/share/runawk

# default directory for creating temp files and dirs
TEMPDIR=		/tmp

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

##################################################

VERSION=		1.1.0

WARNS?=			4
WARNERR?=		no

BIRTHDATE=		2007-09-24

PROG=			runawk
SRCS=			runawk.c

MAN=			runawk.1

MODULES!=		cd ${.CURDIR}; echo modules/*.awk modules/gawk/*.awk

FILES=			${MODULES}
FILESDIR=		${MODULESDIR}
FILESNAME_modules/gawk/ord.awk=	gawk/ord.awk
FILESNAME_ord.awk=	gawk/ord.awk # for FreeBSD mk files

CFLAGS+=		-DAWK_PROG='"${AWK_PROG}"'
CFLAGS+=		-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CFLAGS+=		-DMODULESDIR='"${MODULESDIR}:${MODULESDIR}/gawk"'
CFLAGS+=		-DRUNAWK_VERSION='"${VERSION}"'
CFLAGS+=		-DTEMPDIR='"${TEMPDIR}"'

WITH_ALT_GETOPT?=	yes
.if ${WITH_ALT_GETOPT} == "yes"
SCRIPTS+=			alt_getopt
MAN+=				alt_getopt.1
FILES+=				sh/alt_getopt.sh
FILESDIR_sh/alt_getopt.sh=	${BINDIR}
.endif

CLEANFILES+=   *~ core* *.core ktrace* *.tmp tests/_* *.html1 *.cat1 *.1
CLEANFILES+=  ChangeLog runawk.html _test.res

##################################################

.include "test.mk"
.include <mkc.prog.mk>
