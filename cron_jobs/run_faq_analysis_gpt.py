import schedule
from datetime import datetime
import time
import json
import os
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv
from openai import OpenAI
from pypdf import PdfReader
from io import BytesIO
from models import EmailThread, StagingFAQS, SOPDocument
from utils import session, text_splitter, get_string_between_braces, sortEmails

load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

llm = ChatOpenAI(model="gpt-4", temperature=0.5, max_tokens=1000)

def get_pdf_content_by_doc_id(doc_id: int):
    try:
        sop_document = session.query(SOPDocument).filter_by(doc_id=doc_id).one()
        if sop_document == None:
            raise Exception("Document not found :(")
        pdf_file = BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception as e:
        print ("Exception occurred during extracting pdf: ", e)
        return None

def getDiscussionThread(thread):
    sorted_emails = sortEmails(thread.emails)
    discussion_thread = ""
    for email in sorted_emails:
        sender = email.sender_email
        date = email.email_received_at.strftime('%B %d, %Y %I:%M %p') if email.email_received_at else None
        content = email.email_content
        email_entry = f"From: {sender}\nDate: {date}\nContent: {content}\n\n"
        discussion_thread += email_entry
    return discussion_thread

embeddings = OpenAIEmbeddings()
llm = ChatOpenAI(model="gpt-4", temperature=0.5, max_tokens=1000)
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"),)

def update_staging_faq(thread, doc):
    text_chunks = text_splitter.split_text(doc)
    vector_store = FAISS.from_texts(text_chunks, embedding=embeddings)
    qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 3})  # Increased k for broader search
    )

    discussion_thread = getDiscussionThread(thread)
    json_format = """
        {\"sop_based_email_response\": \"<email response>\" ,
         \"sop_coverage_percentage\": \"<percentage>%\", 
         \"description_for_coverage_percentage\": \"<description>\" , 
        \"FAQ_based_on_email\":\"<A_generalized_FAQ_question_theat_summarizes_email_discussion>\"
         }
        """
    prompt = f"""
    You are a helpful assistant that generates responses based on company SOP guidelines. For the given email discussion:
    - generate a formal and professional response to this email, addressing each point appropriately.
    - Refer yourself as ABC support at the end of the mail.
    - Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    - including step-by-step guidelines, documentation, and any relevant timelines. Don't include the subject line in mail.
    - Do not mention subject in the response!
    - Also generate a percentage for how sufficient is the SOP document to generate an answer. Where 0% = topic not covered at all, 100% = topic is fully covered. 
    - Your output should be a JSON object that matches the following schema:
        {json_format}
    - Make sure it is a valid JSON object.
    - Use \n instead of whitespace or newline.
    - Never return anything other than a JSON object.

    Below are the emails asking about a specific process related to the company SOP.
    Email exchanges: 
    {discussion_thread}
    """
    r = qa.run(prompt)
    print (r)
    jsonRes = get_string_between_braces(r)
    if (not jsonRes):
        return
    try:
        encodedJson = json.loads(jsonRes)
    except Exception as e:
        print ("failed to decode json: ", e)
        return
    if not all(k in encodedJson for k in ("sop_coverage_percentage", "FAQ_based_on_email", "description_for_coverage_percentage")):
        return
    percentage = int(encodedJson['sop_coverage_percentage'].replace('%','').strip())
    stageFaq = StagingFAQS(
                thread_id = thread.thread_id
              , faq = encodedJson['FAQ_based_on_email']
              , coverage_percentage = percentage
              , coverage_description  = encodedJson['description_for_coverage_percentage']
            )
    session.add(stageFaq)
    session.commit()  
    
def run_faq_analysis():
    threads = session.query(EmailThread).all()  # Fetch all threads
    doc = get_pdf_content_by_doc_id(1)
    for thread in threads:
        update_staging_faq(thread, doc) 

def job():
    print(f"Running sentiment analysis at {datetime.now()}")
    run_faq_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for a minute between checks
