BEGIN;

CREATE TABLE sop_document (
  doc_id SERIAL PRIMARY KEY,
  doc_content BYTEA NOT NULL,
  doc_timestamp TIMESTAMP DEFAULT NOW()
);

CREATE TABLE threads (
  thread_id SERIAL UNIQUE PRIMARY KEY,
  thread_topic VARCHAR(100),
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

CREATE TABLE emails (
  email_record_id SERIAL PRIMARY KEY,
  sender_email VARCHAR(50) NOT NULL,
  sender_name VARCHAR(100),
  receiver_email VARCHAR(50) NOT NULL,
  receiver_name VARCHAR(100),
  thread_id INT NOT NULL,
  email_received_at TIMESTAMP,
  email_subject VARCHAR(100) NOT NULL,
  email_content TEXT NOT NULL,
  is_resolved Boolean DEFAULT true,
  coverage_percentage INT,
  coverage_description text
);

ALTER TABLE emails
ADD CONSTRAINT emails_fkey
FOREIGN KEY (thread_id)
REFERENCES threads (thread_id);

CREATE OR REPLACE FUNCTION update_thread_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE threads
  SET updated_at = NOW()
  WHERE thread_id = NEW.thread_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_thread_timestamp_trigger
AFTER INSERT OR UPDATE ON emails
FOR EACH ROW
EXECUTE FUNCTION update_thread_timestamp();

CREATE TABLE summaries (
  summary_id SERIAL PRIMARY KEY,
  thread_id INTEGER NOT NULL REFERENCES threads (thread_id),
  summary_content TEXT NOT NULL,
  summary_created_at TIMESTAMP DEFAULT NOW(),
  summary_modified_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE SENTIMENT AS ENUM (
  'Critical', 
  'Needs attention',
  'Neutral', 
  'Positive'
);

CREATE TABLE email_thread_sentiment (
  sentiment_id SERIAL PRIMARY KEY,
  thread_id INTEGER NOT NULL REFERENCES threads (thread_id), 
  sentiments sentiment NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE TYPE GAP_CATEGORY AS ENUM (
  'Fully Covered',
  'Partially Covered',
  'Inaccurately Covered',
  'Ambiguously Covered',
  'Not Covered'
);

CREATE TABLE query_categories (
  category_id SERIAL PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL,
  sop_doc_id INTEGER NOT NULL REFERENCES sop_document (doc_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
 
CREATE TABLE faqs (
  faq_id SERIAL PRIMARY KEY, 
  faq TEXT NOT NULL, 
  freq INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_positive CHECK (freq >= 0),
  coverage_percentage Integer,
  coverage_description text,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

CREATE TABLE sop_gap_coverage (
	coverage_id serial4 NOT NULL,
	sop_doc_id int NOT null references sop_document(doc_id) on delete cascade,
	faq_id int not null references faqs(faq_id) on delete  cascade,
	gap_type public."gap_category" NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	updated_at timestamp DEFAULT now() NULL,
	CONSTRAINT sop_gap_coverage_pkey PRIMARY KEY (coverage_id)
);

CREATE TABLE staging_sop_gap_coverage (
  staging_coverage_id SERIAL PRIMARY KEY,
  thread_id INTEGER NOT NULL REFERENCES threads (thread_id),
  sop_doc_id INTEGER NOT NULL REFERENCES sop_document (doc_id),
  category_id INTEGER NOT NULL REFERENCES query_categories (category_id),
  gap_type gap_category NOT NULL,
  processed_flag BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE staging_faqs (
  staging_faq_id SERIAL PRIMARY KEY,
  thread_id INTEGER NOT NULL REFERENCES threads (thread_id),
  faq TEXT NOT NULL,
  coverage_percentage int,
  coverage_description text,
  processed_flag BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TYPE BUCKET_NAME AS ENUM (
  'Excellent Coverage',
  'Good Coverage',
  'Moderate Coverage',
  'Minimal Coverage',
  'Poor Coverage'
);

CREATE TABLE coverage_buckets (
  bucket_id SERIAL PRIMARY KEY,
  bucket_name VARCHAR(256) NOT NULL,
  faq_count INTEGER NOT NULL,
  percentage FLOAT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
	updated_at TIMESTAMP DEFAULT now()
);

COMMIT;