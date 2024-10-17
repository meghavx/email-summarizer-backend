
import spacy
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, Column, Integer, String, Text, TIMESTAMP, ForeignKey, func, CheckConstraint, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class EmailThread(Base):
    __tablename__ = 'threads'
    thread_id = Column(Integer, primary_key=True)
    thread_topic = Column(String(100), nullable=False)
    emails = relationship("Email", back_populates="email_thread")

class Email(Base):
    __tablename__ = 'emails'
    email_record_id = Column(Integer, primary_key=True)
    sender_email = Column(String(50), nullable=False)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    email_content = Column(Text, nullable=True)
    email_received_at = Column(TIMESTAMP, nullable=True)
    email_thread = relationship("EmailThread", back_populates="emails")

class FAQS(Base):
    __tablename__ = 'faqs'
    faq_id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(Integer, ForeignKey('query_categories.category_id'), nullable=False)
    faq = Column(Text, nullable=False)
    freq = Column(Integer, nullable=False, default=0)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())
    __table_args__ = (
        CheckConstraint('freq >= 0', name='chk_positive'),
    )

class Category(Base):
    __tablename__ = 'query_categories'
    category_id = Column(Integer, primary_key=True)
    category_name = Column(String(100), nullable=False)
    sop_doc_id = Column(Integer, ForeignKey('sop_document.doc_id'), nullable=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())

class StagingFAQS(Base):
    __tablename__ = 'staging_faqs'
    staging_faq_id = Column(Integer, primary_key=True, autoincrement=True)
    thread_id = Column(Integer, ForeignKey('threads.thread_id'), nullable=False)
    faq = Column(Text, nullable=False)
    processed_flag = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())

# Load spaCy model
nlp = spacy.load("en_core_web_lg")

# Connect to the database
DATABASE_URI = 'postgresql://ruchita:qwerty@localhost:5432/poc'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

# Define the similarity threshold (tuneable based on needs)
SIMILARITY_THRESHOLD = 0.87

# Function to refresh the main FAQ list from the database
def refresh_main_faq_list(session):
    faqs = session.query(FAQS).all()
    return [(faq.faq_id, faq.faq, faq.freq) for faq in faqs]

# Initialize the FAQ list for the first time
main_faq_list = refresh_main_faq_list(session)

# Fetch all unprocessed staging FAQs
unprocessed_staging_faqs = session.query(StagingFAQS).filter_by(processed_flag=False).order_by(StagingFAQS.created_at).all()

# Function to find the closest matching FAQ
def find_closest_faq(unprocessed_faq, main_faqs, model):
    max_similarity = 0
    closest_faq = None
    unprocessed_doc = model(unprocessed_faq)
    
    for faq_id, faq_text, freq in main_faqs:
        main_doc = model(faq_text)
        similarity = unprocessed_doc.similarity(main_doc)
        
        if similarity > max_similarity:
            max_similarity = similarity
            closest_faq = (faq_id, faq_text, freq)

    return closest_faq, max_similarity

# Process each unprocessed FAQ from staging
for staging_faq in unprocessed_staging_faqs:
    unprocessed_faq_text = staging_faq.faq
    closest_faq, similarity = find_closest_faq(unprocessed_faq_text, main_faq_list, nlp)
    
    if closest_faq and similarity >= SIMILARITY_THRESHOLD:
        # If a similar FAQ is found, increment the `freq` of the matched FAQ
        faq_id = closest_faq[0]
        faq_record = session.query(FAQS).filter_by(faq_id=faq_id).first()
        
        if faq_record:
            faq_record.freq += 1  # Increment the frequency
            print(f"FAQ '{unprocessed_faq_text}' matched '{closest_faq[1]}' (similarity: {similarity:.2f}). Incrementing count.")
    else:
        # If no similar FAQ is found, add the unprocessed FAQ as a new entry
        new_faq = FAQS(faq=unprocessed_faq_text, freq=1, category_id=1)  # Adjust `category_id` as necessary
        session.add(new_faq)
        print(f"FAQ '{unprocessed_faq_text}' is new. Adding it to the FAQ list with count 1.")
    
    # Mark the staging FAQ as processed
    staging_faq.processed_flag = True

    # Commit changes and refresh the main FAQ list
    session.commit()
    main_faq_list = refresh_main_faq_list(session)  # Refresh the main FAQ list after each update

# Close the session after processing
session.close()

