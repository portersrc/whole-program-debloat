#!/usr/bin/env python3
import sys
import re

# Usage example:
#   input:  echo 3m34.475s | ./parse_time.py
#   output: 214.475

runtime = 0

for line in sys.stdin:
    line = line.strip()

    m = re.match(r"(.*)(m)(.*)(s)", line)
    if m:
        minutes = int(m.group(1))
        seconds = float(m.group(3))
        runtime = minutes * 60 + seconds
    else:
        print("Unexpected input")
        sys.exit(1)

print('{}'.format(runtime))
