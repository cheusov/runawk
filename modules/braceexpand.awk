# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 braceexpand.awk
#
# =over 2
#
# =item I<braceexp(STRING)>
#
# shell-like brace expansion.
#
# For example:
#	print braceexpand("ab{,22{,7,8}}z{8,9}")
#   -| abz8 abz9 ab22z8 ab22z9 ab227z8 ab227z9 ab228z8 ab228z9
#
# =back
#

#use "match_br.awk"

BEGIN {
	__runawk_expanded = 0
}

function __runawk_braceexpand1 (s,

							left,mid,right,len,accu,i,ch,deep)
{
	__runawk_expanded = 0

	if (match_br(s, "{", "}")){
		left  = substr(s, 1, RSTART-1)
		mid   = substr(s, RSTART+1, RLENGTH-2) ","
		right = substr(s, RSTART+RLENGTH)

		len = RLENGTH-1

		s = ""

		accu = ""
		deep = 0
		for (i=1; i <= len; ++i){
			ch = substr(mid, i, 1)

			if (deep == 0 && ch == ","){
				if (s != ""){
					s = s " "
				}

				accu = __runawk_braceexpand1(accu)

				if (gsub(/ /, ",", accu)){
					s = s __runawk_braceexpand1(left "{" accu "}" right)
				}else{
					s = s left accu right
				}

				accu = ""
			}else{
				accu = accu ch

				if (ch == "{")
					++deep
				else if (ch == "}")
					--deep
			}
		}

		__runawk_expanded = 1
	}

	return s
}

function braceexpand (s,            arr,i,cnt,cont){
	cont = 1

	while (cont){
		cont = 0

		cnt = split(s, arr, / /)
		s = ""
		for (i=1; i <= cnt; ++i){
			if (i > 1)
				s = s " "

			s = s __runawk_braceexpand1(arr [i])
			cont = (cont || __runawk_expanded)
		}
	}

	return s
}
