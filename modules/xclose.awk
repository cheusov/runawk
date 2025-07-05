# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 xclose.awk
#
# =over 2
#
# =item I<xclose(FILE)>
#
# safe wrapper for 'close'.
# awk exits with error if close() function failed.
#
# =back
#

#use "alt_assert.awk"

function xclose (fn){
	assert(close(fn) == 0, "close(\"" fn "\") failed")
}
