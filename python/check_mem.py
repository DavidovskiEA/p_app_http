#!/usr/bin/python3

import os

domain = input('Input domain:')
path = 'domains/' + domain # real path
print(path)
os.chdir(path)
os.system('pwd')
os.system('du -sh *')