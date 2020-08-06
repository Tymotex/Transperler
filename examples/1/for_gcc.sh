#!/bin/dash
for c_file in *.c *.h
do
    echo gcc -c $c_file
done
