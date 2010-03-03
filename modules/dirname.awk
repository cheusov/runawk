# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# basename -- return filename portion of pathname
# (the same as dirname(1))

# See example/demo_dirname for the sample of usage

function dirname (pathname){
	if (!sub(/\/[^\/]*\/?$/, "", pathname))
		return "."
	else if (pathname != "")
		return pathname
	else
		return "/"
}
