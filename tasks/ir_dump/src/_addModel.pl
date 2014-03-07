open F, shift or die;
sysread F, $d, -s F;
close F;

$d =~ s/[\r\n]//g;
print "RMC364GY".$d;
