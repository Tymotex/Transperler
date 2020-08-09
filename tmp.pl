#!/usr/bin/perl -w

$myVar = 3;
if (2 >= 0) {
    if ($myVar eq 1) {
        print "hello\n";
    }
    elsif ($myVar eq 2) {
        print "hi\n";
        $myOtherVar = 5;
        if ($myOtherVar eq 'hello') {
            print "I'm here\n";
        }
        elsif ($myOtherVar eq world) {
            print "I'm actually here\n";
        }
        else {
            print "I'm really here\n";
            $yetAnotherVar = 1;
            if ($yetAnotherVar eq 1) {
                print "hello\n";
            }
        }
    }
    elsif ($myVar eq 3) {
        print "hey\n";
        if (5 < 10) {
            print "hahahahahaha ha\n";
        }
    }
    else {
        print "why hello\n";
        for $i (3, 4, 5) {
            print "hehehehe hehehe $i\n";
        }
    }
}

$outerVar = 10;
if ($outerVar eq 1) {
    print "outer var\n";
}
elsif ($outerVar eq 2) {
    print "hello\n";
}
