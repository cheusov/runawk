#!/bin/sh

set -e

runtest (){
    echo '--------------------------------------------------'
    echo "------- args: $@"
    ../runawk "$@"
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
runtest --execute 'BEGIN {print "Hello World"}'

cat > _test.tmp <<EOF
#use "`pwd`/mods1/module1.1.awk"
#use "`pwd`/mods1/module1.3.awk"
#use "module2.1.awk"
#use "module2.3.awk"
EOF

export AWKPATH=`pwd`/mods2
runtest _test.tmp
