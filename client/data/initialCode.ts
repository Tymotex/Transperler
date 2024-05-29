export const initShSourceCode = `#!/bin/sh

# → Start typing!


# Some examples of what you can transpile:
myVal=42
if test $myVal -eq 42; then
    echo 42!
fi

for i in 2 4 6; do
    echo $i
done

grep -i "hi" bar.txt

foo=1
case $foo in
    1)
        echo "Hello world"
        ;;
    2) 
        echo "Goodbye world"
        ;;
esac
`;

export const initPlSourceCode = `#!/usr/bin/perl

# → Start typing!


# Some examples of what you can transpile:
$myVal = 42;
if ($myVal == 42) {
    print "42!\\n";
}

for $i (2, 4, 6) {
    print "$i\\n";
}

system("grep -i "hi" bar.txt");

$foo = 1;
if ($foo eq 1) {
    print "Hello world\\n";
}
elsif ($foo eq 2) {
    print "Goodbye world\\n";
}
`;
