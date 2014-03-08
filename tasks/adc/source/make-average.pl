use strict;

@ARGV==2 or die "Args: fname average\n";
my ($fname,$average) = @ARGV;

open F, $fname or die;
chomp(my $count = <F>);
chomp(my $d = <F>);
close F;

$d =~ s/[\[\] ]//g;
my @data = split ',', $d;
die if @data != $count;

my @result;

my ($sum, $pos);
$sum += $data[$_] for 0..$average-1;
while ($pos < @data) {
    push @result, int($sum/$average);
    $sum -= $data[$pos];
    $sum += $data[$pos+$average];
    $pos++;
}

print "@result\n";
