# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 embed_str.awk
#
# This module reads a program's file, find .begin-str/.end-str pairs
# and reads lines between them.
#
# I<EMBED_STR> - Associative array with string index
#
# Example:
#  Input:
#   .begin-str mymsg
#    Line1
#    Line2
#   .end-str
#  Output (result)
#   EMBED_STR ["mymsg"]="Line1\nLine2"
#
# See example/demo_embed_str for the sample of usage
#

#use "xgetline.awk"
#use "modinfo.awk"
#use "xclose.awk"

BEGIN {
	_embed_str_id = ""
	while (xgetline0(MODMAIN)){
		if ($0 ~ /^#[.]begin-str/){
			_embed_str_id = $2
		}else if ($0 ~ /^#[.]end-str/){
			_embed_str_id = ""
		}else if (_embed_str_id != ""){
			if (EMBED_STR [_embed_str_id] != "")
				_nl = "\n"
			else
				_nl = ""

			EMBED_STR [_embed_str_id] = EMBED_STR [_embed_str_id] _nl substr($0, 3)
		}
	}
	xclose(MODMAIN)
}
