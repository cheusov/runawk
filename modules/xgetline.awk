# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 xgetline.awk
#
# =over 2
#
# =item I<xgetline0([FILE])>
#
# Safe analog to 'getline < FILE' or 'getline' (if no FILE is specified).
# 0 at the end means that input line is assigned to $0.
#
# =item I<xgetline([FILE])>
#
# Safe analog to 'getline __input < FILE' and 'getline __input'
# (if no FILE is specified)
#
# =back
#
# In both cases "safe" means that returned value is analysed and
# if it is less than zero (file reading error happens) program will
# be terminated emmidiately with appropriate error message sent to stderr.
# Both functions return zero if end of file is reached or non-zero otherwise.
#
# Example:
#       while (xgetline("/etc/passwd")){
#           print "user: " __input
#       }
#

#use "alt_assert.awk"

function xgetline0 (fn,                 ret){
	if (fn == ""){
		ret = getline
		assert(ret >= 0, "getline failed")
	}else{
		ret = (getline < fn)
		assert(ret >= 0, "getline < " fn " failed")
	}

	return (ret > 0)
}

function xgetline (fn,                 ret){
	if (fn == ""){
		ret = getline __input
		assert(ret >= 0, "getline failed")
	}else{
		ret = (getline __input < fn)
		assert(ret >= 0, "getline < " fn " failed")
	}

	return (ret > 0)
}
