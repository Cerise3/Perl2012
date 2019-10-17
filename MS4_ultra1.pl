print "What is the cost of your electricity?\n";        		#query's user about cost of electricity
$cost = <>;                           					#input from the user
print "Thank you.\n";


$x = 0;                               					#set counter x equal to 0
$cdf[0] = 0;                            				#set the array cdf[0] equal to 0

for ($z = 1; $z <= 13; $z++)                    			#for loop for z, to keep track of the array 
 {
  if ($z <= 2 || $z >= 11)                   				#for the cdf values of 5, 10 and 95, 100     
   {
    $cdf[$z] = $cdf[$x]+ 0.05;                    			#makes the above cdf values 0.05
    $x++                           					#x increments, one less than z
   }
  else                                					#for all others
   {
    $cdf[$z] = $cdf[$x]+ 0.10;                   			#make all the other cdf values 0.10
    $x++;                        					#x increments, one less than z
   }            
}                   							#closes the for loop, with the z counter

do
 {
  print "What station model would you like to evaluate?\n";   		#query's user about station model
  $stationu = <>;                        				#input from the user
  chomp $stationu;
  print "Thank you.\n";

  $file6 = $stationu."_peopletable."."txt";                		#renames the file for each station
  open (OUTFILE6, "> $file6") or die "Can't open $file1 for write: $!"; #opens output filehandle
  $file7 = $stationu."_ultra."."txt";                    		#renames the file for each station
  open (OUTFILE7, "> $file7") or die "Can't open $file1 for write: $!"; #opens output filehandle
  $file8 = $stationu."_computertable."."txt";               		#renames the file for each station
  open (OUTFILE8, "> $file8") or die "Can't open $file1 for write: $!";	#opens output filehandle

  open (FH, $stationu.".txt") ||
    die "ERROR Unable to open Dates: $!\n";                    		#opens up textfile and assigns it a file handle
  @array = <FH>;                        				#puts the textfile into an array
  close FH;                            					#closes the file handle
  print OUTFILE6 "\t\t\t\t\t\t\t PRICES\n\n";   			# header                     
 
  for($i = 0; $i <= 74; $i++)                    			#looping through the 75 rows
   {                        
    @Temp = split(" ", @array[$i]);                			#split the file array into a Temperature array 

     if ($i % 25 == 0) 
     {
       print OUTFILE6 " \n";   						# header                     
       print OUTFILE6 "|  CDF 0 |  CDF 5 | CDF 10 | CDF 20 | CDF 30 | CDF 40 | CDF 50 | CDF 60 | CDF 70 | CDF 80 | CDF 90 | CDF 95 | CDF 100|\n";    
       print OUTFILE6 "'--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------'\n";   
     }

    for($p = 1; $p <= 13; $p++)                   			#loop through the 13 values in the row
     {
      $price = sprintf("%.2f", 1.36 *(abs($Temp[$p]-55)) +20);  	#convert Temp to price
      print OUTFILE6 "|  $price ";
      print OUTFILE8 " $price ";               				#output price to the table

     if ($p == 13)             						#every 13 values, aka end of row           
       {
        print OUTFILE8 "\n";						#computer friendly, new line
        print OUTFILE6 "|";						#user friendly, bar
        print OUTFILE6 "\n";						#user friendly, new line
        print OUTFILE6 "'--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------'";
        print OUTFILE6 "\n";                 			 	# user friendly, new line
       }

      $Pindicator = ($price - $cost);                			#calculates the profit
      $profit = sprintf("%.2f", $profit + $Pindicator * $cdf[$p]);	#calculates profit for the whole week    
      $worthit = sprintf("%.2f", -10000 + $profit);			#determines if we overcome the startup cost
      $plant = sprintf("%.2f", 10000 - $profit);			#keeps track of how much until we overcome the startup cost
      $xxxx = 3 * $i;							#calculates the number of hours elapsed 
     }


    if($worthit > 0)   {                     				#you have made a profit 
      print OUTFILE7 "To make $worthit profit your plant will have run for $xxxx hours. \n";
     }
    else   {                          					#you have not yet made a profit
      print OUTFILE7 "If the plant runs $xxxx hours, you will still need to make $plant to break even.\n";
     }
 }                                					#closes the outside for loop, with the i counter

print "Did you want to evaluate another Station(y/n)?\n";		#Input from the user to evaluate another station
  $ans = <>;
  chomp $ans;
 }while ($ans eq 'y');      						#ends the Do-While loop

close OUTFILE6 or die "Can't close file: $!";            		#closes the files used
close OUTFILE7 or die "Can't close file: $!"; 
close OUTFILE8 or die "Can't close file: $!";	
