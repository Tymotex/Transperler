#!/usr/bin/perl
use warnings;
use Term::ANSIColor;

sub printC($) {
    print colored(sprintf($_[0]), "yellow");
}

sub printD($) {
    print colored(sprintf($_[0]), "blue");
}

sub printE($) {
    print colored(sprintf($_[0]), "green");
}

sub printColoured($) {
    my %args = @_;
    my %defaults = (colour => "yellow");
    my %params = (%defaults, %args);
    $message = $_[0];
    print colored(sprintf($params{"$message"}), $params{"colour"});
}

# Returns the level of indentation for a given string 
# TODO: not robust?
sub getIndentLevel($) {
    my $line = $_[0];
    my @tabs = $line =~ /\G\s/g;
    my $tabCount = @tabs;
    return $tabCount; 
}

# Strips leading tabs
# TODO: accept references instead? To modify inplace
sub stripIndent(\$) {
    my $line = ${$_[0]};
    $line =~ s/^\s*//;
    return $line;
}

sub processForLoop(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing For Loop =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");

    my $subject = $1;
    my $iterable = $2;
    my $convertedLine = "for \$$1 (glob(\"$2\")) ";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processDo(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing 'do' =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    my $convertedLine = "{\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processDone(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing 'done' =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    my $convertedLine = "}\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processSystemCommand(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing 'done' =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    my $convertedLine = "system(\"$currLine\");\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}


# Opening the input shell file for reading and creating the output perl file for writing
$inputFileName = $ARGV[0];
open my $inputFile, "<", "$inputFileName" or die("Couldn't open file: $!\n");
$outputFileName = $inputFileName =~ s/\.[^.]+$//;
$outputFileName .= ".pl";
open my $perlFile, ">", "$inputFileName.pl" or die("Couldn't create file: $!\n");

# Write the hashbang line
$perlPath = `which perl`;
chomp $perlPath;
print $perlFile "#!$perlPath -w\n";

@inputLines = <$inputFile>;

for ($i = 0; $i <= $#inputLines; $i++) {
    $currLine = $inputLines[$i];
    chomp $currLine;
    $indentLevel = getIndentLevel($currLine);
    $currLine = stripIndent($currLine);
    printC("===> $currLine (indentation: $indentLevel)\n");
    next if ($currLine =~ /^#!/);    # Skip the hashbang line

    my $tabs = ' ' x $indentLevel;
    print $perlFile $tabs;
    if ($currLine =~ /for (.+) in (.+)/) {
        print $perlFile processForLoop(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*done\s*/) {
        print $perlFile processDone(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*do\s*/) {
        print $perlFile processDo(@inputLines, $i, $currLine);
    }
    else {
        # Reached a line of 'standard' shell code
        print $perlFile processSystemCommand(@inputLines, $i, $currLine);
    }
}

# Closing the output file
close($perlFile);
