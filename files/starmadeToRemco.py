#!/usr/bin/env python3
import re

regex = re.compile('(\w+)\s?=\s?(.*?)?\s?(\/\/.*)')
data = ''

try:
  with open('server.cfg', 'r') as fh:
    lines = fh.readlines()
    for line in lines:
        match = regex.search(line)
        if len(match.groups()) < 3 and '//' in match.group(2):
            data += (match.group(1) + " = {{ getv(\"/starmade/" + match.group(1).replace("_", "-").lower() + "\", \"\") }} " + match.group(2) + "\n")
        else:
            data += (match.group(1) + " = {{ getv(\"/starmade/" + match.group(1).replace("_", "-").lower() + "\", \"" + match.group(2) + "\") }} " + match.group(3) + "\n")
        print(data)

  with open('server.cfg.new', 'w') as fh:
    fh.write(data)
except Exception as err:
    raise

