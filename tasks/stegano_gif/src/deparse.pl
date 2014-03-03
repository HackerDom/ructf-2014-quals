#!/usr/bin/perl

use GD;

sub bit2str {
    local $_ = shift;
    my $r = '';
    while ($_) {
        $r .= chr(oct('0b' . substr($_, 0, 8)));
        $_ = substr($_, 8);
    }
    $r;
}

$l = shift;

eval { push @img, GD::Image->newFromGif($_) } for @ARGV;

$w = $img[0]->width;
$h = $img[0]->height;

$text = '';

for $y (0 .. $h - 1) {
    for $x (0 .. $w - 1) {
        $c = 0;
        for (@img) {
            my ($r, $g, $b) = $_->rgb($_->getPixel($x, $y));
            $c ^= $r;
        }
        $text .= $c;

        print(bit2str($text) . $/), exit unless --$l;
    }
}

