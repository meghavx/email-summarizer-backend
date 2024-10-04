import schedule
import time
import psycopg2
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, Enum, ForeignKey, func
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
import random
from nltk.sentiment.vader import SentimentIntensityAnalyzer


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


# Initialize VADER sentiment intensity analyzer
sid = SentimentIntensityAnalyzer()

def analyze_sentiment_and_priority(text):
    # Analyze sentiment
    sentiment_scores = sid.polarity_scores(text)
    compound = sentiment_scores['compound']
    
    # Determine sentiment based on compound score
    if compound >= 0.05:
        sentiment = "positive"
    elif compound <= -0.8:
        sentiment = "critical negative"  # Very negative sentiment
    elif compound <= -0.05:
        sentiment = "negative"
    else:
        sentiment = "neutral"
    
    # Assign priority based on sentiment
    if sentiment == 'critical negative':
        priority = "Critical"
    elif sentiment == 'negative':
        priority = "Needs attention"
    elif sentiment == 'positive':
        priority = "Positive"
    else:
        priority = "Neutral"
    
    return priority

def update_sentiment(thread):
    if not thread:
        return

    current_time = datetime.now()

    # Check if a sentiment record exists
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



    sentiment_category = analyze_sentiment_and_priority(prompt)

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