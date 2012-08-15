# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 trim.awk
#
# =over 2
#
# =item trim_l(STRING)
#
# Removes leading Tab and Space characters from STRING and returns
# the result.
#
# =item trim_r(STRING)
#
# Removes Tab and Space characters at the end of STRING and returns
# the result.
# 
# =item trim_c(STRING, REPL)
#
# Replaces sequences of Tab and Space characters in STRING with REPL
# and returns the result. If REPL is not specified, it defaults to
# single Space character.
#
# =item trim_lr(STRING)
#
# Equal to trim_l(trim_r(STRING))
#
# =item trim_lrc(STRING, REPL)
#
# Equal to trim_l(trim_r(trim_c(STRING, REPL)))
#
# =back
#
# See example/demo_trim for the sample of usage
#

function trim_l (s){
	sub(/^[ \t]+/, "", s)
	return s
}

function trim_r (s){
	sub(/[ \t]+$/, "", s)
	return s
}

function trim_c (s, repl){
	if (repl == "")
		repl = " "

	gsub(/[ \t][ \t]+/, repl, s)
	return s
}

function trim_lr (s){
	sub(/[ \t]+$/, "", s)
	sub(/^[ \t]+/, "", s)
	return s
}

function trim_lrc (s, repl){
	if (repl == "")
		repl = " "

	gsub(/[ \t][ \t]+/, repl, s)
	sub(/[ \t]+$/, "", s)
	sub(/^[ \t]+/, "", s)
	return s
}
