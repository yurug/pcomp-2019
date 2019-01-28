#!/usr/bin/python
import sys


def searchWords():
    for word in sys.argv[1:]:
        with open('mydict','r') as f:
            print (word+':\n')
            l=[]
            for line in f:
                if sorted(line.strip()) == sorted(word.strip()):
                    l.append(line)
            for m in sorted(l): print(m)
searchWords()

