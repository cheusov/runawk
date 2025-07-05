# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 alt_join.awk
#
# =over 2
#
# =item I<join_keys(HASH, SEP)>
#
# return string consisting of all keys from HASH separated by SEP.
#
# =item I<join_values(HASH, SEP)>
#
# return string consisting of all values from HASH separated by SEP.
#
# =item I<join_by_numkeys(ARRAY, SEP [, START [, END]])>
#
# return string consisting of all values from ARRAY
# separated by SEP. Indices from START (default: 1) to END
# (default: +inf) are analysed. Collecting values is stopped
# on index absent in ARRAY.
#
# =back
#

function join_keys (hash, sep,                   k,ret,flag){
	ret = ""
	for (k in hash){
		if (flag){
			ret = ret sep k
		}else{
			flag = 1
			ret = k
		}
	}
	return ret
}

function join_values (hash, sep,                   k,ret,flag){
	ret = ""
	for (k in hash){
		if (flag){
			ret = ret sep hash [k]
		}else{
			flag = 1
			ret = hash [k]
		}
	}
	return ret
}

function join_by_numkeys (array, sep, start, end,                  ret,flag){
	ret = ""

	if (start == "")
		start = 1

	if (end == "")
		end = 1.0E+37

	for (; start <= end && (start in array); ++start){
		if (flag){
			ret = ret sep array [start]
		}else{
			flag = 1
			ret = array [start]
		}
	}

	return ret
}
