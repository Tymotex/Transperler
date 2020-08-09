
$str = $ARGV[0];

if ($str =~ /(?<!;);(?!;)/) {
    print("yes\n");
}

