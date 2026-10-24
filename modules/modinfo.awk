# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        https://github.com/cheusov/runawk
#    
############################################################

# =head2 modinfo.awk
#
# This module provides the following variables
#
# =over 2
#
# =item I<MODC>
#
# A number of modules (-f <filename>) passed to an awk interpreter
#
# =item I<MODV>
#
# Array with [0..MODC) indexes of those modules
#
# =item I<MODMAIN>
#
# Path to the main module, i.e. program filename
#
# =back
#
# See example/demo_modinfo for the sample of usage
#

BEGIN {
	MODC = ENVIRON ["RUNAWK_MODC"] + 0 # force to number

	for (i=0; i < MODC; ++i){
		MODV [i] = ENVIRON ["RUNAWK_MODV_" i]
	}

	MODMAIN = MODV [MODC-1]
}
