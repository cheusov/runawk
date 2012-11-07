# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 dirname.awk
#
# =over 2
#
# =item I<dirname (PATH)>
#
# return dirname portion of the PATH
# (the same as I<dirname(3)>)
#
# =back
#
# See example/demo_dirname for the sample of usage
#

function dirname (pathname){
	if (!sub(/\/[^\/]*\/?$/, "", pathname))
		return "."
	else if (pathname != "")
		return pathname
	else
		return "/"
}
