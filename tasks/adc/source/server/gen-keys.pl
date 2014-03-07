use strict;
use Digest::MD5 qw(md5_hex);

my $salt = 'oiuHYOIUgshadkwqfdshgfdsafdsaf';
my $rnd = int rand 65536;

$\=$/;

my $count = shift || 300;
print md5_hex($salt.$rnd.$_) for 1..$count;
