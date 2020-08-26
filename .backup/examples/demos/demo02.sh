#!/usr/bin/sh

i=10
while test $i -lt 100
do
    echo $i
    i=$(expr $i \* 2)
    j=2
    while test $j -lt 100
    do
        echo $j
        j=$(expr $j \* 2 \* 2)
        if [ $j -eq 32 ]
        then
            echo hehehe
        elif [ $j -eq 80 ]
        then
            echo hahaha
        else
            echo hohoho
        fi        
    done
done

