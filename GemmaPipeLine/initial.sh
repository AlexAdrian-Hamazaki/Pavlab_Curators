#!bin/bash
$GEMMACMD fillBatchInfo -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'initialList.txt'
$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'initialList.txt';
python attention.py 'initialList.txt' $GEMMAUSERNAME $GEMMAPASSWORD;