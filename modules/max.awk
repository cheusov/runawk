# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# max, max3, max4, max5 -- maximum function
#
# max_key(HASH, DFLT)
#    returns a maximum key in HASH or DFLT is HASH is empty
#
# max_value(HASH, DFLT)
#    returns a maximum value in HASH or DFLT is HASH is empty
#
# key_of_max_value(HASH, DFLT)
#    returns A KEY OF maximum value in HASH or DFLT is HASH is empty

function max (a, b){
	return (a > b ? a : b)
}

function max3 (a, b, c,          m){
	m = (a > b ? a : b)
	return (m > c ? m : c)
}

function max4 (a, b, c, d,         m){
	m = (a > b ? a : b)
	m = (m > c ? m : c)
	return (m > d ? m : d)
}

function max5 (a, b, c, d, e,        m){
	m = (a > b ? a : b)
	m = (m > c ? m : c)
	m = (m > d ? m : d)
	return (m > e ? m : e)
}


function max_key(hash, dflt,                    i){
	for (i in hash){
		dflt = i
		break
	}
	for (i in hash){
		if (i > dflt)
			dflt = i
	}
	return dflt
}

function max_value(hash, dflt,                    i){
	for (i in hash){
		dflt = hash [i]
		break
	}
	for (i in hash){
		if (hash [i] > dflt)
			dflt = hash [i]
	}
	return dflt
}

function key_of_max_value(hash, dflt,                  i,v){
	for (i in hash){
		dflt = i
		v = hash [i]
		break
	}
	for (i in hash){
		if (hash [i] > v){
			dflt = i
			v = hash [i]
		}
	}
	return dflt
}
