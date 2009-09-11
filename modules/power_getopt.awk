# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RUNAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

#use "alt_getopt.awk"
#use "embed_str.awk"

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

	if (__getopt_opts [opt] == takes_arg)
		if (opt in options)
			return options [opt]
		else
			return dflt
	else
		if (opt in options)
			return 1
		else
			return 0
}

BEGIN {
	if ("help" in EMBED_STR){
		_help_msg = EMBED_STR ["help"]
		_help_msg_cnt = split(_help_msg, _help_msg_arr, /\n/)
		for (i = 1; i <= _help_msg_cnt; ++i){
			if (match(_help_msg_arr [i], /^[ \t]*[-=][^ \t]+/)){
				_opt = substr(_help_msg_arr [i], RSTART, RLENGTH)
				sub(/^[ \t]+/, "", _opt)

				if (_opt ~ /^-.[|]--.+$/){
					# -h|--help
					_sopt = substr(_opt, 1, 2)
					_lopt = substr(_opt, 4)
				}else if (_opt ~ /^=.[|]--.+$/){
					# =h|--help
					_sopt = substr(_opt, 1, 2)
					_lopt = "=" substr(_opt, 5)
				}else if (_opt ~ /^[-=].$/){
					# -h or =h
				_sopt = _opt
					_lopt = ""
				}else if (_opt ~ /^[-=]-.+$/){
					# --help or =-help
					_sopt = ""
					_lopt = _opt
				}

				if (_sopt ~ /^-.$/){
					# -h
					short_opts = short_opts substr(_sopt, 2, 1)
				}else if (_sopt ~ /^=.$/){
					# =F
					short_opts = short_opts substr(_sopt, 2, 1) ":"
				}

				sub(/^[-=]/, "", _sopt)

				if (_lopt ~ /^--.+$/){
					# --help
					long_opts [substr(_lopt, 3)] = _sopt
				}else if (_lopt ~ /^=-.+$/){
					# =-FLAG
					if (_sopt != "")
						long_opts [substr(_lopt, 3)] = _sopt
					else
						long_opts [substr(_lopt, 3)] = takes_arg
				}
			}
		}

		# options
		while (getopt(short_opts)){
			if (optopt in long_opts){
				_i = long_opts [optopt]
				if (_i != "" && _i != takes_arg)
					optopt = _i
			}
			options [optopt] = optarg
		}

		if ("help" in options){
			print_help()
			exit 0
		}
		if (("help" in long_opts) && (long_opts ["help"] in options)){
			print_help()
			exit 0
		}
	}
}
