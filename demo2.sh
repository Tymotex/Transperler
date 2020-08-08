#!/usr/bin/sh
# Testing echo

echo '\\\\'
myVar="This is myVar"
echo "hello    $myVar    world " 1 2 'Andrew' "Taylor" 'the variable $myVar has been escaped !!    yes' wow
echo -n "This line has no newline" 'at ' the end
echo $ and '$' gets escaped properly

