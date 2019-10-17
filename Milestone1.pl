use strict;

my $file = "StationK11R.txt";
open (INFILE, "< $file") or die "Can't open $file for read: $!";
open (OUTFILE, ">date.txt") or die "Can't open for write: $!";
while (<INFILE>) {
my($date,$station,$p5,$p10,$p20,$p30,$p40,$p50,$p60,$p70,$p80,$p90,$p95,$mean,$sd)=split(' ',$_,15);
if ($date=='valid')
{}
elsif ($date>1){
$date=~/(\d\d\d\d)(\d\d)(\d\d)(\d\d)/;
print OUTFILE "$2-$3-$1 at $4 Zulu \n";
print "$2-$3-$1 at $4 Zulu \n";
}
}
close INFILE or die "Cannot close $file: $!";
close OUTFILE or die "Cannot close $file: $!";



