# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 min.awk
#
# =over 2
#
# =item min, min3, min4, min5
#
# minimum functions
#
# =item min_key(HASH, DFLT)
#
# returns a minimum key in HASH or DFLT if it is empty
#
# =item min_value(HASH, DFLT)
#
# returns a minimum value in HASH or DFLT if it is empty
#
# =item key_of_min_value(HASH, DFLT)
#
# returns A KEY OF minimum value in HASH or DFLT if it is empty
#
# =back
#

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

function min_key(hash, dflt,                    i){
	for (i in hash){
		dflt = i
		break
	}
	for (i in hash){
		if (i < dflt)
			dflt = i
	}
	return dflt
}

function min_value(hash, dflt,                    i){
	for (i in hash){
		dflt = hash [i]
		break
	}
	for (i in hash){
		if (hash [i] < dflt)
			dflt = hash [i]
	}
	return dflt
}

function key_of_min_value(hash, dflt,                  i,v){
	for (i in hash){
		dflt = i
		v = hash [i]
		break
	}
	for (i in hash){
		if (hash [i] < v){
			dflt = i
			v = hash [i]
		}
	}
	return dflt
}
