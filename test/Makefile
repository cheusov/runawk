DIFF_PROG?=	diff -u

.PHONY : test
all: test
test :
	@echo 'running tests...'; \
	export OBJDIR=${OBJDIR_runawk} SRCDIR=${.CURDIR}/.. AWKPATH=${.CURDIR}/../modules; \
	if { ${.CURDIR}/test.sh > ${.OBJDIR}/_test.res; \
	    ${DIFF_PROG} ${.CURDIR}/test.out ${.OBJDIR}/_test.res; };\
	then echo '   succeeded'; \
	else echo '   failed'; false; \
	fi

# test using all available awk version except mawk which
# is definitely buggy, oawk is also NOT supported

AWK_PROGS=/usr/bin/awk /usr/bin/nawk /usr/bin/gawk /usr/bin/original-awk \
   /usr/pkg/bin/nawk /usr/pkg/bin/gawk /usr/pkg/bin/nbawk #\
#   /usr/pkg/heirloom/bin/posix/awk /usr/pkg/heirloom/bin/posix2001/awk
#   /usr/pkg/heirloom/bin/nawk
#   /usr/bin/mawk /usr/pkg/bin/mawk /usr/pkg/bin/mawk-uxre

.PHONY: test_all
test_all:
.for awk in ${AWK_PROGS}
	@if test -x ${awk}; then \
		echo testing ${awk}; \
		export RUNAWK_AWKPROG=${awk}; cd ${.CURDIR} && ${MAKE} test; \
		echo ''; \
	fi
.endfor

CLEANFILES += ${OBJDIR_runawk}/temp1.awk ${OBJDIR_runawk}/temp2.awk ${OBJDIR_runawk}/temp3.awk
DISTCLEANFILES += _test.res

.include <mkc.files.mk>
