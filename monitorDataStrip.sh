#!/bin/bash
date
FILE="FRCDISP1.TXT"
if [[ ! -f $FILE ]]
then
    echo "$FILE does not exist"
    exit
fi
countSource=`cat $FILE | wc -l`
echo $countSource

filename=`ls -dt read* | head -1`
echo $filename
countTarget=`cat $filename | wc -l`
echo $countTarget

for ((i=1;i<=100;i++))
do  
#clear
printf  "Source =$countSource Target =$countTarget counter =$i \n "
sleep 10
countTarget=`cat $filename | wc -l`
done

date

