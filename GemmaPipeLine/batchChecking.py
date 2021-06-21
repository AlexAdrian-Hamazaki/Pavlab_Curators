#"""
# Linear operation of systematically find out which experiemnts require attention for outlier (possible to optimize runtime using multiprocessing module)
#"""

import json
import urllib2
import base64
import sys
import ssl
import re

def main():
    # Without this the urllib2.request would fail
    ssl._create_default_https_context = ssl._create_unverified_context

    # Change this if you want to simutaneously process more than 50 GSEs
    limit = 100

    username = sys.argv[2]
    password = sys.argv[3]
    base64string = base64.encodestring('{}:{}'.format(username, password))[:-1]
    
    
    GSE = str(sys.argv[1])

    print ('Start scrapping using the Gemma REST_api')
    api_url= 'https://gemma.msl.ubc.ca/rest/v2/datasets/{}?offset=0&limit=20'.format(GSE)
    plat= "https://gemma.msl.ubc.ca/rest/v2/datasets/GSE98566/platforms".format(GSE)
    # Add basic authentication header
    request = urllib2.Request(api_url)
    request.add_header("Authorization", "Basic {}".format(base64string)) 
    response = urllib2.urlopen(request)
    text = response.read()
    experiments_dict = json.loads(text)
    state = "False"
    if len(experiments_dict[u'data']) == 0:
        state = "False"
    elif experiments_dict[u'data'][0][u'batchConfound'] is not None or (experiments_dict[u'data'][0][u'batchEffect'] is not None and experiments_dict[u'data'][0][u'batchEffect'] !="No batch information was available" and 
    experiments_dict[u'data'][0][u'batchEffect'] != "No batch effect was detected"):
	    print("{} has batch info, correcting now".format(GSE))
	    state = "True"

    request = urllib2.Request(api_url)
    request.add_header("Authorization", "Basic {}".format(base64string)) 
    response = urllib2.urlopen(request)
    text = response.read()
    platform_dict = json.loads(text)
    platform=" "
    if re.match("^Affy", platform_dict[u'data'][0]["name"]):
        platform = "affy"
    
    

    with open('temp.txt', 'w') as f:
        f.write(state + "   " + platform)
	

if __name__ == "__main__":
    main()