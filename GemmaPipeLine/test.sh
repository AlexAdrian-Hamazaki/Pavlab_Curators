#!bin/bash
# python batchChecking.py GSE12293 $GEMMAUSERNAME $GEMMAPASSWORD
# while IFS= read -r line || [ -n "$line" ]
# do
# gse=$(awk '{print $1}' <<< "$line")
# done < curatingList.txt
variable="$(head -n 1 temp.txt)"
# echo $variable
# state=$(echo $variable|awk '{print $1}')
state=$(awk '{print $1}' <<< $variable)
platform=$(awk '{print $2}' <<< $variable)
echo $state
echo $platform