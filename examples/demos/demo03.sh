#!/bin/dash

greet() {
    local firstname
    firstname=$1
    echo "Hello I'm $firstname" 
}

for i in 1 2 3 4 5 andrew taylor; do
    greet $i
done
