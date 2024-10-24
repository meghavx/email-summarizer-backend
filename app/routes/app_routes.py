from flask import Blueprint, jsonify, request
from ..models import EmailThread, Email, db, EmailThreadSentiment, SOPDocument
from ..utils import getSentimentHelper, BUSINESS_SIDE_EMAIL, BUSINESS_SIDE_NAME, getCustomerNameAndEmail
from datetime import datetime, timezone

app = Blueprint('main', __name__)

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
            'coveragePercentage': email.coverage_percentage,
            'coverageDescription' : email.coverage_description
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
    if not data:
        return jsonify({'error': 'unable to parse JSON'}), 400
    # Validate the necessary fields
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    new_thread = EmailThread(thread_topic=data['subject'])
    db.session.add(new_thread)
    db.session.flush()

    new_email = Email(
        sender_email=data['senderEmail'],
        sender_name=data['senderEmail'].split('@')[0],
        thread_id=new_thread.thread_id,
        email_subject=data['subject'],
        email_content=data['content'],
        receiver_email=BUSINESS_SIDE_EMAIL,
        receiver_name=BUSINESS_SIDE_NAME,
        email_received_at=db.func.now()  # Set timestamp to now
    )
    db.session.add(new_email)
    db.session.commit()

    return jsonify({'success': 'Email and thread created successfully', 'thread_id': new_thread.thread_id, 'email_record_id': new_email.email_record_id}), 201


@app.route('/create/email/<int:thread_id>', methods=['POST'])
def add_email_to_thread(thread_id):
    data = request.json
    if not data:
        return jsonify({'error': 'unable to parse JSON'}), 400
    if not all(k in data for k in ("senderEmail", "subject", "content")):
        return jsonify({'error': 'Missing required fields'}), 400

    thread = EmailThread.query.get(thread_id)
    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    customerName, customerEmail = getCustomerNameAndEmail(thread.emails)
    new_email = Email(
        sender_email=BUSINESS_SIDE_EMAIL,
        sender_name=BUSINESS_SIDE_NAME,
        thread_id=thread_id,
        email_subject=data['subject'],
        email_content=data['content'],
        receiver_email=customerEmail,
        receiver_name=customerName,
        email_received_at=db.func.now()  # Set timestamp to now
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
    sop_document = SOPDocument(doc_content=binary_data)
    db.session.add(sop_document)
    db.session.commit()
    return jsonify({}), 200


@app.route("/check_new_emails/<last_updated_timestamp>", methods=["GET"])
def check_new_emails(last_updated_timestamp):
    dt = datetime.strptime(last_updated_timestamp, "%d-%m-%y_%H:%M:%S")
    threads = EmailThread.query.all()
    for thread in threads:
        if thread.updated_at > dt:
            print("New mail found in the DB, fetching new emails: ",
                  thread.updated_at, dt)
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
