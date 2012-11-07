# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

# =head2 runcwd.awk
#
# =over 2
#
# =item I<runcmd1 (CMD, OPTS, FILE)>
#
# wrapper for system() function
# that runs a command CMD with options OPTS and one filename FILE.
# Unlike system(CMD " " OPTS " " FILE) the function runcmd1 handles
# correctly FILE containing spaces, single quote, double quote,
# tilde etc.
#
# =item I<xruncmd1 (FILE)>
#
# safe wrapper for 'runcmd1'.
# awk exits with error if runcmd1() function failed.
#
# =back
#

#use "alt_assert.awk"
#use "shquote.awk"

function runcmd1 (cmd, opts, file){
	return system(shquote(cmd) " " opts " " shquote(file))
}

function xruncmd1 (cmd, opts, file){
	assert(runcmd1(cmd, opts, file) == 0, "runcmd1() failed")
}
