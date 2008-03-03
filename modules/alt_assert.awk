# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# assert -- expression verification function
function assert (cond, msg, status){
	if (!cond){
		abort("assertion failed: " msg, status)
	}
}
