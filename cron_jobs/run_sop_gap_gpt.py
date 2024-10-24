from sqlalchemy.ext.declarative import declarative_base
import schedule
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, Text, TIMESTAMP, ForeignKey, func, LargeBinary, Boolean, CheckConstraint, Enum
from sqlalchemy.orm import sessionmaker
import time
import re
import json
from PyPDF2 import PdfReader
import io
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_openai import ChatOpenAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
import os
from dotenv import load_dotenv

load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

Base = declarative_base()
class SOPDocument(Base):
    __tablename__ = 'sop_document'
    doc_id = Column(Integer, primary_key=True)
    doc_content = Column(LargeBinary, nullable=False)
    doc_timestamp = Column(TIMESTAMP, default=func.now()) 

class FAQS(Base):
    __tablename__ = 'faqs'
    faq_id = Column(Integer, primary_key=True, autoincrement=True)
    faq = Column(Text, nullable=False)
    freq = Column(Integer, nullable=False, default=0)
    created_at = Column(TIMESTAMP , default = func.now())
    updated_at = Column(TIMESTAMP , default = func.now(), onupdate=func.now())
    __table_args__ = (
        CheckConstraint('freq >= 0', name='chk_positive'),
    )

class StagingFAQS(Base):
    __tablename__ = 'staging_faqs'
    staging_faq_id = Column(Integer, primary_key=True, autoincrement=True)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    faq = Column(Text, nullable=False)
    processed_flag = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())

class SOPGapCoverage(Base):
    __tablename__ = 'sop_gap_coverage'
    coverage_id = Column(Integer, primary_key=True)
    faq_id = Column(Integer, ForeignKey('faqs.faq_id'), nullable=False)
    sop_doc_id = Column(Integer, ForeignKey('sop_document.doc_id'), nullable=False)
    gap_type = Column(Enum('Fully Covered', 'Partially Covered', 'Inaccurately Covered', 'Ambiguously Covered', 'Not Covered', name='gap_category'), nullable=False)
    created_at = Column(TIMESTAMP , default = func.now())
    updated_at = Column(TIMESTAMP , default = func.now(), onupdate = func.now())

text_splitter = RecursiveCharacterTextSplitter(
    separators=['\n\n', '\n', '.', ','],
    chunk_size=750,
    chunk_overlap=50)

embeddings = OpenAIEmbeddings()
llm = ChatOpenAI(model="gpt-4", temperature=0.5, max_tokens=1000)

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
        sop_document = session.query(SOPDocument).filter_by(doc_id=doc_id).one()
        if sop_document == None:
            return ""
        pdf_file = io.BytesIO(sop_document.doc_content)
        reader = PdfReader(pdf_file)
        pdf_content = " ".join([page.extract_text() for page in reader.pages])
        return pdf_content
    except Exception as e:
        print ("exception happend",e)
        return None

def analyze_coverage_for_FAQ(mainFaq, doc_content):
    text_chunks = text_splitter.split_text(doc_content)
    vector_store = FAISS.from_texts(text_chunks, embedding=embeddings)
    qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 3})  # Increased k for broader search
    )
    jsonFormat = "{ coverage_type: \"Coverage Type\", \"reason\": \"Reason for the coverage percentage\" }"

    prompt = f"""
    You are an assistant checking SOP compliance.
    Please evaluate how much of the following question is covered by the SOP and provide a detailed reason for your assessment.
    Inquiry: "{mainFaq.faq}"
    
    Your answer must include a coverage type (Fully Covered, Partially Covered, Ambiguously Covered, 
                                              Not Covered) followed by a detailed explanation of why you assigned this score.
    For example:
    - If it's Fully Covered, explain why.
    - If it's Partially Covered, mention what's missing.
    - If it's Ambiguously Covered, explain the gaps.
    - If it's Not Covered, mention why the question is out of context.
        Give me the response in json in this format: {jsonFormat} and nothing else.
    """
    answer = qa.run(prompt)
    print ("answer",answer)
    jsonRes = get_string_between_braces(answer)
    encodedJson = json.loads(jsonRes)
    print ("encodedJson",encodedJson)
    if (not jsonRes):
        return
    coverageType = encodedJson['coverage_type']
    if (not coverageType):
        print ("coverage type is wrong", coverageType)
        return
    sopGapCoverage = SOPGapCoverage(
                faq_id = mainFaq.faq_id
              , sop_doc_id = 1 # Always 1 by default
              , gap_type = coverageType
            )
    session.add(sopGapCoverage)
    session.commit()  
    
def run_gap_coverage_analysis():
    mainFaqs = session.query(FAQS).all()
    doc_content = get_pdf_content_by_doc_id(1)
    for mainFaq in mainFaqs:
        analyze_coverage_for_FAQ(mainFaq, doc_content)  # Passing doc_id = 1 by default

def job():
    print(f"Running gap coverage analysis by gpt at {datetime.now()}")
    run_gap_coverage_analysis()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)
