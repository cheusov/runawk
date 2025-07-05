# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 xsystem.awk
#
# =over 2
#
# =item I<xsystem(FILE)>
#
# safe wrapper for 'system'.
# awk exits with error if system() function failed.
#
# =back
#

#use "alt_assert.awk"

function xsystem (fn){
	assert(system(fn) == 0, "system(\"" fn "\") failed")
}
