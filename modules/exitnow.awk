# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# exitnow -- similar to the statement 'exit' but do not run program's
# END sections. The code is trivial, see below.  'exitnow' function is
# used by alt_assert.awk and abort.awk modules.
#           
function exitnow (exit_status){
	__runawk_exit_status = exit_status
	__runawk_exit        = 1

	exit exit_status
}

END {
	if (__runawk_exit){
		exit __runawk_exit_status
	}
}
