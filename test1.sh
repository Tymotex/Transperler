#!/bin/dash
for c_file in *.c
do
    echo $c_file
    for h_file in *.h
    do
        echo $h_file
        # This is a comment
        echo I love perl
    done
done
