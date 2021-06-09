#!bin/bash
$GEMMACMD diffExAnalyze -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'curatingList.txt';
$GEMMACMD generateDataFile -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'curatingList.txt';
$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'curatingList.txt' -diagupdate;
python eeID.py 'curatingList.txt' $GEMMAUSERNAME $GEMMAPASSWORD;

