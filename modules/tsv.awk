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
# =item I<init_tsv_header( )>
#
# initialize the header raw of TSV input.
#
# =item I<get_tsv_col(col_name)>
#
# return a column index for the specified name.
#
# =item I<TSV_COL>
#
# array with column indices, keys are column names.
#
# =item I<TSV_COL_NAME>
#
# array with column names, keys are column indices.
#
# =back
#

#use "alt_assert.awk"

function init_tsv_header(               i) {
	TSV_COL_COUNT = NF
	for (i = 1; i <= NF; ++i){
		TSV_COL[$i] = i
		TSV_COL_NAME[i] = $i
	}
}

function get_tsv_col(col_name,           ret){
	assert(col_name in TSV_COL, "Unknown column " col_name)
	return TSV_COL[col_name]
}

function get_tsv_col_name(col_num,           ret){
	assert(col_num in TSV_COL_NAME, "Unknown column " col_num)
	return TSV_COL_NAME[col_num]
}
