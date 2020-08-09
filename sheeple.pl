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

# Ideas:
# - Tokenise each line we read?  
#
#

# ===== Debugging =====

$debugging = 0;

sub printC($) {
    if ($debugging == 1) {
        print colored(sprintf($_[0]), "yellow");
    }
}

sub printD($) {
    if ($debugging == 1) {
        print colored(sprintf($_[0]), "blue");
    }
}

sub printE($) {
    if ($debugging == 1) {
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

sub globConsecutive {
    my @args = @_;
    my @globbedArgs = ();
    foreach my $arg (@args) {
        push(@globbedArgs, "glob(\"$arg\")");
    }
    my $globbedArgsJoined = "(" . join(",", @globbedArgs) . ")";
    return $globbedArgsJoined;
}

sub processGlobbing($) {
    my $line = $_[0];
    my @tokens = split(/ /, $line);
    my @newTokens = ();
    for (my $i = 0; $i <= $#tokens; $i++) {
        my $j = $i;
        my $token = $tokens[$i];
        my $isGlob = 0;
        while ($token =~ /(\S*)\*(\S*)/ or $token =~ /(\S*)\?(\S*)/ or ($token !~ /\$/ and $token =~ /\S*\[.+\]\S*/)) {
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

sub wrapQuotes($) {
    my $line = $_[0];
    return "'" . $line . "'"
}


sub escapeCharacters($@) {
    my ($line, @charsToEscape) = @_;
    foreach my $charToEscape (@charsToEscape) {
        $line =~ s/\Q$charToEscape/\\$charToEscape/g;
    }
    return $line;
}

sub wipeBackslashes($) {
    my $line = $_[0];
    $line =~ s/\\//g;
    return $line;
}

sub isVariable {
    my $line = $_[0];
    if ($line =~ /^\$/) {
        return 1;
    } else {
        return 0;
    }
}

sub isRawString {
    my $line = $_[0];
    if ($line =~ /^[\$@%`"']/ or 
        $line =~ /\s[-+*\/%]\s/ or 
        $line =~ /\s(eq|ne|gt|ge|lt|le)\s/ or 
        $line =~ /join\(/ or 
        $line =~ /glob\(/ or
        looks_like_number($line)) {  # TODO: spaghetti
        return 0;
    } else {
        return 1;
    }
}

# TODO: Clean up tokenise. lots of repetition
sub tokenise {
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
        $arg = escapeCharacters($arg, '$', '`');  # TODO: need to escape a lot more characters like |, *, ?, etc. right?
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
        # Get the remaining string of tokens so we can pass it to subsequent recursive calls
        $remainder = $line;
        $remainder =~ s/^\Q$arg//;
        $remainder =~ s/^\s*//;
        # $arg = escapeCharacters($arg, '$', '`');
        push(@tokens, $arg);
    }
    # Recursively tokenise the remaining string
    my @remainingTokens = tokenise($remainder);
    push(@tokens, @remainingTokens);
    return @tokens;
}

# ===== Constructs Processing ===== 

sub processForLoop(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    $line =~ /for (.+) in (.+)/;
    my $loopVar = $1;
    my $iterable = $2;
    my @loopArgs = tokenise($iterable);
    foreach my $arg (@loopArgs) {
        if (isRawString($arg)) {
            $arg = wrapQuotes($arg);
        }
    }
    my $loopArgsJoined = join(", ", @loopArgs);
    my $convertedLine = "for \$$loopVar ($loopArgsJoined) ";
    return $convertedLine;
}

sub processDo(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    my $convertedLine = "{\n";
    return $convertedLine;
}

sub processDone(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    my $convertedLine = "}\n";
    return $convertedLine;
}

sub processSystemCommand(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing 'done' =====\n");
    my $convertedLine = "system(\"$$line\");\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processAssignment(\@$$) {
    my @lines = @{$_[0]};  # TODO: myVar="text here" should be $myVar = "text here", not $myVar = '"text here"'
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing assignment =====\n");
    my $leftVariable = $1;
    my $rightValue = $2;
    if (isRawString($rightValue)) {
        $rightValue = wrapQuotes $rightValue;
    }
    my $convertedLine = "\$$leftVariable = $rightValue;\n";

    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

sub processComment(\@$$) {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing comment =====\n");
    my $convertedLine = "$line\n";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

# ===== Built-ins =====

sub processEcho($) {   # TODO: need to handle echo -n option
    my $line = $_[0];
    $line =~ /echo (.*)/;
    my @echoArgs = tokenise($1);
    my $addTrailingNewline = 1;
    if ($echoArgs[0] eq "-n") {
        $addTrailingNewline = 0;
        shift @echoArgs;
    }
    my $joinedArgs = join(" ", @echoArgs);
    my $convertedLine = "$joinedArgs";
    $convertedLine .= "\\n" if ($addTrailingNewline);
    $convertedLine = escapeCharacters($convertedLine, '"');
    $convertedLine = "print \"$convertedLine\";\n";
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
        my $specialVar = $1;
        if (looks_like_number($specialVar)) {
            $argNum = $specialVar - 1;   # Shift the arg number down 1 position
            $line =~ s/\$$specialVar/\$ARGV[$argNum]/g;
            # print ("New line: $line\n");
        }
        elsif ($specialVar =~ /#/) {
            $line =~ s/\$#/\$#ARGV+1/g;  # TODO: Untested
        }
        elsif ($specialVar =~ /@/) {
            $line =~ s/\$@/\@ARGV/g;  # TODO: Untested
        }
        elsif ($specialVar =~ /\*/) {
            $line =~ s/\$\*/join(" ", \@ARGV)/g;  # TODO: Untested
        }
    }
    my $convertedLine = $line;
    return $convertedLine;
}

# ========================================================================================

# TODO: What if we have test $var1 = $var2? 
# Expects a line consisting of test args
sub processTest($) {                           # TODO: -r and -d
    my $line = $_[0];      
    my @testArgs = split(/ /, $line);
    foreach my $arg (@testArgs) {              # TODO: Missing handling for ( EXP ), ! EXP, etc. see man test
        if ($arg eq "-a") {      # Logical operators
            $arg = "&&";
        } elsif ($arg eq "-o") {
            $arg = "||";
        } elsif ($arg eq "=") {  # String and integer comparison
            $arg = "eq";
        } elsif ($arg eq "!="){
            $arg = "-ne";
        } elsif ($arg eq "-eq"){
            $arg = "==";
        } elsif ($arg eq "-ge"){
            $arg = ">=";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-le"){
            $arg = "<=";
        } elsif ($arg eq "-lt"){
            $arg = "<";
        } elsif ($arg eq "-ne"){
            $arg = "!=";
        } elsif ($arg eq "-n"){   # TODO: test if non-zero works
            $arg = "eq \"\"";
        } elsif ($arg eq "-z"){   # TODO: test if zero works
            $arg = "ne \"\"";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-gt"){
            $arg = ">";
        } elsif ($arg eq "-r"){
            $arg = "-r";
        } elsif ($arg eq "-d"){
            $arg = "-d";
        } else {
            if (isRawString($arg)) {
                # Treat this argument as a raw string by wrapping it with single quotes
                $arg = wrapQuotes $arg;
            }
        }
    }
    $line = join(" ", @testArgs);
    my $convertedLine = $line;
}

# Given a string expr ... args ...
sub processExpr($) {
    my $line = $_[0];      
    $line =~ /^expr (.*)/;
    $line = $1;
    $line = wipeBackslashes $line;
    my @exprArgs = split(/ /, $line);
    # print("Expr args: $line\n");
    
    foreach my $arg (@exprArgs) {
        if ($arg =~ /\|/) {
            $arg = "||";
        } elsif ($arg =~ /&/) {
            $arg = "&&";  # TODO: Need to swap around the two
        } elsif ($arg =~ /</) {
            $arg = "lt";
        } elsif ($arg =~ /<=/) {
            $arg = "le";
        } elsif ($arg =~ /=/) {
            $arg = "eq";
        } elsif ($arg =~ /!=/) {
            $arg = "ne";
        } elsif ($arg =~ />=/) {
            $arg = "ge";
        } elsif ($arg =~ />/) {
            $arg = "gt";
        } elsif ($arg =~ /\+/) {
            # TODO: leave empty?
            $arg = "+";
        } elsif ($arg =~ /-/) {
            # TODO: leave empty?
            $arg = "-";
        } elsif ($arg =~ /\*/) {
            $arg = "*";
        } elsif ($arg =~ /\//) {
            $arg = "/";
        } elsif ($arg =~ /%/) {     # TODO: more operators like: match, substr, length, index. Should these be handled?
            $arg = "%";
        }
    }
    $line = join(" ", @exprArgs);
    my $convertedLine = $line;
    return $convertedLine;
}

sub processCondition($) {
    my $line = $_[0];
    if ($line =~ /^test (.*)/) {
        $line = processTest $1;
    } elsif ($line =~ /^\[ (.*) \]/) {
        $line = processTest $1;
    }
}

sub processIf($) {
    my $line = $_[0];
    $line =~ /if (.*)/;   # TODO: Can I trust the remainder of the if statement is the condition?

    my $condition = $1;
    $condition = processCondition $condition;

    my $convertedLine = "if ($condition) ";
    return $convertedLine;
}

sub processThen {
    my $line = $_[0];
    return "{\n";
} 

sub processElse {
    my $line = $_[0];
    return "else {\n";
}

sub processElif {
    my $line = $_[0];
    $line =~ /elif (.*)/;   # TODO: Can I trust the remainder of the if statement is the condition?

    my $condition = $1;
    $condition = processCondition $condition;

    my $convertedLine = "elsif ($condition) ";
}

sub processFi {
    my $line = $_[0];
    return "}\n";
}

sub processWhileLoop {
    my @lines = @{$_[0]};
    my $i = $_[1];
    my $line = $_[2];
    printD("===== Processing While Loop =====\n");  # TODO: Repeat the regex match
    my $condition = $1;
    $condition = processCondition $condition;
    
    my $convertedLine = "while ($condition) ";
    printE("===> Converted:   $convertedLine\n");
    printD("===============================\n");
    return $convertedLine;
}

# ========================================================================================

# Handling: $() and ``
# Given a line, swaps out $(...)
sub processCommandSubstitution {
    my $line = $_[0];
    if ($line =~ /\$\([^(](.*)\)/) {
        my $innerCommand = $1;
        if ($innerCommand =~ /^expr/) {
            $innerCommand = processExpr($innerCommand);
            $line =~ s/\$\((.*)\)/$innerCommand/;
        } else {
            $line =~ s/\$\((.*)\)/`$innerCommand`/;
        }
    } 
    elsif ($line =~ /`(.*)`/) {
        my $innerCommand = $1;
        if ($innerCommand =~ /^expr/) {
            $innerCommand = processExpr($innerCommand);
            $line =~ s/`(.*)`/$innerCommand/;
        }
    }
    return $line;
}

# Handling: $() and ``
# Given a line, swaps out $(...)
sub processArithmetic {
    my $line = $_[0];
    if ($line =~ /\$\(\((.*)\)\)/) {
        $innerExpr = $1;
        my @exprArgs = split(/ /, $innerExpr);
        foreach my $arg (@exprArgs) {
            next if (looks_like_number($arg));
            next if ($arg =~ /[-+*\/%]/);
            $arg = '$' . $arg;
        }
        $convertedExpr = join(" ", @exprArgs);
        $line =~ s/\$\(\((.*)\)\)/$convertedExpr/;
    }
    return $line;
}

# ========================================================================================

# TODO: temp prototypes
sub processLine($\@$$);
sub processSwitchCase($$\@$$);

# Returns how many lines to skip 
sub processLine($\@$$) {
    no warnings;
    my $perlFile = $_[0];
    my @lines = @{$_[1]};
    my $i = $_[2];
    my $indentationShift = $_[3];   # How many levels of indentation to add (can be negative)

    my $currLine = $lines[$i];
    chomp $currLine;
    $indentLevel = getIndentLevel($currLine);
    $currLine = stripIndent($currLine);
    # print("===> Main: $currLine\n");
    return 0 if ($currLine =~ /^#!/);    # Skip the hashbang line   TODO This okay?

    my $tabs = ' ' x ($indentLevel + 4 * $indentationShift);  # TODO: shitty code
      
    # Search and replace shell's special variables, where they occur
    $currLine = substituteSpecialVars($currLine);
    $currLine = processGlobbing($currLine);  # TODO:

    $currLine = processArithmetic($currLine);
    $currLine = processCommandSubstitution($currLine);

    my $linesToSkip = 0;

    # Inline comment
    if ($currLine =~ /(.*)[^\$](#.*)/) { 
        print $perlFile $tabs;
        # Matched a shell comment
        print $perlFile processComment(@inputLines, $i, $2);
        $currLine = $1;
        $currLine =~ s/\s*$//;
    }

    # TODO: match patterns aren't so robust
    # For loops and while loops:
    if ($currLine =~ /for (.+) in (.+)/) {
        print $perlFile $tabs;
        print $perlFile processForLoop(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /while (.+)/) {
        print $perlFile $tabs;
        print $perlFile processWhileLoop(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*done\s*/) {  # TODO: \s* isn't necessary since tabs are stripped first
        print $perlFile $tabs;
        print $perlFile processDone(@inputLines, $i, $currLine);
    }
    elsif ($currLine =~ /\s*do\s*/) {
        print $perlFile processDo(@inputLines, $i, $currLine);
    }
    # If statements:
    elsif ($currLine =~ /^\s*elif /) {
        print $perlFile $tabs;
        print $perlFile processFi($currLine);
        print $perlFile $tabs;
        print $perlFile processElif($currLine);
    }
    elsif ($currLine =~ /^\s*if /) {
        print $perlFile $tabs;
        print $perlFile processIf($currLine);
    }
    elsif ($currLine =~ /^\s*then\s*$/) {
        print $perlFile processThen($currLine);
    }
    elsif ($currLine =~ /^\s*else\s*$/) {
        print $perlFile $tabs;
        print $perlFile processFi($currLine);
        print $perlFile $tabs;
        print $perlFile processElse($currLine);
    }
    elsif ($currLine =~ /^\s*fi\s*$/) {
        print $perlFile $tabs;
        print $perlFile processFi($currLine);
    }
    # Comments:
    elsif ($currLine =~ /^#[^!](.*)/) { 
        print $perlFile $tabs;
        # Matched a shell comment
        print $perlFile processComment(@inputLines, $i, $currLine);
    }
    else {
        # Reached a line of 'general' shell code

        # Checking if this line is an assignment operation
        if ($currLine =~ /^(\S+)=(.*)/) {
            print $perlFile $tabs;
            print $perlFile processAssignment(@inputLines, $i, $currLine);
        }
        
        # Checking if this is an empty line
        elsif ($currLine !~ /\S+/) {
            print $perlFile $tabs;
            print $perlFile "\n";
            return 0;  # TODO This okay?
        }

        # Checking if this line is running a built-in command
        elsif ($currLine =~ /^echo /) {
            print $perlFile $tabs;
            print $perlFile processEcho($currLine);
        }
        elsif ($currLine =~ /^expr /) {
            print $perlFile $tabs;
            my $processedExpr = "print " . processExpr($currLine) . ", \"\\n\";\n";  # TODO: doesn't print 0
            print $perlFile $processedExpr;
        }
        elsif ($currLine =~ /^cd /) {
            print $perlFile $tabs;
            print $perlFile processCd($currLine);
        }
        elsif ($currLine =~ /^read /) {
            print $perlFile $tabs;
            print $perlFile processRead($currLine);
        }
        elsif ($currLine =~ /^exit /) {
            print $perlFile $tabs;
            print $perlFile processExit($currLine);
        }

        # Case?
        elsif ($currLine =~ /^case (.*) in/) {
            my $caseVar = $1;
            # Start processing the switch case on the next line (first case)
            $linesToSkip += processSwitchCase($perlFile, $caseVar, @lines, $i + 1, $indentationShift - 1);
        }   
        elsif ($currLine =~ /^esac/) {  # TODO: shouldnt have this
            return 0;
        }

        # Treating this line as a system command
        else {
            print $perlFile processSystemCommand(@inputLines, $i, $currLine);
        }
    }
    # print("============================== SKIP $linesToSkip\n");
    return $linesToSkip;
}

sub processSwitchCase($$\@$$) {
    no warnings;
    my $perlFile = $_[0];
    my $caseVar = $_[1];
    my @lines = @{$_[2]};
    my $lineIndex = $_[3];
    my $indentationShift = $_[4];   # How many levels of indentation to add (can be negative)

    my $isFirstCase = 1;
    my $currLine = $lines[$lineIndex];

    my $linesProcessed = 0;
    while ($currLine !~ /esac/) {
        $currLine =~ /(\S+)\)/;
        my $indentLevel = getIndentLevel($currLine);
        $currLine = stripIndent($currLine);
        my $case = $1;
        if (isRawString($case)) {
            $case = wrapQuotes $case;
        } 
        my $tabs = ' ' x ($indentLevel + 4 * $indentationShift);
        # print("===> Handling: $currLine\n");
        $linesProcessed++;
        if ($isFirstCase) {
            # print("===> Converted to: if ($caseVar eq $case) {\n");
            print $perlFile $tabs;  
            print $perlFile ("if ($caseVar eq $case) {\n");
            $isFirstCase = 0;
        } else {
            if ($currLine =~ /[;]{2}/) {
                $tabs = ' ' x ($indentLevel + 4 * ($indentationShift - 1));
                print $perlFile $tabs;
                print $perlFile ("}\n");
            }
            elsif ($currLine =~ /^\*\)/) {
                print $perlFile $tabs;
                print $perlFile ("else {\n");
            }
            elsif ($currLine =~ /(\S+)\)/) {   # TODO: No need to do this twice
                $case = $1;
                print $perlFile $tabs;
                print $perlFile ("elsif ($caseVar eq $case) {\n");
            }
            else {
                # Regular command here
                $linesProcessed += processLine($perlFile, @lines, $lineIndex + $linesProcessed - 1, $indentationShift);
            }
        }
        $currLine = $lines[$lineIndex + $linesProcessed];
    }
    return $linesProcessed + 1;
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
$inputs = join("", @inputLines);      # Preprocessing the shell code so that semicolons become newlines - but leaving double semicolon untouched
$inputs =~ s/(?<!;);(?!;)\s*/\n/g;    # TODO: Need to also pad with correct indentiation after the newline
@inputLines = split(/\n/, $inputs);

# print ("=====ORIGINAL LINES:=====\n");
# foreach $inputLine (@inputLines) {
#     print("$inputLine\n");
# }
# print("========================\n");

for ($i = 0; $i <= $#inputLines; $i++) {
    # print("Passing in $inputLines[$i]\n");
    $i += processLine($perlFile, @inputLines, $i, 0);
}

# Closing the output file
close($perlFile);
