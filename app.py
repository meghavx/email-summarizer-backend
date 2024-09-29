
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import random
from sqlalchemy import Enum
import requests
import ollama
from flask import Response, stream_with_context

# Initialize Flask app
app = Flask(__name__)

# Configure the PostgreSQL database
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://ruchita:qwerty@localhost/poc'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the database
db = SQLAlchemy(app)
CORS(app)
# Models
# These represent the tables identical in database


# to_dict Method is useful for serializing the object to JSON when sending responses through API endpoints.

class EmailThread(db.Model):
    __tablename__ = 'threads'
    thread_id = db.Column(db.Integer, primary_key=True)
    thread_topic = db.Column(db.String(50), nullable=False)

    def to_dict(self):
        return {
            'thread_id': self.thread_id,
            'thread_topic': self.thread_topic
        }

class Email(db.Model):
    __tablename__ = 'emails'
    email_record_id = db.Column(db.Integer, primary_key=True)
    sender_email = db.Column(db.String(50), nullable=False)
    sender_name = db.Column(db.String(100),nullable=False)
    receiver_email = db.Column(db.String(100), nullable=False)
    receiver_name = db.Column(db.String(100),nullable=False)
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False)
    email_received_at = db.Column(db.TIMESTAMP, nullable=True)
    email_subject = db.Column(db.String(50), nullable=False)
    email_content = db.Column(db.Text, nullable=True)

    # Relationship to EmailThread
    email_thread = db.relationship('EmailThread', backref=db.backref('emails', lazy=True))

    def to_dict(self):
        return {
            'email_record_id': self.email_record_id,
            'sender_email': self.sender_email,
            'thread_id': self.thread_id,
            'email_received_at': self.email_received_at.strftime('%B %d, %Y %I:%M %p') if self.email_received_at else None,
            'email_subject': self.email_subject,
            'email_content': self.email_content
        }

# Summaries model
class Summary(db.Model):
    __tablename__ = 'summaries'
    summary_id = db.Column(db.Integer, primary_key=True)  # SERIAL equivalent
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False)  # Foreign key to threads
    summary_content = db.Column(db.Text, nullable=False)
    summary_created_at = db.Column(db.TIMESTAMP, default=db.func.now())  # Default to current timestamp
    summary_modified_at = db.Column(db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())  # Auto-update on modification

    # Relationship to Thread
    thread = db.relationship('EmailThread', backref=db.backref('summaries', lazy=True))

    def to_dict(self):
        return {
            'summary_id': self.summary_id,
            'thread_id': self.thread_id,
            'summary_content': self.summary_content,
            'summary_created_at': self.summary_created_at.strftime('%B %d, %Y %I:%M %p'),
            'summary_modified_at': self.summary_modified_at.strftime('%B %d, %Y %I:%M %p')
        }

 # 4. SBP-3 [ 26th Sept 2024 ]

# Modified as per UI requirements
class SentimentEnum(db.Enum):
    CRITICAL = 'Critical'
    NEEDS_ATTENTION = 'Needs attention'
    NEUTRAL = 'Neutral'
    POSITIVE = 'Positive'

# EmailThreadSentiment model
class EmailThreadSentiment(db.Model):
    __tablename__ = 'email_thread_sentiment'
    sentiment_id = db.Column(db.Integer, primary_key = True)    # Primary key to email_thread_sentiment
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False, primary_key=True)  # Foreign key to threads
    sentiments = db.Column(Enum('Critical', 'Needs attention', 'Neutral', 'Positive', name='sentiment'), nullable=False)
    timestamp = db.Column(db.TIMESTAMP, default=db.func.now()) 
    # Relationship to Thread
    thread = db.relationship('EmailThread', backref=db.backref('sentiments', lazy=True))

    @classmethod
    def save_sentiment(cls, thread_id, sentiment_category):
        # Check if sentiment already exists for this thread
        existing_record = cls.query.filter_by(thread_id=thread_id).first()

        if existing_record:
            existing_record.sentiments = sentiment_category   # Update sentiment
            existing_record.timestamp = db.func.now() # Update timestamp
        else:
            # Create a new sentiment record
            new_sentiment = cls(
                thread_id=thread_id,
                sentiments=sentiment_category,
                timestamp=db.func.now()
            )
            db.session.add(new_sentiment)
        
        db.session.commit()

    def to_dict(self):
        return {
            'thread_id': self.thread_id,
            'sentiments': self.sentiments,
            'timestamp': self.timestamp.strftime('%B %d, %Y %I:%M %p')
        }

# Routes

@app.route('/')
def hello():
    return "Hello, Ruchita!"

# 1. GET all emails
@app.route('/all_emails', methods=['GET'])
def get_all_emails():
    emails = Email.query.all()
    emails_list = [email.to_dict() for email in emails]
    return jsonify(emails_list)

# 2. GET all email threads with their associated emails
@app.route('/all_email_threads', methods=['GET'])
def get_all_threads():
    threads = EmailThread.query.order_by('thread_id').all()
    thread_list = []
    sentiments = ['neutral','positive','needs_attention','critical'] # temp
    for thread in threads:
        try:
            sentiment_response = requests.post(f'http://localhost:5000/generate_sentiment/{thread.thread_id}')
            sentiment_data = sentiment_response.json()
            sentiment = sentiment_data.get('overall_sentiment', 'neutral')  # Default to 'neutral' if missing
        except Exception as e:
            print(f"Error in fetching sentiment for thread {thread.thread_id}: {e}")
            sentiment = 'neutral'  # Fallback sentiment if the request fails
        sorted_emails = sorted(
            thread.emails, 
            key=lambda email: email.email_received_at or db.func.now(), 
            reverse=True
        )
        """
        Sentiment analysis should be fetched here
        """
        emails = [{
            'seq_no': i,
            'sender': email.sender_email.split('@')[0],  # Extracting name from email
            'senderEmail': email.sender_email,
            'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
            'content': email.email_content,
            'isOpen': False  # Assuming 'isOpen' is false for simplicity
        } for i,email in  enumerate(sorted_emails)]
        
        thread_list.append({
            'threadId' : thread.thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails,
            'sentiment': sentiment # sentiments[random.randint(0,len(sentiments)-1)] # Here sentiments which would be generated shall be fetched.
        })

    return jsonify(thread_list)

# 3. GET specific email thread by thread_id with its emails
@app.route('/all_email_by_thread_id/<int:thread_id>', methods=['GET'])
def get_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)

    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    emails = [{
        'sender': email.sender_email.split('@')[0],  # Extracting name from email
        'senderEmail': email.sender_email,
        'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
        'content': email.email_content,
        'isOpen': False  # Assuming 'isOpen' is false for simplicity
    } for email in thread.emails]

    thread_data = {
        'threadTitle': thread.thread_topic,
        'emails': emails
    }

    return jsonify(thread_data)

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_at)

@app.post('/summarize/<int:thread_id>')
def summarize_thread_by_id(thread_id):

    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404
    
    emails = [{
        'senderEmail': email.sender_email,
        'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
        'content': email.email_content,
    } for email in thread.emails]
  
    prompt = f"""Please quickly summarize the following email thread titled '{thread.thread_topic}' in 2-3 points. 
                Include the main points, important decisions, and highlight any significant dates. Here is the list of emails in the thread:\n\n"""

    # Iterate through the emails and format them into a readable string
    for email in emails:
        sender = email['senderEmail']
        date = email['date']
        content = email['content']
    
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    # Ollama code
    stream = ollama.chat(
    model='llama3.1',
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,)

     # Generator to stream the chunks as they arrive
    def generate_summary():
        first_chunk = True
        for chunk in stream:
            # Ensure proper JSON formatting for streaming chunks
            if not first_chunk:
                yield ' '
            yield chunk['message']['content']
            first_chunk = False

    # Return a streaming response using Flask's Response object
    return Response(stream_with_context(generate_summary()), content_type='application/json')

@app.route('/create/email', methods=['POST'])
def create_email():
    data = request.json  # Parse the incoming JSON data

    # Validate the necessary fields
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    # Create new EmailThread and Email instances
    new_thread = EmailThread(thread_topic = data['subject'])
    db.session.add(new_thread)
    db.session.flush()  # This will generate an ID for the new thread before committing

    new_email = Email(
        sender_email= data['senderEmail'],
        thread_id= new_thread.thread_id,
        email_subject= data['subject'],
        email_content= data['content'],
        sender_name = data['senderEmail'].split('@')[0],
        receiver_email = 'alex@abc.com',
        receiver_name = 'alex',
        email_received_at=db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email and thread created successfully', 'thread_id': new_thread.thread_id, 'email_record_id': new_email.email_record_id}), 201

@app.route('/create/email/<int:thread_id>', methods=['POST'])
def add_email_to_thread(thread_id):
    data = request.json  # Parse the incoming JSON data
    
    # Validate the necessary fields
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    # Check if the thread exists
    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    # Create a new Email instance
    new_email = Email(
        sender_email= data['senderEmail'],
        thread_id= thread_id,
        email_subject= data['subject'],
        email_content= data['content'],
        sender_name = data['senderEmail'].split('@')[0],
        receiver_email = 'alex@abc.com',
        receiver_name = 'alex',
        email_received_at=db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email added to thread', 'email_record_id': new_email.email_record_id}), 201

@app.route('/generate_sentiment/<int:email_thread_id>', methods=['POST'])
def generate_sentiment(email_thread_id):
    # Fetch the email thread based on email_thread_id
    email_thread = EmailThread.query.get(email_thread_id)
    if not email_thread:
        return jsonify({'error': 'Email thread not found'}), 404
    
    # Fetch all emails related to the thread
    emails = email_thread.emails
    
    if not emails:
        return jsonify({'error': 'No emails found in this thread.'}), 404
    """
    AI team's function will come here, we are expecting a integer between 1 to 10.
    """
    polarity = random.randint(1,10)
    # Determine overall sentiment category based on polarity
    if polarity > 6:
        sentiment_category = "Positive"
    elif 3 < polarity <= 6:
        sentiment_category = "Needs attention"
    elif polarity == 3:
        sentiment_category = "Neutral"
    else:
        sentiment_category = "Critical"

    # Saving to DB with table name : email_thread_sentiment
    try:
        EmailThreadSentiment.save_sentiment(email_thread_id, sentiment_category)
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

    # Response body for UI
    sentiment_response = ""
    if (sentiment_category == 'Positive'):
        sentiment_response = 'positive'
    elif (sentiment_category == 'Critical'):
        sentiment_response = 'critical'
    elif (sentiment_category == 'Needs attention'):
        sentiment_response = 'needs_attention'
    elif (sentiment_category == 'Neutral'):
        sentiment_response = 'neutral'
    else: # Something went wrong here
        print ("Something went wrong with sentiment_response: ",sentiment_category,)
        sentiment_response = 'neutral'

    response = { 'overall_sentiment': sentiment_response }
    return jsonify(response), 200

# Run the application
if __name__ == '__main__':
    app.run(debug=True)