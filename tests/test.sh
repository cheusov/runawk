#!/bin/sh

set -e

unify_paths (){
    sed -e "s,`pwd`,ROOT," \
	-e 's,/tmp/runawk[.]......,/tmp/runawk.NNNNNN,' \
	-e 's,new_argv \[0\] = .*awk,new_argv [0] = awk,' \
	-e 's,ARGV\[0\]=.*awk,ARGV[0]=awk,' \
	-e 's,FILENAME=-$,FILENAME=,'
}

runtest (){
    echo '--------------------------------------------------'
    echo "------- args: $@" | unify_paths
    ../runawk "$@" 2>&1 | awk '!/\/_test_program/' | unify_paths
}

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

cat > _test.tmp <<EOF
#use "`pwd`/mods1/module1.1.awk"
#use "`pwd`/mods1/module1.3.awk"
#use "module2.1.awk"
#use "module2.3.awk"
EOF

export AWKPATH=`pwd`/mods2
runtest _test.tmp

unset AWKPATH
runtest _test.tmp

####################

export AWKPATH=`pwd`/mods3
runtest `pwd`/mods3/failed1.awk
runtest `pwd`/mods3/failed2.awk
runtest `pwd`/mods3/failed3.awk
runtest `pwd`/mods3/failed4.awk

####################

export TESTVAR=testval
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
export AWKPATH=`pwd`/../modules
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
export AWKPATH=`pwd`/../modules
runtest test_multisub

####################    tokenre
runtest test_tokenre

####################    tokenre
runtest test_getopt -h
runtest test_getopt --help
runtest test_getopt -h --help -v --verbose -V -o 123 -o234
runtest test_getopt --output 123 --output 234 -n 999 -n9999 --len 5 --fake
