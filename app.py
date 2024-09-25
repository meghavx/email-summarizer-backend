
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy.orm import joinedload
from sqlalchemy import desc

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
    __tablename__ = 'email_threads'
    email_thread_id = db.Column(db.Integer, primary_key=True)
    thread_topic = db.Column(db.String(50), nullable=False)

    def to_dict(self):
        return {
            'email_thread_id': self.email_thread_id,
            'thread_topic': self.thread_topic
        }

class Email(db.Model):
    __tablename__ = 'emails'
    email_record_id = db.Column(db.Integer, primary_key=True)
    sender_email = db.Column(db.String(50), nullable=False)
    email_thread_id = db.Column(db.Integer, db.ForeignKey('email_threads.email_thread_id'), nullable=False)
    email_received_timestamp = db.Column(db.TIMESTAMP, nullable=True)
    email_subject = db.Column(db.String(50), nullable=False)
    email_content = db.Column(db.Text, nullable=True)

    # Relationship to EmailThread
    email_thread = db.relationship('EmailThread', backref=db.backref('emails', lazy=True))

    def to_dict(self):
        return {
            'email_record_id': self.email_record_id,
            'sender_email': self.sender_email,
            'email_thread_id': self.email_thread_id,
            'email_received_timestamp': self.email_received_timestamp.strftime('%B %d, %Y %I:%M %p') if self.email_received_timestamp else None,
            'email_subject': self.email_subject,
            'email_content': self.email_content
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
    threads = EmailThread.query.all()
    thread_list = []
    for thread in threads:
        emails = [{
            'seq_no': i,
            'sender': email.sender_email.split('@')[0],  # Extracting name from email
            'senderEmail': email.sender_email,
            'date': email.email_received_timestamp.strftime('%B %d, %Y %I:%M %p') if email.email_received_timestamp else None,
            'content': email.email_content,
            'isOpen': False  # Assuming 'isOpen' is false for simplicity
        } for i,email in  enumerate(thread.emails)]
        
        thread_list.append({
            'threadId' : thread.email_thread_id,
            'threadTitle': thread.thread_topic,
            'emails': emails
        })

    return jsonify(thread_list)

# 3. GET specific email thread by email_thread_id with its emails
@app.route('/all_email_by_thread_id/<int:thread_id>', methods=['GET'])
def get_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)

    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    emails = [{
        'sender': email.sender_email.split('@')[0],  # Extracting name from email
        'senderEmail': email.sender_email,
        'date': email.email_received_timestamp.strftime('%B %d, %Y %I:%M %p') if email.email_received_timestamp else None,
        'content': email.email_content,
        'isOpen': False  # Assuming 'isOpen' is false for simplicity
    } for email in thread.emails]

    thread_data = {
        'threadTitle': thread.thread_topic,
        'emails': emails
    }

    return jsonify(thread_data)

def sortEmails(emailList):
    return sorted(emailList, key=lambda email: email.email_received_timestamp)

@app.post('/summarize/<int:thread_id>')
def summarize_thread_by_id(thread_id):
    thread = EmailThread.query.options(
    joinedload(EmailThread.emails).order_by(desc(Email.email_received_timestamp))
).all()
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404
    
    emails = [{
        'senderEmail': email.sender_email,
        'date': email.email_received_timestamp.strftime('%B %d, %Y %I:%M %p') if email.email_received_timestamp else None,
        'content': email.email_content,
    } for email in thread.emails]

    request_body = {
        'threadTitle': thread.thread_topic,
        'emails': emails
    }

    """
    # Call API (POST) endpoint
    response = generate_summary(request_body)
    thread_summary = ThreadSummary(
        thread_id = thread.thread_id,
        summary_content = str(response)
    )
    db.session.add(thread_summary)
    db.session.commit()    
    """
    return jsonify({'summary':"Here is the summary of the data...summary summary summary"})

# Run the application
if __name__ == '__main__':
    app.run(debug=True)