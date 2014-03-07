use strict;
use GD;
require LWP::UserAgent;

my $HOST = '172.16.16.17';
my $KEY = '2d372373ee0d0c472bbeafcda29f8ebe';

@ARGV == 6 or die "Usage: vga2-solve.pl w h freq average delay count\n";
my ($W,$H,$Freq,$Average,$Delay,$Count) = @ARGV;

my $PixelTime = 1000000 / ($W*$H*$Freq);
my $FrameTime = 1000000 / $Freq;

sub url { 
    sprintf "http://$HOST:22222/?key=%s&delay=%s&count=%s", $KEY, @_;
}

sub load {
    my $url = url(@_);

    print STDERR "Load $url ... ";

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($url);

    die sprintf "%s:%s\n", $response->status_line, $response->decoded_content unless $response->is_success;

    print STDERR "done\n";

    split /[\r\n]+/, $response->decoded_content;
}

sub picture {
    my $im = new GD::Image($W,$H);
    my @colors = map { $im->colorAllocate($_,$_,$_) } 0..255;

    print STDERR "Create picture ... ";

    for (@_) {
        /^(\d+\.?\d*):([0-9a-f]{2})/i or warn $_ and next;
        my $time = substr($1,8);
        my $value = hex($2);

        my $skipFullFrames = int $time / $FrameTime;
        $time -= $skipFullFrames * $FrameTime;

        my $pixel = int $time / $PixelTime;
        my $x = $pixel % $W;
        my $y = int $pixel / $W;

        $im->setPixel($x+$_, $y, $colors[$value]) for 1..$Average;
    }

    print STDERR "done\n";

    $im->png;
}

binmode STDOUT;
print picture load $Delay, $Count;
