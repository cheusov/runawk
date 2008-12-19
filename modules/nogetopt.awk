# written by Aleksey Cheusov <vle@gmx.net>
# public domain

#use "abort.awk"
#use "alt_assert.awk"

BEGIN {
	opterr = ""

	takes_arg = -1
}

function __nogetopt_prepare (\
	short_opts,
	i, len, nc) # local vars
{
	if ("-" in __nogetopt_opts){
		# already initialized
		return
	}

	len = length(short_opts)
	for (i=1; i <= len; ++i){
		if (i < len && substr(short_opts, i+1, 1) == ":"){
			__nogetopt_opts [substr(short_opts, i, 1)] = takes_arg
			++i
		}else{
			__nogetopt_opts [substr(short_opts, i, 1)] = ""
		}
	}

	for (i in long_opts){
		__nogetopt_opts [i] = long_opts [i]
	}
}

function __nogetopt_process_short_opts (\
	i,
	opts) # local vars
{
	opts = substr(ARGV [i], 2)
	optopt = substr(opts, 1, 1)

	if (! (optopt in __nogetopt_opts)){
		abort("Unknown option `-" optopt "'")
	}

	if (__nogetopt_opts [optopt] == takes_arg){
		if (1){
			if (length(opts) == 1){
				optarg = ARGV [i+1]
				ARGV [i] = ARGV [i+1] = ""
			}else{
				optarg = substr(opts, 2)
				ARGV [i] = ""
			}
			return 1
		}

		abort("Bad usage of option `-" optopt "'")
	}

	if (length(opts) > 2)
		ARGV [i] = "-" substr(opts, 2)
	else
		ARGV [i] = ""

	return 1
}

function __nogetopt_process_long_opts (\
	i,
	opt,val,prefix,eq)
{
	opt = substr(ARGV [i], 3)
	eq = sub(/=.*$/, "", opt)
	prefix = "--"

	if ((opt in __nogetopt_opts) &&
		__nogetopt_opts [opt] != "" &&
		__nogetopt_opts [opt] != takes_arg)
	{
		prefix = "-"
		opt = __nogetopt_opts [opt]
	}

	#			print "opt: " opt > "/dev/stderr"

	if (opt in __nogetopt_opts){
		optopt = opt

		val = __nogetopt_opts [opt]
		if (val == ""){
			assert(!eq, "Unexpected argument for option `" opt "'")
			ARGV [i] = ""
			return opt
		}else if (val == takes_arg){
			if (eq){
				optarg = ARGV [i]
				sub(/^[^=]*=/, "", optarg)
			}else{
				optarg = ARGV [i+1]
				ARGV [i+1] = ""
			}
			ARGV [i] = ""
			return 1
		}
	}

	abort("Unknown option `" prefix opt "'")
}

function nogetopt (\
	short_opts,
	i) # local vars
{
	__nogetopt_prepare(short_opts)

	for (i = 1; i <= ARGC; ++i){
		optarg = ""

		if (ARGV [i] == ""){
			continue
		}

#		print "zzz: " ARGV [i] > "/dev/stderr"

		if (ARGV [i] == "--"){
			ARGV [i] = ""
			return ""
		}

		if (ARGV [i] !~ /^-/ || ARGV [i] == "-"){
			return ""
		}

		if (ARGV [i] ~ /^--/){
			return __nogetopt_process_long_opts(i)
		}

		assert(ARGV [i] ~ /^-/)

		return __nogetopt_process_short_opts(i)
	}
}
