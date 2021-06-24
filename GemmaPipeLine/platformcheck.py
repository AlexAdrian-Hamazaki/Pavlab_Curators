#"""
# Linear operation of systematically find out which experiemnts require attention for outlier (possible to optimize runtime using multiprocessing module)
#"""
"""
Concurrent.futures pool executor worth considering if the task gets bigger.
Purpose: This script simply takes an input of GSEs from curationList.txt to get a list of platform into platform.txt
"""
import json
from os import error
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

	print('Start scrapping using the Gemma REST_api')
	platforms=[]
	with open(sys.argv[1], "r") as f:
		for line in f:
			while True:
				try:
					GSE=line.strip()
					plat= "https://gemma.msl.ubc.ca/rest/v2/datasets/{}/platforms".format(GSE)
					# Add basic authentication header
					request = urllib2.Request(plat)
					base64string = base64.encodestring('{}:{}'.format(username, password))[:-1]
					request.add_header("Authorization", "Basic {}".format(base64string))
					response = urllib2.urlopen(request)
					text = response.read()
					platform_dict = json.loads(text)
					platforms.append(platform_dict[u'data'][0][u'name'].encode('ascii', 'ignore'))
				except urllib2.HTTPError:
					break
				except error:
					exit("something happend {}".format(error))
				break
					
				
		    
	with open('platform.txt', 'w') as f:
	    for platform in platforms:
        	f.write(platform + "\n")

   

if __name__ == "__main__":
    main()