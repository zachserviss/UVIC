#! /usr/bin/env python3

"""
Concordance program to read in two files.

Author: Zach Serviss
        V00950002

Mar 3rd 2020
"""

import sys
import os
import argparse

def main():
    argList = getArgs()
    if argList is None:
        return
    include = argList[0]
    exclude = argList[1]
    #exit program if there is no data in inculde file
    if getFileSize(include) == 0 or getFileSize(include) == None:
        return
    if include is not None:
        includeWordList = setIncludeToList(include)
    if exclude is not None:
        excludeWordList = setFileAsWords(exclude)
    else:
        excludeWordList = None
    uniqueWords = setUniqueWords(includeWordList,excludeWordList)
    longestNum = getLongestUniqueWord(uniqueWords)
    lines = setFileAsLines(include)
    printConcordance(uniqueWords,lines,longestNum)
    return

def getArgs():
    try:
        #using argparse to see which file is flagged as exclusion
        parser = argparse.ArgumentParser()
        parser.add_argument('-e','--exclude', nargs=1)
        parser.add_argument('include')
        args = parser.parse_args()
        if args.exclude:
            argList = [args.include,''.join(args.exclude)]
        else:
            argList = [args.include,None]
        return argList
    except:
        print("Please enter at least one file")

def getFileSize(file):
    try:
        return os.stat(file).st_size
    except:
        print("oh no, couldn't read the file")

def setFileAsWords(file):
    try:
        with open(file) as f:
            wordList = [word for line in f for word in line.split()]
    except:
        print("oh no, something went wrong reading the file")
    finally:
        f.close()
        return wordList

def setIncludeToList(file):
    includeWordList = setFileAsWords(file)
    includeWordList = [item.lower() for item in includeWordList]
    includeWordList.sort()
    includeWordList = list(dict.fromkeys(includeWordList))
    return includeWordList

def setUniqueWords(includeWordList,excludeWordList):
    if excludeWordList is not None:
        uniqueWords = list(set(includeWordList)-set(excludeWordList))
    else:
        uniqueWords = includeWordList
    uniqueWords.sort()
    return uniqueWords

def getLongestUniqueWord(uniqueWords):
    return len(max(uniqueWords, key = lambda x: len(x)))

def setFileAsLines(file):
    try:
        with open(file,'r') as f:
            lines = f.read().split("\n")
    except:
        print("oh no, something went wrong reading the file")
    finally:
        f.close()
        return lines
#function to print concordance in correct format
def printConcordance(uniqueWords,lines,longestNum):
    for word in uniqueWords:
        for num,line in enumerate(lines):
            lineWords = line.lower().split()
            if word in lineWords:
                count = lineWords.count(word)
                if count > 1:
                    print("{}  {} ({}*)".format(word.upper().ljust(longestNum,' '),line, num+1))
                else:
                    print("{}  {} ({})".format(word.upper().ljust(longestNum,' '),line, num+1))

if __name__ == "__main__":
    main()
