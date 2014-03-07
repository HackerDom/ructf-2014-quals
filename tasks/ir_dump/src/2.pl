++$|;
$prev = '';
$N = 0;
while (<>) {
    chomp;
    s/ //g;
    @one = /(1)/g;
    next if 0+@one != 17;
    s/1/ /g;
    s/000/1/g;
    next if /00/;
    s/ //g;
    next if length($_)!=16;
    $cmd = unpack 'H4', pack 'b16', $_;
	$cmd =~ s/(..)(..)/$1 $2/;
    printf "%04d | %s\n", $N++, $cmd;
    $prev = $cmd;
}
