#!/usr/bin/perl

use File::Basename;
use GD;

sub help {
    $name = basename $0;
    print "Usage: $name image.gif string\n";
}

&help, exit if (@ARGV != 2) || $ARGV[0] eq '-h';

$name = $ARGV[0];
eval { $image = GD::Image->newFromGif($name) }
    or die "Can't open gif file: '$name'";

$text = $ARGV[1];
die "Image too small"
    if $image->width * $image->height < 8 * length($text);

die "Too many colors: " . $image->colorsTotal
    if $image->colorsTotal > 128;

$colors{join ':', $image->rgb($_)} = $_ for 0 .. $image->colorsTotal - 1;

@images = map { GD::Image->newFromGif($name) } (1 .. 7);
@bits = map { split //, sprintf "%08b", ord } split //, $text;

$w = $image->width;
for $i (0 .. @bits - 1) {
    next unless $bits[$i];

    my $x = $i % $w;
    my $y = int($i / $w);

    my $layer = int rand 7;

    my ($r, $g, $b) = $image->rgb($image->getPixel($x, $y));
    $r ^= 1;

    my $color = $colors{"$r:$g:$b"};
    unless (defined $color) {
        $color = $image->colorAllocate($r, $g, $b);
        $_->colorAllocate($r,$g, $b) for @images;

        $colors{"$r:$g:$b"} = $color;
    }

    $images[$layer]->setPixel($x, $y, $color);
}

$anim = $image->gifanimbegin;
$anim .= $image->gifanimadd;
$anim .= join '', map { $_->gifanimadd } @images;
$anim .= $image->gifanimend;

binmode STDOUT;
print $anim;

