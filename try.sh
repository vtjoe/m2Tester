#!/bin/bash
date
#!/bin/bash

# Run as: table.sh < {input-file-name} > {output-file-name}
# The script requires a space-delimited data file to parse into an html table.
# It does not automatically create a header row.

echo \<table\>
while read line; do
    echo \<tr\>
    for item in $line; do
#	col=`echo $ln | awk -F, '{print$3}'`
	temp=`echo $item | awk '{print$3"\<\/td\>\<td\>"$7"\<\/td\>\<td\>"$11"\<\/td\>\<td\>"$15"\<\/td\>\<td\>"$19"\<\/td\>\<td\>"$22"\<\/td\>}'`
        echo \<td\>$item\<\/td\>
	echo $temp
    done
    echo \<\/tr\>
done
echo \<\/table\>
