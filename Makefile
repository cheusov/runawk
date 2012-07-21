##################################################

SUBPRJ       =	runawk modules examples a_getopt doc
SUBPRJ_DFLT ?=	runawk modules

WITH_ALT_GETOPT ?=	yes

.if ${WITH_ALT_GETOPT:tl} == "yes"
SUBPRJ_DFLT +=		a_getopt
.endif

MKC_REQD =		0.22.0

##################################################

manpages: _manpages
	rm ${MKC_CACHEDIR}/_mkc*

.include "test.mk"
.include "Makefile.inc"
.include <mkc.subprj.mk>

.if !empty(OBJDIR_runawk:N/*)
OBJDIR_runawk := ${.CURDIR}/${OBJDIR_runawk}
.endif
