#!/usr/bin/sh
# Testing nested switch-case

myVar=2
case $myVar in
    1)
        ;;
    2)
        myOtherVar='hello'
        case $myOtherVar in
            hello)
                yetAnotherVar=1;
                case $yetAnotherVar in
                    1)
                        echo hello
                        ;;
                esac
                ;;
            esac
        ;;
esac