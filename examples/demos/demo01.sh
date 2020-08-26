#!/usr/bin/sh
# Testing loops and nested loops
# and further system command + globbing

for i in 1 2 3 4 5
do
    j=0
    for k in 2 3 4
    do
        echo $k
        for l in 4 5 6
        do
            echo $l
        done
    done
done

touch a.c b.c a.h b.h 
for file in *.c *.h *.c *.h *.c *.h
do
    echo $file
done
rm ?.c ?.h

exit 0
