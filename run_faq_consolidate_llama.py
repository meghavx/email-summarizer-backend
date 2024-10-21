from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, Boolean
from sqlalchemy.orm import sessionmaker, relationship
import time
import ollama
import re
import json

Base = declarative_base()
class EmailThread(Base):
    __tablename__ = 'threads'
    thread_id = Column(Integer, primary_key=True)
    thread_topic = Column(String(100), nullable=False)
    emails = relationship("Email", back_populates="email_thread")

class Email(Base):
    __tablename__ = 'emails'
    email_record_id = Column(Integer, primary_key=True)
    sender_email = Column(String(50), nullable=False)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    email_content = Column(Text, nullable=True)
    email_received_at = Column(TIMESTAMP, nullable=True)
    email_thread = relationship("EmailThread", back_populates="emails")

class FAQS(Base):
    __tablename__ = 'faqs'
    faq_id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(Integer, ForeignKey('query_categories.category_id'), nullable=False)
    faq = Column(Text, nullable=False)
    freq = Column(Integer, nullable=False, default=0)
    created_at = Column(TIMESTAMP , default = func.now())
    updated_at = Column(TIMESTAMP , default = func.now(), onupdate=func.now())
    __table_args__ = (
        CheckConstraint('freq >= 0', name='chk_positive'),
    )

class Category(Base):
    __tablename__ = 'query_categories'
    category_id = Column(Integer, primary_key=True)
    category_name = Column(String(100), nullable=False)
    sop_doc_id = Column(Integer, ForeignKey('sop_document.doc_id'), nullable=False)
    created_at = Column(TIMESTAMP , default = func.now())
    updated_at = Column(TIMESTAMP , default = func.now(), onupdate=func.now())

class StagingFAQS(Base):
    __tablename__ = 'staging_faqs'
    staging_faq_id = Column(Integer, primary_key=True, autoincrement=True)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    faq = Column(Text, nullable=False)
    processed_flag = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())

DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

def findFirstOccurance(text,ch):
    for i in range(0,len(text)-1):
        if(text[i] == ch):
            return i
    return None

def findLastOccurance(text,ch):
    lastIdx = -1
    for i in range(0, len(text) - 1):
        if(text[i] == ch):
            lastIdx = i
    if (lastIdx == -1):
        return None
    return lastIdx

def get_string_between_braces(text):
    n1 = findFirstOccurance(text,'{')
    n2 = findLastOccurance(text,'}')
    if (not n1 and not n2):
        return None
    return text[n1:(n2+1)]
    
def update_faq(stagingFaqs):
    print ("reached here")
    stagingFaqString = "[\n"
    
    i = 0
    for stagingFaq in stagingFaqs:
        stagingFaqString += (stagingFaq.faq + "\n") if (i == len(stagingFaqs) - 1) else (stagingFaq.faq + ".\n")

    stagingFaqString += "\n]\n"

    jsonFormat = "{ \"result\" : [{\"group\": [\"question1\",\"question2\"] }] }"
    prompt = f"""
        From the below list, group the questions which are contextually simialar to each other:
        faqs = {stagingFaqString}
        Can you give me the result in a JSON format strucutured as {jsonFormat}
        """
    res = ollama.generate(model = 'llama3.2', prompt = prompt )
    print("res",res['response'])
    jsonRes = get_string_between_braces(res['response'])
    print ("jsonRes",jsonRes)
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    resultList = encodedJson['result']
    for res in resultList:
        faqRes = FAQS(
                category_id = 1 # default value
              , faq = res['group'][0]
              , freq = len(res['group'])
            )
        print (res['group'])
        session.add(faqRes)
    
    for staging_faq in stagingFaqs:
        staging_faq.processed_flag = True
    session.commit()  

    
def run_faq_consolidation():
    stagingFaqs = session.query(StagingFAQS).filter_by(processed_flag = False).limit(20).all()
    update_faq(stagingFaqs)  

def job():
    print(f"Running consolidating FAQs at {datetime.now()}")
    run_faq_consolidation()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # S
