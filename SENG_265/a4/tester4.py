#!/usr/bin/env python3

#
# UVic SENG 265, Spring 2020, Assignment #4
#
# This test-driver program invokes methods on the class to be
# completed for the assignment.
# 

import sys
import argparse
from concordance import KWOC


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', type=str, help='exception-word file')
    parser.add_argument('infile', type=str, help='input text file')

    args = parser.parse_args()

    if not args.infile:
        print("Need an infile...")
        sys.exit(1)

    kwoc = KWOC(args.infile, args.e)
    result = kwoc.concordance()
    if result != []:
        print("\n".join(result))


if __name__ == "__main__":
    main()
