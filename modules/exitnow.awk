# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# exitnow -- similar to the statement 'exit' but do not run program's
# END sections. The code is trivial, see below.  'exitnow' function is
# used by alt_assert.awk and abort.awk modules.
#           
function exitnow (exit_status){
	__runawk_exit_status = exit_status

	exit exit_status
}

END {
	if (__runawk_exit_status){
		exit __runawk_exit_status
	}
}
