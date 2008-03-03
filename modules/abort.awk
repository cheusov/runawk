# written by Aleksey Cheusov <vle@gmx.net>
# public domain

#use "exitnow.awk"

# abort(MSG, [EXIT_STATUS]) -- print MSG to stderr and exits programwith
# EXIT_STATUS.  if EXIT_STATUS is zero of is not specified, 1 is
# assigned.
function abort (msg, status){
	printf "error: %s\n", msg > "/dev/stderr"
	printf "       ARGV[0]=%s\n", ARGV[0] > "/dev/stderr"
	printf "       $0=`%s`\n", $0 > "/dev/stderr"
	printf "       FNR=%d\n", FNR > "/dev/stderr"
	printf "       FILENAME=%s\n", FILENAME > "/dev/stderr"

	if (!status){
		status = 1
	}

	exitnow(status)
}
