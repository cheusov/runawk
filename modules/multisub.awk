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

function mawk_bug_test (tmp){
	tmp = "\\\\"
	gsub(/\\/, "\\\\", tmp)
	assert(tmp == "\\\\\\\\", "Do not use buggy mawk! ;-)")
}

function __runawk_multisub_prepare (repls,

					arr, i, repl_left, repl_right, re)
{
	if (!repls){
		return -1
	}else if (repls in __runawk_multisub){
		return __runawk_multisub [repls]
	}else{
		++__runawk_multisub_num

		__runawk_multisub [repls] = __runawk_multisub_num
		split(repls, arr, /   /)

		for (i in arr){
			# split into 'repl_left' and 'repl_right'
			repl_right = repl_left = arr [i]
			sub(/:.*$/, "", repl_left)
			sub(/^.*:/, "", repl_right)

			# substr to repl
			__runawk_tr_repl [__runawk_multisub_num, repl_left] = repl_right

#			print "zzz:", repl_left, repl_right
			# whole regexp
			if (re != ""){
				re = re "|"
			}

			gsub(/[?]/, "[?]", repl_left)
			gsub(/\[/, "[[]", repl_left)
			gsub(/\]/, "\\]", repl_left)
			gsub(/[{]/, "[{]", repl_left)
			gsub(/[}]/, "[}]", repl_left)
			gsub(/[|]/, "[|]", repl_left)
			gsub(/[(]/, "[(]", repl_left)
			gsub(/[)]/, "[)]", repl_left)
			gsub(/[*]/, "[*]", repl_left)
			gsub(/[+]/, "[+]", repl_left)
			gsub(/[.]/, "[.]", repl_left)
			gsub(/\^/, "[^]", repl_left)
			gsub(/[$]/, "[$]", repl_left)

			if (repl_left ~ /\\/){
				mawk_bug_test()
				gsub(/\\/, "\\\\", repl_left)
			}

			re = re "(" repl_left ")"
		}

		__runawk_tr_regexp [__runawk_multisub_num] = re

#		print "re=" re

		return __runawk_multisub_num
	}
}

function multisub (str, repls,

					n, middle) #local vars
{
	n = __runawk_multisub_prepare(repls)
	if (n < 0 || !match(str, __runawk_tr_regexp [n])){
		return str
	}else{
		middle = substr(str, RSTART, RLENGTH)

		assert((n SUBSEP middle) in __runawk_tr_repl, "E-mail bug to the author!")

		return substr(str, 1, RSTART-1)			\
		       __runawk_tr_repl [n, middle]		\
		       multisub(substr(str, RSTART+RLENGTH), repls)
	}
}

BEGIN {
	assert("ccBBde" == multisub("ABBABBBBBBAAB", "ABB:c   BBA:d   AB:e"),
		   "Email bug to the author")
}
