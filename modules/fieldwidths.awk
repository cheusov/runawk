# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 fieldwidth.awk
#
# By default AWK interpreter splits input lines into tokens according
# to regular expression that defines "spaces" between them using
# special variable FS. Sometimes it is useful to define a fixed-size
# fields for tokens. This is what this module is for. The
# functionality of fieldwidths.awk is very close to GNU awk's
# FIELDWIDTHS variable.
#
# =over 2
#
# =item I<fieldwidths(STRING, FW)>
#
# extracts substrings from STRING according to FW
# from the left to the right and assigns $1, $2 etc. and NF
# variable. FW is a space separated list of numbers that specify
# fields widths.
#
# =item I<fieldwidths0(FW)>
#
# Does the the same as `fieldwidths' function but splits $0 instead.
#
# =item I<FW>
#
# global variable. If it is set to non-empty string, all input
# lines are split automatically and the value of variable FS is
# ignored in this case.
#
# =back
#
# See example/demo_fieldwidths for the sample of usage
#

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
