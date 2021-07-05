#!bin/bash
echo "what is the GPL number? (enter in the form as GPLXXXX)"
read gpl
$GEMMACMD addPlatformSequences -u $GemmaUsername -p $GEMMAPASSWORD -a $gpl -y OLIGO -f ${gpl}.probetab
$GEMMACMD blatPlatform -u $GemmaUsername -p $GEMMAPASSWORD --array $gpl
$GEMMACMD makePlatformAnnotFiles -u $GemmaUsername -p $GEMMAPASSWORD -a $gpl
$GEMMACMD mapPlatformToGenes -u $GEMMAUSERNAME -p $GEMMAPASSWORD --array $gpl
rm raw.${gpl}.probetab
rm noSequence_${gpl}.probetab
rm ${gpl}.probetab