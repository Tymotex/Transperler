#!/usr/bin/perl
use warnings;
use Term::ANSIColor;
use Scalar::Util qw(looks_like_number);
use FindBin;
use lib $FindBin::Bin;

if ($#ARGV < 0) {
    print("Usage: sheeple <shell file>\n");
    exit(1);
}

# ===== Debugging =====

$debugging = 0;

sub printC($) {
    if ($debugging) {
        print colored(sprintf($_[0]), "yellow");
    }
}

sub printD($) {
    if ($debugging) {
        print colored(sprintf($_[0]), "blue");
    }
}

sub printE($) {
    if ($debugging) {
        print colored(sprintf($_[0]), "green");
    }
}

# ===== Utilities =====

# Returns the level of indentation for a given string TODO: not robust?
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

sub processGlob($) {
    my $line = $_[0];
    printE("Globbing: $line\n");
    $line =~ s/(\S*)\*(\S*)/glob("$1*$2")/g;

    $globbed = $line;
    printE("Globbed:  $globbed\n");
    return $line;
}

# Given a list of strings, if the string is non-numeric and not a glob 
# operation, it is wrapped around single quotes
sub wrapQuotesForStrings(\@) {
    my @lines = @{$_[0]};
    for (my $i = 0; $i <= $#lines; $i++) {
        $line = $lines[$i];
        # Checks the line is non-numeric
        if (!looks_like_number($line)) {
            # Checks the line doesn't contain glob characters
            # TODO: Not robust way of checking for globbing. What if filename contains [ and not []?
            if ($line !~ /[?*\[\]]/ ) {
                # printE("Wrapping: $line\n");
                @lines[$i] = "'" . $line . "'";
            }
        }
    }
    return @lines;
}

# ===== Constructs Processing ===== 

sub processForLoop(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing For Loop =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    # TODO: Repeat the regex match
    my $subject = $1;
    my $iterable = $2;

    my @loopArgs = split(/ /, $iterable);
    @loopArgs = wrapQuotesForStrings @loopArgs;
    $iterable = processGlob($iterable);
    my $loopArgsJoined = join(", ", @loopArgs);

    my $convertedLine = "for \$$1 ($loopArgsJoined)\n";
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

sub processAssignment(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing assignment =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    my $convertedLine = "\$$1 = '$2';\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processComment(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing comment =====\n");
    printD("===> Line number: $i\n");
    printD("===> Line:        $line\n");
    my $convertedLine = "$line\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

# ===== Built-ins =====

sub processEcho($) {
    my $line = $_[0];
    $line =~ /echo (.*)/;
    my $convertedLine = "print \"$1\\n\";\n";
    return $convertedLine;
}

sub processCd($) {
    my $line = $_[0];
    $line =~ /cd (.*)/;
    my $convertedLine = "chdir '$1';\n";
    return $convertedLine;
}

sub processRead($) {
    my $line = $_[0];
    $line =~ /read (.*)/;
    my $convertedLine = "\$$1 = <STDIN>; chomp \$$1;\n";   # TODO: Should make 'process' subroutines return a list of lines to print, rather than just one scalar
    return $convertedLine;
}

sub processExit($) {
    my $line = $_[0];
    $line =~ /exit(.*)/;
    my $convertedLine = "exit$1;\n";
    return $convertedLine;
}

# ===== Special Variables =====

sub substituteSpecialVars($) {
    my $line = $_[0];
    my @variables = $line =~ /(\$\S+)/g;   # TODO: What if the variable isn't delimited normally? Eg. $myVarhello
    # print("Subbing: $line\n");
    foreach my $variable (@variables) {
        $variable =~ /\$(\S+)/;
        my $argNum = $1;
        if (looks_like_number($argNum)) {
            $newArgNum = $argNum - 1;   # Shift the arg number down 1 position
            $line =~ s/\$$argNum/\$ARGV[$newArgNum]/g;
            # print ("New line: $line\n");
        }
    }
    my $convertedLine = $line;
    return $convertedLine;
}

# ========================================================================================
# ===== Currently Working On =====

sub processIf($) {
    my $line = $_[0];
    $line =~ /if (.*)/;   # TODO: Can I trust the remainder of the if statement is the condition?

    my $condition = $1;
    my $convertedLine = "if ($condition)\n";
    return $convertedLine;
}

sub processThen {
    my $line = $_[0];
    return "{\n";
} 

sub processElse {
    my $line = $_[0];
    return "}\nelse {\n";
}

sub processElif {
    my $line = $_[0];
    $line =~ /elif (.*)/;   # TODO: Can I trust the remainder of the if statement is the condition?

    my $condition = $1;
    my $convertedLine = "}\nelsif ($condition)\n";
}

sub processFi {
    my $line = $_[0];
    return "}\n";
}

sub processCondition {
    
}

sub processWhileLoop {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing While Loop =====\n");
    # TODO: Repeat the regex match
    my $condition = $1;

    my @loopArgs = split(/ /, $iterable);
    @loopArgs = wrapQuotesForStrings @loopArgs;
    $iterable = processGlob($iterable);
    my $loopArgsJoined = join(", ", @loopArgs);

    my $convertedLine = "for \$$1 ($loopArgsJoined)\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
    
}

# ========================================================================================

# Opening the input shell file for reading and creating the output perl file for writing
$inputFileName = $ARGV[0];
open my $inputFile, "<", "$inputFileName" or die("Couldn't open file: $!\n");
$outputFileName = $inputFileName =~ s/\.[^.]+$//;
$outputFileName .= ".pl";
open my $perlFile, ">", "$inputFileName.pl" or die("Couldn't create file: $!\n");

if (!$debugging) {
    $perlFile = STDOUT;
}

# Writing the hashbang line
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

    # Search and replace shell's special variables, where they occur
    $currLine = substituteSpecialVars($currLine);

    # TODO: match patterns aren't so robust
    # For loops and while loops:
    if ($currLine =~ /for (.+) in (.+)/) {
        print $perlFile processForLoop(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /while (.+)/) {
        print $perlFile processWhileLoop(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*done\s*/) {  # TODO: \s* isn't necessary since tabs are stripped first
        print $perlFile processDone(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*do\s*/) {
        print $perlFile processDo(@inputLines, $i, $currLine);
    }
    # If statements:
    elsif ($currLine =~ /\s*elif /) {
        print $perlFile processElif($currLine);
    }
    elsif ($currLine =~ /\s*if /) {
        print $perlFile processIf($currLine);
    }
    elsif ($currLine =~ /\s*then/) {
        print $perlFile processThen($currLine);
    }
    elsif ($currLine =~ /\s*else/) {
        print $perlFile processElse($currLine);
    }
    elsif ($currLine =~ /\s*fi/) {
        print $perlFile processFi($currLine);
    }
    # Comments:
    elsif ($currLine =~ /^#[^!](.*)/) {
        # Matched a shell comment
        print $perlFile processComment(@inputLines, $i, $currLine);
    }
    else {
        # Reached a line of 'general' shell code

        # Checking if this line is an assignment operation
        if ($currLine =~ /^(.+)=(.*)/) {
            print $perlFile processAssignment(@inputLines, $i, $currLine);
        }

        # Checking if this is an empty line
        elsif (!$currLine =~ /\S+/) {
            print $perlFile "\n";
        }

        # Checking if this line is running a built-in command
        elsif ($currLine =~ /^echo /) {
            print $perlFile processEcho($currLine);
        }
        elsif ($currLine =~ /^cd /) {
            print $perlFile processCd($currLine);
        }
        elsif ($currLine =~ /^read /) {
            print $perlFile processRead($currLine);
        }
        elsif ($currLine =~ /^exit /) {
            print $perlFile processExit($currLine);
        }

        # Treating this line as a system command
        else {
            print $perlFile processSystemCommand(@inputLines, $i, $currLine);
        }
    }
}

# Closing the output file
close($perlFile);
