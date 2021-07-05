#!bin/bash
echo "what is the GPL number enter in this form (GPLXXXX)"
read gpl
echo "Enter the url of the full table"
read url
python3 get.py $url
sed -i '/^[[:space:]]*$/d' platform.txt 
sed -i '/^GEO /d' platform.txt
sed -i '/^#/d' platform.txt
echo which column is Element ID
read elementID
echo which column is Sequence ID
read sequenceID
echo which column is Sequence
read sequence
cat platform.txt | awk -F '\t' -v "col1=$elementID" -v "col2=$sequenceID" -v "col3=$sequence" '{print $col1 "\t" $col2 "\t" $12}' > raw.${gpl}.probetab
cat raw.${gpl}.probetab | awk -F '\t' 'NR>1 && $3 ~/[A-Z]{4}$/' > ${gpl}.probetab ; cat raw.${gpl}.probetab | awk -F '\t' 'NR>1 && !$3' > noSequence_${gpl}.probetab
rm platform.txt
sed -i '/\"/d' ${gpl}.probetab 