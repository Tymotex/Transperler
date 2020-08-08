#!/bin/bash


for a in $*
do
    echo $a
done

for a in "$@"
do
    echo $a
done

for a in $@
do
    echo $a
done    
