# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 exitnow.awk
#
# =over 2
#
# =item I<exitnow (STATUS)>
#
# similar to the statement 'exit' but do not run
# END sections.
#
# =back
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
