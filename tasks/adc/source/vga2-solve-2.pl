use strict;
use bignum;
use GD;
$|++;

@ARGV==5 or die "Args: fin w h freq\n";

my ($Fin,$W,$H,$Freq,$ADCAverage) = @ARGV;

my $PixelTime = 1000000/($W*$H*$Freq);
my $FrameTime = 1000000/$Freq;

my $im = new GD::Image($W,$H);
my @colors = map { $im->colorAllocate($_,$_,$_) } 0..255;

open F, $Fin or die "Cannot open input file\n";
<F> for 1..3;
while (<F>) {
    /^(\d+\.?\d*) us, voltage: ([0-9a-f]{2})/i or warn and next;
    my $time = $1;
    my $value = hex($2);
    my $skipFullFrames = int($time/$FrameTime);
    $time -= $skipFullFrames*$FrameTime;
    my $pixel = int($time/$PixelTime);
    my $x = $pixel % $W;
    my $y = int($pixel / $W);

    my $color = $colors[$value];
    $im->setPixel($x+$_, $y, $color) for 1..$ADCAverage;
}
close F;

binmode STDOUT;
print $im->png;

print STDERR "Image created.\n";
