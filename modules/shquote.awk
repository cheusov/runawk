# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# shquote(str)
#   `shquote' transforms the string `str' by adding shell escape and
#   quoting characters to include it to the system() and popen()
#   functions as an argument, so that the arguments will have the
#   correct values after being evaluated by the shell.
#
# For example:
#      print shquote("file name.txt")
#      |- 'file name.txt'
#      print shquote("'")
#      |- \'
#      print shquote("Peter's")
#      |- 'Peter'\''s'
#      print shquote("*&;<>#~")
#      |- '*&;<>#~'
#
# This module was inspired by NetBSD shquote(3)
#    http://netbsd.gw.com/cgi-bin/man-cgi?shquote+3+NetBSD-current
# and shquote(1) by Alan Barrett
#    http://ftp.sunet.se/pub/os/NetBSD/misc/apb/shquote.20080906/

function shquote (str){
	gsub(/'/, "'\\''", str)
	return "'" str "'"
}
