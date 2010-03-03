# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

#use "init_getopt.awk"

# power_getopt.awk module provides a very easy way to add options
# to AWK application and follows rules from
# SUS/POSIX "Utility Syntax Guidelines"
#
# power_getopt.awk analyses '.begin-str help/.end-str' section in
# AWK program (main module), and processes options specified there.
# The following strings mean options:
#  -X             single letter option
#  --XXX          long option
#  -X|--XXX       single letter option with long synonym
#  =X             single letter option with argument
#  =-XXX          long option with argument
#  =X|--XXX       single letter option and long synonym with argument
#
# If --help option was applied, usage information is printed
# (lines between ".begin-str help" and ".end-str") replacing leading
# `=' character with `-'.
#
# power_getopt.awk also provides the function getarg.
#
# getarg(OPT, DEFAULT)
#  returns either 1 (option OPT was applied) or 0 (OPT was not
#  applied) for options not accepting the argument, and either
#  specified value or DEFAULT for options accepting the argument.
#
# See example/demo_power_getopt for the sample of usage
#

function print_help (            i){
	for (i = 1; i <= _help_msg_cnt; ++i){
		if (_help_msg_arr [i] ~ /^[ \t]*=/){
			sub(/=/, "-", _help_msg_arr [i])
		}
		print _help_msg_arr [i] > "/dev/stderr"
	}
}

function getarg (opt, dflt,              tmp){
	assert(opt in __getopt_opts, "Bad option `" opt "`")

	if (opt in long_opts){
		tmp = long_opts [opt]
		if (tmp != "" && tmp != takes_arg)
			opt = tmp
	}

	if (opt in options){
		return options [opt]
	}else if (__getopt_opts [opt] == takes_arg){
		return dflt
	}else{
		return 0
	}
}

BEGIN {
	# options
	__getopt_fill = "\001getopt_fake\002"

	while (getopt(short_opts)){
		if (optopt in long_opts){
			_i = long_opts [optopt]
			if (_i != "" && _i != takes_arg)
				optopt = _i
		}
		if (__getopt_opts [optopt] == takes_arg)
			options [optopt] = optarg
		else
			++options [optopt]
	}

	__getopt_to = 1
	for (__getopt_from = 1; __getopt_from < ARGC; ++__getopt_from){
		if (ARGV [__getopt_from] != __getopt_fill){
			ARGV [__getopt_to++] = ARGV [__getopt_from]
		}
	}
	ARGC = __getopt_to

	if (("help" in options) ||
		("help" in long_opts) && (long_opts ["help"] in options))
	{
		print_help()
		exitnow(0)
	}
}
