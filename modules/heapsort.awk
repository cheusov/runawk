# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# heapsort (src_array, dest_remap, start, end)
#     The content of `src_array' is sorted using awk's rules for
#     comparing values. Values with indices in range [start, end] are
#     sorted.  `src_array' array is not changed.
#     Instead dest_remap array is generated such that
#
#     Result:
#     src_array [dest_remap [start]] <=
#        <= src_array [dest_remap [start+1]] <=
#        <= src_array [dest_remap [start+2]] <= ... <=
#        <= src_array [dest_remap [end]]
#
#     `heapsort' algorithm is used.
# Examples: see demo_heapsort and demo_heapsort2 executables.

# heapsort_values (src_hash, dest_remap)
#     The same as `heapsort' described above, but hash values are sorted.
#
#     Result: 
#     src_array [dest_remap [1]] <=
#        <= src_array [dest_remap [2]] <=
#        <= src_array [dest_remap [3]] <= ... <=
#        <= src_array [dest_remap [count]]
#
#     `count', a number of elements in `src_hash', is a return value.
#
# Examples: see demo_heapsort3 and demo_heapsort4 executables.

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

function heapsort_values (hash, remap_idx,
   array, remap, i, j, cnt)
{
	cnt = 0
	for (i in hash) {
		++cnt
		array [cnt] = hash [i]
		remap [cnt] = i
	}

	heapsort(array, remap_idx, 1, cnt)

	for (i=1; i <= cnt; ++i) {
		remap_idx [i] = remap [remap_idx [i]]
	}

	return cnt
}
