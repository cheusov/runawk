# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# max -- maximum function
function max (a, b){
	if (a > b)
		return a
	else
		return b
}
