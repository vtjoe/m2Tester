#!/bin/bash
result=`ps aux | grep -i "strip-m2TestData.sh" | grep -v "grep" | wc -l`
if [ $result -eq 0 ]
   then
        /home/pi/m2Tester/strip-m2TestData.sh > /dev/null 2>&1 & 
	echo " Result ==> $result "
        echo "starting script "
   else
        echo "script is running"
	echo " Result else ==> $result "
	exit
fi
