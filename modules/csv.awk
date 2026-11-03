# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 csv.awk
#
# =over 2
#
# =item I<cvs_parse( str, array)>
#
# splits CSV record (as described in RFC4180) in variable I<str> into
# fields, saves them to I<array>. and returns the number of fields.
#
# =item I<cvs_parse0( )>
#
# splits CSV record $0 (as described in RFC4180) into fields and saves them to $1, $2 etc.,
# sets NF to the number of fields
#
# =item I<init_tsv_header0( )>
#
# process the header row of CSV input, provided that csv_parse0() has been already called.
#
# =item I<get_tsv_col(col_name)>, I<get_tsv_col_name(col_num)>, I<TSV_COL> and I<TSV_COL_NAME>
#
# same as in tsv.awk but for CSV.
#
# =item I<csv_field>(I<str>)
#
# converts str to CSV field.
#
# =item I<csv_record0>()
#
# converts $0 to CSV record.
#
# =back
#

#use "alt_assert.awk"
#use "tsv.awk"

#function csv_parse1(                   input,s) {
#	input = $0
#	NF = 0
#	while (input != ""){
#		++NF
#		match(input, /^("([^"]|"")*"|[^,]*)/)
#		s = substr(input, 1, RLENGTH)
#		if (s ~ /^"/) {
#			s = substr(s, 2, length(s)-2)
#			gsub(/""/, "\"", s)
#		}
#		$NF = s
#		input = substr(input, RLENGTH+2)
#	}
#}

function csv_parse0(                   i,nf,a) {
	nf = csv_parse($0, a)
	$0 = ""
	for (i=1; i <= nf; ++i) {
		$i = a[i]
	}
	delete a
}

function csv_parse(input, a,                   nf) {
	nf = 1
	while (1){
		match(input, /^("([^"]|"")*"|[^,"]*)/)
		s = substr(input, 1, RLENGTH)
		if (s ~ /^"/) {
			s = substr(s, 2, length(s)-2)
			gsub(/""/, "\"", s)
		}
		a[nf] = s
		if (length(input) == RLENGTH) break
		else if (substr(input, RLENGTH+1, 1) == ",") ++nf
		else assert(0, "failed on input `" input "`")
		input = substr(input, RLENGTH+2)
	}
	return nf
}

function csv_field(str) {
	if (index(str, "\"")) {
		gsub(/"/, "\"\"", str)
		return "\"" str "\""
	} else if (index(str, ",")) {
		return "\"" str "\""
	} else {
		return str
	}
}

function csv_record0(              i) {
	for (i = 1; i <= NF; ++i) {
		$i = csv_field($i)
	}
}
