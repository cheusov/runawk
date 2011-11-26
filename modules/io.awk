# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# This module provides a number of IO functions.

# is_file(FILENAME)
#   `is_file' returns 1 if the specified FILENAME
#   is a regular file or 0 otherwise.

# is_socket(FILENAME)
#   `is_socket' returns 1 if the specified FILENAME
#   is a socket or 0 otherwise.

# is_dir(FILENAME)
#   `is_dir' returns 1 if the specified FILENAME
#   is a dir or 0 otherwise.

# is_exec(FILENAME)
#   `is_exec' returns 1 if the specified FILENAME
#   is executable or 0 otherwise.

# is_fifo(FILENAME)
#   `is_fifo' returns 1 if the specified FILENAME
#   is a FIFO or 0 otherwise.

# is_blockdev(FILENAME)
#   `is_blockdev' returns 1 if the specified FILENAME
#   is a block special file or 0 otherwise.

# is_chardev(FILENAME)
#   `is_chardev' returns 1 if the specified FILENAME
#   is a character special file or 0 otherwise.

# is_symlink(FILENAME)
#   `is_symlink' returns 1 if the specified FILENAME
#   is a symlink or 0 otherwise.

# file_size(FILENAME, USE_STAT_NOT_LSTAT)
#   `file_size' returns the size of the specified FILENAME.
#   If USE_STAT_NOT_LSTAT is True, stat(2) is used instead of lstat(2).
#   Return value:
#     -2 if file doesn't exist
#     -1 if file is not a regular file
#     filesize otherwise
#
# file_type(FILENAME, USE_STAT_NOT_LSTAT)
#   `file_type' returns a single letter that corrspond to the file
#   type. If USE_STAT_NOT_LSTAT is True, stat(2) is used instead of
#   lstat(2).
#   Return value:
#     -  --  regular file
#     d  -- directory
#     c  -- character device
#     b  -- block device
#     p  -- FIFO
#     l  -- symlink
#     s  -- socket

# See example/demo_tokenre for the sample of usage

#use "shquote.awk"

function is_file (fn){
	return !system("test -f " shquote(fn))
}

function is_socket (fn){
	return !system("test -S " shquote(fn))
}

function is_dir (fn){
	return !system("test -d " shquote(fn))
}

function is_exec (fn){
	return !system("test -x " shquote(fn))
}

function is_fifo (fn){
	return !system("test -p " shquote(fn))
}

function is_blockdev (fn){
	return !system("test -b " shquote(fn))
}

function is_chardev (fn){
	return !system("test -c " shquote(fn))
}

function is_symlink (fn){
	return !system("test -h " shquote(fn))
}

function file_size (fn, stat,          d0,arr,cmd){
	cmd = "ls -ld " (stat ? "-L " : "") shquote(fn) " 2>/dev/null"
	if (0 < (cmd | getline d0)){
		close(cmd)
		if (d0 ~ /^-/){
			split(d0, arr)
			return arr [5]
		}else{
			return -1;
		}
	}else{
		close(cmd)
		return -2
	}
}

function file_type (fn, stat,          d0,cmd){
	cmd = "ls -ld " (stat ? "-L " : "") shquote(fn) " 2>/dev/null"
	if (0 < (cmd | getline d0)){
		close(cmd)
		return substr(d0, 1, 1)
	}else{
		close(cmd)
		return ""
	}
}
