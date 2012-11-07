# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 has_suffix.awk
#
# =over 2
#
# =item I<has_suffix(STRING, SUFFIX)>
#
# return TRUE if STRING ends with SUFFIX
#
# =back
#
# See example/demo_has_suffix for the sample of usage
#

function has_suffix (s, suf,                 suf_len, s_len){
	suf_len = length(suf)
	s_len   = length(s)

	return suf_len <= s_len && substr(s, s_len - suf_len + 1) == suf
}
