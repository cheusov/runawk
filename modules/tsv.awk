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
# =item I<get_tsv_col(COL_NAME)>
#
# return a column index for the specified name.
#
# =item I<TSV_COL>
#
# array with column indices, keys are column names.
#
# =back
#

#use "alt_assert.awk"

function init_tsv_header(               i) {
	TSV_COL_COUNT = NF
	for (i = 1; i <= NF; ++i){
		TSV_COL[$i] = i
	}
}

function get_tsv_col(col_name,           ret){
	ret = TSV_COL[col_name]
	assert(ret != "", "Unknown column " col_name)
	return ret + 0
}
