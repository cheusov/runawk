# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# isnum -- returns 1 if an argument is a number
function isnum (v){
	return v == v + 0
}
