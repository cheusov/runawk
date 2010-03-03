# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

#use "has_suffix.awk"

# basename -- return filename portion of pathname
# (the same as dirname(1))

# See example/demo_basename for the sample of usage

function basename (pathname, suffix){
	sub(/\/$/, "", pathname)
	if (pathname == "")
		return "/"

	sub(/^.*\//, "", pathname)

	if (suffix != "" && has_suffix(pathname, suffix))
		pathname = substr(pathname, 1, length(pathname) - length(suffix))

	return pathname
}
