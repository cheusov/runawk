# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# xgetline0([FILE])
#  Safe analog to 'getline < FILE' or 'getline' (if no FILE is specified).
#  0 at the end means that input line is assigned to $0.
#
# xgetline([FILE])
#  Safe analog to 'getline __input < FILE' and 'getline __input'
#    (if no FILE is specified)
#
# In both cases "safe" means that returned value is analysed and
# if it is less tha zero (file reading error happens) program will
# be terminated emmidiately with appropriate error message sent to stderr.
# Both functions return zero if end of file is reached or non-zero otherwise.
#
# Example:
#       while (xgetline("/etc/passwd")){
#           print "user: " __input
#       }

#use "alt_assert.awk"

function xgetline0 (fn,                 ret){
	if (fn == "")
		ret = getline
	else
		ret = (getline < fn)

	assert(ret >= 0, "function getline failed")

	return (ret > 0)
}

function xgetline (fn,                 ret){
	if (fn == "")
		ret = getline __input
	else
		ret = (getline __input < fn)

	assert(ret >= 0, "function getline failed")

	return (ret > 0)
}
