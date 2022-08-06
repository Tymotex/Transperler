#!/bin/dash
# A demo for subset 0
# Testing variable assignments, reassignments
# and variable interpolation in printing when translating from echo

myVar=3
myOtherVar="Hello Andrew Taylor"
# This is a comment!  do not get translated
echo $myVar and $myOtherVar
myVar=$myOtherVar
echo $myOtherVar $myVar
