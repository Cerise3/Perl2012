use Term::ANSIColor;						#accesses the folder for colors
$file = "AllStations.txt";					#textfile of stations
open (INFILE, "< $file") or die "Can't open $file for read: $!";#opens the infile handle
open (OUTFILE1, ">nws3.txt") or die "Can't open for write: $!"; #opens the outfile handle names the file
open (OUTFILE2, ">nws2.txt") or die "Can't open for write: $!"; #opens the outfile handle names the file
print "What station model would you like to evaluate?\n";	#query's user about station model
print "1.K11R  2.K12N  3.K1F0  4.K1H2  5.TJSJ \n"; 		#station models to pick from
$stationu = <>;							#input from the user
print "Thank you.\n";

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

$c00=$c10+(2*($c05-$c10));  					#linear extrapolation for the 0 value
$c1h=$c90+(2*($c95-$c90));					#linear extrapolation for the 100 value

$month[$c] = $2; 						#puts the month in a variable
$day[$c] = $3;							#puts the day in a variable
$year[$c] = $1;							#puts the year in a variable
$hour[$c] = $4;							#puts the hour in a variable
$c = $c + 1;							#increments time 	counter								#from the users input, output a station 

if ($stationu==1)						#if the user input 1, then station K11R will output output the cdf to nws2.txt 											
{
if(/K11R/../K11R/){
print OUTFILE1 "$c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";
}}
elsif ($stationu == 2) 						#if the user input 2, then station K12N will output the cdf to nws2.txt
{
if(/K12N/../K12N/){
print OUTFILE1 "$c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";
}}
elsif ($stationu == 3) 						#if the user input 3, then station K1F0 will output output the cdf to nws2.txt
{
if(/K1F0/../K1F0/){
print OUTFILE1 "$c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";
}}
elsif ($stationu == 4) 						#if the user input 4, then station K1H2 will output output the cdf to nws2.txt
{
if(/K1H2/../K1H2/){
print OUTFILE1 "$c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";
}}
elsif ($stationu == 5) 						#if the user input 5, then station TJSJ will output output the cdf to nws2.txt
{
if(/TJSJ/../TJSJ/){
print OUTFILE1 "$c00 $c05 $c10 $c20 $c30 $c40 $c50 $c60 $c70 $c80 $c90 $c95 $c1h\n";
}}

}}

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
open (FH, "nws3.txt") ||
    die "ERROR Unable to open Dates: $!\n";            		#opens up textfile and assigns it a file handle

@array = <FH>;							#puts the textfile into an array

close FH;							#closes the file handle
	
for($i = 0; $i <= 11; $i++) {					#looping through the 12 values in each row	

    @Temp = split(" ", @array[$i]);				#split the file array into a Temperature array 

$n = ($Temp[12] - $Temp[0]) / 0.1;				#number of bins
$T = $Temp[0];							#Sets T for incrementation
$Ntemp[0] = $Temp[0];						#Sets new temp for zero value
$CDF[0] = 0;							#sets the CDF
$Tbot = $Temp[0]; 						#sets the lower bound on temp
$Cbot = $cdf[0];						#sets the lower bound on cdf
$j = 1;								#counter for changing Ttop and Ctop
$Ttop = $Temp[$j];						#sets the upper bound on temp
$Ctop = $cdf[$j];						#sets the upper bound on cdf
$k = 0;								#counter for differnece, pdf and temp

for ($i=1; $i<=$n; $i++)					#we are going to loop through n times, all of the bins
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

$CDF[$i]=$Cbot +((($T-$Tbot)/($Ttop-$Tbot))*($Ctop-$Cbot));	#this is my interpolation
$Ntemp[$i] = $T;						#creates the array for incremented temp

$pdf[$i] = $CDF[$i] - $CDF[$k];					#does the difference for the pdf
$Mid[$i] = ($Ntemp[$i]+$Ntemp[$k])/2;				#calculate middle of the bin
$k = $k + 1;							#increment the difference counter

$price[$i] = 1.36 *(abs($Mid[$i]-55)) +20;			#price of the middle
}

for ($x = 0; $x <= $n; $x++)
 {
   $mean=$mean + $pdf[$x]*$Mid[$x];				#expected value of X
   $meansq=$meansq + $pdf[$x]*($Mid[$x]**2);			#expected value of X^2
   $var2=$meansq-($mean**2);					#is that squared
   $StDev=(sqrt(abs($var2))); 					#square root


$Pindicator = ($price[$x] - $cost);				#calculates the profit

$dailyp = sprintf("%.2f", $Pindicator * $pdf[$x]);		#calculates the profit for each day
$profit = sprintf("%.2f", $profit + $Pindicator * $pdf[$x]);	#calculates profit for the whole week	

$exprofit = sprintf("%.2f",$profit/$n);				#computes expected profit to 2 decimal places
print "\n \nThe expected profit is $exprofit \n";		#displays the expected profit

$std_dev = sprintf("%.2f",sqrt(abs($exprofit)));		#computes standard deviation to 2 decimal places
print "The standard deviation of profit is $std_dev\n";		#dispalys standard deviation

if ($profit < 0){						#when profit is less than 0
	print color 'red';					#prints the following in red if no profit
	print "You net a loss of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's loss
	}
print color 'reset';						#resets color to black
if ($profit > 0){						#when profit is greater than 0
	print color 'blue';					#prints the following in blue for profit
	print "You net a profit of $dailyp for $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu \n";#display today's profit
	}
print color 'reset';						#resets color to black
print "The accumulated profit is $profit from $month[0]-$day[0]-$year[0] at $hour[0] Zulu to $month[$c]-$day[$c]-$year[$c] at $hour[$c] Zulu\n";								#displays accumulated profit
$c = $c + 1;							#increment tome counter
 }

        }
print "\n";							#print a blank line


