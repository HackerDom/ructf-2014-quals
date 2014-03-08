use strict;
use Digest::MD5 qw(md5_hex);

my $salt = '+VseChtoUgodno+';
my $taskId = 'hardware:300';

$\=$/;

my $count = shift || 300;
print md5_hex($taskId.$_.$salt) for 1..$count;
