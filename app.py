from datetime import datetime, timezone
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from gpt_ai_functions import get_answer_from_email, get_summary_response
from llama_ai_functions import llama_get_summary_response, llam_get_answer_from_email
from pypdf import PdfReader
from sqlalchemy import Enum, desc
from threading import Thread

import io

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://ruchita:qwerty@localhost/poc'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
CORS(app)

BUSINESS_SIDE_NAME = "Support Team"
BUSINESS_SIDE_EMAIL = "support@business.com"
AI_MODEL = "gpt"  # Use either "gpt" or "llama".

class EmailThread(db.Model):
    __tablename__ = 'threads'
    thread_id = db.Column(db.Integer, primary_key=True)
    thread_topic = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(db.TIMESTAMP, default=db.func.now(
    ), onupdate=db.func.now()) 

class Email(db.Model):
    __tablename__ = 'emails'
    email_record_id = db.Column(db.Integer, primary_key=True)
    sender_email = db.Column(db.String(50), nullable=False)
    sender_name = db.Column(db.String(100), nullable=False)
    receiver_email = db.Column(db.String(100), nullable=False)
    receiver_name = db.Column(db.String(100), nullable=False)
    thread_id = db.Column(db.Integer, db.ForeignKey(
        'threads.thread_id'), nullable=False)
    email_received_at = db.Column(db.TIMESTAMP, nullable=True)
    email_subject = db.Column(db.String(100), nullable=False)
    email_content = db.Column(db.Text, nullable=True)
    is_resolved = db.Column(db.Boolean, default=True)
    coverage_percentage = db.Column(db.Integer)
    email_thread = db.relationship(
        'EmailThread', backref=db.backref('emails', lazy=True))

class Summary(db.Model):
    __tablename__ = 'summaries'
    summary_id = db.Column(db.Integer, primary_key=True) 
    thread_id = db.Column(db.Integer, db.ForeignKey(
        'threads.thread_id'), nullable=False) 
    summary_content = db.Column(db.Text, nullable=False)
    summary_created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    summary_modified_at = db.Column(db.TIMESTAMP, default=db.func.now(
    ), onupdate=db.func.now()) 
    thread = db.relationship(
        'EmailThread', backref=db.backref('summaries', lazy=True))

class SentimentEnum(db.Enum):
    CRITICAL = 'Critical'
    NEEDS_ATTENTION = 'Needs attention'
    NEUTRAL = 'Neutral'
    POSITIVE = 'Positive'

class EmailThreadSentiment(db.Model):
    __tablename__ = 'email_thread_sentiment'
    sentiment_id = db.Column(db.Integer, primary_key=True)
    thread_id = db.Column(db.Integer, db.ForeignKey(
        'threads.thread_id'), nullable=False, primary_key=True)
    sentiments = db.Column(Enum('Critical', 'Needs attention',
                           'Neutral', 'Positive', name='sentiment'), nullable=False)
    timestamp = db.Column(db.TIMESTAMP, default=db.func.now())
    thread = db.relationship(
        'EmailThread', backref=db.backref('sentiments', lazy=True))

    @classmethod
    def save_sentiment(cls, thread_id, sentiment_category):
        existing_record = cls.query.filter_by(thread_id=thread_id).first()
        if existing_record:
            existing_record.sentiments = sentiment_category 
            existing_record.timestamp = db.func.now() 
        else:
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

class Category(db.Model):
    __tablename__ = 'query_categories'
    category_id = db.Column(db.Integer, primary_key=True)
    category_name = db.Column(db.String(100), nullable=False)
    sop_doc_id = db.Column(db.Integer, db.ForeignKey(
        'sop_document.doc_id'), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(
        db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())

class SOPGapCoverage(db.Model):
    __tablename__ = 'sop_gap_coverage'
    coverage_id = db.Column(db.Integer, primary_key=True)
    faq_id = db.Column(db.Integer, db.ForeignKey(
        'faqs.faq_id'), nullable=False)
    sop_doc_id = db.Column(db.Integer, db.ForeignKey(
        'sop_document.doc_id'), nullable=False)
    gap_type = db.Column(db.Enum('Fully Covered', 'Partially Covered', 'Inaccurately Covered',
                         'Ambiguously Covered', 'Not Covered', name='gap_category'), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(
        db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())

class FAQS(db.Model):
    __tablename__ = 'faqs'
    faq_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    faq = db.Column(db.Text, nullable=False)
    freq = db.Column(db.Integer, nullable=False, default=0)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(
        db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())
    __table_args__ = (
        db.CheckConstraint('freq >= 0', name='chk_positive'),
    )

class StagingFAQS(db.Model):
    __tablename__ = 'staging_faqs'
    staging_faq_id = db.Column(
        db.Integer, primary_key=True, autoincrement=True)
    thread_id = db.Column(db.Integer, db.ForeignKey(
        'threads.thread_id'), nullable=False)
    faq = db.Column(db.Text, nullable=False)
    processed_flag = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(
        db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())

class StagingSopGapCoverage(db.Model):
    __tablename__ = 'staging_sop_gap_coverage'
    staging_coverage_id = db.Column(
        db.Integer, primary_key=True, autoincrement=True)
    thread_id = db.Column(db.Integer, db.ForeignKey(
        'threads.thread_id'), nullable=False)
    sop_doc_id = db.Column(db.Integer, db.ForeignKey(
        'sop_documents.doc_id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey(
        'query_categories.category_id'), nullable=False)
    gap_type = db.Column(Enum('Fully Covered', 'Partially Covered', 'Inaccurately Covered',
                         'Ambiguously Covered', 'Not Covered', name='gap_category'), nullable=False)
    processed_flag = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(
        db.TIMESTAMP, default=db.func.now(), onupdate=db.func.now())

class BucketName(Enum):
    EXCELLENT_COVERAGE = 'Excellent Coverage'
    GOOD_COVERAGE = 'Good Coverage'
    MODERATE_COVERAGE = 'Moderate Coverage'
    MINIMAL_COVERAGE = 'Minimal Coverage'
    POOR_COVERAGE = 'Poor Coverage'

class CoverageBucket(db.Model):
    __tablename__ = 'coverage_buckets'
    bucket_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    bucket_name = db.Column(Enum('Excellent Coverage', 'Good Coverage', 'Moderate Coverage', 'Minimal Coverage',
                            'Poor Coverage', name='bucket_name'), nullable=False)  # Should match the ENUM type
    faq_count = db.Column(db.Integer, nullable=False)
    percentage = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=db.func.now())
    updated_at = db.Column(db.TIMESTAMP, default=db.func.now())

# Utils
def get_pdf_content_by_doc_id(doc_id):
    try:
        sop_document = SOPDocument.query.filter_by(doc_id=doc_id).one()
        if sop_document == None:
            pass # TODO: throw exception here
        pdf_file = io.BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception as e:
        print ("Exception occurred during extracting pdf: ", e)
        return None

# Helper funtion to extract customer name and email from a list of emails
def getCustomerNameAndEmail(emails):
    for email in emails:
        # If email receiver is not the business itself then it must be the customer
        if not BUSINESS_SIDE_EMAIL in email.receiver_email.lower():
            return email.receiver_name, email.receiver_email
    return "user", "user@abc.com"

def sortEmails(emailList, sortOrder):
    return sorted(emailList, key=lambda email: email.email_received_at, reverse = not sortOrder)

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
        print("something went wrong", sentiment_)
        sentiment = 'positive'
    return sentiment
# Routes
@app.route('/')
def hello():
    return "Hello, User!"

@app.route('/all_email_threads', methods=['GET'])
def get_all_threads():
    threads = EmailThread.query.order_by(EmailThread.updated_at.desc(
    ), EmailThread.created_at.desc(), EmailThread.thread_id.desc()).all()

    thread_list = []
    for thread in threads:
        sentiment_record = EmailThreadSentiment.query.filter_by(
            thread_id=thread.thread_id).first()
        sentiment = getSentimentHelper(sentiment_record)

        sorted_emails = sorted(
            thread.emails,
            key=lambda email: email.email_received_at or db.func.now(),
            reverse=True
        )
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
            'isResolved': email.is_resolved,
            'coveragePercentage': email.coverage_percentage
        } for i, email in enumerate(sorted_emails)]

        thread_list.append({
            'threadId': thread.thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails,
            'sentiment': sentiment
        })

    return jsonify({"threads": thread_list, "time": datetime.now(timezone.utc).strftime("%d-%m-%y_%H:%M:%S")})

@app.route('/create/email', methods=['POST'])
def create_email():
    data = request.json 
    # Validate the necessary fields
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

    customerName, customerEmail = getCustomerNameAndEmail(thread.emails)
    new_email = Email(
        sender_email = BUSINESS_SIDE_EMAIL,
        sender_name = BUSINESS_SIDE_NAME,
        thread_id = thread_id,
        email_subject = data['subject'],
        email_content = data['content'],
        receiver_email = customerEmail,
        receiver_name = customerName,
        email_received_at = db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()
    return jsonify({'success': 'Email added to thread', 'email_record_id': new_email.email_record_id}), 201

@app.post('/upload_sop_doc/')
def store_sop_doc_to_db():
    if "file" not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files["file"]
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    binary_data = file.read()
    sop_document = SOPDocument(doc_content = binary_data)
    db.session.add(sop_document)
    db.session.commit()
    return jsonify({}), 200

@app.route("/check_new_emails/<last_updated_timestamp>", methods=["GET"])
def check_new_emails(last_updated_timestamp):
    dt = datetime.strptime(last_updated_timestamp, "%d-%m-%y_%H:%M:%S")
    threads = EmailThread.query.all()
    for thread in threads:
        if thread.updated_at > dt:
            print("New mail found in the DB, fetching new emails: ", thread.updated_at, dt)
            return get_all_threads()
    return jsonify([])

@app.route('/update/email/<int:email_id>', methods=['PUT'])
def update_email(email_id):
    data = request.json
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

# AI APIs
def get_summary(discussion_thread):
    if (AI_MODEL == "llama"):
        return llama_get_summary_response(discussion_thread)
    else:
        return get_summary_response(discussion_thread)

def sop_email(thread_topic, discussion_thread, sender_name, doc):
    if (AI_MODEL == "llama"):
        return llam_get_answer_from_email(doc, discussion_thread)
    else:
        return get_answer_from_email(thread_topic, discussion_thread, sender_name, doc)

def store_email_document_(thread_id, doc_id):
    with app.app_context():
        # Fetch all valid email thread based on thread_id
        email_thread = EmailThread.query.get(thread_id)
        if not email_thread:
            return jsonify({'error': "Email thread not found"}), 404

        document = get_pdf_content_by_doc_id(doc_id)

        if not document:
            return jsonify({'error': "Document not found"}), 404

        sorted_emails = sorted(
            email_thread.emails,
            key=lambda email: email.email_received_at or db.func.now(),
            reverse=True
        )
        latest_email = sorted_emails[0]

        discussion_thread = ""
        for email in sorted_emails:
            sender = email.sender_email
            date = email.email_received_at.strftime(
                '%B %d, %Y %I:%M %p') if email.email_received_at else None
            content = email.email_content
            email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
            discussion_thread += email_entry

        (content, coverage_percentage) = sop_email(email_thread.thread_topic,
                                                   discussion_thread, latest_email.sender_name, document)
        customerName, customerEmail = latest_email.sender_name, latest_email.sender_email

        new_email = Email(
            sender_email = BUSINESS_SIDE_EMAIL,
            sender_name = BUSINESS_SIDE_NAME,
            thread_id = thread_id,
            email_subject = email_thread.thread_topic,
            email_content = content,
            receiver_email = customerName,
            receiver_name = customerEmail,
            email_received_at = db.func.now(), 
            is_resolved = False,
            coverage_percentage = coverage_percentage
        )
        db.session.add(new_email)
        db.session.commit()

@app.route('/store_thread_and_document', methods=['POST'])
def store_email_document():
    data = request.json  

    if not data:
        return { jsonify({'error:' 'cannot decode json data'}) }, 400

    thread_id = data.get('thread_id') 
    document_id = data.get('doc_id') 
    
    if not thread_id or not document_id:
        return jsonify({'error': "Provide valid thread_id and documemnt_id"}), 400
    
    Thread(target=store_email_document_, args=(thread_id, document_id)).start()
    return jsonify({'success': 'Processing started in background', 'thread_id': thread_id}), 200

@app.post('/summarize/<int:thread_id>')
def summarize_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    sorted_emails = sortEmails(thread.emails, True) # True means sort in Asc order
    discussion_thread = ""

    for email in sorted_emails:
        sender = email.sender_email
        date = email.email_received_at.strftime(
            '%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        discussion_thread += email_entry

    response = get_summary(discussion_thread)
    thread_summary = Summary(
        thread_id = thread.thread_id,
        summary_content = response
    )
    db.session.add(thread_summary)
    db.session.commit()
    return (response)

@app.route('/get_category_gap/<int:doc_id>', methods=['GET'])
def get_category_gaps(doc_id):
    enum_counts = (
        db.session.query(
            SOPGapCoverage.gap_type,
            db.func.count(SOPGapCoverage.coverage_id).label('count')
        )
        .filter(SOPGapCoverage.sop_doc_id == doc_id)
        .group_by(SOPGapCoverage.gap_type)
        .all()
    )
    count_dict = {
        gap_type: 0 for gap_type in
        ['Fully Covered', 'Partially Covered', 'Inaccurately Covered',
            'Ambiguously Covered', 'Not Covered']
    }
    for gap_type, count in enum_counts:
        count_dict[gap_type] = count
    gaps = (
        db.session.query(
            FAQS.faq,
            SOPGapCoverage.gap_type,
            SOPGapCoverage.coverage_id
        )
        .join(SOPGapCoverage, FAQS.faq_id == SOPGapCoverage.faq_id)
        .filter(SOPGapCoverage.sop_doc_id == doc_id)
        # You can change the ordering here
        .order_by(SOPGapCoverage.coverage_id)
        .all()
    )
    gap_list = [
        {
            "faq": gap.faq,
            "gap_type": gap.gap_type,
            "id": gap.coverage_id
        }
        for gap in gaps
    ]
    response = {
        "count": count_dict,
        "gaps": gap_list
    }
    return jsonify(response)

@app.get('/get_faqs_with_freq')
def get_faqs_with_freq():
    faqs = FAQS.query.with_entities(
        FAQS.faq, FAQS.freq).order_by(desc(FAQS.freq)).all()
    faq_list = [{"faq": faq.faq, "freq": faq.freq} for faq in faqs]
    return jsonify(faq_list)

if __name__ == '__main__':
    app.run(debug=True)
