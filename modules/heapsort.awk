# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 heapsort.awk
#
# =over 2
#
# =item I<heapsort(src_array, dest_remap, start, end)>
#
# The content of `src_array' is sorted using awk's rules for
# comparing values. Values with indices in range [start, end] are
# sorted.  `src_array' array is not changed.
# Instead dest_remap array is generated such that
#
#   Result:
#     src_array [dest_remap [start]] <=
#        <= src_array [dest_remap [start+1]] <=
#        <= src_array [dest_remap [start+2]] <= ... <=
#        <= src_array [dest_remap [end]]
#
#   `heapsort' algorithm is used.
# Examples: see demo_heapsort and demo_heapsort2 executables.
#
# =item I<heapsort_values(src_hash, dest_remap)>
#
# The same as `heapsort' described above, but hash values are sorted.
#
#   Result: 
#     src_array [dest_remap [1]] <=
#        <= src_array [dest_remap [2]] <=
#        <= src_array [dest_remap [3]] <= ... <=
#        <= src_array [dest_remap [count]]
#
#   `count', a number of elements in `src_hash', is a return value.
#
# Examples: see demo_heapsort3 executable.
#
# =item I<heapsort_indices(src_hash, dest_remap)>
#
# The same as `heapsort' described above, but hash indices are sorted.
#
#   Result: 
#     dest_remap [1] <=
#        <= dest_remap [2] <=
#        <= dest_remap [3] <= ... <=
#        <= dest_remap [count]
#
#   `count', a number of elements in `src_hash', is a return value.
#
# Examples: demo_ini
#
# =item I<heapsort_fields(dest_remap, [start [, end [, strnum]]])>
#
# The same as function "heapsort0" but $1, $2... array is sorted.
# Note that $1, $2... are not changed, but dest_remap array is filled in!
# The variable "start" default to 1, "end" -- to NF.
# If "strnum" is set to 1, values are forcibly compared as strings.
# If "strnum" is set to 2, values are forcibly compared as numbers.
#
# =item I<heapsort0([start [, end [, strnum]]])>
#
# The same as "heapsort_fields" but $1, $2... are changed.
#
# =back
#

function sift_down (array, root, start, end, index_remap,               n0, v){
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

function sift_up (array, root, start, end, index_remap,               n0, v){
	while (1){
		n0 = int((root - start + 1)/2) - 1 + start

		if (n0 < start)
			return

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
		sift_down(array, i, start, end, index_remap)
	}
	for (; end > start; --end){
		v = index_remap [start]
		index_remap [start] = index_remap [end]
		index_remap [end] = v

		sift_down(array, start, start, end-1, index_remap)
	}
}

function heapsort_values (hash, remap_idx,
   array, remap, i, cnt)
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

function heapsort_indices (hash, remap_idx,
   array, i, cnt)
{
	cnt = 0
	for (i in hash) {
		++cnt
		array [cnt] = i
	}

	heapsort(array, remap_idx, 1, cnt)

	for (i=1; i <= cnt; ++i) {
		remap_idx [i] = array [remap_idx [i]]
	}

	return cnt
}

function heapsort_fields (index_remap, start, end, str,              i,arr)
{
	if (start == "")
		start = 1
	if (end == "")
		end = NF

	if (str == 1){
		for (i=start; i <= end; ++i){
			arr [i] = ($i "")
		}
	}else if (str == 2){
		for (i=start; i <= end; ++i){
			arr [i] = $i + 0
		}
	}else{
		for (i=start; i <= end; ++i){
			arr [i] = $i
		}
	}
	heapsort(arr, index_remap, start, end)
}

function heapsort0 (start, end, str,              i,arr,remap)
{
	if (start == "")
		start = 1
	if (end == "")
		end = NF

	if (str == 1){
		for (i=start; i <= end; ++i){
			arr [i] = ($i "")
		}
	}else if (str == 2){
		for (i=start; i <= end; ++i){
			arr [i] = $i + 0
		}
	}else{
		for (i=start; i <= end; ++i){
			arr [i] = $i
		}
	}

	heapsort(arr, remap, start, end)
	for (i=start; i <= end; ++i){
		$i = arr [remap [i]]
	}
}
