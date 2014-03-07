++$|;

$prev = '';
$n = 0;
$start = 1;
while (<>) {
    s/[^01]//g;
    for my $i (0..length($_)-1) {
        $c = substr($_,$i,1);
        if ($prev ne $c) {
            if (!$start) {
                print process($prev, $n);
                $n = 1;
            }
            else {
                $n++;
            }
        }
        else {
            $n++;
        }
        $start = 0 if $start;
        $prev = $c;
    }
}
print process($c, $n);

exit 0;

sub process {
    my ($char, $count) = @_;
    $count = sprintf "%.f", $count/100;

    if ($char eq '0') {
        return "\n\n" if $count > 100;
        return "\n" if $count > 20;
        return ($char x $count)."\n" if $count > 6;
    }
    $count = 1 if $count < 1;
    return ($char x $count)." ";
}
