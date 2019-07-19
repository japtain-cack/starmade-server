#!/usr/bin/env python3
import re

regex = re.compile('(\w+)\s=\s(.*?)\s(\/\/.*)')
data = ''

try:
  with open('server.cfg', 'r') as fh:
    lines = fh.readlines()
    for line in lines:
        match = regex.search(line)
        data += (match.group(1) + " = {{ getenv(\"" + match.group(1) + "\", \"" + match.group(2) + "\") }} " + match.group(3) + "\n")

  with open('server.cfg.new', 'w') as fh:
    fh.write(data)
except Exception as err:
  print(str(err))

