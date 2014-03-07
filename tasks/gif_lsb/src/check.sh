#!/bin/bash

[ ${#@} -eq 3 ] || {
    echo "usage: $0 <base_file> <key> <result_file>"
    exit
} 

BASE=$1
KEY=$2
OUTPUT=$3

./create.pl $BASE $KEY >$OUTPUT || exit
convert $OUTPUT -scene 1 +adjoin temp_%d.gif

RESULT=`./deparse.pl $((${#KEY} * 8)) temp_*`

[ $RESULT = $KEY ] && echo "OK"
rm temp_*

