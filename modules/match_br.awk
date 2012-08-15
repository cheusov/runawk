# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 match_br.awk
#
# =over 2
#
# =item match_br(STRING, BR_OPEN, BR_CLOSE)
#
# return start position (or zero if failure) of the substring
# surrounded by balanced (), [], {} or similar characters
# Also sets RSTART and RLENGTH variables just like
# the standard 'match' function does
#  
# For example:
#   print match_br("A (B (), C(D,C,F (), 123))", "(", ")")
#   print RSTART, RLENGTH
#   -| 3
#   -| 3
#   -| 24
#
# =back
#

function match_br (s, br_open, br_close,                len,i,cnt){
	len = length(s)
	cnt = 0
	for (i=1; i <= len; ++i){
		ch = substr(s, i, 1)

		if (ch == br_open){
			if (cnt == 0){
				RSTART = i
			}

			++cnt
		}else if (ch == br_close){
			--cnt

			if (cnt == 0){
				RLENGTH=i-RSTART+1
				return RSTART
			}
		}
	}

	return 0
}
