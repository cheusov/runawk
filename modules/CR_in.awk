# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 CR_in.awk
#
# As the name of this module says (_in suffix) this module reads and
# optionally changes input lines.
# 
# Carriage-Return symbol at the end of input lines is removed.
# This symbol usually appears in Windows text files.
# If you want to adapt your script to accept windows files on input,
# just put
#
#    #use "CR_in.awk"
#
# in the very beginning of your script.
#

{
	gsub(/\r+$/, "")
}
