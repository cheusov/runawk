VERSION =	1.4.1

BIRTHDATE =	2007-09-24

EGDIR ?=	${DATADIR}/doc/runawk/examples
MODULESDIR ?=	${DATADIR}/runawk
DOCDIR ?=	${DATADIR}/doc/runawk

# We use _manpages for making a distribution tarball
TARGETS += _manpages test_all
