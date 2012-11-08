# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 tokenre.awk
#
# By default AWK splits input lines into tokens according to regular
# expression that defines "spaces" between tokens using special
# variable FS. In many situations it is more useful to define regular
# expressions for tokens themselves. This is what this module does.
#
# =over 2
#
# =item I<tokenre(STRING, REGEXP)>
#
# extracts substrings from STRING
# according to REGEXP from the left to the right and assigns $1, $2
# etc. and NF variable.
#
# =item I<tokenre0(REGEXP)>
#
# Does the the same as `tokenre' but splits $0 instead.
#
# =item I<splitre(STRING, ARR, REGEXP)>
#
# The same as `tokenre' but ARR[1], ARR[2]... are assigned.
# A number of extracted tokens is a return value.
#
# =item I<TRE>
#
# global variable. If it is set to non-empty string, all input
# lines are splitted automatically.
#
# =back
#

# See example/demo_tokenre for the sample of usage

function tokenre (s, re){
	NF = 0
	while (match(s, re)){
		++NF
		$NF = substr(s, RSTART, RLENGTH)
		s = substr(s, RSTART+RLENGTH)
	}
}

function tokenre0 (re){
	tokenre($0, re)
}

function splitre (s, arr, re,             cnt){
	cnt = 0
	while (match(s, re)){
		++cnt
		arr [cnt] = substr(s, RSTART, RLENGTH)
		s = substr(s, RSTART+RLENGTH)
	}
	return cnt
}

function splitre0 (arr, re){
	return splitre($0, arr, re)
}

{
	if (TRE != ""){
		tokenre0(TRE)
	}
}
