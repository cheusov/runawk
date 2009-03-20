# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# basename -- return filename portion of pathname
function basename (pathname){
	sub(/^.*\//, "", pathname)
	return pathname
}
