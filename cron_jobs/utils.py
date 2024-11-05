import re
from typing import Optional
from langchain.text_splitter import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(
    separators=['\n\n', '\n', '.', ','],
    chunk_size=750,
    chunk_overlap=50)

def get_str_between_braces(text: str) -> Optional[str]:
    match = re.search(r'\{.*?\}', text)
    if match:
        return match.group() # Return the matched string
    return None  # Return None if no match is found

def get_string_between_braces(text: str) -> Optional[str]:
    n1 = findFirstOccurrence(text,'{')
    n2 = findLastOccurrence(text,'}')
    if (not n1 and not n2):
        return None
    return text[n1:(n2+1)]

def findFirstOccurrence(text: str, ch: str) -> int | None:
    for i in range(0,len(text)):
        if(text[i] == ch):
            return i
    return None

def findLastOccurrence(text: str, ch: str) -> int | None:
    lastIdx = -1
    for i in range(0, len(text)):
        if(text[i] == ch):
            lastIdx = i
    if (lastIdx == -1):
        return None
    return lastIdx