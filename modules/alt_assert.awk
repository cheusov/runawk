# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# abort -- cause abnormal program termination
function abort (msg, status){
	printf "error: %s\n", msg > "/dev/stderr"
	printf "       ARGV[0]=%s\n", ARGV[0] > "/dev/stderr"
	printf "       $0=`%s`\n", $0 > "/dev/stderr"
	printf "       FNR=%d\n", FNR > "/dev/stderr"
	printf "       FILENAME=%s\n", FILENAME > "/dev/stderr"

	if (!status){
		_exit_status = status = 1
	}

	_exit_status = status

	exit status
}

# assert -- expression verification function
function assert (cond, msg, status){
	if (!cond){
		abort("assertion failed: " msg, status)
	}
}

END {
	if (_exit_status){
		exit _exit_status
	}
}
