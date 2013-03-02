MODULES !=			cd ${.CURDIR}; echo *.awk gawk/*.awk

FILES =				${MODULES}
FILESDIR =			${MODULESDIR}
FILESNAME_gawk/ord.awk =	gawk/ord.awk

MAN =				runawk_modules.3

.PHONY: _manpages
_manpages: ${MAN}

.PATH:				${.OBJDIR}

CLEANFILES += runawk_modules.3 runawk_modules.pod

runawk_modules.pod: ${MODULES} pod_header.txt pod_footer.txt
	set -e; cd ${.CURDIR}; \
	cat pod_header.txt > ${.TARGET}; \
	awk '/^# =head/, NF==0 {if (/^#/) print substr($$0, 3)}' \
		${MODULES} >> ${.TARGET}; \
	cat pod_footer.txt >> ${.TARGET}

.include <mkc.files.mk>
