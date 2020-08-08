#!/usr/bin/perl

# sub tokenise {
#     my $line = $_[0];
#     my @tokens = ();

#     my $doubleQuoteOpen = 0;
#     my $currStart;
#     my $runLength = -1;
#     my $i = 0;
#     foreach my $char (split(//, $line)) {
#         print("Looping ($i): $char\n");
#         if ($char eq '"') {
#             if (!($doubleQuoteOpen)) {
#                 $doubleQuoteOpen = 1;
#                 $currStart = $i + 1;
#                 print("Double quote open at: $i\n");
#             } else {
#                 $doubleQuoteOpen = 0;
#                 $currEnd = $i;
#                 print("Double quote closed at: $i\n");
#                 # Extracting the substring from the marked start and end indices
#                 print("Extracting from $currStart to $currStart + $runLength\n");
#                 push(@tokens, substr $line, $currStart, $runLength);
#                 $runLength = -1;
#             }
#         }
        
#         $i++;
#         if ($doubleQuoteOpen) {
#             $runLength++;
#             next;
#         } # Keep scanning forward until the terminating double quote

#         # Double quote is not open. Split at spaces




#     }



#     print ("Size: $#tokens\n");

#     return @tokens;
# }



sub escapeCharacters($@) {
    my ($line, @charsToEscape) = @_;
    foreach my $charToEscape (@charsToEscape) {
        $line =~ s/\Q$charToEscape/\\$charToEscape/g;
    }
    return $line;
}

sub tokenise($\@) {
    my $line = $_[0];
    my @tokens = ();
    return @tokens if ($line eq "");
    my $arg;
    my $remainder = "";
    if ($line =~ /^"/) {
        # Extracting a token wrapped in double quotes
        $endQuoteIndex = index($line, '"', 1);
        $arg = substr($line, 1, $endQuoteIndex - 1);
        push(@tokens, $arg);
        # Get the remaining string of tokens so we can pass it to subsequent recursive calls
        $remainder = substr($line, $endQuoteIndex + 1, length($line));
        $remainder =~ s/^\s*//;
    } elsif ($line =~ /^'/) {
        # Extracting a token wrapped in single quotes
        $endQuoteIndex = index($line, "'", 1);
        $arg = substr($line, 1, $endQuoteIndex - 1);
        $arg = escapeCharacters($arg, '$', '`');
        push(@tokens, $arg);
        # Get the remaining string of tokens so we can pass it to subsequent recursive calls
        $remainder = substr($line, $endQuoteIndex + 1, length($line));
        $remainder =~ s/^\s*//;
    } else { 
        # Extracting a normal token (not wrapped by any quotes)
        $endIndex = index($line, ' ', 0);
        if ($endIndex == -1) {
            # This argument is at the end of the supplied line - so extract the whole string
            $arg = substr($line, 0, length($line));
        } else {
            $arg = substr($line, 0, $endIndex);
        }
        push(@tokens, $arg);
        # Get the remaining string of tokens so we can pass it to subsequent recursive calls
        $remainder = $line;
        $remainder =~ s/^\Q$arg//;
        $remainder =~ s/^\s*//;
    }
    # Recursively tokenise the remaining string
    my @remainingTokens = tokenise($remainder);
    push(@tokens, @remainingTokens);
    return @tokens;
}

$string = '"hello    $myVar    world " 1 2 \'Andrew\' "Taylor" \' the variable $myVar has been escaped \'w$ow';
print("Original string: $string\n");
@myTokens = ();
@myTokens = tokenise($string, @myTokens);

foreach my $token (@myTokens) {
    print("Token: $token\n");
}
