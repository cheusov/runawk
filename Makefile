##################################################

SUBPRJ =	runawk modules examples a_getopt doc
SUBPRJ_DFLT ?=	runawk modules

WITH_ALT_GETOPT?=	yes

.if ${WITH_ALT_GETOPT:tl} == "yes"
SUBPRJ_DFLT +=		a_getopt
.endif

MKC_REQD=		0.21.0

##################################################
.if defined(MAKEOBJDIRPREFIX)
OBJDIR_runawk=${MAKEOBJDIRPREFIX/runawk}
.elif defined(MAKEOBJDIR)
OBJDIR_runawk=${MAKEOBJDIR}
.else
OBJDIR_runawk=${.CURDIR}/runawk
.endif

.PHONY: manpages
manpages:
	set -e; \
	MKC_CACHEDIR=`pwd`; export MKC_CACHEDIR; \
	cd runawk; ${MAKE} runawk.1; cd ..; \
	cd a_getopt; ${MAKE} alt_getopt.1; cd ..; \
	rm -f _mkc_*

.include "test.mk"
.include "Makefile.inc"
.include <mkc.subprj.mk>
