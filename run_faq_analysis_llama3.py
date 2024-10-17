from sentence_transformers import SentenceTransformer, util
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from models import FAQS, StagingFAQS  # Assuming your models are in `models.py`

# Load a pre-trained Sentence-BERT model (contextual embeddings)
model = SentenceTransformer('all-MiniLM-L6-v2')  # Fast and lightweight model for sentence similarity

# Connect to the database
DATABASE_URI = 'your_database_uri_here'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()

# Define the similarity threshold (tuneable based on needs)
SIMILARITY_THRESHOLD = 0.85

# Fetch all FAQs from the main `FAQS` table
main_faqs = session.query(FAQS).all()

# Fetch all unprocessed staging FAQs
unprocessed_staging_faqs = session.query(StagingFAQS).filter_by(processed_flag=False).all()

# Convert FAQs to a list of (faq_id, faq_text, frequency)
main_faq_list = [(faq.faq_id, faq.faq, faq.freq) for faq in main_faqs]

# Extract the FAQ text for embedding comparison
main_faq_texts = [faq_text for _, faq_text, _ in main_faq_list]

# Encode all main FAQ texts to embeddings (this is efficient since we're encoding all FAQs at once)
main_faq_embeddings = model.encode(main_faq_texts, convert_to_tensor=True)

# Process each unprocessed FAQ from staging
for staging_faq in unprocessed_staging_faqs:
    unprocessed_faq_text = staging_faq.faq
    
    # Encode the unprocessed FAQ into an embedding
    unprocessed_faq_embedding = model.encode(unprocessed_faq_text, convert_to_tensor=True)

    # Compute cosine similarities between the unprocessed FAQ and all main FAQs
    similarities = util.cos_sim(unprocessed_faq_embedding, main_faq_embeddings)
    
    # Find the index of the closest FAQ based on cosine similarity
    best_match_idx = similarities.argmax().item()
    best_similarity_score = similarities[0][best_match_idx].item()
    
    if best_similarity_score >= SIMILARITY_THRESHOLD:
        # If a similar FAQ is found, increment the `freq` of the matched FAQ
        best_match_faq_id = main_faq_list[best_match_idx][0]
        best_match_faq = session.query(FAQS).filter_by(faq_id=best_match_faq_id).first()
        
        if best_match_faq:
            best_match_faq.freq += 1  # Increment the frequency
            print(f"FAQ '{unprocessed_faq_text}' matched '{best_match_faq.faq}' "
                  f"(similarity: {best_similarity_score:.2f}). Incrementing count.")
    else:
        # If no similar FAQ is found, add the unprocessed FAQ as a new entry
        new_faq = FAQS(faq=unprocessed_faq_text, freq=1, category_id=1)  # Adjust `category_id` as necessary
        session.add(new_faq)
        print(f"FAQ '{unprocessed_faq_text}' is new. Adding it to the FAQ list with count 1.")

    # Mark the staging FAQ as processed
    staging_faq.processed_flag = True

# Commit the changes to the database
session.commit()

# Close the session after processing
session.close()
