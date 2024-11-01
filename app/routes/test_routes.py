from flask import Blueprint, jsonify, request
from ..models import EmailThread, Email, db
from ..utils import BUSINESS_SIDE_EMAIL, BUSINESS_SIDE_NAME

app = Blueprint('test', __name__)

# Get an email thread by `thread_id`
@app.get('/thread_by_id/<int:thread_id>')
def get_thread_by_id(thread_id):
    thread = EmailThread.query.get(thread_id)

    if not thread:
        return jsonify({'error': 'Thread not found'}), 404

    emails = [{
        'sender_name': email.sender_name,
        'sender_email': email.sender_email,
        'receiver_name': email.receiver_name,
        'receiver_email': email.receiver_email,
        'email_date': email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None,
        'email_content': email.email_content,
    } for email in thread.emails]

    thread_data = {
        'thread_title': thread.thread_topic,
        'thread_emails': emails,
        'updated_at': thread.updated_at
    }
    return jsonify(thread_data)

# Add dummy emails
@app.post('/add_dummy_emails')
def add_dummy_emails():
  data = request.json

  if isinstance(data, list):
    for i, item in enumerate(data):
      sender = f"customer{i+1}@abc.com"
      subject = item.get('Subject')
      message = item.get('Message')
    
      new_thread = EmailThread(thread_topic=subject)
      db.session.add(new_thread)
      db.session.flush()

      new_email = Email(
        sender_email=sender,
        sender_name=sender.split('@')[0].capitalize(),
        thread_id=new_thread.thread_id,
        email_subject=subject,
        email_content=message,
        receiver_email=BUSINESS_SIDE_EMAIL,
        receiver_name=BUSINESS_SIDE_NAME,
        email_received_at=db.func.now()
      )
      db.session.add(new_email)
      db.session.commit()

      print({"thread_id": new_thread.thread_id, "email_record_id": new_email.email_record_id})

    return jsonify({"status": "success", "message": "Emails added"}), 200
  else:
    return jsonify({"status": "error", "message": "Expected an array of JSON objects"}), 400