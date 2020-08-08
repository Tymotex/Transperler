#!/usr/bin/perl -w

for $i (1, 2, 'andrew', 'taylor', (glob("*.c"),glob("*.h"))) {
    print "$i\n";
}
