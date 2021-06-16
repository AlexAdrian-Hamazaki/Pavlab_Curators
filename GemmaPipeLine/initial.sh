#!bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
for gse in $(grep . initialList.txt)
do
$GEMMACMD fillBatchInfo -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $gse;
python batchChecking.py $gse $GEMMAUSERNAME $GEMMAPASSWORD
for line in $(grep . "temp.txt")
do
if [[ "$line" == "True" ]]
then
	$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $gse;
else
	echo no batch to worried about for $gse, moving on 
fi
$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $gse -diagupdate;
done
rm temp.txt
done
python attention.py 'initialList.txt' $GEMMAUSERNAME $GEMMAPASSWORD;