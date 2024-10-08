from datetime import datetime,timezone 
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import Enum
from PyPDF2 import PdfReader
import io
from sop_based_email_ai import get_answer_from_email
from threading import Thread

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://ruchita:qwerty@localhost/poc'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
CORS(app)

# GLOBAL VARIABLES
BUSINESS_SIDE_NAME = "Support Team"
BUSINESS_SIDE_EMAIL = "support@business.com"

class EmailThread(db.Model):
    __tablename__ = 'threads'
    thread_id = db.Column(db.Integer, primary_key=True)
    thread_topic = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())  # Default to current timestamp
    updated_at = db.Column(db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())  # Auto-update on modification
    
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

class Summary(db.Model):
    __tablename__ = 'summaries'
    summary_id = db.Column(db.Integer, primary_key=True)  # SERIAL equivalent
    thread_id = db.Column(db.Integer, db.ForeignKey('threads.thread_id'), nullable=False)  # Foreign key to threads
    summary_content = db.Column(db.Text, nullable=False)
    summary_created_at = db.Column(db.TIMESTAMP, default=db.func.now())  # Default to current timestamp
    summary_modified_at = db.Column(db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())  # Auto-update on modification
    thread = db.relationship('EmailThread', backref=db.backref('summaries', lazy=True))

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

# SOP Document model
class SOPDocument(db.Model):
    __tablename__ = 'sop_document'
    doc_id = db.Column(db.Integer, primary_key=True)
    doc_content = db.Column(db.LargeBinary, nullable=False)
    doc_timestamp = db.Column(db.TIMESTAMP, default=db.func.now()) 

# Routes
@app.route('/')
def hello():
    return "Hello, User!"

def getSentimentHelper(sentiment_record):
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
        print ("something went wrong",sentiment_)
        sentiment = 'positive'
    return sentiment


@app.route('/all_email_threads', methods=['GET'])
def get_all_threads():
    threads = EmailThread.query.order_by(EmailThread.updated_at.desc(),EmailThread.created_at.desc(),EmailThread.thread_id.desc()).all()
    thread_list = []
    for thread in threads:
        sentiment_record = EmailThreadSentiment.query.filter_by(thread_id=thread.thread_id).first()
        sentiment = getSentimentHelper(sentiment_record)
        
        sorted_emails = sorted(
            thread.emails, 
            key=lambda email: email.email_received_at or db.func.now(),
            reverse=True
        )
        emails = [{
            'seq_no': i,
            'sender': email.sender_name,
            'senderEmail': email.sender_email,
            'receiver': email.receiver_name,
            'receiverEmail': email.receiver_email,
            'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
            'content': email.email_content,
            'isOpen': False  
        } for i,email in  enumerate(sorted_emails)]
        
        thread_list.append({
            'threadId' : thread.thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails,
            'sentiment': sentiment
        })

    return jsonify({ "threads": thread_list,"time": datetime.now(timezone.utc).strftime("%d-%m-%y_%H:%M:%S")})

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_at)

@app.post('/summarize/<int:thread_id>')
def summarize_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404
    
    sorted_emails = sortEmails(thread.emails)
    # Request body to be sent along to the AI Team's
    # `summarize email thread` endpoint call
    request_body = {
        'email_thread_id': thread.thread_id,
        'email_subject': thread.thread_topic,
        'email_messages': [
            {
                'sender': email.sender_name,
                'sequence_no': index + 1,
                'content': email.email_content
            }
            for index, email in enumerate(sorted_emails)
        ]
    }

    """
    # Call AI Team's `summarize thread` (POST) Endpoint
    # with request body as generated above
    # And receive the returned summarized version as `response` 
    response = --Call to the AI Team's Endpoint

    # Construct thread summary record with given thread_id
    # and `response` received as above as summary content
    thread_summary = ThreadSummary(
        thread_id = thread.thread_id,
        summary_content = str(response)
    )

    # Store summary record to DB
    db.session.add(thread_summary)
    db.session.commit()  

    # Send back an OK status  
    """
    return jsonify({}), 200

    # Temporary return statement
    return jsonify({'summary':"Here is the summary of the data...summary summary summary"})

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
        sender_email = data['senderEmail'],
        sender_name = data['senderEmail'].split('@')[0],
        thread_id= new_thread.thread_id,
        email_subject= data['subject'],
        email_content= data['content'],
        receiver_email = BUSINESS_SIDE_EMAIL,
        receiver_name = BUSINESS_SIDE_NAME ,
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

    customerName, customerEmail = getCustomerNameAndEmail(thread.emails)
    # Create a new Email instance
    new_email = Email(
        sender_email= BUSINESS_SIDE_EMAIL,
        sender_name = BUSINESS_SIDE_NAME,
        thread_id= thread_id,
        email_subject= data['subject'],
        email_content= data['content'],
        receiver_email = customerEmail,
        receiver_name = customerName,
        email_received_at=db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email added to thread', 'email_record_id': new_email.email_record_id}), 201

# Helper funtion to extract customer name and email from a list of emails
def getCustomerNameAndEmail(emails):
    customerName = customerEmail = None
    for email in emails:
        # If email receiver is not the business itself then it must be the customer
        if not BUSINESS_SIDE_EMAIL in email.receiver_email.lower():
            return email.receiver_name, email.receiver_email
    return "user","user@abc.com"

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

        if sop_document == None:
            return ""

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

def store_email_document_(thread_id, doc_id):
    with app.app_context():
      # Fetch all valid email thread based on thread_id
      email_thread = EmailThread.query.get(thread_id) 
      if not email_thread:
          return jsonify ({'error' : "Email thread not found"}) , 404
  
      document = get_pdf_content_by_doc_id(doc_id)
  
      if not document:
          return jsonify ({'error' : "Document not found"}) , 404
      
      sorted_emails = sorted(
          email_thread.emails, 
          key=lambda email: email.email_received_at or db.func.now(),
          reverse=True
      )
      latest_email = sorted_emails[0]
      print ("latest_email",latest_email)
      # AI Team's response to the latest email in this thread
      content = get_answer_from_email(email_thread.thread_topic,latest_email.email_content,latest_email.sender_name,document)
      customerName, customerEmail = latest_email.sender_name,latest_email.sender_email
      new_email = Email(
          sender_email= BUSINESS_SIDE_EMAIL,
          sender_name = BUSINESS_SIDE_NAME,
          thread_id= thread_id,
          email_subject= email_thread.thread_topic,
          email_content= content,
          receiver_email = customerName,
          receiver_name = customerEmail,
          email_received_at=db.func.now()  # Set timestamp to now
      )
      db.session.add(new_email)
      db.session.commit()

@app.route('/store_thread_and_document' , methods=['POST'])
def store_email_document():
    data = request.json # Parsing incoming JSON data 
    thread_id = data.get('thread_id') # Fetching thread_id in JSON
    document_id = data.get('doc_id') # Fetching document_id in JSON

    # Check for valid thread_id and document_id 
    if not thread_id or not document_id:
        return jsonify ({'error' : "Provide valid thread_id and documemnt_id"}) , 400 
    
    Thread(target=store_email_document_, args=(thread_id, document_id)).start()

    # Immediately respond with a 200 status
    return jsonify({'success': 'Processing started in background', 'thread_id': thread_id}), 200

@app.route("/check_new_emails/<last_updated_timestamp>", methods=["GET"])
def check_new_emails(last_updated_timestamp):
    dt = datetime.strptime(last_updated_timestamp, "%d-%m-%y_%H:%M:%S")
    threads = EmailThread.query.all()
    for thread in threads:
        if thread.updated_at > dt:
            print ("Condition got passed", thread.updated_at,dt)
            return get_all_threads()
    return jsonify([])

# Run the application
if __name__ == '__main__':
    app.run(debug=True)
