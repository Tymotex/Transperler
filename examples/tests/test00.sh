#!/usr/bin/sh
# Testing tokenisation with echo on problematic arguments

echo '\\\\'
myVar="This is myVar"
echo "hello    $myVar    world " 1 2 'Andrew' "Taylor" 'the variable $myVar has been escaped !!    yes' wow
echo -n "This line has no newline" 'at ' the end
echo '$' gets escaped properly
