# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 has_prefix.awk
#
# =over 2
#
# =item has_prefix (STRING, PREFIX)
#
# return TRUE if STRING begins with PREFIX
#
# =back
#
# See example/demo_has_prefix for the sample of usage
#

function has_prefix (s, pre,                 pre_len, s_len){
	pre_len = length(pre)
	s_len   = length(s)

	return pre_len <= s_len && substr(s, 1, pre_len) == pre
}
