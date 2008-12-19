# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# getopt(SHORT_OPTS) -- like standard getopt(3) function (NOT EQUIVALENT!)
#   This function processes ARGV array and
#   returns TRUE value if option is recieved, 
#   recieved option is saved in 'optopt' variable, option argument (if any)
#   is saved in 'optarg' variable. Long options (like --help or
#   --long-option) present in GNU libc and BSD systems are also supported.
#   See tests/test_getopt script for usage.
# NOTE: 'getopt' function from alt_getopt.awk is not compatible
#       to the function from GNU awk (getopt.awk)

#use "alt_assert.awk"

function __getopt_errexit (msg, status)
{
	fflush()
	print msg > "/dev/stderr"
	exitnow(status)
}

function __getopt_addstdin (                  i)
{
	for (i=1; i <= ARGC; ++i){
		if (ARGV [i] != ""){
			return
		}
	}

	ARGV [1] = "-"
}

BEGIN {
	opterr = ""

	takes_arg = -1
}

function __getopt_prepare (\
	short_opts,
	i, len, nc) # local vars
{
	if ("-" in __getopt_opts){
		# already initialized
		return
	}

	len = length(short_opts)
	for (i=1; i <= len; ++i){
		if (i < len && substr(short_opts, i+1, 1) == ":"){
			__getopt_opts [substr(short_opts, i, 1)] = takes_arg
			++i
		}else{
			__getopt_opts [substr(short_opts, i, 1)] = ""
		}
	}

	for (i in long_opts){
		__getopt_opts [i] = long_opts [i]
	}
}

function __getopt_process_short_opts (\
	i,
	opts) # local vars
{
	opts = substr(ARGV [i], 2)
	optopt = substr(opts, 1, 1)

	if (! (optopt in __getopt_opts)){
		__getopt_errexit("Unknown option `-" optopt "'", 2)
	}

	if (__getopt_opts [optopt] == takes_arg){
		if (!__getopt_shortened [i]){
			if (length(opts) == 1){
				optarg = ARGV [i+1]
				ARGV [i] = ARGV [i+1] = ""
			}else{
				optarg = substr(opts, 2)
				ARGV [i] = ""
			}
			return 1
		}

		__getopt_errexit("Bad usage of option `-" optopt "'", 2)
	}

	++__getopt_shortened [i]

	if (length(opts) > 1)
		ARGV [i] = "-" substr(opts, 2)
	else
		ARGV [i] = ""

	return 1
}

function __getopt_process_long_opts (\
	i,
	opt,val,prefix,eq)
{
	opt = substr(ARGV [i], 3)
	eq = (opt ~ /[=]/)
	sub(/[=].*$/, "", opt)
	prefix = "--"

	if ((opt in __getopt_opts) &&
		__getopt_opts [opt] != "" &&
		__getopt_opts [opt] != takes_arg)
	{
		prefix = "-"
		opt = __getopt_opts [opt]
	}

	if (opt in __getopt_opts){
		optopt = opt

		val = __getopt_opts [opt]
		if (val == ""){
			assert(!eq, "Unexpected argument for option `" opt "'")
			ARGV [i] = ""
			return 1
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

	__getopt_errexit("Unknown option `" prefix opt "'", 2)
}

function getopt (\
	short_opts,
	i) # local vars
{
	__getopt_prepare(short_opts)

	for (i = 1; i <= ARGC; ++i){
		optarg = ""

		if (ARGV [i] == ""){
			continue
		}

		if (ARGV [i] == "--"){
			ARGV [i] = ""
			__getopt_addstdin()
			return 0
		}

		if (ARGV [i] !~ /^-/ || ARGV [i] == "-"){
			return 0
		}

		if (ARGV [i] ~ /^--/){
			return __getopt_process_long_opts(i)
		}

		assert(ARGV [i] ~ /^-/)

		return __getopt_process_short_opts(i)
	}

	__getopt_addstdin()
	return 0
}
