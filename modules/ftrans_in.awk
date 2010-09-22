# ftrans.awk --- handle data file transitions
#
# user supplies beginfile() and endfile() functions
#
# Arnold Robbins, arnold@skeeve.com, Public Domain, November 1992
# Aleksey Cheusov, vle@gmx.net, Public Domain, September 2010
#   (fix and adaptation for nawk by B.Kernighan)

# beginfile() function provided by user is called before file reading
# endfile()   function provided by user is called after file reading

FNR == 1 {
	if (_filename_ != "")
		endfile(_filename_)

	_filename_ = (FILENAME == "" ? "-" : FILENAME) # for nawk

	beginfile(_filename_)
}

END {
	if (_filename_ != "") # fix for Arnold's version
		endfile(_filename_)
}
