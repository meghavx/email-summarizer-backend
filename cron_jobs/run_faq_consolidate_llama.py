from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, Boolean, String
from sqlalchemy.orm import sessionmaker, relationship
import time
import ollama
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


class StagingFAQS(Base):
    __tablename__ = 'staging_faqs'
    staging_faq_id = Column(Integer, primary_key=True, autoincrement=True)
    thread_id = Column(Integer, ForeignKey(
        'threads.thread_id'), nullable=False)
    faq = Column(Text, nullable=False)
    processed_flag = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())


DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()


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


def get_string_between_braces(text):
    n1 = findFirstOccurance(text, '{')
    n2 = findLastOccurance(text, '}')
    if (not n1 and not n2):
        return None
    return text[n1:(n2+1)]


def update_main_faq(mainFaqs):
    i = 0
    mainFaqString = "[\n"
    for mainFaq in mainFaqs:
        mainFaqString += (mainFaq.faq + "\n") if (i ==
                                                  len(mainFaqs) - 1) else (mainFaq.faq + ", \n")
        i += 1
    mainFaqString += "]"
    print(mainFaqString)
    jsonFormat = "{ \"result\" : [{\"group\": [\"question1\",\"question2\"] }] }"
    prompt = f"""
        From the below list, group the questions which are contextually simialar to each other:
        faqs = {mainFaqString}
        Don't group questions which are not similar to each other. You can add single question in each group if none of them are 
        contextually similar to each other. Group only if they very similar to each other.
        Can you give me the result in a JSON format strucutured as {jsonFormat}
        """

    res = ollama.generate(model='llama3.2', prompt=prompt)
    print("res", res['response'])
    jsonRes = get_string_between_braces(res['response'])
    print("jsonRes", jsonRes)
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    resultList = encodedJson['result']
    for group in resultList:
        faq_group = group['group']
        if not faq_group:
            continue

        main_faq = faq_group[0]  # Use the first FAQ as the main FAQ
        total_count = 0

        faqs = session.query(FAQS).filter(FAQS.faq.in_(faq_group)).all()
        for faq in faqs:
            total_count += faq.freq

        main_faq_record = session.query(FAQS).filter_by(faq=main_faq).first()

        if main_faq_record:
            main_faq_record.freq = total_count

        for faq in faqs:
            if faq.faq != main_faq:
                session.delete(faq)

    session.commit()


def update_faq(stagingFaqs):
    i = 0
    stagingFaqString = "[\n"
    for stagingFaq in stagingFaqs:
        stagingFaqString += (stagingFaq.faq + "\n") if (i ==
                                                        len(stagingFaqs) - 1) else (stagingFaq.faq + ", \n")
        i += 1
    stagingFaqString += "\n]\n"

    jsonFormat = "{ \"result\" : [{\"group\": [\"question1\",\"question2\"] }] }"
    prompt = f"""
        From the below list, group the questions which are contextually simialar to each other:
        faqs = {stagingFaqString}
        Can you give me the result in a JSON format strucutured as {jsonFormat}
        """

    res = ollama.generate(model='llama3.2', prompt=prompt)
    print("res", res['response'])
    jsonRes = get_string_between_braces(res['response'])
    print("jsonRes", jsonRes)
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    resultList = encodedJson['result']
    print(resultList)
    for res in resultList:
        faqRes = FAQS(
            faq=res['group'][0], freq=len(res['group'])
        )
        session.add(faqRes)

    for staging_faq in stagingFaqs:
        staging_faq.processed_flag = True
    session.commit()

def run_faq_consolidation():
    stagingFaqs = session.query(StagingFAQS).filter_by(
        processed_flag=False).limit(20).all()
    mainFaqs = session.query(FAQS).all()
    flag = False
    if (len(mainFaqs) > 0):
        flag = True
    update_faq(stagingFaqs)
    if (flag):
        update_main_faq(mainFaqs)

def job():
    print(f"Running consolidating FAQs at {datetime.now()}")
    run_faq_consolidation()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # S
