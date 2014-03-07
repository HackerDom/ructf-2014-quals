use strict;
use bignum;
++$|;

################# Config #################

my $W = 1344;        # Whole line (pixels)
my $H = 806;         # Whole frame (pixels)
my $Freq = 60;       # Refresh time (Hz)

my $MaxVoltage = 0.7; # Volts
my $ADCAverage = 15;  # Pixels

##########################################

@ARGV==3 or die "Args: datafile sampleDelay(us) sampleCount\n";

my ($fname,$sampleDelay,$sampleCount) = @ARGV;

die "ADC min delay: 0.1us\n" if $sampleDelay < 0.1;
die "ADC max delay: 1s\n" if $sampleDelay > 1000000;
#die "ADC max memory: 4 Kb\n" if $sampleCount > 4096;

open F, $fname or die "Error: open\n";
chomp(my $data = <F>);
close F;

warn 'read ok';

my @data = split' ', $data;
die sprintf "Data count mismatch: %d != %d\n",0+@data,$W*$H if @data != $W*$H;

warn 'split ok';

my $PixelTime = 1000000/($W*$H*$Freq);

print "OK\n";
print "Pixel time: ",$PixelTime," us",$/;
print "Sample delay: ",$sampleDelay," us = ",$sampleDelay/$PixelTime," pixels",$/;

my $time = time*1000000 + int rand 1000000;
my $pixel = int rand @data;

my $pixelsDelta = $sampleDelay/$PixelTime;

for (1..$sampleCount) {
    my $voltage = sprintf "%02x", $data[int($pixel) % @data];
    #print "pos = $pos, ";
    print $time, " us, voltage: ", $voltage, $/;
    $time += $sampleDelay;
    $pixel += $pixelsDelta;
}

warn 'generate ok';

exit 0;
