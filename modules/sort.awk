
function __sift (array, start, end, index_remap,               n0, v){
	while (1){
		n0 = start + start

		if (n0 > end)
			return

		if (n0 < end && array [index_remap [n0]] < array [index_remap [n0+1]])
			++n0

		if (array [index_remap [start]] >= array [index_remap [n0]])
			return

		v = index_remap [start]
		index_remap [start] = index_remap [n0]
		index_remap [n0] = v

		start = n0
	}
}

function heapsort (array, start, end, index_remap,            i,v){
	for (i=start; i <= end; ++i){
		index_remap [i] = i
	}
	for (i=int((start+end)/2); i >= 1; --i){
		__sift(array, i, end, index_remap)
	}
	for (; end > 1; --end){
		v = index_remap [1]
		index_remap [1] = index_remap [end]
		index_remap [end] = v

		__sift(array, 1, end-1, index_remap)
	}
}

BEGIN {
	srand()
	cnt = 40
	for (i=1; i <= cnt; ++i){
		arr [i] = int (rand() * 1000)
	}
	heapsort(arr, 1, cnt, index_map)
	for (i=1; i <= cnt; ++i){
		print arr [index_map [i]]
	}
}
