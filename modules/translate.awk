#
# $0 = translate($0, "\\t:\t   \\r:\r   \\\\:\\")
#

BEGIN {
	__runawk_tr_num = -1
}

function __runawk_tr_prepare (rules,

					arr, i, repl_left, repl_right, re)
{
	if (rules in rules2num){
		return rules2num [rules]
	}else{
		++__runawk_tr_num

		rules2num [rules] = __runawk_tr_num
		split(rules, arr, /   /)

		for (i in arr){
			# split into 'repl_left' and 'repl_right'
			repl_right = repl_left = arr [i]
			sub(/:.*$/, "", repl_left)
			sub(/^.*:/, "", repl_right)

			# substr to repl
			__runawk_tr_repl [__runawk_tr_num, repl_left] = repl_right

			print "zzz:", repl_left, repl_right
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
			gsub(/\\/, "\\\\", repl_left)

			re = re "(" repl_left ")"
		}

		__runawk_tr_regexp [__runawk_tr_num] = re

		print "re=" re

		return __runawk_tr_num
	}
}

function translate (str, rules,

					n) #local vars
{
	n = __runawk_tr_prepare(rules)
	if (!match(str, __runawk_tr_regexp [n])){
		return str
	}else{
		print "RSTART=" RSTART
		print "RLENGTH=" RLENGTH
		print substr(str, 1, RSTART-1)
		print substr(str, RSTART, RLENGTH)
		print substr(str, RSTART+RLENGTH)
		print ""

		return substr(str, 1, RSTART-1) \
		       __runawk_tr_repl [n, substr(str, RSTART, RLENGTH)]		\
		       translate(substr(str, RSTART+RLENGTH), rules)
	}
}

{
	print "trtrtr=" translate($0, "..:<TREEDOTS>   \\t:<TAB>   \\r:<CR>   \\\\:<BACKSLASH>   .:<DOT>")
}
