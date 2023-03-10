#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <columns> <input file> " >&2
    exit 1
fi


# Redirect STDOUT to an html file
exec >> /home/pi/m2Tester/readings.html

# Start table
echo "<table>"
declare -a line

count=0 # Initialize a counter for columns
while read line; do
    if [[ $count -eq 0 ]]; then
        # We're at the start of a new row, open it.
        printf "\t<tr>\n"
    fi

    if [[ $count -lt $1 ]]; then
        # Print next line from data file
    #    printf "\t\t<td>${line[$count]} </td>\n" 
        echo "\t\t<td>${line[$count]} </td>\n" 
    fi

    (( count++ ))

    if [[ $count -eq $1 ]]; then
        # We're at the end of a row, close it.
        printf "\t</tr>\n"
        count=0
    fi
done < $2

if [[ $count -ne 0 ]]; then
    # Kludge for when columns doesn't divide equally into data size
    printf "\t</tr>\n"
fi

# End table
echo "</table>"
