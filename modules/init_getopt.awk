# Written by Aleksey Cheusov <vle@gmx.net>, public domain
#
# This awk module is a part of RunAWK distribution,
#        http://sourceforge.net/projects/runawk
#
############################################################

# =head2 init_getopt.awk
#
# Initialization step for power_getopt.awk module.  In some cases it
# makes sense to process options in a while() loop.  This module
# allows to do this.  See the documentation about how options are
# initialized in power_getopt.awk module.
#
# =over 2
#
# =item I<print_help ()>
#
# display help message.
#
# =back
#

#use "alt_getopt.awk"
#use "embed_str.awk"

function print_help (            i){
	for (i = 1; i <= _help_msg_cnt; ++i){
		if (_help_msg_arr [i] ~ /^[ \t]*=/){
			sub(/=/, "-", _help_msg_arr [i])
		}
		print _help_msg_arr [i] > "/dev/stderr"
	}
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
	}
}
