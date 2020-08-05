#!/usr/bin/perl -w
for $c_file (glob("*.c")) {
    system("gcc -c $c_file");
}
