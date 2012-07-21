##################################################

SUBPRJ       =	runawk modules examples a_getopt doc
SUBPRJ_DFLT ?=	runawk modules

WITH_ALT_GETOPT ?=	yes

.if ${WITH_ALT_GETOPT:tl} == "yes"
SUBPRJ_DFLT +=		a_getopt
.endif

MKC_REQD =		0.22.0

##################################################

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

.if !empty(OBJDIR_runawk:N/*)
OBJDIR_runawk := ${.CURDIR}/${OBJDIR_runawk}
.endif
