# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    

#use "exitnow.awk"

# =head2 abort.awk
#
# =over 2
#
# =item I<abort(MSG, [EXIT_STATUS])>
#
# print MSG to stderr and exits program with
# EXIT_STATUS.  EXIT_STATUS defaults to 1.
#
# =back
#

function abort (msg, status){
	printf "error: %s\n", msg > "/dev/stderr"
	printf "       ARGV[0]=%s\n", ARGV[0] > "/dev/stderr"
	printf "       $0=`%s`\n", $0 > "/dev/stderr"
	printf "       NF=%d\n", NF > "/dev/stderr"
	printf "       FNR=%d\n", FNR > "/dev/stderr"
	printf "       FILENAME=%s\n", FILENAME > "/dev/stderr"

	if (!status){
		status = 1
	}

	exitnow(status)
}
