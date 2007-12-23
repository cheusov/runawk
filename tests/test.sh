#!/bin/sh

set -e

runtest (){
    echo '--------------------------------------------------'
    echo "------- args: $@"
    ../runawk "$@"
}

trap 'rm -f test_program' 0 1 2 3 15
touch test_program

runtest -d  test_program
runtest -d  test_program --long-option
runtest -d  test_program -o=file
runtest -dI test_program -o=file
runtest -d  test_program fn1 fn2
runtest -di test_program arg1 arg2
runtest -V | awk 'NR <= 2 {print $0} NR == 3 {print "xxx"}'
runtest -h | awk 'NR <= 3'
runtest -e 'BEGIN {print "Hello World"}'

cat > test.tmp <<EOF
#use "`pwd`/mods1/module1.1.awk"
#use "`pwd`/mods1/module1.3.awk"
#use "module2.1.awk"
#use "module2.3.awk"
EOF

export AWKPATH=`pwd`/mods2
runtest test.tmp
