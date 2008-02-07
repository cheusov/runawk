# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# By default AWK splits input strings into tokens according to regular
# expression that defines "space" between tokens using special
# variable FS. In many situations it is more useful to define regular
# expressions for tokens themselves. This is what this module does.

# tokenre(STRING, REGEXP)
#   `tokenre' extracts substrings from STRING
#   according to REGEXP from the left to the right and assigns $1, $2
#   etc. and NF variable.
#
# tokenre0(REGEXP)
#   Does the the same as `tokenre' but splits $0 instead
#
# TRE - variable. If it is set to not empty string, splitting is
#   made by default for all input strings.
#
# For example:
#      tokenre("print \"Hello world!\"", "\"([^\"]|\\\")*\"|[[:alnum:]_]+")
#      | NF == 2
#      | $1 == print
#      | $2 == "Hello world!"

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

BEGIN {
	TRE = ""
}

{
	if (TRE != ""){
		tokenre0(TRE)
	}
}
