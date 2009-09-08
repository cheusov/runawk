#!/bin/sh

set -e

LC_ALL=C
export LC_ALL

OBJDIR=${OBJDIR:=..}

unify_paths (){
    sed -e "s,`pwd`,ROOT," \
	-e 's,/tmp/runawk[.]......,/tmp/runawk.NNNNNN,' \
	-e 's,new_argv \[0\] = .*awk,new_argv [0] = awk,' \
	-e 's,ARGV\[0\]=.*awk,ARGV[0]=awk,' \
	-e 's,FILENAME=-$,FILENAME=,'
#	-e 's,[.][.]/examples/,,'
}

runtest (){
    echo '--------------------------------------------------'
    echo "------- args: $@" | unify_paths
    $OBJDIR/runawk "$@" 2>&1 | grep -v '/_test_program' | unify_paths
}

runtest_nostderr (){
    echo '--------------------------------------------------'
    echo "------- args: $@" | unify_paths
    $OBJDIR/runawk "$@" 2>/dev/null | grep -v '/_test_program' | unify_paths
}

PATH=`pwd`/examples:$PATH
export PATH

####################

trap 'rm -f _test_program _test.tmp' 0 1 2 3 15
touch _test_program

runtest -d  _test_program
runtest -d  _test_program --long-option
runtest --debug  _test_program -o=file
runtest -d --without-stdin _test_program -o=file
runtest --debug -I _test_program -o=file
runtest -d  _test_program fn1 fn2
runtest -di _test_program arg1 arg2
runtest --debug --with-stdin _test_program arg1 arg2
runtest -V | awk 'NR <= 2 {print $0} NR == 3 {print "xxx"}'
runtest -h | awk 'NR <= 3'
runtest -e 'BEGIN {print "Hello World"}'
runtest -v one=1 -e 'BEGIN {print one} {print "unbelievably"}' /dev/null
runtest -v two=2 -e 'BEGIN {print two}'
runtest --execute 'BEGIN {print "Hello World"}' /dev/null
runtest --assign var1=123 -v var2=321 -e 'BEGIN {print var1, var2}'

################### use
cat > _test.tmp <<EOF
#use "`pwd`/mods1/module1.1.awk"
#use "`pwd`/mods1/module1.3.awk"
#use "module2.1.awk"
#use "module2.3.awk"
EOF

####################
AWKPATH=`pwd`/mods2
export AWKPATH
runtest _test.tmp

unset AWKPATH
runtest _test.tmp

################### RUNAWK_MODx
AWKPATH=`pwd`/../modules:`pwd`/mods2
export AWKPATH

runtest `pwd`/mods1/test_modinfo

####################

AWKPATH=`pwd`/mods3
export AWKPATH
runtest `pwd`/mods3/failed1.awk
runtest `pwd`/mods3/failed2.awk
runtest `pwd`/mods3/failed3.awk
runtest `pwd`/mods3/failed4.awk

####################

TESTVAR=testval
export TESTVAR
runtest `pwd`/mods3/test5.awk

####################
runtest -e '
#interp "/invalid/path"

BEGIN {print "Hello World!"}
'

####################
runtest -e '
#use "/invalid/path/file.awk"
'

####################
runtest -d -e '
#env "LC_ALL=C"
#env "FOO2=bar2"

BEGIN {
   ...
}
'

runtest -e '
#env "LC_ALL=C"
#env "FOO2=bar2"

BEGIN {
   print ("y" ~ /^[a-z]$/)
   print ("Y" ~ /^[a-z]$/)
   print ("z" ~ /^[a-z]$/)
   print ("Z" ~ /^[a-z]$/)

   print ("env FOO2=" ENVIRON ["FOO2"])
}
'

####################
AWKPATH=`pwd`/../modules
export AWKPATH
runtest -d -e '
#use "alt_assert.awk"

BEGIN {
   print "Hello world!"
   abort("just a test", 7)
}
' /dev/null

runtest -e '
#use "alt_assert.awk"

BEGIN {
   abort("just a test", 7)
}
'

####################    multisub
AWKPATH=`pwd`/../modules
export AWKPATH
runtest ../examples/demo_multisub

####################    tokenre
runtest ../examples/demo_tokenre  ../examples/demo_tokenre.in
runtest ../examples/demo_tokenre2 ../examples/demo_tokenre2.in

####################    getopt
runtest ../examples/demo_alt_getopt -h -
runtest ../examples/demo_alt_getopt --help
runtest ../examples/demo_alt_getopt -h --help -v --verbose -V -o 123 -o234
runtest ../examples/demo_alt_getopt --output 123 --output 234 -n 999 -n9999 --len 5 --fake /dev/null
runtest ../examples/demo_alt_getopt -hVv -- -1 -2 -3
runtest ../examples/demo_alt_getopt --fake -v -- -1 -2 -3
runtest ../examples/demo_alt_getopt - -1 -2 -3
runtest ../examples/demo_alt_getopt --fake -v - -1 -2 -3
runtest ../examples/demo_alt_getopt -1 -2 -3
runtest ../examples/demo_alt_getopt -hvV
runtest ../examples/demo_alt_getopt -ho 123
runtest ../examples/demo_alt_getopt -hoV 123
runtest ../examples/demo_alt_getopt --unknown
runtest ../examples/demo_alt_getopt --output='file.out' -nNNN --len=LENGTH
runtest ../examples/demo_alt_getopt --output --file--

####################    modinfo
runtest ../examples/demo_modinfo

####################    has_suffix
runtest ../examples/demo_has_suffix  ../examples/demo_has_suffix.in

####################    has_prefix
runtest ../examples/demo_has_prefix  ../examples/demo_has_prefix.in

####################    dirname
runtest ../examples/demo_dirname
runtest ../examples/demo_dirname /path/to/file
runtest ../examples/demo_dirname file.txt
runtest ../examples/demo_dirname /
runtest ../examples/demo_dirname /dir/

####################    basename
runtest ../examples/demo_basename
runtest ../examples/demo_basename /path/to/file
runtest ../examples/demo_basename file.txt
runtest ../examples/demo_basename /
runtest ../examples/demo_basename /dir/

runtest ../examples/demo_basename /path/to/file.txt .txt
runtest ../examples/demo_basename file.txt .txt
runtest ../examples/demo_basename / .txt
runtest ../examples/demo_basename /dir/ .txt

runtest ../examples/demo_basename /path/to/file.txt .log
runtest ../examples/demo_basename file.txt .log
runtest ../examples/demo_basename / .log
runtest ../examples/demo_basename /dir/ .log

####################    shquote
runtest ../examples/demo_shquote ../examples/demo_shquote.in

####################    alt_join
runtest_nostderr ../examples/demo_alt_join

####################    readfile
runtest ../examples/demo_readfile
runtest ../examples/demo_readfile ../examples/demo_readfile.in

####################    power_getopt
runtest ../examples/demo_power_getopt
echo //////////////////////////////////////////////////
runtest ../examples/demo_power_getopt -h 2>&1 | sort
echo //////////////////////////////////////////////////
runtest ../examples/demo_power_getopt -f --long-flag -s -F123 --FLAG=234 --LONG-FLAG 345 -S 456 2>&1 | sort
echo //////////////////////////////////////////////////
