# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# dirname -- return directory portion of pathname
function dirname (pathname){
	if (sub(/\/[^\/]*$/, "", pathname))
		return pathname
	else
		return "."
}
