
# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 pow.awk
#
# =over 2
#
# =item I<pow(X, Y)>
#
# returns the value of X to the exponent Y
#
# =back
#

function pow (x, y){
	return x ^ y
}
