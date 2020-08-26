#!/usr/bin/sh
# Testing globbing behaviour

touch a.c b.c a.h b.h 
for file in *.c *.h *.c *.h *.c *.h
do
    echo $file
done
rm ?.c 
rm *.[h]
