# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 text.awk
#
# =over 2
#
# =item I<repeat(s, n)>
#
# Concatenate string I<s> I<n> times.
#
# =back
#

function repeat (s, n,            ret){
	ret = ""
	while (n-- > 0) ret = ret s
	return ret
}
