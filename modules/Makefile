MODULES       =	CR_in.awk abort.awk abs.awk alt_assert.awk \
   alt_getopt.awk alt_join.awk backslash_in.awk basename.awk \
   braceexpand.awk dirname.awk embed_str.awk exitnow.awk \
   fieldwidths.awk ftrans_in.awk glob.awk has_prefix.awk \
   has_suffix.awk heapsort.awk ini.awk init_getopt.awk \
   io.awk isnum.awk match_br.awk max.awk min.awk modinfo.awk \
   multisub.awk pow.awk power_getopt.awk quicksort.awk readfile.awk \
   runcmd.awk shquote.awk sort.awk str2regexp.awk tmpfile.awk \
   tokenre.awk trim.awk trim_in.awk tsv.awk xclose.awk \
   xgetline.awk xsystem.awk gawk/ord.awk

FILES         =	${MODULES}
FILESDIR      =	${MODULESDIR}
FILESNAME_gawk/ord.awk =gawk/ord.awk

MAN           =	runawk_modules.3

.PHONY: _manpages
_manpages: ${MAN}

.PATH:			${.OBJDIR}

CLEANFILES   +=	runawk_modules.3 runawk_modules.pod

runawk_modules.pod: ${MODULES} pod_header.txt pod_footer.txt
	{ set -e; cd ${.CURDIR}; \
	cat pod_header.txt; \
	awk '/^# =head/, NF==0 {if (/^#/) print substr($$0, 3)}' \
		${MODULES}; \
	cat pod_footer.txt; } > ${.TARGET}

CLEANFILES +=	runawk_modules.pod

.include <mkc.files.mk>
