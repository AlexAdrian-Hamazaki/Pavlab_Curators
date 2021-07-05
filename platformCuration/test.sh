echo which column is Element ID
read elementID
cat platform.txt | awk -F '\t' '{print $elementID "\t"}' > raw.GPLXXXX.probetab
