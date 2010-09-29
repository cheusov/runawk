# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# multisub(STRING, SUBST_REPLS[, KEEP])
#   `multisub' is a substitution function. It searches for
#   a list of substrings, specified in SUBST_REPL
#   in a left-most longest order and (if found) replaces
#   found fragments with appropriate replacement.
#   SUBST_REPL format: "SUBSTRING1:REPLACEMENT1   SUBSTRING2:REPLACEMENT2...".
#   Three spaces separate substring:replacement pairs from each other.
#   If KEEP is specified and some REPLACEMENT<N> is equal to it, then
#   appropriate SUBSTRING<N> is treated as a regular expression
#   and matched text is kept as is, i.e. not changed.
#
# For example:
#      print multisub("ABBABBBBBBAAB", "ABB:c   BBA:d   AB:e")
#      |- ccBBde
#

#use "alt_assert.awk"
#use "str2regexp.awk"

BEGIN {
	__runawk_multisub_num = -1
}

function __runawk_multisub_prepare (repls, keep,
	arr, i, repl_left, repl_right, re) # local vars
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

			# whole regexp
			if (re != ""){
				re = re "|"
			}

			# substr to repl
			if (repl_right != keep){
				__runawk_tr_repl [__runawk_multisub_num, repl_left] = repl_right
				repl_left = str2regexp(repl_left)
			}

			re = re repl_left
		}

		__runawk_tr_regexp [__runawk_multisub_num] = re

		return __runawk_multisub_num
	}
}

function multisub (str, repls, keep,
	n,middle,beg,end,ret,repl) #local vars
{
	n = __runawk_multisub_prepare(repls, keep)
	if (n < 0 || !match(str, __runawk_tr_regexp [n])){
		return str
	}else{
		middle = substr(str, RSTART, RLENGTH)
		beg    = substr(str, 1, RSTART-1)
		end    = substr(str, RSTART+RLENGTH)

		if ((n SUBSEP middle) in __runawk_tr_repl)
			ret = beg __runawk_tr_repl [n, middle] multisub(end, repls)
		else
			ret = beg middle multisub(end, repls)

		return ret
	}
}

BEGIN {
	assert("ccBBde" == multisub("ABBABBBBBBAAB", "ABB:c   BBA:d   AB:e"),
		   "Email bug to the author")
}
