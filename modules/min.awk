# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# min -- minimum function
function min (a, b){
	return (a < b ? a : b)
}

function min3 (a, b, c,          m){
	m = (a < b ? a : b)
	return (m < c ? m : c)
}

function min4 (a, b, c, d,         m){
	m = (a < b ? a : b)
	m = (m < c ? m : c)
	return (m < d ? m : d)
}

function min5 (a, b, c, d, e,        m){
	m = (a < b ? a : b)
	m = (m < c ? m : c)
	m = (m < d ? m : d)
	return (m < e ? m : e)
}
