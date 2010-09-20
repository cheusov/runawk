#!/bin/sh

# this is a demo for alt_getopt(1) program, not for alt_getopt.awk module!

help () {
    cat 1>&2 <<EOF
demo_alt_getopt2.sh is a demo program for alt_getopt(1)
OPTIONS:
$help_msg
EOF
}

process_args (){
    alt_getopt -m \
	'h help'    'help; exit 0' \
            '  -h|--help        display this help' \
	'v|version' 'echo "demo_alt_getopt2.sh 0.1.0"' \
            '  -v|--version     display version' \
	-- "$@" # You MUST specify -- here
}

cmds=`process_args "$@"`
#printf '%s' "$cmds"
eval "$cmds"
