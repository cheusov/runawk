# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# quicksort (src_array, dest_remap, start, end)
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
#     `quicksort' algorithm is used.
# Examples: see demo_quicksort and demo_quicksort2 executables

# quicksort_values (src_hash, dest_remap)
#     The same as `quicksort' described above, but hash values are sorted.
#
#     Result: 
#     src_array [dest_remap [1]] <=
#        <= src_array [dest_remap [2]] <=
#        <= src_array [dest_remap [3]] <= ... <=
#        <= src_array [dest_remap [count]]
#
#     `count', a number of elements in `src_hash', is a return value.
#
# Examples: see demo_heapsort4 executable.

function __quicksort (array, index_remap, start, end,
       MedIdx,Med,v,i,storeIdx)
{
	if ((end - start) <= 0)
		return

	MedIdx = int((start+end)/2)
	Med = array [index_remap [MedIdx]]

	v = index_remap [end]
	index_remap [end] = index_remap [MedIdx]
	index_remap [MedIdx] = v

	storeIdx = start
	for (i=start; i < end; ++i){
		if (array [index_remap [i]] < Med){
			v = index_remap [i]
			index_remap [i] = index_remap [storeIdx]
			index_remap [storeIdx] = v

			++storeIdx
		}
	}

	v = index_remap [storeIdx]
	index_remap [storeIdx] = index_remap [end]
	index_remap [end] = v

	__quicksort(array, index_remap, start, storeIdx-1)
	__quicksort(array, index_remap, storeIdx+1, end)
}

function quicksort (array, index_remap, start, end,             i)
{
	for (i=start; i <= end; ++i)
		index_remap [i] = i

	__quicksort(array, index_remap, start, end)
}

function quicksort_values (hash, remap_idx,
   array, remap, i, j, cnt)
{
	cnt = 0
	for (i in hash) {
		++cnt
		array [cnt] = hash [i]
		remap [cnt] = i
	}

	quicksort(array, remap_idx, 1, cnt)

	for (i=1; i <= cnt; ++i) {
		remap_idx [i] = remap [remap_idx [i]]
	}

	return cnt
}
