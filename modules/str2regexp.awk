# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# str2regex(STRING)
#   returns a regular expression that matches given STRING
#  
# For example:
#   print str2regexp("all special symbols: ^$(){}[].*+?|\\")
#   -| all special symbols: [^][$][(][)][{][}][[]\][.][*][+][?][|]\\
#

#use "alt_assert.awk"

function __runawk_mawk_bug_test (tmp){
	tmp = "\\\\"
	gsub(/\\/, "\\\\", tmp)
	assert(tmp == "\\\\\\\\", "Do not use buggy mawk! ;-)")
}

function str2regexp (s){
	gsub(/\[/, "---runawk-open-sq-bracket---", s)
	gsub(/\]/, "---runawk-close-sq-bracket---", s)

	gsub(/[?]/, "[?]", s)
	gsub(/[{]/, "[{]", s)
	gsub(/[}]/, "[}]", s)
	gsub(/[|]/, "[|]", s)
	gsub(/[(]/, "[(]", s)
	gsub(/[)]/, "[)]", s)
	gsub(/[*]/, "[*]", s)
	gsub(/[+]/, "[+]", s)
	gsub(/[.]/, "[.]", s)
	gsub(/\^/, "[\\^]", s)
	gsub(/[$]/, "[$]", s)

	if (s ~ /\\/){
		__runawk_mawk_bug_test()
		gsub(/\\/, "\\\\", s)
	}

	gsub(/---runawk-open-sq-bracket---/, "[[]", s)
	gsub(/---runawk-close-sq-bracket---/, "\\]", s)

	return s
}
