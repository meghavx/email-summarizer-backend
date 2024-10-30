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
    thread_id = Column(Integer, ForeignKey(
        'threads.thread_id'), nullable=False)
    email_content = Column(Text, nullable=True)
    email_received_at = Column(TIMESTAMP, nullable=True)
    email_thread = relationship("EmailThread", back_populates="emails")


class FAQS(Base):
    __tablename__ = 'faqs'
    faq_id = Column(Integer, primary_key=True, autoincrement=True)
    faq = Column(Text, nullable=False)
    freq = Column(Integer, nullable=False, default=0)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())
    __table_args__ = (
        CheckConstraint('freq >= 0', name='chk_positive'),
    )


class Category(Base):
    __tablename__ = 'query_categories'
    category_id = Column(Integer, primary_key=True)
    category_name = Column(String(100), nullable=False)
    sop_doc_id = Column(Integer, ForeignKey(
        'sop_document.doc_id'), nullable=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())


class StagingFAQS(Base):
    __tablename__ = 'staging_faqs'
    staging_faq_id = Column(Integer, primary_key=True, autoincrement=True)
    thread_id = Column(Integer, ForeignKey(
        'threads.thread_id'), nullable=False)
    faq = Column(Text, nullable=False)
    coverage_percentage = Column(Integer)
    coverage_description = Column(Text)
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
        date = email.email_received_at.strftime(
            '%B %d, %Y %I:%M %p') if email.email_received_at else None
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
    json_format = """
        {\"sop_based_email_response\": \"<email response>\" ,
         \"sop_coverage_percentage\": \"<percentage>%\", 
         \"description_for_coverage_percentage\": \"<description>\" , 
        \"FAQ_based_on_email\":\"<A_generalized_FAQ_question_theat_summarizes_email_discussion>\"
         }
        """
    prompt = f"""
      You are a helpful assistant that generates responses based on company SOP guidelines. For the given email discussion:
    - generate a formal and professional response to this email, addressing each point appropriately.
    - Refer yourself as ABC support at the end of the mail.
    - Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    - including step-by-step guidelines, documentation, and any relevant timelines. Don't include the subject line in mail.
    - Do not mention subject in the response!
    - Also generate a percentage for how sufficient is the SOP document to generate an answer. Where 0% = topic not covered at all, 100% = topic is fully covered. 
    - Your output should be a JSON object that matches the following schema:
        {json_format}
    - Make sure it is a valid JSON object.
    - Use \n instead of whitespace or newline.
    - Never return anything other than a JSON object.

    Below are the emails asking about a specific process related to the company SOP.
    Email exchanges: 
    {discussion_thread}

    """
    res = ollama.generate(model='llama3.2', prompt=prompt)
    print(res['response'])
    jsonRes = get_string_between_braces(res['response'])
    if (not jsonRes):
        return
    try:
        encodedJson = json.loads(jsonRes)
    except Exception as e:
        print("failed while decoding: ", e)
        return
    if not all(k in encodedJson for k in ("sop_coverage_percentage", "FAQ_based_on_email", "description_for_coverage_percentage")):
        return
    percentage = int(
        encodedJson['sop_coverage_percentage'].replace('%', '').strip())
    stageFaq = StagingFAQS(
        thread_id=thread.thread_id, faq=encodedJson['FAQ_based_on_email'], coverage_percentage=percentage, coverage_description=encodedJson['description_for_coverage_percentage']
    )
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
