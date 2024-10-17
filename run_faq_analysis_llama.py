from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, Boolean, desc
from sqlalchemy.orm import sessionmaker, relationship
import time
import ollama
import re
import json
import spacy

# Maintaining a global array that mainitains the threadIds that have been processed.
processedThreads = []
nlp = spacy.load("en_core_web_sm")

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

class Faq:
    def __init__(self, faq_id, faq, count=1):
        self.faq_id = faq_id
        self.faq = faq
        self.count = count

# Sample FAQ data
stagingFaqs = [Faq(None, "How do I reset my password?"), Faq(None, "Where can I find my purchase history?")]
mainFaqs = [Faq(1, "How do I change my password?", count=5), Faq(2, "How to view order history?", count=3)]

# Unprocessed FAQs
unProcessedStagingFaqs = [stagingFaq.faq for stagingFaq in stagingFaqs]

# Main FAQ list: tuples of (faq_id, faq string, count)
mainFaqList = [(mainFaq.faq_id, mainFaq.faq, mainFaq.count) for mainFaq in mainFaqs]

# Threshold for considering a FAQ as similar (tunable based on your needs)
SIMILARITY_THRESHOLD = 0.85

# Function to find the closest matching FAQ from the mainFaqList
def find_closest_faq(unprocessed_faq, main_faqs, model):
    max_similarity = 0
    closest_faq = None
    unprocessed_doc = model(unprocessed_faq)
    
    for faq_id, faq_text, count in main_faqs:
        main_doc = model(faq_text)
        similarity = unprocessed_doc.similarity(main_doc)
        
        if similarity > max_similarity:
            max_similarity = similarity
            closest_faq = (faq_id, faq_text, count)

    return closest_faq, max_similarity

def update_faq():
    stagingFaqs = session.query(StagingFAQS ).filter_by(processed_flag = False).all()
    mainFaqs = session.query(FAQS).all()
    for unProcessedStagingFaq in unProcessedStagingFaqs:
        closest_faq, similarity = find_closest_faq(unProcessedStagingFaq, mainFaqList, nlp)

        if closest_faq and similarity >= SIMILARITY_THRESHOLD:
            # If a similar FAQ is found, increment the count
            print(f"FAQ '{unProcessedStagingFaq}' is similar to '{closest_faq[1]}' (similarity: {similarity:.2f}). Incrementing count.")
            for faq in mainFaqs:
                if faq.faq_id == closest_faq[0]:
                    faq.count += 1
        else:
            # If no similar FAQ is found, add it to the main FAQ list with count 1
            new_faq_id = len(mainFaqs) + 1  # Generate a new FAQ ID
            new_faq = Faq(new_faq_id, unProcessedStagingFaq)
            mainFaqs.append(new_faq)
            mainFaqList.append((new_faq_id, unProcessedStagingFaq, new_faq.count))
            print(f"FAQ '{unProcessedStagingFaq}' is new. Adding it to the list with count 1.")

    # Print final FAQ list with counts
    print("\nUpdated FAQ List:")
    for faq in mainFaqs:
        print(f"FAQ ID: {faq.faq_id}, Text: '{faq.faq}', Count: {faq.count}")


def get_string_between_braces(text):
    match = re.search(r'\{.*?\}', text)
    if match:
        return match.group()  # Return the matched string
    return None  # Return None if no match is found

def update_staging_faq(thread):
    if thread.thread_id in processedThreads:
        return

    discussion_thread = getDiscussionThread(thread)
    jsonFormat = "{ faq : \"generated_faq\" }"
    prompt = f"""
        You are given a email discussion thread between a customer and customer support. You need to understand
        the intent of the email discussion and give me a very generic Frequently Asked question that can be considered for the email discussion.
        Email discussion:
            {discussion_thread}
        Return the result in a JSON format like this {jsonFormat} and nothing else.
    """
    res = ollama.generate(model = 'llama3.2', prompt = prompt + discussion_thread)
    jsonRes = get_string_between_braces(res['response'])
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    stageFaq = StagingFAQS(
                thread_id = thread.thread_id
              , faq = encodedJson['faq']
            )
    print (res['response'])
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
