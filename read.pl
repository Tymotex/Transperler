open my $inputFile, "<", $ARGV[0];

@inputLines = <$inputFile>;
$inputs = join(";", @inputLines); 
@inputLines = split(";", $inputs);
print(@inputLines);
