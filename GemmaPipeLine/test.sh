#!bin/bash
python batchChecking.py GSE12293 $GEMMAUSERNAME $GEMMAPASSWORD
while IFS= read -r line || [ -n "$line" ]
do
gse=$(awk '{print $1}' <<< "$line")
done < curatingList.txt