#!/usr/bin/perl

sub modify {
    my @arr = @{$_[0]};

    foreach $elem (@arr) {
        @arr[0] = $elem + 1;
        print("Elem: $elem\n");
    }
}

my @myArr = (1, 2, 3);
modify(\@myArr);

foreach $elem (@myArr) {
    print("Elem: $elem\n");
}
