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
# ---- GO TO PROCESSING DIRECTORY -----#
cd /home/pi/m2Tester
# Messages
message1="--FRCDISP1.TXT--does--not--exist--"
message2="--Checking.for.Wifi--"
message7="--PROCESSING--"
message3="--Concantenating.data--"
message4="--Sending.to.Github--"
message5="--DONE !!--"
message6="--.--..----......."
FILE="FRCDISP1.TXT"
declare -i  counter=0
# CHANGE THE FOLLOWING 2 VALUES ONLY
limit=75
idleRowThreshold=50
# ---------------------------------------------------------------------
# ----- IS THE TESTER FILE AVAILABLE ------
TFILE="/mnt/usb0/FRCDISP1.TXT"
if [ ! -f "$TFILE" ]; then
    echo "$TFILE does not exist."
    /home/pi/m2Tester/m2-script-message.py $message1
    exit
fi
# ----------------------------
# IS THERE WIFI ?
WGET="/usr/bin/wget"

$WGET -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]
then
	/home/pi/m2Tester/m2-script-message.py "WIFI NOT CONNECTED"
#    	echo "Not Connected..!"
	exit
else
	wifi=`ifconfig | grep "inet " | sed -n 2p | awk '{print$2".."}'`
#       echo "Connected..!"
	/home/pi/m2Tester/m2-script-message.py   $wifi
fi
# --------------------------
idle_count=0
TIMESTAMP=`date "+%Y-%m-%d-%H-%M-%S"`
NAME=`echo "FRCDISP1.TXT" | cut -d'.' -f1`
log=` echo "readings-$TIMESTAMP.txt"`
logHtml=` echo "readings-$TIMESTAMP.html"`
touch $log $logHtml
echo " , ,Total Pressure:, Pressure 1:, Pressure 2:, Pressure 3:, Pressure 4:, Horizontal:" >> $log
echo "<tr> <td>TimeStamp</td><td>Date Time</td><td>Total Pressure:</td><td>Pressure 1:</td><td>Pressure 2:</td><td>Pressure 3:</td><td>Pressure 4:</td><td>Horizontal:</td></tr>" >> $logHtml
# Create a timestamped copy of original data
cp /mnt/usb0/$NAME.TXT $NAME-$TIMESTAMP.TXT
cp $NAME-$TIMESTAMP.TXT  ~/m2Tester-RawFile

FILENAME="/mnt/usb0/FRCDISP1.TXT"
#echo $FILENAME
totalRowCount=`cat $FILENAME | wc -l `
totalRowCountStart=`cat $FILENAME | wc -l `

# Timestamp for readings file
# Start Processing
/home/pi/m2Tester/m2-script-message.py $message7
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
        Readings=$Readings`echo $temp | awk -F, '{printf("<td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td></tr>")}'`
#       echo $Readings
       ln="$fileTstampLong,$fileTstamp,$temp"
#       echo $col
#       clear
#       printf "\n  Total Lines $totalRowCountStart Processing Row $counter Decrement counter = $totalRowCount "
#       printf "\n  Beginning of Loop $counter "

       if [ $(echo "$col > $limit " | bc) -eq 1 ]; then
#               echo "$col is greater than $limit (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
#                echo $ >> $log
                idle_count=0
               ((--totalRowCount))
#        printf \n "  Compare against col value $counter"
        elif [ $(echo "$idle_count < $idleRowThreshold " | bc) -eq 1 ]; then
 #               echo "$col is less than $idleRowThreshold - $idle_count  writing to file (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
                ((++idle_count))
               ((--totalRowCount))
#        printf \n " In the idle count loop $counter"

#        elif  [ $(echo "$totalRowCount < 1 " | bc) -eq 1 ]; then
#        elif  [ $totalRowCount -eq 1 ]; then
         elif  [ $counter -eq 1 ]; then
                echo " COMPLETED "
                echo "</table>" >> $logHtml
#        printf \n " Are we done ? $counter"
                  break
                  exit 1
        else
#                echo "$col is less than $limit (linenumber $counter)"
                ((--totalRowCount))

        fi
#sleep 1
done

# Concatenate all the HTML readings
rm README.md
echo "<table>" >> README.md
/home/pi/m2Tester/m2-script-message.py $message3
sleep 5
find . -type f -name 'readings-*.html' -exec cat {} + >> README.md
#
#exit
/home/pi/m2Tester/m2-script-message.py $message4
sleep 5
git-processing-log=` echo "/home/pi/m2Tester/git-processing.$TIMESTAMP.log"`
touch $git-processing
git-processing-log=` echo "/home/pi/m2Tester/git-processing-$TIMESTAMP.log"`
/usr/bin/sudo -u pi -H /usr/bin/git add --all >> $git-log 2>&1
/usr/bin/sudo -u pi -H /usr/bin/git commit -m "Updating Google Sheet  $TIMESTAMP" README.md >> $git-log 2>&1
/usr/bin/sudo -u pi -H /usr/bin/git commit -m "Updating data $TIMESTAMP" readings* >> $git-log 2>&1
/usr/bin/sudo -u pi -H /usr/bin/git push git@github.com:vtjoe/m2Tester.git >> $git-log 2>&1
sleep 5
# Remove Tester file so its not processed again
rm -f $FILENAME
# Loop with Done message
secs=700                         # Set interval (duration) in seconds X 5 sec sleep.
endTime=$(( $(date +%s) + secs )) # Calculate end time.
while [ $(date +%s) -lt $endTime ]; do  # Loop until interval has elapsed.
	/home/pi/m2Tester/m2-script-message.py $message5
       sleep 5
done
exit 0
