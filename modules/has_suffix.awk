# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# has_suffix(STRING, SUFFIX)
#   `has_suffix' returns TRUE if STRING ends with SUFFIX

function has_suffix (s, suf,                 suf_len, s_len){
	suf_len = length(suf)
	s_len   = length(s)

	return suf_len <= s_len && substr(s, s_len - suf_len + 1) == suf
}
