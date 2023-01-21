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
FILE="FRCDISP1.TXT"
message1="--m2Tester.file:--FRCDISP1.TXT--does--not--exist--"
#declare -a Readings
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
echo "<table>" >> $logHtml
echo " <td>TimeStamp</td><dt>Date Time</dt> <td>Total Pressure:</td><td> Pressure 1:</td><td> Pressure 2:</td> <td>Pressure 3:</td><td> Pressure 4:</td><td> Horizontal:</td>" >> $logHtml
# ----- IS THE TESTER FILE AVAILABLE ------
FILE="FRCDISP1.TXT"
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    /home/pi/m2Tester/m2-script-message.py $message1
    exit
fi
# ----------------------------
# Create a timestamped copy of original data
cp $NAME.TXT $NAME-$TIMESTAMP.TXT

FILENAME="FRCDISP1.TXT"
#echo $FILENAME
totalRowCount=`cat $FILENAME | wc -l `
totalRowCountStart=`cat $FILENAME | wc -l `

# Timestamp for readings file

fileTstamp=`date "+ %Y-%m-%d , %H:%M:%S ,"`
#echo $fileTstamp

LINES=$(cat $FILENAME)

for LINE in $LINES
do
        ((++counter))
#       PRINT ONE LINE OF FILE
        ln=`sed -n "$counter"p $FILENAME`
#       IS THE ROW ABOVE OR BELOW THRESHOLD
        col=`echo $ln | awk '{print$3}'`
#       CREATE timestamps for data row
	fileTstamp=`date "+ %Y-%m-%d-%H:%M:%S "`
        fileTstampLong=`date "+%Y%m%d%H%M%S%3N"`
#       ISOLATE just the values
        temp=`echo $ln | awk '{print$3","$7","$11","$15","$19","$22}'`
	Readings=`echo "<tr><td>$fileTstampLong</td><td>$fileTstamp</td>"`
        Readings=$Readings`echo $temp | awk -F, '{printf("<td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td></tr>")}'`
#	echo $Readings 
        ln="$fileTstampLong,$fileTstamp,$temp"
#       echo $col
	clear
	printf " Total Lines $totalRowCountStart Processing Row $counter "  

       if [ $(echo "$col > $limit " | bc) -eq 1 ]; then
#               echo "$col is greater than $limit (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
#                echo $ >> $log
                idle_count=0
               ((--totalRowCount))
        elif [ $(echo "$idle_count < $idleRowThreshold " | bc) -eq 1 ]; then
 #               echo "$col is less than $idleRowThreshold - $idle_count  writing to file (linenumber $counter)"
                echo $ln >> $log
                echo $Readings >> $logHtml
                ((++idle_count))
               ((--totalRowCount))

#        elif  [ $(echo "$totalRowCount < 1 " | bc) -eq 1 ]; then
         elif  [ $totalRowCount == 1 ]; then
                echo " COMPLETED "
		echo "</table>" >> $logHtml
                  break
		  exit 1
        else
#                echo "$col is less than $limit (linenumber $counter)"
                ((--totalRowCount))

        fi
#sleep 1
done
exit 0

