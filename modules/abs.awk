# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 abs.awk
#
# =over 2
#
# =item I<abs(V)>
#
# return absolute value of V.
#
# =back
#

function abs (v){
	if (v < 0)
		return -v
	else
		return v
}
