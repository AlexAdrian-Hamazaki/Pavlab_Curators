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
echo which column is Oligo ID
read oligoID
echo what is the absolute location of the matching file
read file
cat platform.txt | awk -F '\t' -v "col1=$elementID" -v "col2=$oligoID" '{print $col1 "\t" $col2}' > raw.${gpl}.probetab
perl -e 'open(IN, "<raw.'"$gpl"'.probetab");while(<IN>){chomp;@x=split;$k{$x[1]}=$x[0];}close IN;open(IN,"<'"$file"'");while(<IN>){chomp;s/\cM//;@x=split;print "$k{$x[0]}\t$x[0]\t$x[1]\n" if ($k{$x[0]}); }' | sort -g | uniq > ${gpl}.probetab
# rm platform.txt
# sed -i '/\"/d' ${gpl}.probetab 
# $GEMMACMD addPlatformSequences -u $GemmaUsername -p $GEMMAPASSWORD -a $gpl -y OLIGO -f ${gpl}.probetab
# $GEMMACMD blatPlatform -u $GemmaUsername -p $GEMMAPASSWORD --array $gpl
# $GEMMACMD mapPlatformToGenes -u $GEMMAUSERNAME -p $GEMMAPASSWORD --array $gpl -force
# $GEMMACMD makePlatformAnnotFiles -u $GemmaUsername -p $GEMMAPASSWORD -a $gpl
# rm raw.${gpl}.probetab
# rm noSequence_${gpl}.probetab
# rm ${gpl}.probetab