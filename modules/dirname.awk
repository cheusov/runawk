# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# basename -- return filename portion of pathname
# (the same as dirname(1))

function dirname (pathname){
	if (!sub(/\/[^\/]*\/?$/, "", pathname))
		return "."
	else if (pathname != "")
		return pathname
	else
		return "/"
}
