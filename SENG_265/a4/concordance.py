import sys
import re

PATTERN = r'''^((\w|\-)+$'''

class KWOC:

    def __init__(self, filename, exceptions):
        self.filename = filename
        self.exception_file = exceptions

    def concordance(self):
        return []
