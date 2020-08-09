open my $inputFile, "<", $ARGV[0];

@inputLines = <$inputFile>;
$inputs = join("", @inputLines); 
$inputs =~ s/(?<!;);(?!;)\s*/\n/g;
@inputLines = split(/\n/, $inputs);

print("@inputLines");
foreach $line (@inputLines) {
    print("Line: $line\n");
}
