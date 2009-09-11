# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# xsystem(FILE) -- safe wrapper for 'system'.
# awk exits with error if system() function failed.

#use "alt_assert.awk"

function xsystem (fn){
	assert(system(fn) == 0, "system(\"" fn "\") failed")
}
