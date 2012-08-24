##################################################

# default directory for creating temp files and dirs
TEMPDIR =		/tmp

.if !defined(AWK_PROG)
.if exists(/usr/xpg4/bin/awk)
# Solaris' /usr/bin/awk sucks so much... :-(
# /usr/xpg4/bin/awk sucks too but sucks less.
# I'd recommend you use GNU awk, nawk from NetBSD cvs tree
# or mawk-1.3.4 or later.
AWK_PROG           =	/usr/xpg4/bin/awk
.else
MKC_REQUIRE_PROGS +=	awk
AWK_PROG           =	${PROG.awk}
.endif
.endif # !defined(AWK_PROG)

STDIN_FILENAME?=	- #/dev/stdin

##################################################

WARNS ?=	4
WARNERR ?=	no

PROG =		runawk
SRCS =		runawk.c dynarray.c file_hier.c

MAN =		runawk.1

MKC_COMMON_HEADERS  = string.h
MKC_SOURCE_FUNCLIBS = strlcat strlcpy
MKC_CHECK_FUNCS3    = strlcat strlcpy

CFLAGS +=	-DAWK_PROG='"${AWK_PROG}"'
CFLAGS +=	-DSTDIN_FILENAME='"${STDIN_FILENAME}"'
CFLAGS +=	-DMODULESDIR='"${MODULESDIR}:${MODULESDIR}/gawk"'
CFLAGS +=	-DRUNAWK_VERSION='"${VERSION}"'
CFLAGS +=	-DTEMPDIR='"${TEMPDIR}"'

CLEANFILES +=	*~ core* *.core ktrace* *.tmp tests/_* *.html1 *.cat1 *.1
CLEANFILES +=	ChangeLog runawk.html _test.res

.PHONY: _manpages
_manpages: ${MAN}

##################################################

.include <mkc.prog.mk>
