use LWP::Simple;
use Term::ANSIColor;						#accesses the folder for colors
getstore('http://www.mdl.nws.noaa.gov/~naefs_ekdmos/text/naefs_tempcdf_00.txt','AllStations.txt') or die 'unable to get page';#gets the textfile from the webpage and stores it in a textfile

$file = "AllStations.txt";					#textfile of stations
open (INFILE, "< $file") or die "Can't open $file for read: $!";#opens the infile handle
open (OUTFILE1, ">nws3.txt") or die "Can't open for write: $!"; #opens the outfile handle names the file
open (OUTFILE2, ">nws2.txt") or die "Can't open for write: $!"; #opens the outfile handle names the file


print "What is the cost of your electricity?\n";		#query's user about cost of electricity
$cost = <>;							#input from the user
print "Thank you.\n";

$c = 0;								#sets the time counter

while (<INFILE>) {						#while we are reading through AllStations
($date,$station,$c05,$c10,$c20,$c30,$c40,$c50,$c60,$c70,$c80,$c90,$c95,$mean,$sd)=split(' ',$_,15);#split into 15 parts
if ($date=='VALID')						#if the first line is the word VALID
{}								#do nothing with that line
elsif ($date>1){						#all other lines
$date=~/(\d\d\d\d)(\d\d)(\d\d)(\d\d)/;				#split date into year, month, day, hour


if ($c == 0)							#for the first pass through 
     {
      $file1 = $station."."."txt";				#renames the file for each station	
      open (OUTFILE1, "> $file1") or die "Can't open $file1 for write: $!"#opens output filehandle				
     }


$c00=$c10+(2*($c05-$c10));  					#linear extrapolation for the 0 value
$c1h=$c90+(2*($c95-$c90));					#linear extrapolation for the 100 value

    if ($n == 0)						#I just need to do this once  
     {	
      $month[$c] = $2; 						#puts the month in a variable
      $day[$c] = $3;						#puts the day in a variable
      $year[$c] = $1;						#puts the year in a variable
      $hour[$c] = $4;						#puts the hour in a variable
     }
$c = $c + 1;							#increments time counter
print OUTFILE1 "$station $c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";

    if ($c % 75 == 0)						#if the time counter is evenly divisible by 75, do this
     {
      $n = $n + 1;						#station counter
      $c = 0;							#reset time counter
      close OUTFILE1 or die "Cannot close $file1: $!";		#closes the current OUTFILE1
     }#the if
  }#the elsif
}#the while
close INFILE or die "Cannot close $file: $!";

$x = 0;								#set counter x equal to 0
$cdf[0] = 0;							#set the array cdf[0] equal to 0

for ($z = 1; $z <= 13; $z++)					#for loop for z, to keep track of the array 
{
	if ($z <= 2 || $z >= 11)				#for the cdf values of 5, 10 and 95, 100 	
	{
	$cdf[$z] = $cdf[$x]+ 0.05;				#makes the above cdf values 0.05
	$x++							#x increments, one less than z
	}

	else							#for all others
	{
	$cdf[$z] = $cdf[$x]+ 0.10;				#make all the other cdf values 0.10
	$x++;							#x increments, one less than z
	}
}
$c = 0;	

do{
print "What station model would you like to evaluate?\n";	#query's user about station model
$stationu = <>;							#input from the user
chomp $stationu;
print "Thank you.\n";
open (FH, $stationu.".txt") ||
    die "ERROR Unable to open Dates: $!\n";            		#opens up textfile and assigns it a file handle

@array = <FH>;							#puts the textfile into an array

close FH;							#closes the file handle
	
for($i = 0; $i <= 74; $i++) {					#looping through the 75 rows	

    @Temp = split(" ", @array[$i]);				#split line in array into a Temperature array 

$n = ($Temp[13] - $Temp[1]) / 0.1;				#number of bins
$T = $Temp[1];							#Sets T for incrementation
$Ntemp[0] = $Temp[1];						#Sets new temp for zero value
$CDF[0] = 0;							#sets the CDF
$Tbot = $Temp[1]; 						#sets the lower bound on temp
$Cbot = $cdf[0];						#sets the lower bound on cdf
$j = 1;								#counter for changing Ttop and Ctop
$Ttop = $Temp[$j];						#sets the upper bound on temp
$Ctop = $cdf[$j];						#sets the upper bound on cdf
$k = 0;								#counter for differnece, pdf and temp

for ($p=1; $p<=$n; $p++)					#we are going to loop through n times, all of the bins
{
  $T = $T + 0.1;						#increment temperature

  if ($T > $Ttop)						#if what we are incrementing equals the top of the bin
    {
      $j = $j + 1;						#increment my changer
      $Tbot = $Ttop;						#change top to bottom for temp
      $Ttop = $Temp[$j];					#and create a new top for temp
      $Cbot = $Ctop;						#Change top to bottom for cdf
      $Ctop = $cdf[$j];						#and create a new top for cdf
      
    }

$CDF[$p]=$Cbot +((($T-$Tbot)/($Ttop-$Tbot))*($Ctop-$Cbot));	#this is my interpolation
$Ntemp[$p] = $T;						#creates the array for incremented temp

$pdf[$p] = $CDF[$p] - $CDF[$k];					#does the difference for the pdf
$Mid[$p] = ($Ntemp[$p]+$Ntemp[$k])/2;				#calculate middle of the bin
$k = $k + 1;							#increment the difference counter

$price[$p] = 1.36 *(abs($Mid[$p]-55)) +20;			#price of the middle
}#closes a for loop

for ($x = 1; $x <= $n; $x++)
 {
   $mean=$mean + $pdf[$x]*$Mid[$x];				#expected value of X
   $meansq=$meansq + $pdf[$x]*($Mid[$x]**2);			#expected value of X^2
   $var2=$meansq-($mean**2);					#is that squared
   $StDev=(sqrt(abs($var2))); 					#square root


$Pindicator = ($price[$x] - $cost);				#calculates the profit

$dailyp = sprintf("%.2f", $Pindicator * $pdf[$x]);		#calculates the profit for each day
$profit = sprintf("%.2f", $profit + $Pindicator * $pdf[$x]);	#calculates profit for the whole week	

print OUTFILE2 color 'green';
$exprofit = sprintf("%.2f",$profit/$n);				#computes expected profit to 2 decimal places
#print "\n \nThe expected profit is $exprofit \n";		#displays the expected profit to the screen
print OUTFILE2 "\n \nThe expected profit is $exprofit \n";	#display expected profit to the outfile

$std_dev = sprintf("%.2f",sqrt(abs($exprofit)));		#computes standard deviation to 2 decimal places
#print "The standard deviation of profit is $std_dev\n";		#dispalys standard deviation to the screen
print OUTFILE2 "The standard deviation of profit is $std_dev\n";	#display standard deviation to outfile

print OUTFILE2 color 'reset';
#print $c $month[$c];
if ($profit < 0){						#when profit is less than 0
	print color 'red';					#prints the following in red if no profit
	#print "You net a loss of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's loss
	print OUTFILE2 "You net a loss of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's loss in a textfile
	}
print OUTFILE2 color 'reset';						#resets color to black
if ($profit > 0){						#when profit is greater than 0
	print color 'blue';					#prints the following in blue for profit
	#print "You net a profit of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's profit
	print OUTFILE2 "You net a profit of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's profit in a textfile
	}

#print "The accumulated profit is $profit from $month[0]-$day[0]-$year[0] at $hour[0] Zulu to $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu\n";								#displays accumulated profit
print OUTFILE2 "The accumulated profit is $profit from $month[0]-$day[0]-$year[0] at $hour[0] Zulu to $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu\n"; #prints the output to a textfile
							#increment tome counter
print OUTFILE2 color 'reset';	
					#resets color to black
 }#closes a for loop
$c = $c + 1;
}#closes a for loop
print "Did you want to evaluate another Station(y/n)?\n";
$ans = <>;
chomp $ans;
}while ($ans eq 'y');
print "\n";							#print a blank line


