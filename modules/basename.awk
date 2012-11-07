# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

#use "has_suffix.awk"

# =head2 basename.awk
#
# =over 2
#
# =item I<basename (PATH)>
#
# return filename portion of the PATH
# (the same as I<dirname(3)>)
#
# =back
#
# See example/demo_basename for the sample of usage
#

function basename (pathname, suffix){
	sub(/\/$/, "", pathname)
	if (pathname == "")
		return "/"

	sub(/^.*\//, "", pathname)

	if (suffix != "" && has_suffix(pathname, suffix))
		pathname = substr(pathname, 1, length(pathname) - length(suffix))

	return pathname
}
