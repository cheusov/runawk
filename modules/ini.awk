# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 ini.awk
#
# This module provides functions for manipulating .ini files.
# See example/demo_ini  for the sample of use.
#
# =over 2
#
# =item I<read_inifile(FILENAME, RESULT [, SEPARATOR])>
#
# Reads .ini file FILENAME and fills array RESULT, e.g.
# RESULT [<section5><SEPARATOR><name6>] = <value5.6> etc.
# If SEPARATOR is not specified, `.' symbols is used by default.
#
# =back
#
# Features:
#
#   - spaces are allowed everywhere, i.e. at the beginning and end of
#     line, around `=' separator. THEY ARE STRIPPED!
#   - comment lines start with `;' or `#' sign. Comment lines are ignored.
#   - values can be surrounded by signle or double quote. In this case
#     spaces are presenrved, otherwise they are removed from
#     beginning and at the end of line and replaced with single space
#     in the middle of the line.
#   - Escape character are not supported (yet?).
#

#use "alt_assert.awk"
#use "xgetline.awk"
#use "trim.awk"

function __runawk_register_value (s, n, v, r, sep){
	r [s sep n] = v
}

function read_inifile (inifile, result, sep) {
	if (sep == "")
		sep = "."

	while (xgetline(inifile)){
		sub(/^[[:space:]]*[;#].*$/, "", __input)
		sub(/[;#][^"']*$/, "", __input)
		sub(/^[[:space:]]+/, "", __input)
		sub(/[[:space:]]+$/, "", __input)

		if (__input == "")
			continue

		############ [section]
		if (__input ~ /^\[.+\]$/){
			section = substr(__input, 2, length(__input)-2)
			continue
		}

		############ name = value
		idx = match(__input, /=/)
		assert(idx > 0, "`=' cannot be found")

		name  = trim_lrc(substr(__input, 1, idx-1))
		value = trim_lr(substr(__input, idx+1))

		# name = "value"
		if (value ~ /^".*"$/ || value ~ /^'.*'$/){
			__runawk_register_value(\
				section, name,
				substr(value, 2, length(value)-2), result, sep)
			continue
		}

		assert(value !~ /^["']|["']$/, "wrong value")

		# name = v a l u e
		__runawk_register_value(section, name, trim_c(value), result, sep)
	}
}
