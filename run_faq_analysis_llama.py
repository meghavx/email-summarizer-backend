from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, desc
from sqlalchemy.orm import sessionmaker, relationship
import time
import ollama

# Maintaining a global array that mainitains the threadIds that have been processed.
processedThreads = []

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

DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_at)

def update_faq(thread):
    if thread.thread_id in processedThreads:
        return

    faqs = session.query(FAQS).with_entities(FAQS.faq, FAQS.freq).order_by(desc(FAQS.freq)).all()
    faqList = ""
    i = 1
    for faq in faqs:
        faqList += str(i) + '. ' + faq.faq + '\n'
        i += 1

    prompt = f"""
              You are given a list of frequently asked questions and a email thread between customer and customer support. 
             Based on the email discussion decide which frequently asked question can be considered for the email thread and return it's corrosponding number.
            Remeber to only return the number and nothing else! If the email thread cannot be categorised between any of the FAQ. Return a new frequently asked question.
            The new frequently asked question should be short and generalized.

            Here is a list of frequently asked questions:
            {faqList}

            Here is the email discussion:
            """
    
    emails = sortEmails(thread.emails)
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else "Unknown"
        content = email.email_content
        prompt += f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
    
    prompt += "Remember to only return a number or the new question and nothing else!!"
    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}]
    )
    try:
        faqIndex = int(response['message']['content'].strip())
        print ("got index, ", faqIndex, faqs[faqIndex], " for thread topic: ", thread.thread_topic)
        faqRecord = session.query(FAQS).filter_by(faq = faqs[faqIndex].faq).first()
        if faqRecord:
            faqRecord.freq += 1
            session.add(faqRecord)
    except:
        print("Got new faq ",response['message']['content'].strip())
        return 
    session.commit()

def run_faq_analysis():
    threads = session.query(EmailThread).all()  # Fetch all threads
    for thread in threads:
        update_faq(thread)  # Update sentiment for each thread

def job():
    print(f"Running sentiment analysis at {datetime.now()}")
    run_faq_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for a minute between checks
