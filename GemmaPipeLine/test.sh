#!bin/bash
python batchChecking.py GSE12293 $GEMMAUSERNAME $GEMMAPASSWORD
while IFS= read -r line || [ -n "$line" ]
do
echo $line
done < curatingList.txt