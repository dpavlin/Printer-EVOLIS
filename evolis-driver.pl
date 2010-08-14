
my $color = 'k';
# k = black
printf "\x1BPr;$color\r"

my $feeder = 'F';
# F = Feeder
# M = Manual
# B = Auto

print "\x1BPmi;$feeder;s\r";

my $temperature = 10;
print "\x1BPc;$color;=;$temperature\r"

# improve output FIXME not used by cups
print "\x1BPr;k\r";

# FIXME ? only implemented in windows
print "\x1BPdt;DU\r";
print "\x1BMr;s\r";
print "\x1BPpws;1281732635\r";

# FIXME load card into printer
print "\x1BSs\r";
print "\x1BSr\r";

my $line = 2;
my $command_size = 11682
print "\x1BDbc;k;2;11682;"; # bitmap data
print "\r";

# even page on two side-printing
print "\x1BSv\r";

print "\x1BPc;k;=;10\r";

print "\x1BDbc;k;2;31744;"; # bitmap data
print "\r";

print "\x1BSe\r";
print "\x00" x 64; # FIXME some padding?
