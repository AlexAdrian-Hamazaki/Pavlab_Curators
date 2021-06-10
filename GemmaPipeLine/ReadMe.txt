1. If you only want to get the eeids you can follow this
Put the GSEs separated by \n in the curatingList.txt
run source eeid.sh, the results will be in eeIDList.txt

2. If you want to find out which experiments have predicted outlier/bash effects
Put the GSEs separated by \n in the initialList.txt
run source attentionList.sh, the results will be in attentionList.txt

***Below are the two most commonly used commands
3. If you want to run DEA, generate data file, update the graphs in dianostics, and get the eeids
Put the GSEs separated by \n in the curatingList.txt
run source curationPipe.sh, the eeids will be in eeIDList.txt

4. If you want to run fillinbatchinfo, makeProcessData (you can run this on any exp it does not affect it if no data is present), and also run the second step
Put the GSEs separated by \n in the initialList.txt
run source initial.sh, the GSEs that need attentions will be in attentionList.txt