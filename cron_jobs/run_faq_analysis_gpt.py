from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, Boolean
from sqlalchemy.orm import sessionmaker, relationship
import time
import re
import json
import os
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain.text_splitter import RecursiveCharacterTextSplitter

load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

text_splitter = RecursiveCharacterTextSplitter(
    separators=['\n\n', '\n', '.', ','],
    chunk_size=750,
    chunk_overlap=50
)
llm = ChatOpenAI(model="gpt-4", temperature=0.5, max_tokens=1000)

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

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_at)

def getDiscussionThread(thread):
    sorted_emails = sortEmails(thread.emails)
    discussion_thread = ""
    for email in sorted_emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        discussion_thread += email_entry
    return discussion_thread

def get_string_between_braces(text):
    match = re.search(r'\{.*?\}', text)
    if match:
        return match.group()  # Return the matched string
    return None  # Return None if no match is found

def update_staging_faq(thread):
    discussion_thread = getDiscussionThread(thread)
    jsonFormat = "{ faq : \"generated_faq\" }"
    prompt = f"""
        You are given a email discussion thread between a customer and customer support. You need to understand
        the intent of the email discussion and give me a very generic Frequently Asked question that can be considered for the email discussion.
        Email discussion:
            {discussion_thread}
        Return the result in a JSON format like this {jsonFormat} and nothing else.
    """
    messages = [("human", prompt),]
    ai_msg = llm.invoke(messages)
    res = ai_msg.content
    jsonRes = get_string_between_braces(res)
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    stageFaq = StagingFAQS(
                thread_id = thread.thread_id
              , faq = encodedJson['faq']
            )
    print (res)
    session.add(stageFaq)
    session.commit()  
    
def run_faq_analysis():
    threads = session.query(EmailThread).all()  # Fetch all threads
    for thread in threads:
        update_staging_faq(thread)  # Update sentiment for each thread

def job():
    print(f"Running sentiment analysis at {datetime.now()}")
    run_faq_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for a minute between checks
