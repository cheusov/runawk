# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#    
############################################################

#
# This module provides the following variables
#
# MODC - A number of modules (-f <filename>) passed to an awk
#        interpreter
# MODV - Array with [0..MODC) indexes of those modules
#
# MODMAIN - Path to the main module, i.e. program filename
#

# See example/demo_modinfo for the sample of usage

BEGIN {
	MODC = ENVIRON ["RUNAWK_MODC"] + 0 # force to number

	for (i=0; i < MODC; ++i){
		MODV [i] = ENVIRON ["RUNAWK_MODV_" i]
	}

	MODMAIN = MODV [MODC-1]
}
