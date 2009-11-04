# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# quicksort (src, dest_remap, start, end)
#     The contents of `src' are sorted using awk's rules for comparing
#     values. Values with indices in range [start, end] are sorted.
#     `src' array is not changed.
#     Instead dest_remap array is generated such that
#
#     src [dest_remap [start]] <= src [dest_remap [start+1]] <=
#        <= src [dest_remap [start+2]] <= ... <= src [dest_remap [end]]
#
#     `quicksort' algorithm is used.

# Examples: see demo_quicksort and demo_quicksort2 executables

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
