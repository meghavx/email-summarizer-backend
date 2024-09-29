import schedule
import time
import psycopg2
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, Enum, ForeignKey, func
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
import ollama

# SQLAlchemy Base
Base = declarative_base()

# Database Models
class EmailThread(Base):
    __tablename__ = 'threads'
    thread_id = Column(Integer, primary_key=True)
    thread_topic = Column(String(50), nullable=False)
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

# Database connection setup
DATABASE_URI = 'postgresql://ruchita:qwerty@localhost/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

def update_sentiment(thread):
    current_time = datetime.now()

    # Check if a sentiment record exists
    sentiment_record = session.query(EmailThreadSentiment).filter_by(thread_id=thread.thread_id).first()

    if sentiment_record:
        time_difference = current_time - sentiment_record.timestamp
        if time_difference < timedelta(hours=5):
            return  # Sentiment is recent, no need to update

    # Generate sentiment prompt based on emails in the thread
    emails = thread.emails
    prompt = f"""
        Give me a number between 1 to 10 (> 8 means critical, >6 means needs attention, > 3 means neutral and else positive) \n
        by Evaluating the sentiment for the email thread titled '{thread.thread_topic}':\n\n, 
        remember to only return the number and nothing else:\n\n"""
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else "Unknown"
        content = email.email_content
        prompt += f"From: {sender}\nDate: {date}\nContent: {content}\n\n"

    # Fetch sentiment from Ollama
    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}]
    )
    print(f"sentiment for {thread.thread_id}",response['message']['content'].strip())
    try:
        sentiment_score = int(response['message']['content'].strip())
    except ValueError:
        print("Error parsing sentiment score.")
        return

    # Map sentiment score to categories
    if sentiment_score > 8:
        sentiment_category = 'Positive'
    elif sentiment_score > 6:
        sentiment_category = 'Needs attention'
    elif sentiment_score > 3:
        sentiment_category = 'Neutral'
    else:
        sentiment_category = 'Critical'

    # Save or update sentiment in the database
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
    # Schedule the job to run every 5 hours
    schedule.every(5).hours.do(job)

    # Initial run before scheduling the recurring task
    job()

    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for a minute between checks