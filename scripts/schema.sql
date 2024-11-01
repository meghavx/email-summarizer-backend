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

INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12361, '2024-08-19 10:30:00', 'Damaged Product Shipment',
   'Dear Support Team,

I am writing to report that a recent shipment of Product A (Order ID: 123456) arrived with several damaged units. Upon inspection, we found that 10 units were damaged beyond repair.

Attached are photos of the damaged goods, as well as a copy of the delivery receipt.

Please advise on the next steps to resolve this issue. We would like to request a replacement for the damaged units.

Thank you for your prompt attention to this matter.

Best regards,
     Alice Smith'),

  ('support@business.com', 'Support Team', 'customer8@example.com', 'Alice Smith', 12361, '2024-08-19 11:00:00', 'Damaged Product Shipment',
   'Dear Alice Smith,

Thank you for reporting the damaged goods in your recent shipment of Product A. We apologize for any inconvenience this may have caused.

We will initiate a claim process to resolve this issue promptly. Please provide any additional information or documentation that may be helpful, such as the original purchase order or packing list.

We will keep you updated on the progress of the claim.

Thank you for your cooperation.

Best regards,
      Support Team'),

  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12361, '2024-08-19 11:30:00', 'Damaged Product Shipment',
   'Dear Support Team,

I have attached the original purchase order and packing list for your reference.

Please let me know if there is any other information you require. I am eager to resolve this issue as soon as possible.

Thank you for your assistance.

Best regards,
      Alice Smith'),

  ('support@business.com', 'Support Team', 'customer8@example.com', 'Alice Smith', 12361, '2024-08-19 12:00:00', 'Damaged Product Shipment',
   'Dear Alice Smith,

We have received your additional documents and are currently processing your claim for the damaged Product A (Order ID: 123456).

We expect to have a resolution for you within 3 business days. We will contact you as soon as possible with the outcome of the claim.

Thank you for your patience and understanding.

Best regards,
      Support Team'),

  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12361, '2024-08-19 12:30:00', 'Damaged Product Shipment',
   'Dear Support Team,

I am following up on my previous email regarding the damaged Product A (Order ID: 123456).

I have not yet received a resolution to my claim. Please let me know the status of my request.

Thank you for your prompt attention to this matter.

Best regards,
    Alice Smith');


INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer7@example.com', 'John Doe', 'support@business.com', 'Support Team', 12377, '2024-08-08 15:30:00', 'Inquiry Regarding Supplier Portal Access',
   'Dear Support Team,

I am writing to inquire about my access to the supplier portal. I have been unable to log in to my account for the past few days.

I have tried resetting my password multiple times, but I keep receiving an error message saying that my credentials are incorrect.

Please let me know if there is anything I can do to resolve this issue. I need to be able to access the portal to track my orders and submit invoices.

Thank you for your assistance.

Best regards,
John Doe'),

  ('support@business.com', 'Support Team', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 16:00:00', 'Inquiry Regarding Supplier Portal Access',
   'Dear John Doe,

Thank you for contacting our support team. We apologize for any inconvenience this may have caused.

We have checked our system and found that there is indeed a temporary issue with the supplier portal. Our IT team is currently working on resolving the problem.

We will notify you as soon as the portal is back up and running. In the meantime, please accept our apologies for any inconvenience this may cause.

Thank you for your understanding.

Best regards,
   Support Team'),

  ('customer7@example.com', 'John Doe', 'support@business.com', 'Support Team', 12377, '2024-08-08 16:30:00', 'Inquiry Regarding Supplier Portal Access',
   'Dear Support Team,

Thank you for your prompt response. I understand that there is a temporary issue with the supplier portal.

I would like to know if there is an estimated time for when the portal will be back up and running. I have several urgent tasks that require access to the portal.

Thank you for your continued assistance.

Best regards,
   John Doe'),

  ('support@business.com', 'Support Team', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 17:00:00', 'Inquiry Regarding Supplier Portal Access',
   'Dear John Doe,

We apologize for the continued inconvenience. Our IT team has made significant progress in resolving the issue with the supplier portal.

We estimate that the portal will be fully functional again within the next 24 hours. We will send out a notification as soon as the issue is completely resolved.

Thank you for your patience and understanding.

Best regards,
   Support Team'),

  ('customer7@example.com', 'John Doe', 'support@business.com', 'Support Team', 12377, '2024-08-08 17:30:00', 'Order Not Delivered On Time',
   'Dear John Doe,

We are pleased to inform you that the supplier portal is now fully functional. You should be able to access your account without any issues.

If you continue to experience any problems, please do not hesitate to contact our support team.

Thank you for your patience and understanding.

Best regards,
   John Doe');
   

INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES   
  ('customer7@example.com', 'David Lee', 'support@business.com', 'Support Team', 12378, '2024-08-08 18:30:00', 'Request for Training on Supplier Portal Features',
   'Dear Support Team,

I would like to request training on the features of the supplier portal. I am new to using this tool and could benefit from a guided session.

Please let me know if there are any available training sessions or if you can provide me with training materials.

Thank you for your assistance.

Best regards,
   David Lee');


INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES 
  ('customer7@example.com', 'John Doe', 'support@business.com', 'Support Team', 12379, '2024-08-08 20:00:00', 'Inquiry Regarding EDI Integration',
   'Dear Support Team,

I am writing to express my extreme frustration with the ongoing issues with our EDI integration. Despite multiple attempts to resolve these problems, we continue to experience significant disruptions in our operations.

The errors we are encountering are causing delays in order processing and fulfillment, which is negatively impacting our business.

I urge you to prioritize this issue and provide a timely resolution.

Thank you for your immediate attention to this matter.

Best regards,
   John Doe'),

  ('support@business.com', 'Support Team', 'customer7@example.com', 'John Doe', 12379, '2024-08-08 21:00:00', 'Inquiry Regarding EDI Integration',
   'Dear John Doe,

We apologize for the ongoing issues with the EDI integration. We understand the impact this is having on your business, and we are working diligently to resolve the problems.

Our IT team is investigating the matter and will provide you with an update as soon as possible.

Thank you for your patience and understanding.

Best regards,
   Support Team'),

  ('customer7@example.com', 'John Doe', 'support@business.com', 'Support Team', 12379, '2024-08-08 22:00:00', 'Inquiry Regarding EDI Integration',
   'Dear Support Team,

I am following up on my previous email regarding the EDI integration issues.

I have not received any updates on the progress of your investigation. This is causing significant disruptions to our business and is unacceptable.

I demand a resolution to these issues immediately.

Thank you for your prompt attention to this matter.

Best regards,
   John Doe'),

  ('support@business.com', 'Support Team', 'customer7@example.com', 'John Doe', 12379, '2024-08-08 22:30:00', 'Inquiry Regarding EDI Integration',
   'Dear John Doe,

We apologize for the continued delay in resolving the EDI integration issues. Our IT team has identified the root cause of the problems and is working on a solution.

We expect to have a resolution within the next 24 hours.

We understand the impact this is having on your business, and we are committed to resolving these issues as quickly as possible.

Thank you for your patience and understanding.

Best regards,
   Support Team');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Reports Balance Issue
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-14 16:30:00', 'Gift Card Balance',
   'Dear Support Team,I am writing to express my frustration regarding my gift card balance, which seems incorrect.'
   || 'Here’s what I have observed:'
   || '- The gift card was for $100.   
   - I have made purchases totaling $30.   
   - My balance should be $70, but it shows $50.'
   || 'This is unacceptable, and I expect a prompt resolution.
   Best regards,
   Alice Smith'),

  -- Support Team Acknowledges Issue
  ('support@business.com', 'Support Team', 'customer6@example.com', 'Alice Smith', 12360, '2024-08-14 17:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for contacting us about your gift card balance. We apologize for any confusion this has caused.'
   || 'To assist you better, please provide the following:'
   || '- The gift card number   
   - Details of recent transactions made with the gift card'
   || 'We appreciate your cooperation and will work to resolve this issue promptly.
   Best regards,
   Support Team'),

  -- Customer Provides Details
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-14 17:30:00', 'Gift Card Balance',
   'Hi Support,I appreciate your quick response. Here are the details you requested:'
   || '- Gift Card Number: 1234-5678-9012   - Recent Transactions:'
   || '- Purchase 1: $20 on August 10'
   || '- Purchase 2: $10 on August 12'
   || 'This should total $30, and I should have a balance of $70. Please investigate this issue further.Thank you! 
   Best,
   Alice Smith'),

  -- Support Team Requests More Information
  ('support@business.com', 'Support Team', 'customer6@example.com', 'Alice Smith', 12360, '2024-08-14 18:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for the information provided.'
   || 'To clarify the situation further, we need:'
   || '- Confirmation of any purchases made outside of this gift card   
   - Screenshots of your balance shown on your account'
   || 'This will help us expedite our investigation. Thank you for your patience!
   Best regards,
   Support Team'),

  -- Customer Provides Additional Information
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-14 18:30:00', 'Gift Card Balance',
   'Hi Support,I do not have any other purchases made outside of this gift card. All transactions were exclusively from it.'
   || 'Attached are the screenshots of my account balance showing $50.'
   || 'I expect this matter to be resolved swiftly, as I rely on this gift card for my purchases.Thank you for your attention!
   Best,
   Alice Smith'),

  -- Support Team Investigates Issue
  ('support@business.com', 'Support Team', 'customer6@example.com', 'Alice Smith', 12360, '2024-08-14 19:00:00', 'Gift Card Balance',
   'Dear Alice,We have received your screenshots and appreciate your detailed response.'
   || 'Our team is currently investigating the discrepancy in your gift card balance. We aim to resolve this issue as quickly as possible.'
   || 'In the meantime, if you have any further questions, please do not hesitate to reach out.
   Best regards,
   Support Team'),

  -- Customer Checks In on Status
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-15 10:00:00', 'Gift Card Balance',
   'Hi Support,I wanted to check in regarding my gift card balance issue. It’s been over a day, and I have yet to receive any updates.'
   || 'As a reminder:   - Gift Card Number: 1234-5678-9012   - Expected Balance: $70'
   || 'I would appreciate any information you have on this matter.Thank you!
   Best,
   Alice Smith'),

  -- Support Team Provides an Update
  ('support@business.com', 'Support Team', 'customer6@example.com', 'Alice Smith', 12360, '2024-08-15 11:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for your patience. We are still investigating your balance discrepancy.'
   || 'To help with the resolution, we are reaching out to our transactions department to verify your activity.'
   || 'We understand this may be frustrating and appreciate your understanding as we work to resolve this matter.
   Best regards,
   Support Team'),

  -- Customer Expresses Continued Concern
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-15 12:00:00', 'Gift Card Balance',
   'Hi Support,I understand these things take time, but I’m becoming increasingly concerned.'
   || 'The gift card is for an upcoming event, and I need to use it soon.'
   || 'Please expedite this process and keep me updated.Thank you!
   Best,
   Alice Smith'),

  -- Support Team Assures Customer
  ('support@business.com', 'Support Team', 'customer6@example.com', 'Alice Smith', 12360, '2024-08-15 12:30:00', 'Gift Card Balance',
   'Dear Alice,We completely understand your concern, and we assure you that we are prioritizing your case.'
   || 'We are in contact with the transactions department and will provide you with an update shortly'
   || 'Thank you for your continued patience.
   Best regards,
   Support Team'),

  -- Customer Responds with Urgency
  ('customer6@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12360, '2024-08-15 13:00:00', 'Gift Card Balance',
   'Hi Support,I really need this sorted out by the end of today.'
   || 'I have made plans to use the gift card, and I can’t do that if the balance is incorrect. Please treat this as urgent!'
   || 'Thank you for your help.
   Best,
   Alice Smith');


 


INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('johndoe@yahoo.com', 'John Doe', 'support@business.com', 'Support Team', 12376, '2024-08-07 09:30:00', 'Contract Renewal for Contract #2357',
   'Dear Support Team,

I am writing to inquire about the renewal of our contract, Contract #2357.

We would like to confirm the terms of our existing agreement and understand the process for renewing the contract.

Please let us know if there are any changes or updates to the contract terms for renewal.

Thank you for your prompt attention to this matter.

Best regards,
   John Doe'),

  ('support@business.com', 'Support Team', 'johndoe@yahoo.com', 'John Doe', 12376, '2024-08-07 10:00:00', 'Contract Renewal for Contract #2357',
   'Dear John Doe,

Thank you for your inquiry regarding the renewal of Contract #2357.

We are currently reviewing your contract and will provide you with an update on the renewal process shortly.

Please note that there may be some changes to the contract terms for renewal, based on our current business needs.

We will keep you informed of any updates.

Thank you for your cooperation.

Best regards,
   Support Team'),

  ('johndoe@yahoo.com', 'John Doe', 'support@business.com', 'Support Team', 12376, '2024-08-07 10:30:00', 'Contract Renewal for Contract #2357',
   'Dear Support Team,

I am following up on my previous email regarding the renewal of Contract #2357.

I have not yet received a response from your team regarding the proposed renewal terms and the next steps.

Please let me know the status of my request.

Thank you for your prompt attention to this matter.

Best regards,
   John Doe');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12375, '2024-08-19 10:30:00', 'Loyalty Program',
   'Dear Support Team,
      I am writing to express my dissatisfaction with your loyalty program. It has been quite underwhelming.'
   || 'Here are my concerns:'
   || '   - Limited rewards compared to competitors   
          - Complicated redemption process   
          - Lack of communication about points expiration'
   || 'I expected much more from a loyalty program. Please address these issues promptly.
     Best regards,
     Alice Smith'),

  ('support@business.com', 'Support Team', 'customer8@example.com', 'Alice Smith', 12375, '2024-08-19 11:00:00', 'Loyalty Program',
   'Dear Alice,
       Thank you for reaching out and sharing your feedback regarding our loyalty program. We apologize for any inconvenience you have faced.'
   || 'We value your opinion and are currently reviewing the loyalty program to enhance our customer experience.'
   || 'Your concerns are important to us, and we will keep you updated on any improvements.
      Best regards,
      Support Team'),

  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12375, '2024-08-19 11:30:00', 'Loyalty Program',
   'Hi Support,
       Thank you for acknowledging my concerns. However, I would like to see specific changes:'
   || '   - Increase in reward points for purchases   
          - Easier redemption options   
          - Regular updates on loyalty status'
   || 'If these changes are not made soon, I may reconsider my loyalty to your brand.
      Thank you,
      Alice Smith'),

  ('support@business.com', 'Support Team', 'customer8@example.com', 'Alice Smith', 12375, '2024-08-19 12:00:00', 'Loyalty Program',
   'Dear Alice,
      We appreciate your suggestions for improving our loyalty program. To better understand customer needs, we are planning to conduct a survey.'
   || 'We would love your participation in this survey to gather more insights. Your feedback will directly influence our program enhancements.'
   || 'Thank you for your continued feedback.
      Best regards,
      Support Team'),

  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12375, '2024-08-19 12:30:00', 'Loyalty Program',
   'Hi Support,
       While I appreciate the offer to participate in a survey, I am skeptical about whether any real changes will come from it.'
   || 'I have seen similar surveys in the past without any follow-up. Please assure me that this feedback will be taken seriously.'
   || 'Looking forward to your response,
    Alice Smith'),

  ('support@business.com', 'Support Team', 'customer8@example.com', 'Alice Smith', 12375, '2024-08-19 14:00:00', 'Loyalty Program',
   'Dear Alice,
      Thank you for your patience. We aim to implement key changes to the loyalty program by September 15, 2024'
   || 'We will communicate the specific enhancements through our website and email.'
   || 'We appreciate your feedback and look forward to improving your experience.
   Best regards,
   Support Team'),

  ('customer8@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12375, '2024-08-19 15:30:00', 'Loyalty Program',
   'Hi Support,
   I have completed the survey and provided my honest feedback. I hope it contributes to meaningful changes.'
   || 'Please keep me updated on any decisions made based on this feedback.
   Thank you,
   Alice Smith');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Initiates Exchange Request
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-05 16:50:00', 'Exchange Process',
   'Dear Support Team,I am reaching out to request an exchange for an item I purchased recently (Order #456123).'
   || 'The product arrived faulty, and I’m quite disappointed as I was looking forward to using it. Here are the details:'
   || '- Item: Bluetooth Headphones   - Issue: Not charging'
   || 'Please let me know how to proceed with the exchange process.
   Thank you,
   John Doe'),

  -- Support Team Acknowledges Request
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 17:00:00', 'Exchange Process',
   'Dear John,Thank you for contacting us regarding your exchange request for Order #456123.'
   || 'We apologize for the inconvenience caused by the faulty product. To assist you better, please provide us with the following:'
   || '- Photo of the defective item   - Any additional comments regarding the issue'
   || 'Once we receive this information, we will initiate the exchange process.
   Best regards,
   Support Team'),

  -- Customer Provides Details for Exchange
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-05 17:15:00', 'Exchange Process',
   'Hi Support,Thank you for your quick response! I’ve attached a photo of the faulty Bluetooth headphones for your review.'
   || 'I would appreciate a swift resolution, as I was looking forward to using them during my travels next week.'
   || 'Thank you for your assistance!
   Best,
   John Doe'),

  -- Support Team Reviews Details
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 17:30:00', 'Exchange Process',
   'Dear John,We have received the photo and your comments. Thank you for providing this information.'
   || 'We will initiate the exchange process immediately. Here’s what will happen next:'
   || '- We will send you a prepaid shipping label to return the faulty item.  - Once we receive the item, we will ship the replacement to you.'
   || 'Thank you for your patience in this matter.
   Best regards,
   Support Team'),

  -- Customer Requests Shipping Label
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-05 18:00:00', 'Exchange Process',
   'Hi Support,I appreciate your assistance. When can I expect to receive the prepaid shipping label to return the faulty headphones?'
   || 'I want to ensure that the replacement arrives before my travels next week.
   Thank you,
   John Doe'),

  -- Support Team Sends Shipping Label
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 18:15:00', 'Exchange Process',
   'Dear John,Attached to this email, you will find the prepaid shipping label for returning the faulty Bluetooth headphones.'
   || 'Please follow these steps to return the item:'
   || '1. Print the attached label.   2. Pack the item securely.   3. Affix the label to the package.   4. Drop it off at the nearest shipping location.'
   || 'Once we receive the item, we will expedite the shipment of your replacement.
   Best regards,
   Support Team'),

  -- Customer Confirms Shipment
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-06 09:00:00', 'Exchange Process',
   'Hi Support,I have shipped the faulty headphones using the label you provided. I will send you the tracking number shortly.'
   || 'Thank you for your help in this process!
   Best,
   John Doe'),

  -- Support Team Acknowledges Shipment
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-06 09:30:00', 'Exchange Process',
   'Dear John,Thank you for confirming the shipment of the faulty headphones. Please share the tracking number so we can monitor the return.'
   || 'As soon as we receive the item, we will dispatch your replacement. Thank you for your cooperation!
   Best regards,
   Support Team'),

  -- Customer Provides Tracking Information
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-06 10:00:00', 'Exchange Process',
   'Hi Support,Here’s the tracking number for the return shipment: TRACK123456.'
   || 'I appreciate your quick responses throughout this process.
   Thank you,
   John Doe'),

  -- Support Team Confirms Receipt of Return
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-06 10:30:00', 'Exchange Process',
   'Dear John,We have received the return shipment and are currently processing your exchange request.'
   || 'Your replacement Bluetooth headphones will be shipped within the next 2-3 business days.Thank you for your patience!
   Best regards,
   Support Team'),

  -- Customer Inquires About Replacement Shipment
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-08 11:00:00', 'Exchange Process',
   'Hi Support,I wanted to follow up on my exchange request. When can I expect the replacement headphones to be shipped?'
   || 'I appreciate your help with this matter.
   Thank you,
   John Doe'),

  -- Support Team Provides Shipping Update
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-08 11:30:00', 'Exchange Process',
   'Dear John,Your replacement Bluetooth headphones are scheduled to ship by the end of today.'
   || 'You will receive a confirmation email with tracking information as soon as they are on their way to you.'
   || 'Thank you for your continued patience!
   Best regards,
   Support Team'),

  -- Customer Receives Confirmation of Replacement Shipment
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-09 09:00:00', 'Exchange Process',
   'Hi Support,I just received the email confirming that my replacement headphones have been shipped. Thank you for resolving this issue!'
   || 'I look forward to receiving them soon.
   Best,
   John Doe'),

  -- Support Team Acknowledges Final Steps
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-09 09:30:00', 'Exchange Process',
   'Dear John,We are glad to hear that your replacement headphones are on the way!'
   || 'If you have any further questions or concerns, feel free to reach out. We are here to help!
   Best regards,
   Support Team'),

  -- Customer Expresses Gratitude
  ('customer3@example.com', 'John Doe', 'support@business.com', 'Support Team', 12374, '2024-08-09 10:00:00', 'Exchange Process',
   'Hi Support,I wanted to take a moment to thank you for your help throughout this process. I really appreciate your support in resolving my issue.'
   || 'Looking forward to receiving the replacement headphones!
   Best,
   John Doe'),

  -- Support Team Thanks Customer
  ('support@business.com', 'Support Team', 'customer3@example.com', 'John Doe', 12374, '2024-08-09 10:30:00', 'Exchange Process',
   'Dear John,Thank you for your kind words! We strive to provide the best support possible.'
   || 'If you have any more questions in the future, please don’t hesitate to reach out.
   Best regards,
   Support Team');






INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Initial Request from Customer
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-04 14:10:00', 'Request for Order Cancellation',
   'Dear Support Team,I am writing to request the cancellation of my recent order (#789456). '
   || 'I made the order just two days ago, but due to unforeseen circumstances, I no longer need the items.'
   || 'Please confirm the cancellation and any steps I need to follow.
   Thank you,
   Alice Smith'),

  -- Support Team Acknowledges Request
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-04 14:15:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for reaching out. We understand your request for cancellation of order #789456.'
   || 'To ensure we handle this promptly, could you please confirm the following?   
   - Order Number   
   - Reason for Cancellation'
   || 'Once we receive this information, we will process your cancellation right away.
   Best regards,
   Support Team'),

  -- Customer Clarifies Cancellation Details
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-04 14:20:00', 'Request for Order Cancellation',
   'Hi Support,Thank you for your prompt response. Here are the details you requested:'
   || '- Order Number: #789456   
   - Reason: Change of mind due to personal reasons.'
   || 'I appreciate your help in processing this cancellation quickly.
   Best,
   Alice Smith'),

  -- Support Team Confirms Cancellation Process
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-04 14:30:00', 'Request for Order Cancellation',
   'Dear Alice,We have received your cancellation request and the details provided. '
   || 'Your order (#789456) is currently being processed for cancellation. We expect it to be finalized within the next 24 hours.'
   || 'Thank you for your patience during this process.
   Best regards,
   Support Team'),

  -- Customer Checks on Cancellation Status
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-05 10:05:00', 'Request for Order Cancellation',
   'Hi Support,I wanted to follow up on my cancellation request for order #789456. It has been over 24 hours, and I haven’t received a confirmation yet.'
   || 'Could you please provide me with an update? I would like to ensure everything is on track.
   Thank you,
   Alice Smith'),

  -- Support Team Apologizes for Delay
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-05 10:30:00', 'Request for Order Cancellation',
   'Dear Alice,We apologize for the delay in confirming your cancellation. There was a temporary system glitch, but we have resolved it now.'
   || 'I’m pleased to inform you that your order (#789456) has been successfully canceled. You should receive a confirmation email shortly.'
   || 'Thank you for your understanding, and we appreciate your patience.
   Best regards,
   Support Team'),

  -- Customer Acknowledges Cancellation
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-05 11:00:00', 'Request for Order Cancellation',
   'Hi,Thank you for the quick resolution! I received the cancellation confirmation, and I appreciate your prompt assistance in this matter.'
   || 'I’ll consider shopping with you again in the future based on how efficiently this was handled.
   Best,
   Alice Smith'),

  -- Support Team Thanks Customer
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-05 11:15:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your understanding and kind words! We strive to provide the best service possible.'
   || 'If you have any further questions or need assistance with anything else, please feel free to reach out.
   Best regards,
   Support Team'),

  -- Customer Inquires About Future Orders
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-06 09:30:00', 'Request for Order Cancellation',
   'Hi Support,I have another question regarding future orders. I’m considering placing a new order soon but would like to know if you have any promotions available right now.'
   || 'Thank you for your help!
   Best,
   Alice Smith'),

  -- Support Team Responds with Promotions
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-06 10:00:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your interest in placing a new order! Currently, we have several promotions running:'
   || '- 10% off on your first order   - Free shipping on orders over $50   - Buy one get one 50% off on selected items'
   || 'We’d love to assist you with your next purchase!
   Best regards,
   Support Team'),

  -- Customer Expresses Interest in Promotion
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-06 11:30:00', 'Request for Order Cancellation',
   'Hi Support,Thank you for sharing the promotions! I’m interested in the buy one get one 50% off offer.'
   || 'I’d like to know which items are eligible and if I can combine this with the free shipping offer as well.
   Best,
   Alice Smith'),

  -- Support Team Clarifies Promotion Details
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-06 12:00:00', 'Request for Order Cancellation',
   'Dear Alice,I’m glad to hear you’re interested in our promotions! The eligible items for the buy one get one 50% off offer are:'
   || ' - Item A   || - Item B  || - Item C'
   || 'Yes, you can absolutely combine this offer with free shipping on orders over $50.'
   || 'If you need any further assistance or wish to place your order, please let me know!
   Best regards,
   Support Team'),

  -- Customer Places New Order
  ('customer2@example.com', 'Alice Smith', 'support@business.com', 'Support Team', 12373, '2024-08-07 14:00:00', 'Request for Order Cancellation',
   'Hi Support,I’d like to proceed with placing a new order including Item A and Item B. '
   || 'Please apply the buy one get one 50% off promotion along with the free shipping offer to my order.'
   || 'Thank you for all your assistance! Looking forward to your confirmation.
   Best,
   Alice Smith'),

  -- Support Team Confirms New Order
  ('support@business.com', 'Support Team', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-07 14:30:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your order! We have successfully placed your order for Item A and Item B with the applied promotions.'
   || 'Order Summary:  
    - Item A: $5.0  
     - Item B: $3.8   
     - Discount: 50%  
     - Shipping: Free'
   || 'Your order will be shipped within the next 2-3 business days, and you will receive a confirmation email shortly.'
   || 'We appreciate your business and look forward to serving you again!
   Best regards,
   Support Team');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer2@example.com', 'Sarah Lee', 'support@business.com', 'Support Team', 12372, '2024-08-26 15:00:00', 'Product Inquiry: New Collection Availability',
   'Hi,I’ve recently come across your website and saw some items from your new collection that I’m interested in. '
   || 'Could you provide more details about the availability of the following items:'
   || '- Leather Jacket (SKU: LJ1001)'
   || '- High-waisted Jeans (SKU: HJ2003)'
   || 'I’d also like to know if these items are available in different sizes and colors.'
   || 'Looking forward to your reply.
   Best regards,
   Sarah Lee'),

  ('support@business.com', 'Support Team', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 15:45:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,Thank you for your inquiry about our new collection! We’re excited that you’ve found some items that you’re interested in.'
   || 'Regarding the items you mentioned:'
   || '- The Leather Jacket (SKU: LJ1001) is currently available in sizes S, M, and L, and comes in black and brown.'
   || '- The High-waisted Jeans (SKU: HJ2003) are available in sizes 26 to 32, and they come in light and dark blue.'
   || 'Let us know if you would like us to reserve these items for you, or if you have any other questions.'
   || 'Best regards,
   Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@business.com', 'Support Team', 12372, '2024-08-26 16:30:00', 'Product Inquiry: New Collection Availability',
   'Hello,Thank you for the quick response. I’d like to proceed with the following:'
   || '- Leather Jacket (Size: M, Color: Black)'
   || '- High-waisted Jeans (Size: 28, Color: Dark Blue)'
   || 'Could you also let me know if you offer free shipping on these items?'
   || 'Thanks again for your help.
   Best regards,
   Sarah Lee'),

  ('support@business.com', 'Support Team', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 17:15:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’re glad to hear that you’re interested in proceeding with the order! Here’s what we can confirm:'
   || '- The Leather Jacket (Size: M, Color: Black) is reserved for you.'
   || '- The High-waisted Jeans (Size: 28, Color: Dark Blue) are also available and reserved.'
   || 'Regarding shipping, we offer free standard shipping for orders over $100. Since your order qualifies, shipping will be free.'
   || 'Would you like to finalize the order? Once confirmed, we’ll send you the payment link.
   Best regards,
   Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@business.com', 'Support Team', 12372, '2024-08-26 18:00:00', 'Product Inquiry: New Collection Availability',
   'Hi,That’s great news! Yes, please proceed with the order. I’m ready to finalize the payment.'
   || 'Looking forward to receiving the payment link.
   Best regards,
   Sarah Lee'),

  ('support@business.com', 'Support Team', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 18:30:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’re thrilled to finalize your order! Here’s the payment link: [payment-link-here].'
   || 'Once the payment is complete, we’ll process your order immediately and send you a confirmation email with the tracking details.'
   || 'Please feel free to reach out if you need any further assistance.
   Best regards,
   Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@business.com', 'Support Team', 12372, '2024-08-26 19:15:00', 'Product Inquiry: New Collection Availability',
   'Hi,I’ve just completed the payment. Could you confirm that everything went through successfully?'
   || 'Also, could you provide an estimated delivery time? Thanks again!
   Best regards,
   Sarah Lee'),

  ('support@business.com', 'Support Team', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 20:00:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,Thank you for your payment. We’ve received the payment, and your order has been successfully processed.'
   || 'Here’s what you can expect next:'
   || '- Your order will be dispatched within the next 24 hours.'
   || '- You will receive an email with the tracking details once the shipment is on its way.'
   || 'Standard shipping takes 3-5 business days, so you can expect to receive your items soon.'
   || 'Best regards,
   Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@business.com', 'Support Team', 12372, '2024-08-27 10:15:00', 'Product Inquiry: New Collection Availability',
   'Hi,Thanks for the update. I’m excited to receive my order! Could you let me know if I can make any changes to the delivery address before it ships?'
   || 'Just in case, here’s the current address I’d like it shipped to:'
   || '- 123 Park Avenue, Suite 500'
   || '- New York, NY 10001'
   || 'Thanks again for your help!
   Best regards,
   Sarah Lee'),

  ('support@business.com', 'Support Team', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-27 11:00:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’ve updated your shipping address as requested.');




INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('emily.green@gmail.com', 'Emily Green', 'support@business.com', 'Support Team', 12358, '2024-08-26 15:00:00', 'Inquiry Regarding In-Store Merchandising Guidelines',
   'Dear Support Team,

I am writing to inquire about the specific guidelines for in-store merchandising of our products.

We would like to ensure that our products are displayed in a manner that maximizes visibility and aligns with your company''s branding standards.

Could you please provide us with a detailed outline of the guidelines, including information on display standards, end cap placement, and signage requirements?

Thank you for your assistance.

Best regards,
Emily Green');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Initial Inquiry from Customer
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-02 11:35:00', 'Order Delayed',
   'Hi Support Team,I noticed that my order has not yet been delivered, even though it was supposed to arrive two days ago. '
   || 'Could you please provide an update on the delivery status? The order number is #456789.'
   || 'I’d appreciate any information you can share regarding the current status.
   Thank you,
   John Doe'),

  -- Support Team's Initial Response
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-02 12:00:00', 'Order Delayed',
   'Dear John,Thank you for reaching out regarding your order. We apologize for the delay and are currently investigating the issue.'
   || 'We’ll update you as soon as we receive more information from our shipping partner.We appreciate your patience.
   Best regards,
   Support Team'),

  -- Customer Follow-Up Inquiry
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-03 10:00:00', 'Order Delayed',
   'Hi,I haven’t received an update on my order yet. Could you provide a more concrete timeline? '
   || 'It’s been almost a week now since the original delivery date, and I’m getting concerned.'
   || 'Please expedite the process or offer an alternative solution.
   Thank you,
   John Doe'),

  -- Support Team Delay Notification
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-03 12:15:00', 'Order Delayed',
   'Dear John,We apologize for the inconvenience. Our shipping partner has reported some logistical delays due to unforeseen circumstances.'
   || 'We are working to ensure that your order is prioritized for delivery. The estimated delivery time is now extended by 3-5 business days.'
   || 'If there is anything else we can do to assist you, please let us know.
   Best regards,
   Support Team'),

  -- Customer Expresses Frustration
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-04 09:30:00', 'Order Delayed',
   'Hi Support,This is becoming really frustrating. A delay of 3-5 business days is unacceptable, especially since I wasn’t informed earlier. '
   || 'I expect much better communication and service from a company like yours.'
   || 'If my order isn’t delivered by the end of this week, I’ll be forced to escalate this issue.'
   || 'I hope you understand my position and can ensure timely action.
   John Doe'),

  -- Support Team's Apology and Offer
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-04 11:00:00', 'Order Delayed',
   'Dear John,We sincerely apologize for the inconvenience caused by this delay. 
   We understand your frustration and assure you that we are doing everything in our power to resolve this matter.'
   || 'As a gesture of goodwill, we would like to offer you a 15% discount on your current order or on a future purchase. '
   || 'We’ll continue to monitor your shipment closely and keep you updated.Thank you for your understanding.
   Best regards,
   Support Team'),

  -- Customer Escalates the Issue
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-04 16:30:00', 'Order Delayed',
   'Hi,While I appreciate the discount offer, it doesn’t change the fact that I’m still without my order. This has gone beyond just a delay. '
   || 'The lack of communication until I reached out and the continuing delays have been extremely frustrating.'
   || 'I will be sharing my experience publicly if this isn’t resolved in the next 48 hours. Additionally, I expect full compensation for the inconvenience caused.'
   || 'Please escalate this issue to your manager.John Doe'),

  -- Support Team Escalates to Management
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-05 09:15:00', 'Order Delayed',
   'Dear John,We understand your frustration and sincerely apologize once again for the delay. '
   || 'We have escalated this issue to our management team and are expediting the delivery process as a priority.'
   || 'Our team will update you within the next 24 hours regarding the status of your shipment.'
   || 'We greatly appreciate your patience and apologize for the inconvenience caused.
   Best regards,
   Support Team'),

  -- Customer Expresses Discontent
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-05 10:45:00', 'Order Delayed',
   'Hi,This situation is completely unacceptable. I expected better from a company like yours. '
   || 'The escalation and “priority delivery” don’t seem to be making any difference. '
   || 'If I don’t receive my order by the end of the day tomorrow, I will be requesting a full refund, and I will never shop with your company again.'
   || 'Your company’s handling of this situation has been nothing short of disappointing.
   John Doe'),

  -- Support Team's Final Apology and Resolution
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-05 13:30:00', 'Order Delayed',
   'Dear John,We are deeply sorry for the ongoing issues with your order. After further escalation, we have confirmed that your shipment will be delivered within the next 24 hours.'
   || 'As a token of our sincere apologies, we are offering you a full refund along with the delivery of your order. '
   || 'We hope this helps to rectify the inconvenience caused, and we will also be offering an additional 25% discount on your next purchase if you choose to shop with us again.'
   || 'Once again, we apologize for the frustration and inconvenience this has caused.
   Best regards,
   Support Team'),

  -- Customer Acknowledges Apology but Maintains Discontent
  ('customer1@example.com', 'John Doe', 'support@business.com', 'Support Team', 12371, '2024-08-05 15:00:00', 'Order Delayed',
   'Hi,Thank you for the update, but I still find it disappointing that it took this long for a resolution. I’ll accept the refund and the delivery of my order, '
   || 'but I hope your company learns from this situation and handles future delays with better communication.'
   || 'I’ll consider the discount offer, but my confidence in your service has taken a significant hit.
   John Doe'),

  -- Support Team's Final Follow-Up
  ('support@business.com', 'Support Team', 'customer1@example.com', 'John Doe', 12371, '2024-08-06 09:30:00', 'Order Delayed',
   'Dear John,We fully understand your concerns, and we are taking your feedback very seriously. '
   || 'Our team is reviewing the entire process to ensure that such delays are communicated more effectively in the future.'
   || 'We appreciate your understanding and hope to regain your trust in the future. 
   If there is anything else we can do to assist, please don’t hesitate to reach out.
   Best regards,
   Support Team');


INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES 
  ('ethan.turner@example.com', 'support@business.com', 12345, '2024-09-23 08:00:00', 'Product Inquiry', 
  'Dear Support Team,

I hope this message finds you well. I am interested in learning more about the features your product offers. Could you kindly provide more information?

Thank you for your time and assistance.

Best regards,
Ethan Turner', 
  'Ethan Turner', 'Support Team'),

  ('support@business.com', 'ethan.turner@example.com', 12345, '2024-09-23 09:00:00', 'Product Inquiry', 
  'Hello Ethan,

Thank you for reaching out to us. We appreciate your interest in our products. Our product line includes a variety of features designed to meet your needs. Please let us know if you have any specific requirements.

Looking forward to your response.

Best regards,
Support Team', 
  'Support Team', 'Ethan Turner'),

  ('ethan.turner@example.com', 'support@business.com', 12345, '2024-09-23 10:00:00', 'Product Inquiry', 
  'Hi Support Team,

Thank you for the quick response. Could you also provide a detailed comparison of your product with similar products on the market?

I look forward to your insights.

Best regards,
Ethan Turner', 
  'Ethan Turner', 'Support Team'),

  ('support@business.com', 'ethan.turner@example.com', 12345, '2024-09-23 11:00:00', 'Product Inquiry', 
  'Hi Ethan,

Certainly! Here is a detailed comparison of our product with our competitors. We believe our product stands out due to its user-friendly interface and comprehensive support.

Please review the attached details.

Best regards,
Support Team', 
  'Support Team', 'Ethan Turner'),

  ('ethan.turner@example.com', 'support@business.com', 12345, '2024-09-23 12:00:00', 'Product Inquiry', 
  'Hello again,

One more question—do you offer any discounts for bulk purchases? We are considering a large order if the pricing works for us.

Thank you in advance.

Best,
Ethan Turner', 
  'Ethan Turner', 'Support Team'),

  ('support@business.com', 'ethan.turner@example.com', 12345, '2024-09-23 13:00:00', 'Product Inquiry', 
  'Hi Ethan,

Yes, we do offer discounts for bulk purchases. Please provide your requirements, and we will be happy to assist with a tailored offer.

Kind regards,
Support Team', 
  'Support Team', 'Ethan Turner'),

  ('ethan.turner@example.com', 'support@business.com', 12345, '2024-09-23 14:00:00', 'Product Inquiry', 
  'Hi Support Team,

Can you also confirm the warranty period for your products?

Best regards,
Ethan Turner', 
  'Ethan Turner', 'Support Team'),

  ('support@business.com', 'ethan.turner@example.com', 12345, '2024-09-23 15:00:00', 'Product Inquiry', 
  'Hello Ethan,

Our products come with a one-year warranty. Please feel free to reach out if you need more information.

Best regards,
Support Team', 
  'Support Team', 'Ethan Turner'),

  ('ethan.turner@example.com', 'support@business.com', 12345, '2024-09-23 16:00:00', 'Product Inquiry', 
  'Hi Support Team,

Lastly, I wanted to ask if you offer any trial period for the product before making a purchase.

Thank you for your help.

Best,
Ethan Turner', 
  'Ethan Turner', 'Support Team'),

  ('support@business.com', 'ethan.turner@example.com', 12345, '2024-09-23 17:00:00', 'Product Inquiry', 
  'Hi Ethan,

Unfortunately, we do not offer a trial period. However, we do have a return policy if the product does not meet your expectations. Please let us know if you have any further questions.

Thank you for considering our product.

Best regards,
Support Team', 
  'Support Team', 'Ethan Turner');
  

INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES 
  ('olivia.johnson@example.com', 'support@business.com', 12346, '2024-09-24 08:00:00', 'Notice of Discontinuation for Product XYZ', 
   'Dear Support Team,

I am writing to inform you of our decision to discontinue Product XYZ from your store.

We kindly request that you remove this product from your product catalog and refrain from placing any further purchase orders.

We will work with your team to manage any existing inventory and explore options for clearing remaining stock.

Thank you for your understanding and cooperation.

Best regards,
Olivia Johnson', 
   'Olivia Johnson', 'Support Team'),

  ('support@business.com', 'olivia.johnson@example.com', 12346, '2024-09-24 09:00:00', 'Notice of Discontinuation for Product XYZ', 
   'Dear Olivia Johnson,

Thank you for your notification regarding the discontinuation of Product XYZ.

We will update our product catalog to reflect this change and ensure that no further purchase orders are placed.

We will be in touch with you shortly to discuss options for managing the existing inventory.

Thank you for your cooperation.

Best regards,
Support Team', 
   'Support Team', 'Olivia Johnson'),

  ('olivia.johnson@example.com', 'support@business.com', 12346, '2024-09-24 10:00:00', 'Notice of Discontinuation for Product XYZ', 
   'Dear Support Team,

I am following up on our previous email regarding the discontinuation of Product XYZ.

I would like to discuss options for managing the remaining inventory. We are open to exploring sales promotions, returns, or buy-back agreements.

Please let me know if you have any suggestions or recommendations.

Thank you for your prompt attention to this matter.

Best regards,
Olivia Johnson', 
   'Olivia Johnson', 'Support Team');

INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES 
  ('mary.jones@example.com', 'support@business.com', 12347, '2024-09-25 08:00:00', 'Price Proposal for Organic Apples', 
  'Dear Support Team,

I am writing to submit my price proposal for Organic Apples.

The proposed wholesale price is 

$1.50 per unit, and the suggested retail price (SRP) is $2.50 per unit.

I believe these prices are competitive and will provide a profitable margin for both our companies.

Please let me know if you have any questions or require further information.

Thank you for your time and consideration.

Best regards,
Mary Jones', 
  'Mary Jones', 'Support Team'),
  ('support@business.com', 'mary.jones@example.com', 12347, '2024-09-25 09:00:00', 'Price Proposal for Organic Apples', 
  'Dear Mary Jones,

Thank you for submitting your price proposal for Organic Apples. We will review your proposal and provide feedback on the proposed wholesale and retail prices.

Please note that our pricing review process takes into account market competitiveness, profitability, and retail price consistency.

We will be in touch with you shortly regarding the outcome of our review.

Thank you for your cooperation.

Best regards,
Support Team', 
  'Support Team', 'Mary Jones');


INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES
  ('support@business.com', 'mary.jones@example.com', 12349, '2024-09-25 10:00:00', 'Price Proposal Feedback', 
  'Dear Mary Jones,

We have reviewed your price proposal for Organic Apples. While we appreciate your proposed prices, we believe that the SRP could be slightly higher to ensure profitability for our retail partners.

We recommend increasing the SRP to $2.75. This will allow for a healthy margin while still maintaining a competitive price.

Please let us know if you are able to adjust the SRP to the recommended level.

Thank you for your understanding.

Best regards,
Support Team', 
  'Support Team', 'Mary Jones'),
  ('mary.jones@example.com', 'support@business.com', 12349, '2024-09-25 10:00:00', 'Price Proposal Feedback', 
  'Dear Support Team,

Thank you for your feedback on the price proposal for Organic Apples.

We are able to adjust the SRP to the recommended level of 

$2.75.

Please confirm that this revised SRP is acceptable.

Thank you for your understanding and cooperation.

Best regards,
Mary Jones', 
  'Mary Jones', 'Support Team'),
  ('support@business.com', 'mary.jones@example.com', 12349, '2024-09-25 11:00:00', 'Price Proposal Feedback', 
  'Dear Mary Jones,

We are pleased to confirm that your revised price proposal for Organic Apples has been approved.

The approved wholesale price is $1.50 per unit, and the approved SRP is $2.75 per unit.

Thank you for your cooperation.

Best regards,
Support Team', 
  'Support Team', 'Mary Jones'),
  ('mary.jones@example.com', 'support@business.com', 12349, '2024-09-25 12:00:00', 'Price Proposal Feedback', 
  'Dear Support Team,

I am writing to request a price adjustment for Organic Apples. Due to increased transportation costs, we need to increase the wholesale price to 

$1.75.

Please let me know if this price adjustment is acceptable.

Thank you for your understanding.

Best regards,
Mary Jones', 
  'Mary Jones', 'Support Team'),
  ('support@business.com', 'mary.jones@example.com', 12349, '2024-09-25 13:00:00', 'Price Proposal Feedback', 
  'Dear Mary Jones,

Thank you for your request for a price adjustment for Organic Apples. We will review your request and provide feedback on the proposed price increase.

Please note that any price adjustments are subject to our approval process. We will let you know if the requested price increase is approved.

Thank you for your understanding.

Best regards,
Support Team', 
  'Support Team', 'Mary Jones');

INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES 
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 08:00:00', 'Vendor Onboarding Application', 
  'Dear Support Team,

I am writing to submit my vendor application for Big Mart. I am interested in supplying Organic Apples to your store.

Please find attached my completed application, which includes my business history, references, product portfolio, and certifications.

I look forward to hearing from you regarding the next steps in the onboarding process.

Thank you for your time and consideration.

Best regards,
Emily Davis', 
  'Emily Davis', 'Support Team'),
  ('support@business.com', 'emily.davis@example.com', 12348, '2024-09-26 09:00:00', 'Vendor Onboarding Application', 
  'Dear Emily Davis,

Thank you for submitting your vendor application. We have received your application and will review it thoroughly.

We will be in touch with you shortly regarding the status of your application and any additional information that may be required.

Thank you for your interest in partnering with Big Mart.

Best regards,
Support Team', 
  'Support Team', 'Emily Davis'),
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 10:00:00', 'Vendor Onboarding Application', 
  'Dear Emily Davis,

Thank you for your patience as we review your vendor application.

We would like to request some additional documentation to complete our review. Please provide copies of the following:

    -Business license
    -Organic certification
    -Liability insurance certificate (minimum coverage of $1,000,000)
    -Tax documentation (W-9 or equivalent)
    -Banking details (Bank name: XYZ Bank, Account number: 1234567890)

Thank you for your cooperation.

Best regards,
Support Team', 
  'Emily Davis', 'Support Team'),
  ('support@business.com', 'emily.davis@example.com', 12348, '2024-09-26 11:00:00', 'Vendor Onboarding Application', 
  'Dear Support Team,

I have attached the requested documentation to this email. Please let me know if you require any further information.

Thank you for your prompt attention to this matter.

Best regards,
Emily Davis', 
  'Support Team', 'Emily Davis'),
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 12:00:00', 'Vendor Onboarding Application', 
  'Dear Emily Davis,

We are pleased to inform you that your vendor application has been approved.

Your unique Vendor ID is 

VENDOR1234. Please use this ID for all future transactions with Big Mart.

We look forward to a successful partnership.

Best regards,
Support Team', 
  'Emily Davis', 'Support Team');

  
 INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES  
  ('mary.jones@example.com', 'support@business.com', 12359, '2024-09-27 08:00:00', 'Request for Volume Discount', 
  'Dear Support Team,

I am writing to request a volume discount for Organic Apples. We are planning to increase our orders for this product and would like to explore the possibility of a discount.

Please let me know if you are able to offer a volume discount for larger orders.

Thank you for your consideration.

Best regards,
Mary Jones', 
'Mary Jones', 'Support Team'),
  ('support@business.com', 'mary.jones@example.com', 12359, '2024-09-27 09:00:00', 'Request for Volume Discount', 
  'Dear Mary Jones,

Thank you for your request for a volume discount for Organic Apples. We are happy to offer a volume discount for larger orders.

For orders of 1000 units or more, we will offer a discount of 10%.

Please let us know if you have any further questions.

Thank you for your cooperation.

Best regards,
Support Team', 
  'Support Team', 'Mary Jones'),
  ('mary.jones@example.com', 'support@business.com', 12359, '2024-09-28 08:00:00', 'Request for Volume Discount', 
  'Dear Support Team,

I am following up on my previous email regarding the volume discount for Organic Apples. I am disappointed that the discount offered is only 10%.

I believe that for the volume of orders we are planning to place, a higher discount is justified.

I would like to request a reconsideration of the discount offered.

Thank you for your attention to this matter.

Best regards,
Mary Jones', 
'Mary Jones', 'Support Team');
  
INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  sender_name,
  receiver_name
)
VALUES 
  ('support@business.com', 'charles.white@example.com', 12350, '2024-09-28 09:00:00', 'Quality Issue with Order #AB123', 
  'Dear Charles White,

We are writing to inform you of a quality issue with Order #AB123. Upon inspection, we found that 10 units of Bananas are defective.

Attached are photos of the defective units.

Please investigate this matter and provide us with a corrective action plan (CAP) within 5 business days. The CAP should outline how you will address this issue, including whether you will replace the defective units or provide a credit.

Thank you for your prompt attention to this matter.

Best regards,
Support Team', 
  'Support Team', 'Charles White'),
  ('charles.white@example.com', 'support@business.com', 12350, '2024-09-28 10:00:00', 'Quality Issue with Order #AB123', 
  'Dear Support Team,

Thank you for bringing this to our attention. We apologize for the quality issue with Order #AB123.

We have initiated an investigation into the matter and will provide you with a corrective action plan within 3 business days.

We will replace the defective 10 units with new, undamaged ones.

Thank you for your understanding.

Best regards,
Charles White', 
  'Charles White', 'Support Team'),
  ('charles.white@example.com', 'support@business.com', 12350, '2024-09-28 12:00:00', 'Quality Issue with Order #AB123', 
  'Dear Support Team,

As promised, we are providing you with the corrective action plan for Order #AB123.

We will ship replacement units for the defective 10 units within 2 business days. We have identified the root cause of the issue and have implemented measures to prevent similar occurrences in the future.

Please let us know if you have any further questions or require additional information.

Thank you for your cooperation.

Best regards,
Charles White', 
  'Charles White', 'Support Team'),
  ('support@business.com', 'charles.white@example.com', 12350, '2024-09-28 13:00:00', 'Quality Issue with Order #AB123', 
  'Dear Charles White,

Thank you for providing the corrective action plan for Order #AB123.

We appreciate your prompt response and your commitment to resolving this issue.

We look forward to receiving the replacement units within the specified time frame.

Thank you for your cooperation.

Best regards,
Support Team', 
  'Support Team', 'Charles White');


INSERT INTO emails ( 
  sender_email,
  sender_name,
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content, 
  receiver_email,
  receiver_name
)
VALUES 
  ('noahmartinez@example.com', 'Noah Martinez', 12369, '2024-09-27 00:30:00', 'Product return', 'Dear Support Team,

I hope this message finds you well. I would like to initiate a return for the product I bought. Unfortunately, it did not meet my expectations. Please let me know the steps I need to follow to return it.

Thank you for your assistance.

Best regards,
Noah Martinez', 'support@business.com', 'Support Team'),
  ('support@business.com', 'Support Team', 12369, '2024-09-27 01:00:00', 'Product return', 'Hi Noah,

Thank you for reaching out. We can assist you with the return process. Could you please provide us with your order number so we can expedite the procedure?

Looking forward to your reply.

Warm regards,
Support Team', 'noahmartinez@example.com', 'Noah Martinez'),
  ('noahmartinez@example.com', 'Noah Martinez', 12369, '2024-09-27 01:30:00', 'Product return', 'Hi,

I really do not have time for this. Just take it back and process my refund as soon as possible!

Thanks,
Noah', 'support@business.com', 'Support Team'),  
  ('support@business.com', 'Support Team', 12369, '2024-09-27 02:00:00', 'Product return', 'Hello Noah,

We appreciate your feedback. Once we receive the product, we will process your return immediately. Thank you for your patience!

Best,
Support Team', 'noahmartinez@example.com', 'Noah Martinez'),  
  ('support@business.com', 'Support Team', 12363, '2024-09-26 13:30:00', 'Product defect', 'Hi Susan,

We are truly sorry for the inconvenience this has caused you. Please return the defective product, and we will send you a replacement right away.

Thank you for your understanding.

Best regards,
Support Team', 'susanwilliams@example.com', 'Susan Williams'),  
  ('susanwilliams@example.com', 'Susan Williams', 12363, '2024-09-26 14:00:00', 'Product defect', 'Dear Support Team,

I understand that you have a return policy, but I simply do not have time to return this item. I would prefer a refund instead.

Thank you.

Sincerely,
Susan', 'support@business.com', 'Support Team'),
  ('support@business.com', 'Support Team', 12363, '2024-09-26 14:30:00', 'Product defect', 'Hi Susan,

We understand your situation and can issue a refund once the product is returned. Please let us know if you need any further assistance.

Regards,
Support Team', 'susanwilliams@example.com', 'Susan Williams'),
  ('oliviajohnson@example.com', 'Olivia Johnson', 12365, '2024-09-26 16:30:00', 'Order cancellation', 'Dear Support Team,

I hope this email finds you well. I would like to cancel my order placed last week. Please confirm once this has been processed.

Thank you for your prompt attention to this matter.

Best wishes,
Olivia Johnson', 'support@business.com', 'Support Team'), 
  ('support@business.com', 'Support Team', 12365, '2024-09-26 17:00:00', 'Order cancellation', 'Hi Olivia,

Thank you for contacting us. We can assist you with the cancellation of your order. Please confirm your request so we can proceed.

Kind regards,
Support Team', 'oliviajohnson@example.com', 'Olivia Johnson'),
  ('oliviajohnson@example.com', 'Olivia Johnson', 12365, '2024-09-26 17:30:00', 'Order cancellation', 'Hi there,

Cancel it immediately! I am very frustrated with the service I received.

Thanks,
Olivia', 'support@business.com', 'Support Team'),
  ('support@business.com', 'Support Team', 12365, '2024-09-26 18:00:00', 'Order cancellation', 'Dear Olivia,

We are processing your cancellation request now. Thank you for your patience during this process.

Best regards,
Support Team', 'oliviajohnson@example.com', 'Olivia Johnson');

INSERT INTO emails ( 
  sender_email,
  receiver_email,
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('support@business.com', 'alex.brown(@example.com', 12364, '2024-09-30 09:00:00', 'Feedback Request for Your Recent Purchase',
  'Hi Alex,

We hope you are enjoying your recent purchase! We would love to hear your feedback to help us improve our products and services. Your input is invaluable to us.

Thank you for taking the time to help us out!

Best regards,
Support Team',
  'Support Team', 'Alex Brown'),
  
  ('support@business.com', 'alex.brown@example.com', 12364, '2024-09-30 09:30:00', 'Feedback Request for Your Recent Purchase',
  'Hi Alex,

We noticed we haven''t received your feedback yet. If you could take a moment to share your thoughts, we would greatly appreciate it! Your feedback makes a significant difference in our efforts to serve you better.

Thanks in advance!

Kind regards,
Support Team',
  'Support Team', 'Alex Brown'),
  
  ('alex.brown@example.com', 'support@business.com', 12364, '2024-09-30 10:00:00', 'Feedback Request for Your Recent Purchase',
  'Dear Support Team,

Honestly, I don''t have time for this feedback nonsense! If you keep bothering me for my opinion, I swear I will stop buying your products altogether!

Regards,
Alex Brown',
  'Alex Brown', 'Support Team'),
  
  ('support@business.com', 'alex.brown@example.com', 12364, '2024-09-30 10:30:00', 'Feedback Request for Your Recent Purchase',
  'Hi Alex,

We sincerely apologize if we have inconvenienced you. Your feedback is important to us, but we understand if you prefer not to respond. Please feel free to reach out if you have any other concerns.

Thank you for your understanding.

Best,
Support Team',
  'Support Team', 'Alex Brown'),
  
  ('alex.brown@example.com', 'support@business.com', 12364, '2024-09-30 11:00:00', 'Feedback Request for Your Recent Purchase',
  'Hi,

Just leave me alone already! I’ll make my own decisions about your products without your constant reminders. Stop sending me these requests!

Thanks,
Alex',
  'Alex Brown', 'Support Team'),
  
  ('support@business.com', 'alex.brown@example.com', 12364, '2024-09-30 11:30:00', 'Feedback Request for Your Recent Purchase',
  'Hi Alex,

Thank you for your honest response! We truly apologize for the inconvenience and respect your preferences. If you have any questions or need assistance in the future, please don''t hesitate to reach out. We’re here to help!

Warm regards,
Support Team',
  'Support Team', 'Alex Brown');


INSERT INTO emails ( 
  sender_email,
  receiver_email,
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('rufus.brown@example.com', 'support@business.com', 12355, '2024-10-10 09:00:00', 'Delivery Appointment for Order #78901',
  'Dear Support Team,

I am writing to request a delivery appointment for Order #78901. We would like to schedule the delivery for Thursday, October 24, 2024 at 2:00 PM.

Please confirm this appointment and let us know if there are any available time slots.

Thank you for your prompt attention to this matter.

Best regards,
Rufus Brown',
  'Rufus Brown', 'Support Team'),

('support@business.com', 'rufus.brown@example.com', 12355, '2024-10-10 08:00:00', 'Delivery Appointment for Order #78901',
  'Dear Rufus Brown,

Thank you for your request for a delivery appointment for Order #78901. We have confirmed your appointment for Thursday, October 24, 2024 at 2:00 PM.

Please ensure that you arrive within the specified time slot to avoid any delays.

Thank you for your cooperation.

Best regards,
Support Team',
  'Support Team', 'Rufus Brown');


INSERT INTO emails ( 
  sender_email,
  receiver_email,
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content,
  sender_name,
  receiver_name
)
VALUES  
  ('rufus.brown@example.com', 'support@business.com', 12356, '2024-10-15 09:00:00', 'Request to Reschedule Delivery Appointment',
  'Dear Support Team,

I am writing to request a reschedule of the delivery appointment for Order #78901. Due to unforeseen circumstances, we are unable to meet the scheduled delivery time.

Please let me know if there are any available time slots for a rescheduled delivery.

Thank you for your understanding.

Best regards,
Rufus Brown',
  'Rufus Brown', 'Support Team'),
  
  ('support@business.com', 'rufus.brown@example.com', 12356, '2024-10-16 09:30:00', 'Request to Reschedule Delivery Appointment',
  'Dear Rufus Brown,

We understand your request to reschedule the delivery appointment for Order #78901.

We have checked our available time slots and can accommodate a rescheduled delivery on Friday, October 25, 2024 at 11:00 AM.

Please confirm this revised appointment.

Thank you for your understanding.

Best regards,
Support Team',
  'Support Team', 'Rufus Brown'),
  
  ('rufus.brown@example.com', 'support@business.com', 12356, '2024-10-16 10:00:00', 'Request to Reschedule Delivery Appointment',
  'Dear Support Team,

I am writing to confirm the rescheduled delivery appointment for Order #78901. The new delivery date is Friday, October 25, 2024 at 11:00 AM.

Thank you for your flexibility.

Best regards,
Rufus Brown',
  'Rufus Brown', 'Support Team');
  

INSERT INTO emails ( 
  sender_email,
  receiver_email,
  thread_id, 
  email_received_at, 
  email_subject, 
  email_content,
  sender_name,
  receiver_name
)
VALUES  
  ('rufus.brown@example.com', 'support@business.com', 12357, '2024-10-15 09:00:00', 'Inquiry Regarding Packaging and Labeling Standards',
  'Dear Support Team,

I have a question regarding your packaging and labeling standards for product deliveries.

Could you please provide me with a detailed list of requirements, including specific information on labeling formats, packaging materials, and any regulatory compliance standards that need to be followed?

Thank you for your assistance.

Best regards,
Rufus Brown',
  'Rufus Brown', 'Support Team');


INSERT INTO emails (
  sender_email, 
  receiver_email, 
  thread_id, 
  email_received_at, 
  email_subject,
  email_content,
  sender_name, 
  receiver_name
) VALUES
    ('alex.brown@example.com', 'support@business.com', 12370, '2024-09-30 09:30:00', 'Issue with Product Quality',
    'Dear Support Team,

I hope this message finds you well. I recently purchased your product, but it has not met my expectations. It''s not functioning as advertised, and I need assistance with this matter. Could you please provide guidance on how to resolve this issue?

Thank you for your prompt attention to this matter.

Best regards,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 12370, '2024-09-30 09:45:00', 'Issue with Product Quality',
    'Hi Alex,

Thank you for reaching out. We sincerely apologize for the inconvenience you are facing with our product. Our team is looking into your issue, and we will reach out shortly with a solution or replacement. We appreciate your patience as we work to resolve this matter.

Best wishes,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 12370, '2024-09-30 10:15:00', 'Issue with Product Quality',
    'Dear Support Team,

I appreciate your prompt response, but I need to know how soon I can expect a resolution. This product is critical for my needs, and I am quite frustrated with the situation. I would greatly appreciate any updates you can provide.

Thank you for your assistance.

Sincerely,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 12370, '2024-09-30 10:30:00', 'Issue with Product Quality',
    'Hello Alex,

We understand your frustration, and we are actively working to resolve this issue. Please bear with us as we investigate further. Your satisfaction is our priority, and we are committed to ensuring you have a positive experience with our products.

Warm regards,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 12370, '2024-09-30 11:00:00', 'Issue with Product Quality',
    'Dear Support Team,

I waited for an update, but nothing has changed. I''m really disappointed that a product from your company would have such quality issues. This is unacceptable, and I hope to hear back soon with a viable solution.

Thank you for your attention to this matter.

Regards,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 12370, '2024-09-30 11:15:00', 'Issue with Product Quality',
    'Hi Alex,

We sincerely apologize for the ongoing issues with your product. Our team is prioritizing your case and will ensure you receive a resolution as soon as possible. Please know that we take this matter seriously and appreciate your understanding.

Thank you for your patience.

Best,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 12370, '2024-09-30 11:30:00', 'Issue with Product Quality',
    'Dear Support Team,

This has been a terrible experience. I expected much more from your product and your support team. I can’t believe I wasted my money on this. Please let me know how you plan to address this issue.

I look forward to your prompt response.

Thanks,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 12370, '2024-09-30 11:45:00', 'Issue with Product Quality',
    'Hello Alex,

We apologize for your experience. We take your feedback seriously and will work to improve our product quality. Please let us know if there is anything we can do to regain your trust. Your satisfaction is important to us, and we are here to help.

Best regards,
Support Team',
    'Support Team', 'Alex Brown');

INSERT INTO emails (sender_email, receiver_email, thread_id, email_received_at, email_subject, email_content, sender_name, receiver_name) 
VALUES
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 22:30:00', 'PO Confirmation for Order #12345', 
  'Dear Support Team,

I am writing to confirm receipt of Purchase Order #12345 for [Product Name]. Please confirm receipt of this PO and let me know if there are any questions or concerns.

I would also like to request a delivery date of [Desired Delivery Date]. Please let me know if this is feasible.

Thank you for your prompt attention to this matter.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),
  
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-26 23:00:00', 'PO Confirmation for Order #12345', 
  'Dear Sofia Garcia,

Thank you for your email. We have received Purchase Order #12345 and are processing it.

Regarding your requested delivery date of [Desired Delivery Date], we will do our best to accommodate your request. However, please note that this is subject to availability and our current production schedule. We will let you know if this is feasible.

Thank you for your understanding.

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 23:30:00', 'PO Confirmation for Order #12345', 
  'Dear Support Team,

I am following up on Purchase Order #12345. I have not received a confirmation regarding the delivery date.

Please let me know the status of this order and when I can expect delivery.

Thank you for your prompt attention to t  his matter.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 00:00:00', 'PO Confirmation for Order #12345', 
  'Dear Sofia Garcia,

We apologize for the delay in responding to your email. We are currently experiencing some production delays that are affecting the delivery of your order.

We anticipate a delay of [Number] days. We will keep you updated on the progress of your order and provide you with a revised delivery date as soon as possible.

We apologize for any inconvenience this may cause.

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-27 12:00:00', 'PO Confirmation for Order #12345', 
  'Dear Support Team,

I am writing to express my disappointment with the delay in the delivery of Purchase Order #12345. The delay is causing significant disruptions to our operations.

I would like to request a revised delivery date. Please let me know if there is any possibility of expediting the delivery.

Thank you for your prompt attention to this matter.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 12:15:00', 'PO Confirmation for Order #12345', 
  'Dear Sofia Garcia,

We understand your disappointment with the delay in the delivery of Purchase Order #12345. We are working diligently to resolve the issue and expedite the delivery.

Unfortunately, due to the unforeseen production delays, we are unable to provide a revised delivery date at this time.

We will continue to keep you updated on the progress of your order and provide you with a revised delivery date as soon as possible.

We apologize for any inconvenience this may cause.

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-28 10:00:00', 'PO Confirmation for Order #12345', 
  'Dear Support Team,

Given the ongoing delays and lack of communication regarding Purchase Order #12345, I am requesting to cancel this order.

The delays are causing significant disruptions to our operations, and we can no longer wait for the delivery.

Please confirm the cancellation of this order and provide instructions for returning any prepaid amounts.

Thank you for your prompt attention to this matter.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-28 10:30:00', 'PO Confirmation for Order #12345', 
  'Dear Sofia Garcia,

We understand your decision to cancel Purchase Order #12345. We apologize for any inconvenience this may have caused.

We will process your cancellation request and issue a refund for any prepaid amounts. Please allow [Number] business days for the refund to be processed.

Thank you for your understanding.

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-02 14:00:00', 'PO Confirmation for Order #12345', 
  'Dear Support Team,

I am following up on my previous email regarding the cancellation of Purchase Order #12345.

I have not yet received a confirmation of the cancellation or the refund. Please provide an update on the status of my request.

Thank you for your prompt attention to this matter.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team');


INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('bobby.brown@example.com', 'support@business.com', 12344, '2024-09-30 09:30:00', 'Vendor Portal Access Issue',
  'Dear Support Team,

I am writing to report an issue I am having with accessing the vendor portal. I have been unable to log in to my account for the past two days. I have tried resetting my password multiple times, but I keep receiving an error message saying that my credentials are incorrect.

Please let me know if there is anything I can do to resolve this issue. I need to be able to access the portal to track my orders and submit invoices.

Thank you for your assistance.

Best regards,
Bobby Brown',
  'Bobby Brown', 'Support Team'),
  ('support@business.com', 'bobby.brown@example.com', 12344, '2024-09-30 09:45:00', 'Vendor Portal Access Issue',
  'Hi Bobby,

Thank you for contacting our support team. We apologize for any inconvenience this may have caused.

We have checked our system and found that there is indeed a temporary issue with the vendor portal. Our IT team is currently working on resolving the problem.

We will notify you as soon as the portal is back up and running. In the meantime, please accept our apologies for any inconvenience this may cause.

Thank you for your understanding.

Best regards,
Support Team',
  'Support Team', 'Bobby Brown'),
  ('bobby.brown@example.com', 'support@business.com', 12344, '2024-09-30 10:15:00', 'Vendor Portal Access Issue',
  'Dear Support Team,

Thank you for your prompt response. I understand that there is a temporary issue with the vendor portal.

I would like to know if there is an estimated time for when the portal will be back up and running. I have several urgent tasks that require access to the portal.

Thank you for your continued assistance.

Best regards,
Bobby Brown',
  'Bobby Brown', 'Support Team'),
  ('support@business.com', 'bobby.brown@example.com', 12344, '2024-09-30 10:30:00', 'Vendor Portal Access Issue',
  'Hello Bobby,

We apologize for the continued inconvenience. Our IT team has made significant progress in resolving the issue with the vendor portal.

We estimate that the portal will be fully functional again within the next 24 hours. We will send out a notification as soon as the issue is completely resolved.

Thank you for your patience and understanding.

Best regards,
Support Team',
  'Support Team', 'Bobby Brown');

INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('john.doe@example.com', 'support@business.com', 12362, '2024-09-30 12:20:00', 'Outstanding Support', 
  'Dear Support Team,

I just wanted to express my gratitude for your prompt assistance! I was worried that it might take a while to fix the issue, but your team resolved it faster than I expected.

Your dedication to customer service is top-notch. Thank you once again!

Best regards,
John Doe', 
  'John Doe', 'Support Team'),
  ('support@business.com', 'john.doe@example.com', 12362, '2024-09-30 12:25:00', 'Outstanding Support', 
    'Hello John,

Thank you for your kind words! We appreciate your feedback and are glad we could help. We strive to resolve every issue as quickly as possible. Don’t hesitate to reach out if you need anything else!

Best,
Support Team', 
    'Support Team', 'John Doe');

INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('daniel.james@example.com', 'support@business.com', 12351, '2024-09-30 08:00:00', 'Invoice Submission for Order #12345',
  'Dear Support Team,

I am writing to submit Invoice #INV001 for Order #12345. Please find the attached invoice, which includes all necessary details as per your invoicing guidelines.

I request that you process this invoice as soon as possible.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12351, '2024-09-30 08:15:00', 'Invoice Submission for Order #12345',
  'Dear Daniel James,

Thank you for submitting Invoice #INV001 for Order #12345. We have received your invoice and will process it in accordance with our standard procedures.

Please allow 3 business days for processing. We will notify you once the payment has been issued.

Thank you for your cooperation.

Best regards,
Support Team',
  'Support Team', 'Daniel James');

--12352
INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('daniel.james@example.com', 'support@business.com', 12352, '2024-09-30 09:00:00', 'Inquiry on Late Payment Penalty',
  'Dear Support Team,

I am writing to inquire about the late payment penalty policy. I have not received payment for Invoice #INV001, which was submitted 

10 days ago.

Please let me know if there is a late payment penalty applicable to this invoice.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team');


INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('daniel.james@example.com', 'support@business.com', 12353, '2024-09-24 10:00:00', 'Request for Expedited Payment',
  'Dear Support Team,

I am writing to submit Invoice #INV001 for Order #12345. Please find the attached invoice, which includes all necessary details as per your invoicing guidelines.

I request that you process this invoice as soon as possible.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12353, '2024-09-24 10:15:00', 'Request for Expedited Payment',
  'Dear Daniel James,

Thank you for submitting Invoice #INV001 for Order #12345. We have received your invoice and will process it in accordance with our standard procedures.

Please allow 3 business days for processing. We will notify you once the payment has been issued.

Thank you for your cooperation.

Best regards,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12353, '2024-09-30 11:00:00', 'Request for Expedited Payment',
  'Dear Support Team,

I am following up on my previous request for expedited payment for Invoice #INV002.

I would like to reiterate the urgency of this request. Please let me know if there is any update on the status of my request.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
   ('daniel.james@example.com', 'support@business.com', 12353, '2024-10-02 11:54:00', 'Request for Expedited Payment',
  'Dear Support Team,

I am writing to express my disappointment with the lack of progress on my request for expedited payment for Invoice #INV002.

I have followed up multiple times, but I have not received any updates or a resolution to my request.

I urge you to prioritize this matter and provide me with a timeline for when I can expect payment.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12353, '2024-10-03 10:15:00', 'Request for Expedited Payment',
  'Dear Daniel James,

We apologize for the delay in processing your request for expedited payment for Invoice #INV002. We have prioritized your request and are working to expedite the payment.

We expect to process the payment within 2 business days. We will notify you as soon as the payment has been issued.

We appreciate your patience and understanding.

Best regards,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12353, '2024-10-04 11:00:00', 'Request for Expedited Payment',
  'Dear Support Team,

I would like to thank you for processing my request for expedited payment for Invoice #INV002.

Thank you for your service.

Best regards,
Daniel James',
  'Daniel James', 'Support Team');


INSERT INTO emails (
  sender_email,
  receiver_email,
  thread_id,
  email_received_at,
  email_subject,
  email_content,
  sender_name,
  receiver_name
)
VALUES
  ('daniel.james@example.com', 'support@business.com', 12354, '2024-09-30 11:45:00', 'Request to Update Bank Details',
  'Dear Support Team,

I am writing to request an update to our bank details for future payments. Please find the attached letter authorizing the change.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12354, '2024-09-30 12:00:00', 'Request to Update Bank Details',
  'Dear Daniel James,

Thank you for your request to update your bank details. We have received your letter and will process the change.

Please allow 2 business days for the update to be completed.

Thank you for your cooperation.

Best regards,
Support Team',
  'Support Team', 'Daniel James'),
('daniel.james@example.com', 'support@business.com', 12354, '2024-09-30 11:45:00', 'Request to Update Bank Details',
  'Dear Support Team,

I am following up on my previous email regarding the update of our bank details.

I have not yet received confirmation that the update has been completed. Please let me know the status of this request.

Thank you for your prompt attention to this matter.

Best regards,
Daniel James',
  'Daniel James', 'Support Team');

INSERT INTO threads (thread_id, thread_topic)
  SELECT thread_id, email_subject
  FROM emails
  GROUP BY thread_id, email_subject
  ORDER BY thread_id 
  ON conflict  do nothing;

ALTER TABLE emails
ADD CONSTRAINT emails_fkey
FOREIGN KEY (thread_id)
REFERENCES threads (thread_id);

COMMIT;
