# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# As the name of this module says (_in suffix) this module reads and
# potentially changes input lines.
# 
# Leading, ending spaces and/or spaces in the middle of input lines
# are removed depending on TRIM variable.
# TRIM values:
#   "l" - remove leading space characters
#   "r" - remove ending space characters
#   "c" - remove extra space characters in the middle of input lines
#   "lr" - See l and r
#   "lrc" - See l, r and c
#   "lc" - See l and c
#   "cr" - See c and r
# By default TRIM variable is set to "lr". TRIM set to a single space
# character means no trimming.

BEGIN {
	if (TRIM == ""){
		TRIM = "lr"
	}
}

{
	if (index(TRIM, "c") > 0)
		gsub(/[ \t][ \t]+/, " ")
	if (index(TRIM, "l") > 0)
		sub(/^[ \t]+/, "")
	if (index(TRIM, "r") > 0)
		sub(/[ \t]+$/, "")
}
