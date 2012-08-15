
# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 pow.awk
#
# =over 2
#
# =item pow (X, Y)
#
# returns the value of X to the exponent Y
#
# =back
#

function pow (x, y){
	return x ^ y
}
