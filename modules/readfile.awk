# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

#use "xgetline.awk"
#use "xclose.awk"

# =head2 readfile.awk
#
# =over 2
#
# =item readfile(FILENAME)
#
# read entire file and return its content as a string
#
# =back
#
# See example/demo_readfile for the sample of usage
#

function readfile (fn,                      ret){
	# Unfortunately there is no way portable accross all awk flavours
	# to read an entire file content by single 'getline' command.
	# This is why I use loop here.
	ret = ""

	while (xgetline(fn)){
		if (ret == "")
			ret = __input
		else
			ret = ret "\n" __input
	}
	xclose(fn)

	return ret
}
