# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# sort (src, dest_remap, start, end)
#   Call either heapsort function from heapsort.awk (if
#   RUNAWK_SORTTYPE environment variable is "heapsort") or quicksort
#   from quicksort.awk (if RUNAWK_SORTTYPE is "heapsort").
#   Sorttype defaults to "heapsort".

#use "abort.awk"
#use "heapsort.awk"
#use "quicksort.awk"

BEGIN {
	if (!__sort_type)
		__sort_type = ENVIRON ["RUNAWK_SORTTYPE"]
	if (!__sort_type)
		__sort_type = "heapsort"
}

function sort (array, index_remap, start, end){
	if (__sort_type == "heapsort")
		heapsort(array, index_remap, start, end);
	else if (__sort_type == "quicksort")
		quicksort(array, index_remap, start, end);
	else
		abort("Bad __sort_type in sort.awk")
}
