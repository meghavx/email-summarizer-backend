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

summaryDict = {
    "convert_to_spanish" : """- Language of the summary shall be in spanish language."""
    , "corporate_email" : """- The email discussion is in the corporate email. Add points related to corporate such as meeting agenda."""
    , "customer_support": """- The email discussion is in between customer and customer support. """
}

def getSummaryPrompt(summaryOption: str | None) -> str | None:
    if not summaryOption:
        return None
    if summaryOption in summaryDict:
        return summaryDict[summaryOption]
    return None
