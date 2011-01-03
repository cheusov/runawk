##################################################

SUBPRJ =	runawk modules a_getopt doc
SUBPRJ_DFLT ?=	runawk modules

WITH_ALT_GETOPT?=	yes

.if ${WITH_ALT_GETOPT:tl} == "yes"
SUBPRJ_DFLT +=		a_getopt
.endif

MKC_REQD=		0.20.0

##################################################
.if defined(MAKEOBJDIRPREFIX)
OBJDIR_runawk=${MAKEOBJDIRPREFIX/runawk}
.elif defined(MAKEOBJDIR)
OBJDIR_runawk=${MAKEOBJDIR}
.else
OBJDIR_runawk=${.CURDIR}/runawk
.endif

.include "test.mk"
.include "Makefile.inc"
.include <mkc.subprj.mk>
