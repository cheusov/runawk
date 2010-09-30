# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# glob2ere(PATTERN)
#   converts glob PATTERN
#   (http://www.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_13)
#   to equivalent extended regular expression
#   (http://www.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap09.html#tag_09_04)

#use "multisub.awk"

BEGIN {
	__g2e="^:\\^   $:[$]   (:[(]   ):[)]   {:[{]   }:[}]"
	__g2e=__g2e "   \\[([^\\[\\]]|\\\\\\[|\\\\\\])*\\]:&   .:[.]   *:.*   +:[+]"
	__g2e=__g2e "   ?:.   |:[|]   \\\\:\\\\"
	__g2e=__g2e "   \\^:\\^   \\$:[$]   \\(:[(]   \\):[)]   \\{:[{]   \\}:[}]"
	__g2e=__g2e "   \\[:\\[   \\]:\\]   \\.:[.]   \\*:[*]   \\+:[+]   \\?:[?]"
	__g2e=__g2e "   \\|:[|]   \\:"
}

function glob2ere (p){
	return multisub(p, __g2e, "&")
}

function glob (s, p,                 re){
	if (p in __runawk_glob2ere)
		re = __runawk_glob2ere [p]
	else
		re = __runawk_glob2ere [p] = ("^" glob2ere(p) "$")

	return s ~ re
}
