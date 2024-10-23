import pytest
from app import create_app
import io
from datetime import datetime,timezone 
from app.routes.ai_routes import store_email_document_helper
from app.models import Email

@pytest.fixture
def app():
    app = create_app()
    app.config['TESTING'] = True
    app.config['BUSINESS_SIDE_NAME'] = "Support Team"
    app.config['BUSINESS_SIDE_EMAIL'] = "support@business.com"
    return app

@pytest.fixture
def client(app):
    return app.test_client()

def test_hello_user_api(client):
    resp = client.get('/')
    assert resp.status_code == 200
    assert resp.data == b"Hello, User!"

def test_get_all_email_threads_api(client):
    resp = client.get('/all_email_threads')
    assert resp.status_code == 200
    assert 'threads' in resp.get_json()

def test_create_email(client):
    data = {
        "senderEmail": "test@example.com",
        "subject": "Test Subject",
        "content": "This is a test email content."
    }
    resp = client.post('/create/email', json=data)
    assert resp.status_code == 201
    assert 'success' in resp.get_json()

def test_add_email_to_thread(client):
    thread_id = 1  # This should be a valid thread_id present in your test database
    data = {
        "senderEmail": "test@example.com",
        "subject": "Test Subject",
        "content": "This is another test email content."
    }
    resp = client.post(f'/create/email/{thread_id}', json=data)
    assert resp.status_code == 201
    assert 'success' in resp.get_json()

def test_store_sop_doc_to_db(client):
    data = {'file': (io.BytesIO(b"fake pdf content"), 'test.pdf')}
    resp = client.post('/upload_sop_doc/', data=data)
    assert resp.status_code == 200

def test_update_email(client):
    email_id = 1  # This should be a valid email_id present in your test database
    data = {"content": "Updated email content"}
    resp = client.put(f'/update/email/{email_id}', json=data)
    assert resp.status_code == 200
    assert 'success' in resp.get_json()

def test_summarization(client):
    thread_id = 1
    resp = client.post(f'/summarize/{thread_id}')
    assert resp.status_code == 200

def test_check_new_emails(client):
    currTime = datetime.now(timezone.utc).strftime("%d-%m-%y_%H:%M:%S")
    resp = client.get(f'check_new_emails/{currTime}')
    assert resp.status_code == 200

def test_store_email_document_(client):
    with client.application.app_context():
        store_email_document_helper(1, 1)
        # Verify new email creation
        email = Email.query.filter_by(thread_id = 1).order_by(Email.email_record_id.desc()).first()
        assert email is not None
        assert email.sender_email == client.application.config['BUSINESS_SIDE_EMAIL']
        assert email.sender_name == client.application.config['BUSINESS_SIDE_NAME']
        assert email.is_resolved is False

def test_store_thread_and_document(client):
    data = { 'thread_id' : 1, 'doc_id' : 1 }
    resp = client.post('/store_thread_and_document', json=data)
    assert resp.status_code == 200

def test_get_category_gaps(client):
    resp = client.get('/get_category_gap/1')
    assert resp.status_code == 200
    assert 'count' in resp.get_json()
