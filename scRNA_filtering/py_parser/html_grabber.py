import os
import urllib2

url = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc="
GSE = "GSE58339"

r = urllib2.urlopen((url+GSE))


