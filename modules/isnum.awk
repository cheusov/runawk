# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 isnum.awk
#
# =over 2
#
# =item isnum (NUM)
#
# returns 1 if an argument is a number
#
# =back
#

function isnum (v){
	return v == v + 0
}
