# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# heapsort (src, dest_remap, start, end)
#     The contents of `src' are sorted using awk's rules for comparing
#     values. Values with indices in range [start, end] are sorted.
#     `src' array is not changed.
#     Instead dest_remap array is generated such that
#
#     src [dest_remap [start]] <= src [dest_remap [start+1]] <=
#        <= src [dest_remap [start+2]] <= ... <= src [dest_remap [end]]
#
#     `heapsort' algorithm is used.

# Examples: see demo_heapsort and demo_heapsort2 executables

function __sift (array, root, start, end, index_remap,               n0, v){
	while (1){
		n0 = root - start + 1 + root

		if (n0 > end)
			return

		if (n0 < end && array [index_remap [n0]] < array [index_remap [n0+1]])
			++n0

		if (array [index_remap [root]] >= array [index_remap [n0]])
			return

		v = index_remap [root]
		index_remap [root] = index_remap [n0]
		index_remap [n0] = v

		root = n0
	}
}

function heapsort (array, index_remap, start, end,               i,v){
	for (i=start; i <= end; ++i){
		index_remap [i] = i
	}
	for (i=int((start+end)/2); i >= start; --i){
		__sift(array, i, start, end, index_remap)
	}
	for (; end > start; --end){
		v = index_remap [start]
		index_remap [start] = index_remap [end]
		index_remap [end] = v

		__sift(array, start, start, end-1, index_remap)
	}
}
