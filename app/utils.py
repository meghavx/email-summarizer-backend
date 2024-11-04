from .llm.llama_ai_functions import llama_get_summary_response, llam_get_answer_from_email
from .llm.gpt_ai_functions import get_answer_from_email, get_summary_response
from .models import SOPDocument
from pypdf import PdfReader
from io import BytesIO

BUSINESS_SIDE_NAME = "Support Team"
BUSINESS_SIDE_EMAIL = "support@business.com"
AI_MODEL = "llama"  # Use either "gpt" or "llama".

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

def get_pdf_content_by_doc_id(doc_id: int):
    try:
        sop_document = SOPDocument.query.filter_by(doc_id=doc_id).one()
        if sop_document == None:
            raise Exception("Document not found :(")
        pdf_file = BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception as e:
        print ("Exception occurred during extracting pdf: ", e)
        return None

def getCustomerNameAndEmail(emails):
    for email in emails:
        # If email receiver is not the business itself then it must be the customer
        if not BUSINESS_SIDE_EMAIL in email.receiver_email.lower():
            return email.receiver_name, email.receiver_email
    return "user", "user@abc.com"

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


def sortEmails(emailList, sortOrder):
    return sorted(emailList, key=lambda email: email.email_received_at, reverse = not sortOrder)
