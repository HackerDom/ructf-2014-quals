#!/usr/bin/env perl
use strict;
use bignum;
use Mojolicious::Lite;

# apt-get install libmath-bigint-perl libmojolicious-perl

++$|;

################# Config #################

my $keysFile = 'keys.txt';    # Keys file
my $dataFile = 'average.txt'; # Data file (keep it secret)
my $W = 1344;                 # Whole line (pixels)
my $H = 806;                  # Whole frame (pixels)
my $Freq = 60;                # Refresh time (Hz)

my $ADCAverage = 15;          # Pixels

my $MinTime = 20;             # Min seconds between requests

my ($MinDelay,$MaxDelay) = (0.1, 1000000);
my ($MinCount,$MaxCount) = (1, 10240);

##########################################

my $PixelTime = 1000000/($W*$H*$Freq);
my @data = LoadData($dataFile);
my %keys = LoadKeys($keysFile);

##########################################

get '/' => sub
{
    my $self = shift;

    my $delay = $self->param('delay') || '';
    my $count = $self->param('count') || '';
    my $key   = $self->param('key') || '';

    $self->app->log->info(sprintf "%s: delay='%s', count='%s', key='%s'", $self->tx->remote_address, $delay, $count, $key);

    $self->res->headers->header('Server' => 'Apache?');
    $self->res->headers->header('X-Powered-By' => 'RuCTF2014');
    $self->res->headers->header('Content-type' => 'text/plain');

    return $self->render(status => 403, text => 'Forbidden') unless exists $keys{$key};

    my $tooFast = time - $keys{$key} < $MinTime;
    $keys{$key} = time;
    return $self->render(status => 418, text => "I'm a teapot") if $tooFast;

    $delay =~ /^\d+\.?\d*$/ or return $self->render(status => 400, text => 'Bad param: delay');
    $count =~ /^\d+$/       or return $self->render(status => 400, text => 'Bad param: count');

    return $self->render(status => 400, text => 'ADC Error: unsupported count') if $count < $MinCount;
    return $self->render(status => 400, text => 'ADC Error: not enough memory') if $count > $MaxCount;
    return $self->render(status => 400, text => 'ADC Error: unsupported delay') if $delay < $MinDelay or $delay > $MaxDelay;

    $self->app->log->info(sprintf "%s: request OK, generate new task data ...", $self->tx->remote_address);
    my @task = NewTask($delay, $count);
    my $text = join("\n", "time:voltage", @task);

    $self->app->log->info(sprintf "%s: sending response (%d bytes)", $self->tx->remote_address, length $text);
    $self->render(text => $text);
};

app->secret('e6521d944c0990c7350b439cbb72a94e');
app->start; 

sub LoadData
{
    open F, shift or die "open";
    app->log->debug("Loading data file ...");
    sysread F, my $data, -s F;
    close F;
    $data =~ s/[^0-9 ]//g;
    my @data = split' ', $data;
    @data == $W*$H or die sprintf "Data count mismatch: %d != %d\n", 0+@data, $W*$H;
    app->log->debug("Done.");
    @data;
}

sub LoadKeys
{
    my %keys;
    open F, shift or die "open";
    app->log->debug("Loading keys file ...");
    while (<F>) {
        chomp;
        $keys{$_} = 1;
    }
    close F;
    app->log->debug("Done.\n");
    %keys;
}

sub NewTask
{
    my ($delay,$count) = @_;

    my $pixelsDelta = $delay/$PixelTime;

    my $time = time * 1000000 + int(rand 10000000)/10;
    my $pixel = int rand @data;

    my @result;
    for (1..$count) {
        my $voltage = sprintf "%02x", $data[int($pixel) % @data];
        push @result, "$time:$voltage";
        $time += $delay;
        $pixel += $pixelsDelta;
    }
    return @result;
}

__DATA__
@@ not_found.html.ep
404 Not found

@@ exception.html.ep
500 Internal Error
