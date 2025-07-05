# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#
############################################################

# =head2 backslash_in.awk
#
# As the name of this module (_in suffix) says this module
# reads and optionally changes input lines.
# 
# Backslash character at the end of line is treated as a sign
# that current line is continued on the next one.
# Example is below.
#
# Input:
#     a b c\
#     d e f g
#     a
#     b
#     e\
#       f
#
# What your program using backslash_in.awk will obtain:
#     a b cd e f g
#     a
#     b
#     e  f
#

#use "xgetline.awk"

{
	while ($0 ~ /\\/){
		assert(xgetline() > 0, "unexpected end of file")
		$0 = substr($0, 1, length($0)-1) __input
	}
}
