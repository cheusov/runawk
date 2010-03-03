# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# Function for generating temporary filenames. All these filenames are
# under temporary directory created by runawk -t.

# tmpfile()
#   `tmpfile' returns a temporary file name.
#
# runawk_tmpdir - global variable that keeps tempdir created by runawk -t
#

# See example/demo_tmpfile for the sample of usage

#use "alt_assert.awk"

BEGIN {
	runawk_tmpdir = ENVIRON ["_RUNAWK_TMPDIR"]
	assert(runawk_tmpdir != "", "_RUNAWK_TMPDIR is unset! This should not happen.")

	_runawk_tmpdir_cnt = 0
}

function tmpfile (){
	return (runawk_tmpdir "/" _runawk_tmpdir_cnt++)
}
