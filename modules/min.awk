# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# min -- minimum function
function min (a, b){
	if (a < b)
		return a
	else
		return b
}
