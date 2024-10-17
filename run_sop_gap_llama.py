from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, LargeBinary
from sqlalchemy.orm import sessionmaker
import time
import ollama
import re
import json
from PyPDF2 import PdfReader
import io

Base = declarative_base()
class SOPDocument(Base):
    __tablename__ = 'sop_document'
    doc_id = Column(Integer, primary_key=True)
    doc_content = Column(LargeBinary, nullable=False)
    doc_timestamp = Column(TIMESTAMP, default=func.now()) 

class FAQS(Base):
    __tablename__ = 'faqs'
    faq_id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(Integer, ForeignKey('query_categories.category_id'), nullable=False)
    faq = Column(Text, nullable=False)
    freq = Column(Integer, nullable=False, default=0)
    created_at = Column(TIMESTAMP , default = func.now())
    updated_at = Column(TIMESTAMP , default = func.now(), onupdate=func.now())
    __table_args__ = (
        CheckConstraint('freq >= 0', name='chk_positive'),
    )

DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

def get_string_between_braces(text):
    match = re.search(r'\{.*?\}', text)
    if match:
        return match.group()  # Return the matched string
    return None  # Return None if no match is found

def get_pdf_content_by_doc_id(doc_id):
    try:
        sop_document = SOPDocument.query.filter_by(doc_id=doc_id).one()
        if sop_document == None:
            return ""
        pdf_file = io.BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception:
        return None

def analyze_coverage_for_FAQ(mainFaq, doc_content):
    jsonFormat = "{ coverage_type : \"TYPE\", \"reason\": \"Reason for the coverage type\" }"
    prompt = f"""
        You are given a Frequently asked question by the customer to customer support:
	{mainFaq.faq}
 is below SOP document content strictly enough to answer the FAQ? Keep in mind the follwing points:
 1. Remeber to only decide based on the below content. 
 2. If you think the instructions are not specific, then put it under Ambiguously Covered.
 3. Don't decide based on implications. If something is not covered directly, mention it as not covered.
	{doc_content}
Answer it in one of the Type:
	 'Fully Covered',
  'Partially Covered',
  'Inaccurately Covered',
  'Ambiguously Covered',
  'Not Covered'
Give me the response in json in this format:
	{jsonFormat} and nothing else
    """
    res = ollama.generate(model = 'llama3.2', prompt = prompt)
    print ("res",res['response'])
    jsonRes = get_string_between_braces(res['response'])
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    """
    stageFaq = StagingFAQS(
                thread_id = thread.thread_id
              , faq = encodedJson['faq']
            )
    print (res['response'])
    session.add(stageFaq)
    session.commit()  
    """
    
def run_gap_coverage_analysis():
    mainFaqs = session.query(FAQS).all()
    doc_content = get_pdf_content_by_doc_id(1)
    for mainFaq in mainFaqs:
        analyze_coverage_for_FAQ(mainFaq, doc_content)  # Passing doc_id = 1 by default

def job():
    print(f"Running gap coverage analysis at {datetime.now()}")
    run_gap_coverage_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)
