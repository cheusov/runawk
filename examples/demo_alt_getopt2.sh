#!/bin/sh

# this is a demo for alt_getopt(1) program and alt_getopt.sh shell module

. alt_getopt.sh

help () {
    cat 1>&2 <<EOF
demo_alt_getopt2.sh is a demo program for alt_getopt.sh
OPTIONS:
$help_msg
EOF
}

# Variable "help_msg" consists of third arguments of add_arg
# invocations separated with NL symbol. See help function above.
add_arg 'h help'    'help; exit 0' \
    '  -h|--help        display this help'
add_arg 'v|version' "echo 'demo_alt_getopt2.sh 0.1.0'" \
    '  -v|--version     display version'
add_arg '=o|output' "output=" \
    '  -o|--output      output file'

cmds=`process_args "$@"`
eval "$cmds"
#shift `process_args "$@"`

echo "output=$output"
