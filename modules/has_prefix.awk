# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# has_prefix(STRING, PREFIX)
#   `has_prefix' returns TRUE if STRING begins with PREFIX

function has_prefix (s, pre,                 pre_len, s_len){
	pre_len = length(pre)
	s_len   = length(s)

	return pre_len <= s_len && substr(s, 1, pre_len) == pre
}
