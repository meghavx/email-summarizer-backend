import re
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from langchain.text_splitter import RecursiveCharacterTextSplitter

DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

text_splitter = RecursiveCharacterTextSplitter(
    separators=['\n\n', '\n', '.', ','],
    chunk_size=750,
    chunk_overlap=50)

def get_string_between_braces(text):
    match = re.search(r'\{.*?\}', text)
    if match:
        return match.group()  # Return the matched string
    return None  # Return None if no match is found

def findFirstOccurance(text, ch):
    for i in range(0, len(text)):
        if (text[i] == ch):
            return i
    return None

def findLastOccurance(text, ch):
    lastIdx = -1
    for i in range(0, len(text)):
        if (text[i] == ch):
            lastIdx = i
    if (lastIdx == -1):
        return None
    return lastIdx

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_at)

