#"""
# Linear operation of systematically find out which experiemnts require attention for outlier (possible to optimize runtime using multiprocessing module)
#"""

import json
import urllib2
import base64
import sys
import ssl


def main():
    # Without this the urllib2.request would fail
    ssl._create_default_https_context = ssl._create_unverified_context

    # Change this if you want to simutaneously process more than 50 GSEs
    limit = 100

    username = sys.argv[2]
    # username = 'Wilson'
    password = sys.argv[3]
    # password = 'chubbyt566'
    base64string = base64.encodestring('{}:{}'.format(username, password))[:-1]
    
    
    importFile = sys.argv[1]

    print ('Start scrapping using the Gemma REST_api')
    attention_set = set()
    count = 0
    with open(importFile, 'r') as f:
        for line in f:
            if line == '':
                pass
            else:
                if count > limit:
                    print('Please limit it to 100 experiments or less otherwise we will create too much traffic to the API call!')
                    sys.exit()
                count +=1
                GSE = line.strip()
                api_url= 'https://gemma.msl.ubc.ca/rest/v2/datasets/{}/samples'.format(GSE)
                # Add basic authentication header
                request = urllib2.Request(api_url)
                request.add_header("Authorization", "Basic {}".format(base64string)) 
                response = urllib2.urlopen(request)
                text = response.read()
                #Coverts Json in to dict
                experiments_dict = json.loads(text)
                for lst in experiments_dict[u'data']:
                    if lst[u'predictedOutlier'] == 'true' or  lst[u'predictedOutlier'] == True:
                        attention_set.add(GSE)
                        print(GSE + "is done!")
                        
                api_url= 'https://gemma.msl.ubc.ca/rest/v2/datasets/{}?offset=0&limit=20'.format(GSE)
                # Add basic authentication header
                request = urllib2.Request(api_url)
                request.add_header("Authorization", "Basic {}".format(base64string)) 
                response = urllib2.urlopen(request)
                text = response.read()
                experiments_dict = json.loads(text)
                if experiments_dict[u'data'][0][u'batchConfound'] is not None:
                    attention_set.add(GSE)
                    print(GSE + "needs help!")
                
    with open('attentionList.txt', 'w') as out_f:
            for GSEid in attention_set:
                out_f.write(GSEid + '\n')

if __name__ == "__main__":
    main()