#!/usr/bin/env python3

import requests
import os
import sys

def main():
    try:
        from bs4 import BeautifulSoup
    except ModuleNotFoundError:
            os.system('pip3 install bs4 --user')
            from bs4 import BeautifulSoup
    url = sys.argv[1]

    platform = requests.get(url)
    soup = BeautifulSoup(platform.text, 'html.parser')
    with open('platform.txt', 'w') as f:
        f.write(soup.text.strip())

if __name__ == "__main__":
    main()  