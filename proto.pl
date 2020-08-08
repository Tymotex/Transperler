#!/usr/bin/perl

sub escapeCharacters($$) {
    my $line = $_[0];
    my $charToEscape = $_[1];
    
    $line =~ s/$charToEscape/\\$charToEscape/g;
    return $line;
}
