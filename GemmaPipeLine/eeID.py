import json
import urllib2
import base64
import sys
import ssl


# Without this the urllib2.request would fail
ssl._create_default_https_context = ssl._create_unverified_context

# Change this if you want to simutaneously process more than 50 GSEs
limit = 200

username = sys.argv[2]
# username = 'Wilson'
password = sys.argv[3]
# password = 'chubbyt566'

importFile = sys.argv[1]

GSEs =''
count = 0
#with open(sys.argv[1], 'r') as f:
with open(importFile, 'r') as f:
    for line in f:
        if line == '':
            pass
        else:
            count += 1
            if GSEs == '':
                GSEs = GSEs + line.strip()
            else:
                GSEs = GSEs + '%2c%20' + line.strip()


if count > limit:
    print('Please limit it to 200 experiments or less otherwise we will create too much traffic to the API call!')
    sys.exit()


api_url= 'https://gemma.msl.ubc.ca/rest/v2/datasets/{}?offset=0&limit=50'.format(GSEs)
print ('Start scrapping using the Gemma REST_api')

# Add basic authentication header
request = urllib2.Request(api_url)
base64string = base64.encodestring('{}:{}'.format(username, password))[:-1]
request.add_header("Authorization", "Basic {}".format(base64string)) 

response = urllib2.urlopen(request)
text = response.read()

#Coverts Json in to dict
experiments_dict = json.loads(text)


#Json file structure outer dict data -> Lists of Lists (every list in a GSE) -> attributes are keys (u'id' is an attribute)
with open('eeIDList.txt', 'w') as f:
    for lst in experiments_dict[u'data']:
        shortName = str(lst[u'shortName'])
        eeid = str(lst[u'id'])
        print(shortName + "      " + eeid)
        f.write(eeid + "      " + shortName + "\n")

    