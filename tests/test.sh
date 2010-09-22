#!/bin/sh

set -e

LC_ALL=C
export LC_ALL

unset AWKPATH || true

OBJDIR=${OBJDIR:=..}
SRCDIR=`pwd`/..

unify_paths (){
    sed -e "s,/.*/tests,ROOT," \
	-e 's,/tmp/runawk[.]......,/tmp/runawk.NNNNNN,' \
	-e 's,new_argv \[0\] = .*awk.*,new_argv [0] = awk,' \
	-e 's,ARGV\[0\]=.*awk.*,ARGV[0]=awk,' \
	-e 's,FILENAME=-$,FILENAME=,' \
	-e 's,/tmp/awk[.][^/]*/,/tmp/awk.XXXX/,'
}

runtest_header (){
    echo '--------------------------------------------------'
    printf ' ------ args: %s\n' "$*" | unify_paths
}

runtest_main (){
    $OBJDIR/runawk "$@" 2>&1 | grep -v '/_test_program' | unify_paths
}

runtest (){
    runtest_header "$@"
    runtest_main "$@"
}

runtest_nostderr (){
    runtest_header "$@"
#    runtest_main "$@" '2>/dev/null'
    $OBJDIR/runawk "$@" 2>/dev/null | grep -v '/_test_program' | unify_paths
}

PATH=${SRCDIR}/examples:${SRCDIR}:$PATH
export PATH

####################

AWKPATH=${SRCDIR}/modules
export AWKPATH

trap 'rm -f _test_program _test.tmp' 0 1 2 3 15
touch _test_program

runtest -d  _test_program
runtest -d  _test_program --long-option
runtest --debug  _test_program -o=file
runtest -d --without-stdin _test_program -o=file
runtest --debug -I _test_program -o=file
runtest -d  _test_program fn1 fn2
runtest -di _test_program arg1 arg2
runtest -d -f abs.awk -e 'BEGIN {print abs(-123), abs(234); exit}'
runtest -d -f alt_assert.awk -e 'BEGIN {exit}'
runtest --debug --with-stdin _test_program arg1 arg2
runtest -V | awk 'NR <= 2 {print $0} NR == 3 {print "xxx"}'
runtest -h | awk 'NR <= 3'
runtest -e 'BEGIN {print "Hello World"}'
runtest -v one=1 -e 'BEGIN {print one} {print "unbelievably"}' /dev/null
runtest -v two=2 -e 'BEGIN {print two}'
runtest --execute 'BEGIN {print "Hello World"}' /dev/null
runtest --assign var1=123 -v var2=321 -e 'BEGIN {print var1, var2}'

unset AWKPATH || true

################## use
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

unset AWKPATH || true
runtest _test.tmp

################### RUNAWK_MODx
AWKPATH=${SRCDIR}/modules:`pwd`/mods2
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
runtest_header '#interp-var directive'

interp_var_test (){
    $OBJDIR/runawk -e '
#interp-var "INTERP_VAR_TEST"

BEGIN {
   print 123
   exit 0
}
' 2>&1 | sed 's/failed:.*/failed/'
}

# success
interp_var_test

# failure
INTERP_VAR_TEST=/invalid/path
export INTERP_VAR_TEST
interp_var_test
unset INTERP_VAR_TEST

####################
runtest_header '#safe-use directive'

touch $OBJDIR/temp1.awk
touch $OBJDIR/temp2.awk

safe_use_test (){
    echo "--- #safe-use test: ---"
    $OBJDIR/runawk -d -e "
#safe-use \"$1\" \"$2\" \"$3\"

BEGIN {
   print 123
   exit 0
}
" |
    unify_paths |
    sed -e 's,/[^ ]*/temp1.awk,/path/temp1.awk,' \
	-e 's,/[^ ]*/temp2.awk,/path/temp2.awk,'
}

safe_use_test "/bad/path1" "$OBJDIR/temp1.awk" "/bad/path2"
safe_use_test "$OBJDIR/temp1.awk" "/bad/path2"  "/bad/path1"
safe_use_test "/bad/path1" "$OBJDIR/temp3.awk" "$OBJDIR/temp2.awk"
safe_use_test "/bad/path3" "/bad/path2" "/bad/path1"

####################
runtest -e '
#use "/invalid/path/file.awk"
'

####################
runtest -d -e '
BEGIN {
   for (i=0; i < ARGC; ++i){
      printf "ARGV [%s]=%s\n", i, ARGV [i]
   }
}' -- -a -b -c

####################
runtest -e '
BEGIN {
   for (i=1; i < ARGC; ++i){
      printf "ARGV [%s]=%s\n", i, ARGV [i]
   }
}' -- file1 file2 file3

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
AWKPATH=${SRCDIR}/modules
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

runtest -f abs.awk -e 'BEGIN {print abs(-123), abs(234); exit}'

runtest -f alt_assert.awk -e 'BEGIN {assert(0, "Hello assert!")}'

############################################################
AWKPATH=${SRCDIR}/modules:${SRCDIR}/modules/gawk
export AWKPATH
####################    multisub
runtest ../examples/demo_multisub

####################    tokenre
runtest ../examples/demo_tokenre  ../examples/demo_tokenre.in
runtest ../examples/demo_tokenre2 ../examples/demo_tokenre2.in
runtest ../examples/demo_tokenre3 ../examples/demo_tokenre3.in

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
runtest ../examples/demo_power_getopt -ffss --flag --long-flag |
sort
echo //////////////////////////////////////////////////
runtest ../examples/demo_power_getopt -h 2>&1 |
sort
echo //////////////////////////////////////////////////
runtest ../examples/demo_power_getopt -f --long-flag -s -F123 --FLAG=234 --LONG-FLAG 345 -S 456 2>&1 |
sort
echo //////////////////////////////////////////////////
runtest ../examples/demo_power_getopt -f --long-flag -s -F123 --FLAG=234 --LONG-FLAG 345 -S 456 -P arg1 '' arg3 arg4 '' 2>&1 |
sort
echo //////////////////////////////////////////////////

runtest ../examples/demo_power_getopt2 --help
runtest ../examples/demo_power_getopt2 -?

####################    runcmd
runtest ../examples/demo_runcmd

####################    heapsort
runtest_header ../examples/demo_heapsort2
for i in 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0; do
    runtest_main ../examples/demo_heapsort2
done

runtest ../examples/demo_heapsort < ../examples/demo_heapsort.in
runtest ../examples/demo_heapsort3 < ../examples/demo_heapsort3.in

####################    quicksort
runtest_header ../examples/demo_quicksort2
for i in 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0; do
    runtest_main ../examples/demo_quicksort2
done

runtest ../examples/demo_quicksort < ../examples/demo_heapsort.in
runtest ../examples/demo_quicksort3 < ../examples/demo_heapsort3.in

####################    fieldwidths
runtest ../examples/demo_fieldwidths < ../examples/demo_fieldwidths.in

####################    tmpfile
runtest ../examples/demo_tmpfile

####################    trim
runtest ../examples/demo_trim ../examples/demo_trim.in

####################    trim_in
runtest ../examples/demo_trim_in ../examples/demo_trim.in
runtest -v TRIM=' ' ../examples/demo_trim_in ../examples/demo_trim.in
runtest -v TRIM='c' ../examples/demo_trim_in ../examples/demo_trim.in

####################    backslash_in
runtest ../examples/demo_backslash_in ../examples/demo_backslash_in.in

####################    ini
runtest ../examples/demo_ini : ../examples/demo_ini.in
runtest ../examples/demo_ini '' ../examples/demo_ini.in

####################    alt_getopt(1)
test_process_args (){
    ../alt_getopt \
	'v|verbose' 'verbose=1' \
	'h help'    help \
	'fake'      fake_flag=1 \
	'=len'      len= \
	'=o output' output= \
	'=m msg'    "msg=" \
	'V version' "echo 'alt_getopt-0-1-0 written by Aleksey Cheusov <vle@gmx.net>'" \
	=n          number= \
	-- "$@"
}

runtest_header 'alt_getopt #1'
test_process_args \
   -h --help -v --verbose -V -o 123 -o234 --output 'file with spaces' -n 999 -n9999 --len 5 --fake \
   -hVv --len 10 --len=100 -m "Aleksey's cat is female" \
   --msg="backslashes (\) is not a problem too" -- -1 -2 -3

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #1'
../examples/demo_alt_getopt.sh

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #1.5'
../examples/demo_alt_getopt.sh arg1 arg2 arg3

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #2'
../examples/demo_alt_getopt.sh -n123 -m "Aleksey's cat is female" arg1

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #3'
../examples/demo_alt_getopt.sh --len=123 -m "Aleksey's cat is female" arg1 arg2

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #4'
../examples/demo_alt_getopt.sh --len 123 -f -m "Aleksey's cat is female" -- -a1 -a2

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #5'
../examples/demo_alt_getopt.sh -n123 --o file.txt -fhFvvv --len=100 \
    -o/path/to/file.out 2>&1

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt.sh #5'
../examples/demo_alt_getopt.sh -n 123 --o file.txt -fhFvq --len=100 \
    -o/path/to/file.out 2>&1

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt2.sh #1'
../examples/demo_alt_getopt2.sh -h 2>&1

####################    demo_alt_getopt.sh
runtest_header 'demo_alt_getopt2.sh #2'
../examples/demo_alt_getopt2.sh --version 2>&1

####################    minmax
runtest_header 'demo_minmax #1'
../examples/demo_minmax 1>&2

####################    ftrans
runtest ../examples/demo_ftrans /dev/null
runtest ../examples/demo_ftrans \
    ../examples/demo_readfile.in
runtest ../examples/demo_ftrans \
    ../examples/demo_readfile.in ../examples/demo_shquote.in \
    ../examples/demo_fieldwidths.in
runtest ../examples/demo_ftrans <<'EOF'
foo
bar
baz
EOF
####################    -F
runtest_header '-F #1'
$OBJDIR/runawk -F: -d -e '{print}'
runtest_header '-F #2'
$OBJDIR/runawk -d -F: -e '{print}'
runtest_header '-F #3'
echo '1:2:3:4' | $OBJDIR/runawk -F: -v a=1 -e '{print "a=" a, NF ":" $1, $2, $3, $4}'
echo '1:2:3:4' | $OBJDIR/runawk -v b=2 -F: -e '{print "b=" b, NF ":" $1, $2, $3, $4}'
