# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# sort (src, dest_remap, start, end)
#   Call either heapsort function from heapsort.awk (if
#   RUNAWK_SORTTYPE environment variable is "heapsort") or quicksort
#   from quicksort.awk (if RUNAWK_SORTTYPE is "heapsort").
#   Sorttype defaults to "heapsort".
# sort_values (src, dest_remap)
#   Call either heapsort_values function from heapsort.awk (if
#   RUNAWK_SORTTYPE environment variable is "heapsort") or
#   quicksort_values from quicksort.awk (if RUNAWK_SORTTYPE is
#   "heapsort").  Sorttype defaults to "heapsort".
# sort_indices (src, dest_remap)
#   Call either heapsort_indices function from heapsort.awk (if
#   RUNAWK_SORTTYPE environment variable is "heapsort") or
#   quicksort_indices from quicksort.awk (if RUNAWK_SORTTYPE is
#   "heapsort").  Sorttype defaults to "heapsort".

#use "abort.awk"
#use "heapsort.awk"
#use "quicksort.awk"

BEGIN {
	if (!__sort_type)
		__sort_type = ENVIRON ["RUNAWK_SORTTYPE"]
	if (!__sort_type)
		__sort_type = "heapsort"
}

function sort (array, index_remap, start, end)
{
	if (__sort_type == "heapsort")
		heapsort(array, index_remap, start, end);
	else if (__sort_type == "quicksort")
		quicksort(array, index_remap, start, end);
	else
		abort("Bad __sort_type in sort.awk")
}

function sort_values (src_hash, index_remap)
{
	if (__sort_type == "heapsort")
		return heapsort_values(src_hash, index_remap);
	else if (__sort_type == "quicksort")
		return quicksort_values(src_hash, index_remap);
	else
		abort("Bad __sort_type in sort.awk")
}

function sort_indices (src_hash, index_remap)
{
	if (__sort_type == "heapsort")
		return heapsort_indices(src_hash, index_remap);
	else if (__sort_type == "quicksort")
		return quicksort_indices(src_hash, index_remap);
	else
		abort("Bad __sort_type in sort.awk")
}
