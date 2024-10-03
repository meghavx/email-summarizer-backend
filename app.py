from datetime import datetime,timezone 
from flask import Flask, Response, jsonify, request, stream_with_context
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import Enum
import ollama
from flask import Response, stream_with_context
import PyPDF2
from PyPDF2 import PdfReader
import io
from threading import Thread

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://ruchita:qwerty@localhost/poc'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
CORS(app)

class EmailThread(db.Model):
    __tablename__ = 'threads'
    thread_id = db.Column(db.Integer, primary_key=True)
    thread_topic = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())  # Default to current timestamp
    updated_at = db.Column(db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())  # Auto-update on modification

    def to_dict(self):
        return {
            'thread_id': self.thread_id,
            'thread_topic': self.thread_topic
        }

class Email(db.Model):
    __tablename__   = 'emails'
    email_record_id = db.Column(db.Integer, primary_key=True)
    sender_email = db.Column(db.String(50), nullable=False)
    sender_name = db.Column(db.String(100),nullable=False)
    receiver_email = db.Column(db.String(100), nullable=False)
    receiver_name = db.Column(db.String(100),nullable=False)
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False)
    email_received_at = db.Column(db.TIMESTAMP, nullable=True)
    email_subject = db.Column(db.String(50), nullable=False)
    email_content = db.Column(db.Text, nullable=True)

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

class Summary(db.Model):
    __tablename__ = 'summaries'
    summary_id = db.Column(db.Integer, primary_key=True)  # SERIAL equivalent
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False)  # Foreign key to threads
    summary_content = db.Column(db.Text, nullable=False)
    summary_created_at = db.Column(db.TIMESTAMP, default=db.func.now())  # Default to current timestamp
    summary_modified_at = db.Column(db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())  # Auto-update on modification
    thread = db.relationship('EmailThread', backref=db.backref('summaries', lazy=True))

    def to_dict(self):
        return {
            'summary_id': self.summary_id,
            'thread_id': self.thread_id,
            'summary_content': self.summary_content,
            'summary_created_at': self.summary_created_at.strftime('%B %d, %Y %I:%M %p'),
            'summary_modified_at': self.summary_modified_at.strftime('%B %d, %Y %I:%M %p')
        }

class SentimentEnum(db.Enum):
    CRITICAL = 'Critical'
    NEEDS_ATTENTION = 'Needs attention'
    NEUTRAL = 'Neutral'
    POSITIVE = 'Positive'

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

# SOP Document model
class SOPDocument(db.Model):
    __tablename__ = 'sop_document'
    doc_id = db.Column(db.Integer, primary_key=True)
    doc_content = db.Column(db.LargeBinary, nullable=False)
    doc_timestamp = db.Column(db.TIMESTAMP, default=db.func.now()) 

    def to_dict(self):
        return {
            'doc_id': self.doc_id,
            'doc_content': self.doc_content,
            'doc_timestamp': self.doc_timestamp
        } 

# Routes

@app.route('/')
def hello():
    return "Hello, User!"

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
    
    for thread in threads:
        sorted_emails = sorted(
            thread.emails, 
            key=lambda email: email.email_received_at or db.func.now(),
            reverse=True
        )
        sentiment_record = EmailThreadSentiment.query.filter_by(thread_id=thread.thread_id).first()
        
        sentiment_ = sentiment_record.sentiments if sentiment_record else 'Positive'
        sentiment = ""
        if (sentiment_ == 'Positive'):
            sentiment = "postive"
        elif (sentiment_ == 'Neutral'):
            sentiment = 'neutral'
        elif (sentiment_ == 'Needs attention'):
            sentiment = 'needs_attention'
        elif (sentiment_ == 'Critical'):
            sentiment = 'critical'
        else:
            print ("something went wrong")
            sentiment = 'positive'

        emails = [{
            'seq_no': i,
            'sender': email.sender_email.split('@')[0],  # Extracting name from email
            'senderEmail': email.sender_email,
            'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
            'content': email.email_content,
            'isOpen': False  # Assuming 'isOpen' is false for simplicity
        } for i, email in enumerate(sorted_emails)]
        
        thread_list.append({
            'threadId': thread.thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails,
            'sentiment': sentiment  
        })

    return jsonify({ "threads": thread_list,"time": datetime.now(timezone.utc).strftime("%d-%m-%y_%H:%M")})

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

    for email in emails:
        sender = email['senderEmail']
        date = email['date']
        content = email['content']
    
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    # Ollama code
    stream = ollama.chat(
    model='llama3.2',
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,)

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


 # 4. SBP-3 [ 26th Sept 2024 ]
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

    # Prepare the LLM prompt to assess sentiment based on the email thread
    prompt = f"""
    Please evaluate the sentiment of the following email thread based on a scale from 1 to 10. The sentiment categories are as follows:
    
    - Critical (1-2)
    - Warning (3)
    - Neutral (4-6)
    - Positive (7-10)
    
    Only return a single number from 1 to 10, and nothing else, based on the sentiment of the thread.

    Email thread title: {email_thread.thread_topic}

    Emails:
    """
    
    # Iterate through the emails and format them into a readable string for the LLM
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    # Send the prompt to the LLM (replace ollama.chat with appropriate API)
    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}],
    )

    print ("response",response['message']['content'].strip())
    # Extract the numeric sentiment (between 1 and 10)
    try:
        polarity = int(response['message']['content'].strip())
    except ValueError:
        return jsonify({'error': 'Invalid response from the LLM. Expected a number.'}), 500

    # Determine overall sentiment category based on polarity
    if polarity > 6:
        sentiment_category = "Positive"
    elif 3 < polarity <= 6:
        sentiment_category = "Needs attention"
    elif polarity == 3:
        sentiment_category = "Neutral"
    else:
        sentiment_category = "Critical"

    # Save the sentiment to the database (EmailThreadSentiment table)
    try:
        EmailThreadSentiment.save_sentiment(email_thread_id, sentiment_category)
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

    # Response body for UI with a normalized sentiment label
    sentiment_response = {
        'Positive': 'positive',
        'Critical': 'critical',
        'Needs attention': 'needs_attention',
        'Neutral': 'neutral'
    }.get(sentiment_category, 'neutral')  # Default to 'neutral' if something goes wrong

    response = { 'overall_sentiment': sentiment_response }
    return jsonify(response), 200

@app.route('/generate_customer_response', methods=['POST'])
def generate_customer_response():
    data = request.json
    if not data or 'email_content' not in data:
        return jsonify({'error': 'Request must contain email content'}), 400

    customer_email_content = data['email_content']

    # Read SOP PDF content
    sop_path = './uploads/SOP.pdf'
    try:
        with open(sop_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            sop_content = " ".join([page.extract_text() for page in reader.pages])
    except FileNotFoundError:
        return jsonify({'error': 'SOP file not found'}), 404

    # Create prompt with SOP and customer email content
    prompt = f"""
    Based on the following Standard Operating Procedure (SOP) and the email content from the customer, generate a customer support email response.

    SOP:
    {sop_content}

    Customer Email:
    {customer_email_content}

    Please draft a response that addresses the customer's concerns while adhering to the SOP guidelines.
    """

    # Ollama API call for response generation
    stream = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}],
        stream=True,
    )

    def generate_response():
        first_chunk = True
        for chunk in stream:
            if not first_chunk:
                yield ' '
            yield chunk['message']['content']
            first_chunk = False

    return Response(stream_with_context(generate_response()), content_type='application/json')

@app.post('/upload_sop_doc/')
def store_sop_doc_to_db():
    if "file" not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files["file"]

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    binary_data = file.read()
    sop_document = SOPDocument(doc_content=binary_data)
    db.session.add(sop_document)
    db.session.commit()
    return jsonify({}), 200

def get_pdf_content_by_doc_id(doc_id):
    try:
        # Query the database to get the document by doc_id
        sop_document = SOPDocument.query.filter_by(doc_id=doc_id).one()

        # Read the PDF content from the binary data
        pdf_file = io.BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        
        # Extract text from all pages
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content

    # except NoResultFound:
    #     return jsonify({'error': 'Document not found with the provided doc_id'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# 5. SBER-2 [ 30th Sept 2024 ]

# Adding email to database based on thread id and document id (considering primary key)
# Response body AI Team

def gen_support_email(sop_content, emails):
    prompt = f"""
    Based on the following Standard Operating Procedure (SOP) and the email content from the customer, generate a customer support email response.
    SOP:
    {sop_content}
    Please draft a response that addresses the customer's concerns while adhering to the SOP guidelines.
    Customer Email:

    """
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    # Ollama API call for response generation
    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}]
    )
    return response['message']['content']

def background_task(thread_id, document_id):
    with app.app_context():
        emails = Email.query.filter_by(thread_id=thread_id).all()
        email_thread = EmailThread.query.get(thread_id)

        if not email_thread:
            print("Email thread not found")
            return

        document = get_pdf_content_by_doc_id(document_id)
        if not document:
            print("Document not found")
            return

        subject = email_thread.thread_topic
        content = gen_support_email(document, emails)

        new_email = Email(
            sender_email="support@abc.com",
            thread_id=thread_id,
            email_subject=subject,
            email_content=content,
            sender_name="support",
            receiver_email='alex@abc.com',
            receiver_name='alex',
            email_received_at=db.func.now()  # Set timestamp to now
        )
        db.session.add(new_email)
        db.session.commit()

@app.route('/store_thread_and_document', methods=['POST'])
def store_email_document():
    data = request.json  # Parsing incoming JSON data
    thread_id = data.get('thread_id')  # Fetching thread_id in JSON
    document_id = data.get('doc_id')  # Fetching document_id in JSON

    # Check for valid thread_id and document_id
    if not thread_id or not document_id:
        return jsonify({'error': "Provide valid thread_id and document_id"}), 400

    # Start the background task
    Thread(target=background_task, args=(thread_id, document_id)).start()

    # Immediately respond with a 200 status
    return jsonify({'success': 'Processing started in background', 'thread_id': thread_id}), 200

@app.route("/check_new_emails/<last_updated_timestamp>", methods=["GET"])
def check_new_emails(last_updated_timestamp):
    dt = datetime.strptime(last_updated_timestamp, "%d-%m-%y_%H:%M")
    threads = EmailThread.query.all()
    for thread in threads:
        if (thread.updated_at > dt):
            return get_all_threads()
    return jsonify([])

# Run the application
if __name__ == '__main__':
    app.run(debug=True)
