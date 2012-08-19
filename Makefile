##################################################

SUBPRJ       =	runawk:test modules examples a_getopt doc
SUBPRJ_DFLT ?=	runawk modules

WITH_ALT_GETOPT ?=	yes

.if ${WITH_ALT_GETOPT:tl} == "yes"
SUBPRJ_DFLT +=		a_getopt
.endif

MKC_REQD =		0.23.0

# for making a tarball
DIST_TARGETS =	manpages

##################################################

# "cleandir" also removes temporary files of regression tests
cleandir: cleandir-test

# Avoid running test-runawk, test-modules etc.
test: all-test
	@:

# Also implement test_all
test_all: test_all-test

# We use "target "manpages" for making a distribution tarball
manpages: _manpages
	rm ${MKC_CACHEDIR}/_mkc*

.include "Makefile.inc"
.include <mkc.subprj.mk>
