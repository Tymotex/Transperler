#!/usr/bin/perl

sub globConsecutive {
    my @args = @_;
    my @globbedArgs = ();
    foreach my $arg (@args) {
        print("Globbing: $arg\n");
        push(@globbedArgs, "glob(\"$arg\")");
    }
    my $globbedArgsJoined = "(" . join(", ", @globbedArgs) . ")";
    return $globbedArgsJoined;
}

sub processGlobbing($) {
    my $line = $_[0];
    my @tokens = split(/ /, $line);
    my @newTokens = ();
    for (my $i = 0; $i <= $#tokens; $i++) {
        my $j = $i;
        my $token = $tokens[$i];
        print("CurrToken: $token\n");
        my $isGlob = 0;
        while ($token =~ /(\S*)\*(\S*)/ or $token =~ /(\S*)\?(\S*)/ or $token =~ /(\S*)\[.*\](\S*)/) {
            print("  $token is globbable\n");
            $isGlob = 1;
            last if ($j >= $#tokens);
            $j++;
            $token = $tokens[$j];
        }
        if ($isGlob) {
            my $stopIndex = ($j >= $#tokens) ? ($j) : ($j - 1);
            push(@newTokens, globConsecutive(@tokens[$i..$stopIndex]));
            last if ($j >= $#tokens);
            $i = $j - 1;            
        } else {
            push(@newTokens, $token);
        }
    }
    return join(" ", @newTokens);
}

$str = "*.c ?.tasd";
$str = processGlobbing($str);
print("$str\n");
