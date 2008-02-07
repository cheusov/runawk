# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# multisub(STRING, SUBST_REPLS)
#   `multisub' is a substitution function. It searches for
#   a list of substrings, specified in SUBST_REPL
#   in a left-most longest order and (if found) replaces
#   found fragments with appropriate replacement.
#   SUBST_REPL format: "SUBSTRING1:REPLACEMENT1   SUBSTRING2:REPLACEMENT2..."
#  
# For example:
#      print multisub("ABBABBBBBBAAB", "ABB:c   BBA:d   AB:e")
#      |- ccBBde
#

#use "alt_assert.awk"

BEGIN {
	__runawk_multisub_num     = -1
}

function __runawk_multisub_prepare (rules,

					arr, i, repl_left, repl_right, re)
{
	if (rules in __runawk_multisub){
		return __runawk_multisub [rules]
	}else{
		++__runawk_multisub_num

		__runawk_multisub [rules] = __runawk_multisub_num
		split(rules, arr, /   /)

		for (i in arr){
			# split into 'repl_left' and 'repl_right'
			repl_right = repl_left = arr [i]
			sub(/:.*$/, "", repl_left)
			sub(/^.*:/, "", repl_right)

			# substr to repl
			__runawk_tr_repl [__runawk_multisub_num, repl_left] = repl_right

#			print "zzz:", repl_left, repl_right
			# whole regexp
			if (re != "")
				re = re "|"

			gsub(/[?]/, "[?]", repl_left)
			gsub(/\[/, "\\[", repl_left)
			gsub(/\]/, "\\]", repl_left)
			gsub(/[{]/, "[{]", repl_left)
			gsub(/[}]/, "[}]", repl_left)
			gsub(/[|]/, "[|]", repl_left)
			gsub(/[(]/, "[(]", repl_left)
			gsub(/[)]/, "[)]", repl_left)
			gsub(/[*]/, "[*]", repl_left)
			gsub(/[.]/, "[.]", repl_left)
			gsub("\\\\", "\\\\", repl_left)

			re = re "(" repl_left ")"
		}

		__runawk_tr_regexp [__runawk_multisub_num] = re

#		print "re=" re

		return __runawk_multisub_num
	}
}

function multisub (str, rules,

					n, middle) #local vars
{
	n = __runawk_multisub_prepare(rules)
	if (!match(str, __runawk_tr_regexp [n])){
		return str
	}else{
		middle = substr(str, RSTART, RLENGTH)

		assert((n SUBSEP middle) in __runawk_tr_repl, "E-mail bug to the author")

		return substr(str, 1, RSTART-1)									\
		       __runawk_tr_repl [n, middle]		\
		       multisub(substr(str, RSTART+RLENGTH), rules)
	}
}
