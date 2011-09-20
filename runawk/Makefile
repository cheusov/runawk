##################################################

# default directory for creating temp files and dirs
TEMPDIR =		/tmp

.if exists(/usr/xpg4/bin/awk)
# Solaris' /usr/bin/awk sucks so much... :-(
# /usr/xpg4/bin/awk sucks too but sucks less.
# I'd recommend you use GNU awk, nawk from NetBSD cvs tree
# or mawk-1.3.4 or later.
AWK_PROG ?=		/usr/xpg4/bin/awk
.else
AWK_PROG ?=		/usr/bin/awk
.endif

STDIN_FILENAME?=	- #/dev/stdin

##################################################

WARNS ?=	4
WARNERR ?=	no

PROG =		runawk
SRCS =		runawk.c dynarray.c

MAN =		runawk.1

CFLAGS +=	-DAWK_PROG='"${AWK_PROG}"'
CFLAGS +=	-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CFLAGS +=	-DMODULESDIR='"${MODULESDIR}:${MODULESDIR}/gawk"'
CFLAGS +=	-DRUNAWK_VERSION='"${VERSION}"'
CFLAGS +=	-DTEMPDIR='"${TEMPDIR}"'

CLEANFILES +=	*~ core* *.core ktrace* *.tmp tests/_* *.html1 *.cat1 *.1
CLEANFILES +=	ChangeLog runawk.html _test.res

##################################################

.include <mkc.prog.mk>
