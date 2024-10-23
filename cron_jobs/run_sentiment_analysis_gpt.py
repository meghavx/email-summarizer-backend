import schedule
import time
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, Enum, ForeignKey, func
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
import os

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

class EmailThreadSentiment(Base):
    __tablename__ = 'email_thread_sentiment'
    sentiment_id = Column(Integer, primary_key=True)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    sentiments = Column(Enum('Critical', 'Needs attention', 'Neutral', 'Positive', name='sentiment'), nullable=False)
    timestamp = Column(TIMESTAMP, default=func.now())
    thread = relationship("EmailThread", backref="sentiments")

DATABASE_URI = 'postgresql://ruchita:qwerty@localhost/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

def get_sentiment_score(text):
    messages = [
    (
        "system",
        f"""
        I will provide an email discussion thread between a customer and a customer support team for a supply chain company. 
        Based on the conversation, categorize the sentiment and urgency of the email using the following categories:
    1. **Critical (Negative Urgency)**: 
        Emails that express high urgency, negative sentiment, or frustration. These emails require immediate action or resolution. 
    2. **Needs Attention (Negative or Neutral)**: 
        Emails with moderate urgency or concern, which may include complaints, requests for clarification, or unresolved issues. 
        They may require follow-up but are not as pressing as critical emails.
    3. **Neutral (No Immediate Action)**: 
        Emails that are purely informational, with no immediate request or concern. These may provide updates, confirmations, or general communication.
    4. **Positive (No Action Needed)**: Emails expressing satisfaction, appreciation, or positive feedback. 
            No action or response is required unless it's to acknowledge the positive sentiment.
    Based on this, categorize each email in the thread and briefly explain why it fits into the chosen category.
     Give me a number between 1 to 10 (> 8 means critical, >6 means needs attention, > 3 means neutral and else positive) \n
     remember to only return the number and nothing else:\n\n
    """,
    ),
    ("human", "Discussion: " + text),
    ]
    ai_msg = llm.invoke(messages)
    return (ai_msg.content)


def analyze_sentiment(text):
    # Analyze sentiment
    res = get_sentiment_score(text)
    try:
        sentiment_score = int(res.strip())
    except ValueError:
        print("Error parsing sentiment score.", res)
        return 
    
    if sentiment_score >= 8:
        sentiment = "Critical"
    elif sentiment_score > 6:
        sentiment = "Needs attention"  # Very negative sentiment
    elif sentiment_score > 3:
        sentiment = "Neutral"
    else:
        sentiment = "Positive"
    return sentiment

def update_sentiment(thread):
    if not thread:
        return
    current_time = datetime.now()
    sentiment_record = session.query(EmailThreadSentiment).filter_by(thread_id=thread.thread_id).first()
    if sentiment_record:
        time_difference = current_time - sentiment_record.timestamp
        if time_difference < timedelta(hours=5):
            return  # Sentiment is recent, no need to update
    emails = [{
        'senderEmail': email.sender_email,
        'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
        'content': email.email_content,
    } for email in thread.emails]

    prompt = ""
    for email in emails:
        sender = email['senderEmail']
        date = email['date']
        content = email['content']
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    sentiment_category = analyze_sentiment(prompt)
    if (not sentiment_category):
        return
    if sentiment_record:
        sentiment_record.sentiments = sentiment_category
        sentiment_record.timestamp = current_time
    else:
        sentiment_record = EmailThreadSentiment(
            thread_id=thread.thread_id,
            sentiments=sentiment_category,
            timestamp=current_time
        )
        session.add(sentiment_record)

    session.commit()
    print(f"Updated sentiment for thread {thread.thread_id} to {sentiment_category}")

def run_sentiment_analysis():
    threads = session.query(EmailThread).all()  # Fetch all threads
    for thread in threads:
        update_sentiment(thread)  # Update sentiment for each thread

def job():
    print(f"Running sentiment analysis at {datetime.now()}")
    run_sentiment_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for a minute between checks
