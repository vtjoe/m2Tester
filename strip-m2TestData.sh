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

declare -i  counter=0
# CHANGE THE FOLLOWING 2 VALUES ONLY
limit=75
idleRowThreshold=50
# ---------------------------------------------------------------------
idle_count=0
TIMESTAMP=`date "+%Y-%m-%d-%H-%M-%S"`
NAME=`echo "FRCDISP1.TXT" | cut -d'.' -f1`
log=` echo "readings-$TIMESTAMP.txt"`
touch $log
echo " , ,Total Pressure:, Pressure 1:, Pressure 2:, Pressure 3:, Pressure 4:, Horizontal:" >> $log
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
        ln=`sed -n "$counter"p $FILENAME`
        col=`echo $ln | awk '{print$3}'`
	fileTstamp=`date "+ %Y-%m-%d %H:%M:%S ,"`
        fileTstampLong=`date "+%Y%m%d%H%M%S%3N"`
        temp=`echo $ln | awk '{print$3","$7","$11","$15","$19","$22}'`
        ln="$fileTstampLong,$fileTstamp$temp"
#       echo $col
	clear
	printf " Total Lines $totalRowCountStart Processing Row $counter "  

       if [ $(echo "$col > $limit " | bc) -eq 1 ]; then
#               echo "$col is greater than $limit (linenumber $counter)"
                echo $ln >> $log
                idle_count=0
               ((--totalRowCount))
        elif [ $(echo "$idle_count < $idleRowThreshold " | bc) -eq 1 ]; then
 #               echo "$col is less than $idleRowThreshold - $idle_count  writing to file (linenumber $counter)"
                echo $ln >> $log
                ((++idle_count))
               ((--totalRowCount))

#        elif  [ $(echo "$totalRowCount < 1 " | bc) -eq 1 ]; then
         elif  [ $totalRowCount == 1 ]; then
                echo " COMPLETED "
                  break
		  exit 1
        else
#                echo "$col is less than $limit (linenumber $counter)"
                ((--totalRowCount))

        fi
#sleep 1
done
exit 0

