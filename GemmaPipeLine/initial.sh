#!bin/bash
for line in $(grep . initialList.txt)
do
$GEMMACMD fillBatchInfo -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $line;
python batchChecking.py line $GEMMAUSERNAME $GEMMAPASSWORD
for line in $(grep . "temp.txt")
do
if [[ "$line" == "True" ]]
then
	$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $line;
else
	echo no batch to worried about for $line, moving on 
fi
$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -f 'initialList.txt' -diagupdate;
done
rm temp.txt
done
python attention.py 'initialList.txt' $GEMMAUSERNAME $GEMMAPASSWORD;