package Debug;

$debugging = 0;

sub enableDebug($) {
    $debugging = 1;
}

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


1;