#!/usr/bin/sh
# Testing extensive nesting

for i in 1 2 3 4 5
do
    j=0
    while test $j -lt $i 
    do
        echo "loop i=$i j=$j"
        if test -r sheeple.pl
        then
            echo "Haha"
        fi
    done
done
