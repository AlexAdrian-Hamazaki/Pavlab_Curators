#!bin/bash
echo "what is the GPL number enter in this form (GPLXXXX)"
read gpl
echo "Enter the url of the full table"
read url

##Get the text from the html that has the full table
python3 get.py $url

##Removing formmating issue that happened during transforming pure html to text and removing unwanted column
sed -i '/^[[:space:]]*$/d' platform.txt 
sed -i '/^GEO /d' platform.txt
sed -i '/^#/d' platform.txt

echo which column is Element ID
read elementID
echo which column is Oligo ID
read oligoID
##eg: /space/grp/databases/arrays/other/operon/humanOligo.raw.txt
echo what is the absolute location of the matching file
read file
#Get columns that we want
cat platform.txt | awk -F '\t' -v "col1=$elementID" -v "col2=$oligoID" '{print $col1 "\t" $col2}' > raw.${gpl}.probetab
#map oligoIDs to actual sequences
perl -e 'open(IN, "<raw.'"$gpl"'.probetab");while(<IN>){chomp;@x=split;$k{$x[1]}=$x[0];}close IN;open(IN,"<'"$file"'");while(<IN>){chomp;s/\cM//;@x=split;print "$k{$x[0]}\t$x[0]\t$x[1]\n" if ($k{$x[0]}); }' | sort -g | uniq > ${gpl}.probetab
rm platform.txt