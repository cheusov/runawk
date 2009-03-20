# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# abs -- absolute value function
function abs (v){
	if (v < 0)
		return -v
	else
		return v
}
