# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

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
