# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# str2regex(STRING)
#   returns a regular expression that matches given STRING
#  
# For example:
#   print str2regexp("all special symbols: ^$(){}[].*+?|\\")
#   -| all special symbols: [^][$][(][)][{][}][[]\][.][*][+][?][|]\\
#

#use "alt_assert.awk"

function __runawk_mawk_bug_test (tmp){
	# returns true if buggy MAWK
	tmp = "\\\\"
	gsub(/\\/, "\\\\", tmp)
	return (tmp != "\\\\\\\\")
}

BEGIN {
	__buggy_mawk = __runawk_mawk_bug_test()
}

function str2regexp (s){
	gsub(/\[/, "---runawk-open-sq-bracket---", s)
	gsub(/\]/, "---runawk-close-sq-bracket---", s)

	gsub(/[?{}|()*+.$]/, "[&]", s)
	gsub(/\^/, "[\\^]", s)

	if (s ~ /\\/){
		if (!__buggy_mawk){
			# normal AWK
			gsub(/\\/, "\\\\", s)
		}else{
			# MAWK /-(
			gsub(/\\/, "\\\\\\\\\\", s)
		}
	}

	gsub(/---runawk-open-sq-bracket---/, "[[]", s)
	gsub(/---runawk-close-sq-bracket---/, "\\]", s)

	return s
}
