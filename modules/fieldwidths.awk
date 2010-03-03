# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# By default AWK splits input strings into tokens according to regular
# expression that defines "spaces" between tokens using special
# variable FS. In some situations it is more useful to define a
# fixed-size fields for tokens. This is what this module does and what
# GNU awk implements with a help FIELDWIDTHS special variable.

# fieldwidths(STRING, FW)
#   `fieldwidths' extracts substrings from STRING according to FW
#   from the left to the right and assigns $1, $2 etc. and NF
#   variable. FW is a space separated list of numbers that specify
#   fields widths.
#
# fieldwidths0(FW)
#   Does the the same as `fieldwidths' function but splits $0 instead.
#
# FW - global variable. If it is set to non-empty string, all input
# lines are splitted automatically and the value of variable FS is
# ignored in this case.

# See example/demo_fieldwidths for the sample of usage

function fieldwidths (s, fw,                   arr,cnt,i){
	cnt = split(fw, arr, " ")

	for (i=1; s != "" && i <= cnt; ++i){
		$i = substr(s, 1, arr [i])
		s = substr(s, arr [i]+1)
	}

	NF = i-1
}

function fieldwidths0 (fw){
	fieldwidths($0, fw)
}

{
	if (FW != ""){
		fieldwidths0(FW)
	}
}
