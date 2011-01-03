# -*- mode: sh; -*-

__nl='
'

__shq (){
    __cmd=`printf '%s\n' "$1" | sed "s|'|'\\\\\''|g"`
    printf "%s\n" "'$__cmd'"
}

add_arg (){
    if test $# -ne 2 -a $# -ne 3; then
	echo 'add_arg function requires either 2 or three arguments' 1>&2
	exit 10
    fi
    if test $# -eq 3; then
	help_msg="${help_msg}$3$__nl"
    fi
    __i=`__shq "$1"`
    __args="$__args $__i"
    __i=`__shq "$2"`
    __args="$__args $__i"
}

__run_alt_getopt (){
    eval "alt_getopt $__args" "$@"
}

process_args (){
    __args="$__args --"
    for i in "$@"; do
	__i=`__shq "$1"`
	__args="$__args $__i"
	shift
    done
    __cmds=`eval alt_getopt -c $__args`
    eval "$__cmds"
}
