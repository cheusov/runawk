# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 tmpfile.awk
#
# This module provides a function `tmpfile' for generating temporary
# filenames. All these filenames are under temporary directory created
# (if necessary) by runawk(1) which is removed automatically during
# normal exit or when runawk(1) reveives SIGINT, SIGQUIT, SIGTERM,
# SIGHUP or SIGPIPE.
#
# =over 2
#
# =item I<tmpfile( )>
#
# returns a temporary file name.
#
# =item I<runawk_tmpdir>
#
# global variable that keeps tempdir created by runawk -t
#
# =back
#
# See example/demo_tmpfile for the sample of usage
#

#use "alt_assert.awk"

BEGIN {
	runawk_tmpdir = ENVIRON ["_RUNAWK_TMPDIR"]
	assert(runawk_tmpdir != "", "_RUNAWK_TMPDIR is unset! This should not happen.")

	_runawk_tmpdir_cnt = 0
}

function tmpfile (){
	return (runawk_tmpdir "/" _runawk_tmpdir_cnt++)
}
