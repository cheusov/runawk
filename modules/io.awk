# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# This module provides a number of IO functions.

# file_exists(FILENAME)
#   `file_exists' returns 1 if the specified FILENAME
#   is a generic file or 0 otherwise.
#
# file_size(FILENAME, USE_STAT_NOT_LSTAT)
#   `file_size' returns the size of the specified FILENAME.
#   If USE_STAT_NOT_LSTAT is True, stat(2) is used instead of lstat(2).
#
# file_type(FILENAME, USE_STAT_NOT_LSTAT)
#   `file_type' returns a single letter that corrspond to the file
#   type. If USE_STAT_NOT_LSTAT is True, stat(2) is used instead of
#   lstat(2).
#

# See example/demo_tokenre for the sample of usage

#use "shquote.awk"

function file_exists (fn){
	return !system("test -f " shquote(fn))
}

function file_size (fn, stat,          sz){
	if (0 < (("stat -q -f%z " (stat ? "-L " : "") shquote(fn) " 2>/dev/null") | \
			 getline sz))
	{
		return sz
	}else{
		return -1
	}
}
