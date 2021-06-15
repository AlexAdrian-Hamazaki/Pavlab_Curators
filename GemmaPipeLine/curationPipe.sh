#!bin/bash
python batchChecking.py GSE12293 $GEMMAUSERNAME $GEMMAPASSWORD
while IFS= read -r line || [ -n "$line" ]
do
$GEMMACMD diffExAnalyze -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $line;
$GEMMACMD generateDataFile -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $line;
done < curatingList.txt
python eeID.py 'curatingList.txt' $GEMMAUSERNAME $GEMMAPASSWORD;