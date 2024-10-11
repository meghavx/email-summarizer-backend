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

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://ruchita:qwerty@localhost:5433/poc'
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
    is_resolved = db.Column(db.Boolean, default=True)
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

class SOPDocument(db.Model):
    __tablename__ = 'sop_document'
    doc_id = db.Column(db.Integer, primary_key=True)
    doc_content = db.Column(db.LargeBinary, nullable=False)
    doc_timestamp = db.Column(db.TIMESTAMP, default=db.func.now()) 

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
        sorted_emails = sorted(
            thread.emails, 
            key=lambda email: email.email_received_at or db.func.now(),
            reverse=True
        )
        sentiment_record = EmailThreadSentiment.query.filter_by(thread_id=thread.thread_id).first()
        sentiment = getSentimentHelper(sentiment_record)

        emails = [{
            'seq_no': i,
            'emailRecordId': email.email_record_id,
            'sender': email.sender_name,
            'senderEmail': email.sender_email,
            'receiver': email.receiver_name,
            'receiverEmail': email.receiver_email,
            'date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
            'content': email.email_content,
            'isOpen': False,
            'isResolved': email.is_resolved
        } for i, email in enumerate(sorted_emails)]
        
        thread_list.append({
            'threadId': thread.thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails,
            'sentiment': sentiment  
        })

    return jsonify({ "threads": thread_list,"time": datetime.now(timezone.utc).strftime("%d-%m-%y_%H:%M:%S")})

@app.post('/summarize/<int:thread_id>')
def summarize_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    summary = Summary.query.filter_by(thread_id=thread_id).first()

    if summary and thread.updated_at <= summary.summary_modified_at:
        return (summary.summary_content)

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

    stream = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}],
        stream=True,
    )

    def generate_summary():
        summary_content = ''

        first_chunk = True
        for chunk in stream:
            if not first_chunk:
                yield ' '
            message_chunk = chunk['message']['content']
            yield message_chunk
            summary_content += message_chunk
            first_chunk = False

        if summary:
            summary.summary_content = summary_content
            summary.summary_modified_at = datetime.now(timezone.utc)
        else:
            new_summary = Summary(
                thread_id=thread_id,
                summary_content=summary_content,
                summary_created_at=datetime.now(timezone.utc),
                summary_modified_at=datetime.now(timezone.utc)
            )
            db.session.add(new_summary)
        db.session.commit()
    # Return a streaming response using Flask's Response object
    return Response(stream_with_context(generate_summary()), content_type='application/json')

@app.route('/create/email', methods=['POST'])
def create_email():
    data = request.json 
    
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    new_thread = EmailThread(thread_topic = data['subject'])
    db.session.add(new_thread)
    db.session.flush()  

    new_email = Email(
        sender_email = data['senderEmail'],
        sender_name = data['senderEmail'].split('@')[0],
        thread_id = new_thread.thread_id,
        email_subject = data['subject'],
        email_content = data['content'],
        receiver_email = BUSINESS_SIDE_EMAIL,
        receiver_name = BUSINESS_SIDE_NAME,
        email_received_at = db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email and thread created successfully', 'thread_id': new_thread.thread_id, 'email_record_id': new_email.email_record_id}), 201

@app.route('/create/email/<int:thread_id>', methods=['POST'])
def add_email_to_thread(thread_id):
    data = request.json 
    
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    new_email = Email(
        sender_email = BUSINESS_SIDE_EMAIL ,
        sender_name = BUSINESS_SIDE_NAME, 
        thread_id = thread_id,
        email_subject = data['subject'],
        email_content = data['content'],
        receiver_email = data['senderEmail'],
        receiver_name = data['senderEmail'].split('@')[0],
        email_received_at = db.func.now()  
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email added to thread', 'email_record_id': new_email.email_record_id}), 201

@app.route('/generate_sentiment/<int:email_thread_id>', methods=['POST'])
def generate_sentiment(email_thread_id):
    email_thread = EmailThread.query.get(email_thread_id)
    
    if not email_thread:
        return jsonify({'error': 'Email thread not found'}), 404
    
    emails = email_thread.emails
    if not emails:
        return jsonify({'error': 'No emails found in this thread.'}), 404

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
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}],
    )

    print ("response",response['message']['content'].strip())
    try:
        polarity = int(response['message']['content'].strip())
    except ValueError:
        return jsonify({'error': 'Invalid response from the LLM. Expected a number.'}), 500

    if polarity > 6:
        sentiment_category = "Positive"
    elif 3 < polarity <= 6:
        sentiment_category = "Needs attention"
    elif polarity == 3:
        sentiment_category = "Neutral"
    else:
        sentiment_category = "Critical"

    try:
        EmailThreadSentiment.save_sentiment(email_thread_id, sentiment_category)
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

    sentiment_response = {
        'Positive': 'positive',
        'Critical': 'critical',
        'Needs attention': 'needs_attention',
        'Neutral': 'neutral'
    }.get(sentiment_category, 'neutral')  # Default to 'neutral' if something goes wrong

    response = { 'overall_sentiment': sentiment_response }
    return jsonify(response), 200

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
        sop_document = SOPDocument.query.filter_by(doc_id=doc_id).one()
        pdf_file = io.BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def gen_support_email(sop_content, emails):
    prompt = f"""
    SOP:
    {sop_content}
   
    You are a helpful assistant that generates responses based on company SOP guidelines.
    Below are the emails asking about a specific process related to the company SOP.
    generate a formal and professional response to this email, addressing each point appropriately.
    Refer yourself as ABC support at the end of the mail.
    Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    including step-by-step guidelines, documentation, and any relevant timelines. Don't include the subject line in mail.
    Do not mention subject in the response!
    Email exchanges: 
    """
    for email in emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        prompt += email_entry

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

        print ("got sop email response",content)
        new_email = Email(
            sender_email = "support@abc.com",
            thread_id = thread_id,
            email_subject = subject,
            email_content = content,
            sender_name = "support",
            receiver_email = "alex@abc.com",
            receiver_name ='alex',
            email_received_at = db.func.now(),  # Set timestamp to now
            is_resolved = False
        )
        db.session.add(new_email)
        db.session.commit()

@app.route('/store_thread_and_document', methods=['POST'])
def store_email_document():
    data = request.json  # Parsing incoming JSON data
    thread_id = data.get('thread_id')  # Fetching thread_id in JSON
    document_id = data.get('doc_id')  # Fetching document_id in JSON

    if not thread_id or not document_id:
        return jsonify({'error': "Provide valid thread_id and document_id"}), 400

    Thread(target=background_task, args=(thread_id, document_id)).start()
    return jsonify({'success': 'Processing started in background', 'thread_id': thread_id}), 200

@app.route("/check_new_emails/<last_updated_timestamp>", methods=["GET"])
def check_new_emails(last_updated_timestamp):
    dt = datetime.strptime(last_updated_timestamp, "%d-%m-%y_%H:%M:%S")
    threads = EmailThread.query.all()
    for thread in threads:
        if thread.updated_at > dt:
            print ("condition passed",thread.updated_at,dt)
            return get_all_threads()
    return jsonify([])

@app.route('/update/email/<int:email_id>', methods=['PUT'])
def update_email(email_id):
    data = request.json 
    print ("data",data)
    if not data or not data['content']:
        return jsonify({'error': 'Field not provided for update'}), 400
    email_record = Email.query.get(email_id)
    if not email_record:
        return jsonify({'error': 'Email not found'}), 404
    email_record.email_content = data['content']
    email_record.is_resolved = True
    
    db.session.commit()
    return jsonify({'success': 'Email updated successfully', 'email': {
        'email_record_id': email_record.email_record_id,
        'content': email_record.email_content
    }}), 200

if __name__ == '__main__':
    app.run(debug=True,port=5001)
