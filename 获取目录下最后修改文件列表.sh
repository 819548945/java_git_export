#!/bin/bash
statistics(){
    LATEST_FILE=$(find $1 -type f -printf "%T@ %p\n" | sort -n | tail -$2 | cut -d' ' -f2-)
    for fname in $LATEST_FILE
    do
        echo "$(stat -c %y "$fname")  $fname "
    done
}
if [ $# = 1 ];then
   statistics $1 1
elif [ $# = 2 ];then
   
     statistics $1 $2
else
    echo -e 参数个数错误;
fi