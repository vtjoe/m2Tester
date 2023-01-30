#!/bin/bash
#########################################
# This script is to be used to clean up the output file      #
# of the m2 tester.                                          #
# settings you can adjust:                                   #
# limit - Set to minimum pressure you want to extract        #
#.           from data file.                                 #
# ---------------------------------------------------------------------- #
# idl-row-threshold - How many rows should be stored                     #
#                                    between valid pressure rows.        #
# -----------------------------------------------------------------------#
# script output goes to readings-DATESTAMP.txt.                          #
# -----------------------------------------------------------------------#
# Messages
message1="--m2Tester.file:--FRCDISP1.TXT--does--not--exist--"
message2="--Checking.for.Wifi--"
message3="--Concantenating.data--
message4="--Sending.to.Github--
message5="--Google.Sheets.refreshes.once.an.hour--"
message6="--.--..--...--....--.....--......--......."
FILE="FRCDISP1.TXT"
declare -i  counter=0
# CHANGE THE FOLLOWING 2 VALUES ONLY
limit=75
idleRowThreshold=50
# ---------------------------------------------------------------------
idle_count=0
TIMESTAMP=`date "+%Y-%m-%d-%H-%M-%S"`
NAME=`echo "FRCDISP1.TXT" | cut -d'.' -f1`
log=` echo "readings-$TIMESTAMP.txt"`
logHtml=` echo "readings-$TIMESTAMP.html"`
touch $log $logHtml
echo " , ,Total Pressure:, Pressure 1:, Pressure 2:, Pressure 3:, Pressure 4:, Horizontal:" >> $log
echo "<tr> <td>TimeStamp</td><td>Date Time</td><td>Total Pressure:</td><td>Pressure 1:</td><td>Pressure 2:</td><td>Pressure 3:</td><td>Pressure 4:</td><td>Horizontal:</td></tr>" >> $logHtml
# ----- IS THE TESTER FILE AVAILABLE ------
FILE="/mnt/usb0/FRCDISP1.TXT"
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    /home/pi/m2Tester/m2-script-message.py $message1
    exit
fi
cp -p $FILE .



# ----------------------------
# IS THERE WIFI ?
wifi=`ifconfig | grep "inet " | sed -n 2p | awk '{print$1"-"$2}'`
/home/pi/m2Tester/m2-script-message.py $message2
sleep 5
/home/pi/m2Tester/m2-script-message.py $wifi
# Create a timestamped copy of original data
cp $NAME.TXT $NAME-$TIMESTAMP.TXT

FILENAME="FRCDISP1.TXT"
#echo $FILENAME
totalRowCount=`cat $FILENAME | wc -l `
totalRowCountStart=`cat $FILENAME | wc -l `

# Timestamp for readings file

fileTstamp=`date "+ %Y-%m-%d , %H:%M:%S ,"`
#echo $fileTstamp

cat $FILENAME | while read line;
do
        ((++counter))
#       PRINT ONE LINE OF FILE
        ln=`sed -n "$counter"p $FILENAME`
#       IS THE ROW ABOVE OR BELOW THRESHOLD
        col=`echo $ln | awk '{print$3}'`
#       CREATE timestamps for data row
	fileTstamp=`date "+%Y-%m-%d %H:%M:%S"`
        fileTstampLong=`date "+%Y%m%d%H%M%S%3N"`
#       ISOLATE just the values
        temp=`echo $ln | awk '{print$3","$7","$11","$15","$19","$22}'`
	Readings=`echo "<tr><td>$fileTstampLong</td><td>$fileTstamp</td>"`
        Readings=$Readings`echo $temp | awk -F, '{printf("<td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>$6</td></tr>")}'`
#	echo $Readings 
        ln="$fileTstampLong,$fileTstamp,$temp"
#       echo $col
#	clear
	printf "\n  Total Lines $totalRowCountStart Processing Row $counter Decrement counter = $totalRowCount "  
	printf "\n  Beginning of Loop $counter "

       if [ $(echo "$col > $limit " | bc) -eq 1 ]; then
#               echo "$col is greater than $limit (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
#                echo $ >> $log
                idle_count=0
               ((--totalRowCount))
	printf \n "  Compare against col value $counter"
        elif [ $(echo "$idle_count < $idleRowThreshold " | bc) -eq 1 ]; then
 #               echo "$col is less than $idleRowThreshold - $idle_count  writing to file (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
                ((++idle_count))
               ((--totalRowCount))
	printf \n " In the idle count loop $counter"

#        elif  [ $(echo "$totalRowCount < 1 " | bc) -eq 1 ]; then
#        elif  [ $totalRowCount -eq 1 ]; then
         elif  [ $counter -eq 1 ]; then
                echo " COMPLETED "
		echo "</table>" >> $logHtml
	printf \n " Are we done ? $counter"
                  break 
		  exit 1
        else
#                echo "$col is less than $limit (linenumber $counter)"
                ((--totalRowCount))

        fi
#sleep 1
done
# Remove tester file
rm -f FRCDISP1.TXT

# Concatenate all the HTML readings
rm README.md
echo "<table>" >> README.md
/home/pi/m2Tester/m2-script-message.py $message3
sleep 5
find . -type f -name 'readings-*.html' -exec cat {} + >> README.md
#exit
/home/pi/m2Tester/m2-script-message.py $message4
sleep 5
git add --all
git commit -m "Updating Google Sheet  $TIMESTAMP" README.md 
git commit -m "Updating data $TIMESTAMP" readings* 
git push git@github.com:vtjoe/m2Tester.git
/home/pi/m2Tester/m2-script-message.py $message5
sleep 5
exit 0

