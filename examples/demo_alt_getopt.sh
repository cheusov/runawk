#!/bin/sh

# Copyright (c) 2007-2008 Aleksey Cheusov <vle@gmx.net>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# this is a demo for alt_getopt(1) program, not for alt_getopt.awk module!

help () {
    cat 1>&2 <<EOF
blablabla help
EOF
}

process_args (){
    alt_getopt \
	'v|verbose' 'verbose=1' \
	'h help'    help \
	'fake'      fake_flag=1 \
	'=len'      len= \
	'=o output' output= \
	'=m msg'    "msg=" \
	'V version' "echo 'alt_getopt-0-1-0, written by Aleksey Cheusov <vle@gmx.net>'" \
	f           'flag=1' \
	F           'flag=' \
	=n          number= \
	-- "$@"
}

a=`process_args "$@"`
eval "$a"

echo "verbose=$verbose"
echo "fake_flag=$fake_flag"
echo "len=$len"
echo "output=$output"
echo "msg=$msg"
echo "n=$number"
echo "flag=$flag"

i=1
while test $# -ne 0; do
    printf "arg [%d]=%s\n" "$i" "$1"
    i=`expr $i + 1`
    shift
done
