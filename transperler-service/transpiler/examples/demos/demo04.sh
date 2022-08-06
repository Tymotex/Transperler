#!/bin/dash
# Extensive nesting of loops and switch-case statements

myVar=3
if test 2 -ge 0; then
    case $myVar in
        1)
            echo hello
            ;;
        2)
            echo hi
            myOtherVar=5
            case $myOtherVar in
                hello)
                    echo "I'm here"
                    ;;
                world)
                    echo "I'm actually here"
                    ;;
                *)
                    echo "I'm really here"
                    yetAnotherVar=1;
                    case $yetAnotherVar in
                        1)
                            echo hello
                            ;;
                    esac
                    ;;
                esac
            ;;
        3)
            echo hey
            if test 5 -lt 10
            then
                echo hahahahahaha ha
            fi
            ;;
        *)
            echo why hello
            for i in 3 4 5; do
                echo hehehehe hehehe $i
            done
            ;;
    esac
fi

outerVar=10
case $outerVar in
    1)
        echo outer var
        ;;
    2) 
        echo hello 
        ;;
esac

