# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 tsv.awk
#
# =over 2
#
# =item I<init_tsv_header0( )>
#
# process the header row $0 of TSV input, and save results to TSV_COL_COUNT, TSV_COL and TSV_COL_NAME.
#
# =item I<init_tsv_header( array )>
#
# process the column names in array, and save results to TSV_COL_COUNT, TSV_COL and TSV_COL_NAME.
#
# =item I<get_tsv_col(col_name)>
#
# return a column index for the specified column name.
#
# =item I<get_tsv_col_name(col_num)>
#
# return a column name for the specified column index.
#
# =item I<TSV_COL>
#
# array with column indices, keys are column names, values -- column indices.
#
# =item I<TSV_COL_NAME>
#
# array with column names, keys are column indices, values -- column names.
#
# =back
#

#use "alt_assert.awk"

function init_tsv_header0(               i) {
	TSV_COL_COUNT = NF
	for (i = 1; i <= NF; ++i){
		TSV_COL[$i] = i
		TSV_COL_NAME[i] = $i
	}
}

function init_tsv_header(a,               i) {
	for (i = 1; i in a; ++i){
		TSV_COL[a[i]] = i
		TSV_COL_NAME[i] = a[i]
	}
	TSV_COL_COUNT = i-1
}

function get_tsv_col(col_name,           ret){
	assert(col_name in TSV_COL, "Unknown column " col_name)
	return TSV_COL[col_name]
}

function get_tsv_col_name(col_num,           ret){
	assert(col_num in TSV_COL_NAME, "Unknown column " col_num)
	return TSV_COL_NAME[col_num]
}
