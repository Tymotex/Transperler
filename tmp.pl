#!/usr/bin/perl -w


for $a ('fuck') {
    print "$a\n";
}

for $a ("@ARGV") {
    print "$a\n";
}

for $a (@ARGV) {
    print "$a\n";
}
