#!bin/bash
SCRIPT_DIR=“$( cd “$( dirname “${BASH_SOURCE[0]}” )” &> /dev/null && pwd )”
cd $SCRIPT_DIR
while IFS= read -r line || [ -n “$line” ]
do
	gse=$(awk ‘{print $1}’ <<< “$line”)
	python batchChecking.py $gse $GEMMAUSERNAME $GEMMAPASSWORD
	for state in $(grep . “temp.txt”)
	do
		if [[ “$state” == “True” ]]
			then
				$GEMMACMD makeProcessedData -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $gse;
			else
				echo no batch to worried about for $gse, moving on
		fi
	done
		rm temp.txt	
		$GEMMACMD diffExAnalyze -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $line;
		$GEMMACMD generateDataFile -u $GEMMAUSERNAME -p $GEMMAPASSWORD -e $gse;
done < curatingList.txt
python eeID.py ‘curatingList.txt’ $GEMMAUSERNAME $GEMMAPASSWORD;