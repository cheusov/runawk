# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

#use "abort.awk"

# =head2 alt_assert.awk
#
# =over 2
#
# =item assert (CONDITION, MSG, STATUS)
#
# print an
# error message MSG to standard error and terminates
# the program with STATUS exit code if CONDITION is false.
#
# =back
#

function assert (cond, msg, status){
	if (!cond){
		abort("assertion failed: " msg, status)
	}
}
