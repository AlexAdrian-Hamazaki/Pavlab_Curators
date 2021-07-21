#!bin/bash
variable=$(head -n 1 temp.txt)
state=$(awk '{print $1}' <<< "$variable")
platform=$(awk '{print $2}' <<< "$variable")
echo $platform