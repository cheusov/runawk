# written by Aleksey Cheusov <vle@gmx.net>
# public domain

#use "abort.awk"

# assert -- expression verification function
function assert (cond, msg, status){
	if (!cond){
		abort("assertion failed: " msg, status)
	}
}
