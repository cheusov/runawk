# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 xsystem.awk
#
# =over 2
#
# =item xsystem(FILE)
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
