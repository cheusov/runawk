# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

#use "abort.awk"

# assert -- expression verification function
function assert (cond, msg, status){
	if (!cond){
		abort("assertion failed: " msg, status)
	}
}
