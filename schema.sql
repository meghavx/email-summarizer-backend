begin;

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
  is_resolved Boolean DEFAULT true
);

CREATE TABLE threads (
  thread_id serial UNIQUE PRIMARY KEY,
  thread_topic VARCHAR(100),
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

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



--SCRIPT UPDATE [4th Oct 2024]

INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Expresses Frustration with Loyalty Program
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 10:30:00', 'Loyalty Program',
   'Dear Support Team,
      I am writing to express my dissatisfaction with your loyalty program. It has been quite underwhelming.'
   || 'Here are my concerns:'
   || '   - Limited rewards compared to competitors   
          - Complicated redemption process   
          - Lack of communication about points expiration'
   || 'I expected much more from a loyalty program. Please address these issues promptly.
     Best regards,
     Alice Smith'),

  -- Support Team Acknowledges Customer Concerns
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 11:00:00', 'Loyalty Program',
   'Dear Alice,
       Thank you for reaching out and sharing your feedback regarding our loyalty program. We apologize for any inconvenience you have faced.'
   || 'We value your opinion and are currently reviewing the loyalty program to enhance our customer experience.'
   || 'Your concerns are important to us, and we will keep you updated on any improvements.
      Best regards,
      Retail Support Team'),

  -- Customer Requests Specific Changes
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 11:30:00', 'Loyalty Program',
   'Hi Support,
       Thank you for acknowledging my concerns. However, I would like to see specific changes:'
   || '   - Increase in reward points for purchases   
          - Easier redemption options   
          - Regular updates on loyalty status'
   || 'If these changes are not made soon, I may reconsider my loyalty to your brand.
      Thank you,
      Alice Smith'),

  -- Support Team Proposes a Survey
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 12:00:00', 'Loyalty Program',
   'Dear Alice,
      We appreciate your suggestions for improving our loyalty program. To better understand customer needs, we are planning to conduct a survey.'
   || 'We would love your participation in this survey to gather more insights. Your feedback will directly influence our program enhancements.'
   || 'Thank you for your continued feedback.
      Best regards,
      Retail Support Team'),

  -- Customer Expresses Skepticism
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 12:30:00', 'Loyalty Program',
   'Hi Support,
       While I appreciate the offer to participate in a survey, I am skeptical about whether any real changes will come from it.'
   || 'I have seen similar surveys in the past without any follow-up. Please assure me that this feedback will be taken seriously.'
   || 'Looking forward to your response,
    Alice Smith'),

  -- Support Team Addresses Skepticism
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 13:00:00', 'Loyalty Program',
   'Dear Alice,
       We understand your skepticism and want to assure you that your feedback is taken seriously.'
   || 'We are committed to implementing changes based on customer feedback, and we will keep you informed about the progress made.'
   || 'Your input is invaluable, and we hope to regain your trust.
      Best regards,
      Retail Support Team'),

  -- Customer Requests Timelines for Changes
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 13:30:00', 'Loyalty Program',
   'Hi Support,I appreciate your response. However, I need a timeline for when these changes will be made.'
   || 'Specific dates would help me feel more assured that my concerns are being prioritized.'
   || 'Thank you for understanding,
      Alice Smith'),

  -- Support Team Provides Timeline
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 14:00:00', 'Loyalty Program',
   'Dear Alice,
      Thank you for your patience. We aim to implement key changes to the loyalty program by September 15, 2024'
   || 'We will communicate the specific enhancements through our website and email.'
   || 'We appreciate your feedback and look forward to improving your experience.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Hope for Improvements
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 14:30:00', 'Loyalty Program',
   'Hi Support,
   Thank you for the timeline. I am hopeful that the upcoming changes will improve the program.'
   || 'I look forward to seeing how my feedback has influenced your decisions.'
   || 'Best,
        Alice Smith'),

  -- Support Team Sends Survey Link
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 15:00:00', 'Loyalty Program',
   'Dear Alice,We appreciate your engagement in this process. Here is the link to our survey: [Loyalty Program Survey].'
   || 'Your input will be invaluable in shaping our future offerings. Thank you for your continued support.
   Best regards,
   Retail Support Team'),

  -- Customer Completes Survey
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 15:30:00', 'Loyalty Program',
   'Hi Support,
   I have completed the survey and provided my honest feedback. I hope it contributes to meaningful changes.'
   || 'Please keep me updated on any decisions made based on this feedback.
   Thank you,
   Alice Smith'),

  -- Support Team Thanks Customer for Feedback
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 16:00:00', 'Loyalty Program',
   'Dear Alice,
   Thank you for completing the survey. We value your insights and will be reviewing all feedback collected.'
   || 'Your participation is crucial to improving our loyalty program, and we will keep you informed of any updates.'
   || 'Best regards,
   Retail Support Team'),

  -- Customer Seeks Assurance on Changes
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 16:30:00', 'Loyalty Program',
   'Hi Support,
   While I appreciate your acknowledgment, I want assurance that the changes will be significant.'
   || 'I want to see more tangible benefits that reflect my loyalty to your brand.'
   || 'Thank you,
   Alice Smith'),

  -- Support Team Reassures Customer
  ('support@retailer.com', 'Retail Support', 'customer8@example.com', 'Alice Smith', 12388, '2024-08-19 17:00:00', 'Loyalty Program',
   'Dear Alice,
   We understand your desire for tangible changes. We are committed to enhancing the value of our loyalty program based on customer feedback.'
   || 'We will be announcing exciting new benefits on September 15, 2024'
   || 'Thank you for your loyalty and support as we work to improve your experience.
   Best regards,
   Retail Support Team'),

  -- Customer Acknowledges Support's Response
  ('customer8@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12388, '2024-08-19 17:30:00', 'Loyalty Program',
   'Hi Support,
   Thank you for the update. I hope to see substantial changes that reflect our loyalty.'
   || 'I look forward to your announcements on September 15'
   || 'Best,
   Alice Smith');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Reports Delivery Issue
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 15:30:00', 'Order Not Delivered On Time',
   'Dear Support Team,I am writing to express my extreme frustration regarding my recent order that has not been delivered on time.\n\n'
   || 'Order Details:'
   || '   - Order Number: 987654321   - Expected Delivery Date: August 6, 2024   - Current Status: Not Delivered'
   || 'This delay is unacceptable. I expect a prompt response with a resolution.Best regards,John Doe'),

  -- Support Team Acknowledges Delivery Issue
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 16:00:00', 'Order Not Delivered On Time',
   'Dear John,Thank you for reaching out regarding your order. We sincerely apologize for the inconvenience this delay has caused.'
   || 'To assist you further, could you please provide the following:'
   || '   - Confirmation of your shipping address   
          - Any tracking information you may have received'
   || 'We appreciate your patience as we investigate this issue.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Shipping Address
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 16:30:00', 'Order Not Delivered On Time',
   'Hi Support,I appreciate your prompt response, but this situation is still very concerning. Here’s my shipping address:'
   || '   - 123 Elm St, Springfield, IL, 62701'
   || 'I did not receive any tracking information either. This lack of communication is frustrating, and I need a resolution immediately.
   Thank you,
   John Doe'),

  -- Support Team Requests Tracking Information
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 17:00:00', 'Order Not Delivered On Time',
   'Dear John,
   Thank you for confirming your shipping address. We are currently looking into your order status.'
   || 'Unfortunately, we do not have tracking information at the moment, but we are contacting the courier service to get updates.'
   || 'We understand how important this order is to you and will keep you posted on any developments.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Discontent
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 17:30:00', 'Order Not Delivered On Time',
   'Hi Support,This is becoming ridiculous. I expected much better service from your company.'
   || 'The lack of tracking information is unacceptable. I have been left in the dark about my order.'
   || 'Please escalate this issue to a manager and provide me with a detailed update as soon as possible.
   Best,
   John Doe'),

  -- Support Team Escalates Issue
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 18:00:00', 'Order Not Delivered On Time',
   'Dear John,We sincerely apologize for the frustration this situation has caused. We are taking your concerns seriously.'
   || 'Your case has been escalated to our management team, and we are actively working to resolve the delivery issue.'
   || 'We appreciate your patience and will provide updates as soon as we have more information.
   Best regards,
   Retail Support Team'),

  -- Customer Requests Immediate Resolution
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 18:30:00', 'Order Not Delivered On Time',
   'Hi Support,Thank you for escalating the issue. However, I cannot wait any longer.'
   || 'I need an immediate resolution. If my order cannot be delivered today, I expect a full refund.'
   || 'Please understand my frustration as I have made plans based on the expected delivery.
   Best,
   John Doe'),

  -- Support Team Attempts Resolution
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 19:00:00', 'Order Not Delivered On Time',
   'Dear John,We completely understand your urgency, and we are doing everything we can to resolve this situation.'
   || 'We are in contact with our shipping partners and will update you within the next hour.'
   || 'Your satisfaction is our priority, and we will ensure this is handled appropriately.
   Best regards, 
   Retail Support Team'),

  -- Customer Follows Up
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 20:00:00', 'Order Not Delivered On Time',
   'Hi Support,It has been over an hour since your last message. I am still waiting for a resolution.'
   || 'This situation is not acceptable, and I am losing confidence in your service.'
   || 'I expect a timely response with a clear action plan on how you will resolve this issue. 
   Best,
   John Doe'),

  -- Support Team Updates on Investigation
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 21:00:00', 'Order Not Delivered On Time',
   'Dear John,We apologize for the delay in communication. We are still in the process of resolving your delivery issue.'
   || 'We have contacted our courier service and are waiting for a detailed update on your order.'
   || 'We understand your frustration and appreciate your continued patience. We are committed to resolving this. 
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Anger
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 22:00:00', 'Order Not Delivered On Time',
   'Hi Support,I am beyond frustrated at this point. Your responses feel automated and insincere.'
   || 'I expected far more from your company. I will not hesitate to share my experience online if this is not resolved immediately.'
   || 'I expect to hear back from you very soon.
   Best,
   John Doe'),

  -- Support Team Provides Update
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 22:30:00', 'Order Not Delivered On Time',
   'Dear John,We are sincerely sorry for your experience and understand your anger. We take full responsibility for this issue.'
   || 'We have confirmed that your order is delayed due to a shipping error on our end.'
   || 'We are working on correcting this and will ensure your order is delivered by tomorrow at the latest.'
   || 'Thank you for your understanding and patience as we rectify this situation.
   Best regards,
   Retail Support Team'),

  -- Customer Requests Confirmation
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-08 23:00:00', 'Order Not Delivered On Time',
   'Hi Support,I appreciate the update, but I need written confirmation that my order will be delivered by tomorrow.'
   || 'I cannot trust that it will happen without it. Please send me an email confirming this as soon as possible.'
   || 'Thank you,
   John Doe'),

  -- Support Team Confirms Delivery
  ('support@retailer.com', 'Retail Support', 'customer7@example.com', 'John Doe', 12377, '2024-08-08 23:30:00', 'Order Not Delivered On Time',
   'Dear John,We confirm that your order will be delivered by August 9, 2024, before 5 PM'
   || 'We are truly sorry for the inconvenience this has caused you, and we appreciate your understanding as we resolve the issue.'
   || 'If you have any further questions or concerns, please do not hesitate to reach out.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Reluctant Acceptance
  ('customer7@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12377, '2024-08-09 12:00:00', 'Order Not Delivered On Time',
   'Hi Support,Thank you for the confirmation. I hope my order arrives as promised today'
   || 'While I am relieved, I still feel that the entire process has been frustrating. I expect better next time.'
   || '
   Thank you,
   John Doe');




INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Reports Balance Issue
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-14 16:30:00', 'Gift Card Balance',
   'Dear Support Team,I am writing to express my frustration regarding my gift card balance, which seems incorrect.'
   || 'Here’s what I have observed:'
   || '- The gift card was for $100.   
   - I have made purchases totaling $30.   
   - My balance should be $70, but it shows $50.'
   || 'This is unacceptable, and I expect a prompt resolution.
   Best regards,
   Alice Smith'),

  -- Support Team Acknowledges Issue
  ('support@retailer.com', 'Retail Support', 'customer6@example.com', 'Alice Smith', 12383, '2024-08-14 17:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for contacting us about your gift card balance. We apologize for any confusion this has caused.'
   || 'To assist you better, please provide the following:'
   || '- The gift card number   
   - Details of recent transactions made with the gift card'
   || 'We appreciate your cooperation and will work to resolve this issue promptly.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Details
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-14 17:30:00', 'Gift Card Balance',
   'Hi Support,I appreciate your quick response. Here are the details you requested:'
   || '- Gift Card Number: 1234-5678-9012   - Recent Transactions:'
   || '- Purchase 1: $20 on August 10'
   || '- Purchase 2: $10 on August 12'
   || 'This should total $30, and I should have a balance of $70. Please investigate this issue further.Thank you! 
   Best,
   Alice Smith'),

  -- Support Team Requests More Information
  ('support@retailer.com', 'Retail Support', 'customer6@example.com', 'Alice Smith', 12383, '2024-08-14 18:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for the information provided.'
   || 'To clarify the situation further, we need:'
   || '- Confirmation of any purchases made outside of this gift card   
   - Screenshots of your balance shown on your account'
   || 'This will help us expedite our investigation. Thank you for your patience!
   Best regards,
   Retail Support Team'),

  -- Customer Provides Additional Information
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-14 18:30:00', 'Gift Card Balance',
   'Hi Support,I do not have any other purchases made outside of this gift card. All transactions were exclusively from it.'
   || 'Attached are the screenshots of my account balance showing $50.'
   || 'I expect this matter to be resolved swiftly, as I rely on this gift card for my purchases.Thank you for your attention!
   Best,
   Alice Smith'),

  -- Support Team Investigates Issue
  ('support@retailer.com', 'Retail Support', 'customer6@example.com', 'Alice Smith', 12383, '2024-08-14 19:00:00', 'Gift Card Balance',
   'Dear Alice,We have received your screenshots and appreciate your detailed response.'
   || 'Our team is currently investigating the discrepancy in your gift card balance. We aim to resolve this issue as quickly as possible.'
   || 'In the meantime, if you have any further questions, please do not hesitate to reach out.
   Best regards,
   Retail Support Team'),

  -- Customer Checks In on Status
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-15 10:00:00', 'Gift Card Balance',
   'Hi Support,I wanted to check in regarding my gift card balance issue. It’s been over a day, and I have yet to receive any updates.'
   || 'As a reminder:   - Gift Card Number: 1234-5678-9012   - Expected Balance: $70'
   || 'I would appreciate any information you have on this matter.Thank you!
   Best,
   Alice Smith'),

  -- Support Team Provides an Update
  ('support@retailer.com', 'Retail Support', 'customer6@example.com', 'Alice Smith', 12383, '2024-08-15 11:00:00', 'Gift Card Balance',
   'Dear Alice,Thank you for your patience. We are still investigating your balance discrepancy.'
   || 'To help with the resolution, we are reaching out to our transactions department to verify your activity.'
   || 'We understand this may be frustrating and appreciate your understanding as we work to resolve this matter.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Continued Concern
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-15 12:00:00', 'Gift Card Balance',
   'Hi Support,I understand these things take time, but I’m becoming increasingly concerned.'
   || 'The gift card is for an upcoming event, and I need to use it soon.'
   || 'Please expedite this process and keep me updated.Thank you!
   Best,
   Alice Smith'),

  -- Support Team Assures Customer
  ('support@retailer.com', 'Retail Support', 'customer6@example.com', 'Alice Smith', 12383, '2024-08-15 12:30:00', 'Gift Card Balance',
   'Dear Alice,We completely understand your concern, and we assure you that we are prioritizing your case.'
   || 'We are in contact with the transactions department and will provide you with an update shortly'
   || 'Thank you for your continued patience.
   Best regards,
   Retail Support Team'),

  -- Customer Responds with Urgency
  ('customer6@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12383, '2024-08-15 13:00:00', 'Gift Card Balance',
   'Hi Support,I really need this sorted out by the end of today.'
   || 'I have made plans to use the gift card, and I can’t do that if the balance is incorrect. Please treat this as urgent!'
   || 'Thank you for your help.
   Best,
   Alice Smith');


 


INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Reports Damage
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 09:30:00', 'Damaged Product',
   'Dear Support Team,I am writing to report an issue with my recent order (Order #456123), which arrived today and is unfortunately damaged.'
   || 'Here’s what I noticed:'
   || '- The item is scratched all over.   
   - There are noticeable dents on one side.   
   - The packaging was inadequate, with no protective materials inside.'
   || 'I am very disappointed, as I expected better quality. Please let me know how to resolve this issue promptly.
   Best regards,
   John Doe'),

  -- Support Team Acknowledges Report
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-07 10:00:00', 'Damaged Product',
   'Dear John,Thank you for reaching out to us regarding the damage to your order. We apologize for the inconvenience this has caused.'
   || 'To assist you better, could you please provide:'
   || '- Photos of the damage   
   - Details of the packaging condition upon arrival'
   || 'We appreciate your cooperation and will work to resolve this matter quickly.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Damage Details
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 10:30:00', 'Damaged Product',
   'Hi Support,Attached are the photos showing the damages to the product and the poor condition of the packaging.'
   || 'Here’s a brief summary of what I experienced:'
   || '- The item should have been properly packaged to avoid this.   
   - I expect a solution soon as this is unacceptable.'
   || 'Please advise on the next steps.
   Best,
   John Doe'),

  -- Support Team Requests Additional Information
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-07 11:00:00', 'Damaged Product',
   'Dear John,Thank you for the prompt response and for providing the images.'
   || 'We understand your frustration and would like to resolve this issue as quickly as possible.'
   || 'Could you please confirm:'
   || '- The date of purchase   
   - Your preferred resolution (refund or replacement)'
   || 'We look forward to your reply.
   Best regards,
   Retail Support Team'),

  -- Customer Chooses Replacement
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 11:30:00', 'Damaged Product',
   'Hi Support,I purchased the product on August 1, 2024, and I would prefer a replacement.'
   || 'I hope this one will be shipped with better packaging to prevent further damage. I am very frustrated with this experience.'
   || 'Please expedite this process, as I need the product urgently!
   Best,
   John Doe'),

  -- Support Team Confirms Replacement Request
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-07 12:00:00', 'Damaged Product',
   'Dear John,Your request for a replacement has been processed, and we will ensure that it is packaged securely this time.'
   || 'The replacement will ship within 1-2 business days, and we will provide you with tracking information once it’s on its way.'
   || 'Thank you for your patience in this matter. We are here to help!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Continued Frustration
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 12:30:00', 'Damaged Product',
   'Hi Support,I appreciate the quick response, but I must emphasize how dissatisfied I am with this situation.'
   || 'I expect the replacement to be of better quality and that proper packaging will be used. This has been a hassle, and it shouldn’t have been.'
   || 'Please keep me updated on the shipping process. Thank you!
   Best,
   John Doe'),

  -- Support Team Apologizes Again
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-07 13:00:00', 'Damaged Product',
   'Dear John,We sincerely apologize for the inconvenience this has caused you. Your feedback is important to us, and we will use it to improve our service.'
   || 'We will monitor your replacement order closely and ensure that it is shipped correctly this time.'
   || 'Thank you for your understanding.
   Best regards,
   Retail Support Team'),

  -- Customer Inquires About Shipping
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 13:30:00', 'Damaged Product',
   'Hi Support,Can you provide me with a more specific timeline on when I can expect my replacement to ship?'
   || 'I am concerned because of the delays I’ve already faced. It’s critical for me to have this resolved soon.'
   || 'Thank you for your attention to this matter!
   Best,
   John Doe'),

  -- Support Team Provides Shipping Update
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-07 14:00:00', 'Damaged Product',
   'Dear John, We are currently processing your replacement order. It is scheduled to ship on August 9, 2024.'
   || 'Once shipped, you will receive tracking information so you can monitor its progress.'
   || 'We appreciate your patience during this process!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Doubts
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-07 14:30:00', 'Damaged Product',
   'Hi Support,I appreciate the update, but I must say I’m skeptical about the replacement arriving in good condition.'
   || 'Given my recent experience, I’ll be keeping a close eye on the shipment.'
   || 'Let’s hope for the best!
   Best,
   John Doe'),

  -- Support Team Reassures Customer
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-08 09:00:00', 'Damaged Product',
   'Dear John,We understand your skepticism, and we’re committed to ensuring your next experience is better.'
   || 'If there are any issues with the replacement, please reach out immediately. We will take immediate action to resolve any concerns.'
   || 'Thank you for your understanding.
   Best regards,
   Retail Support Team'),

  -- Customer Urges for Resolution
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-08 09:30:00', 'Damaged Product',
   'Hi Support,I just want to emphasize how critical it is for me to receive a product that is in perfect condition.'
   || 'After everything I’ve gone through, I need assurance that this will be resolved without any further issues.'
   || 'Thank you for taking this seriously!
   Best,
   John Doe'),

  -- Support Team Assures Final Checks
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-08 10:00:00', 'Damaged Product',
   'Dear John,We appreciate your patience and assure you that we will conduct a final quality check before shipping your replacement.'
   || 'Our goal is to provide you with a product that meets your expectations, and we’re dedicated to making this right.'
   || 'Thank you for allowing us the opportunity to rectify this situation.
   Best regards,
   Retail Support Team'),

  -- Customer Requests Compensation
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-09 09:15:00', 'Damaged Product',
   'Hi Support,Given the trouble I’ve had with my order, I believe compensation is warranted.'
   || 'I have experienced significant inconvenience, and I expect to be compensated for the damages.'
   || 'Please let me know how you plan to address this.
   Best,
   John Doe'),

  -- Support Team Offers Apology and Compensation
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-09 09:30:00', 'Damaged Product',
   'Dear John,We apologize for the inconvenience caused by the damaged product, and we appreciate your feedback'
   || 'As a gesture of goodwill, we are offering you a 15% discount on your next purchase.'
   || 'We hope this can help to mitigate the frustration you have faced, and we’re here to support you moving forward.
   Best regards,
   Retail Support Team'),

  -- Customer Rejects Offer
  ('customer5@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12376, '2024-08-09 10:00:00', 'Damaged Product',
   'Hi Support,I appreciate the offer, but it doesn’t really compensate for the hassle I have experienced.'
   || 'I just want a product that isn’t damaged, and I expect better service next time.'
   || 'Please ensure this replacement arrives without any issues, or I will have to escalate this further.
   Best,
   John Doe'),

  -- Support Team Final Response
  ('support@retailer.com', 'Retail Support', 'customer5@example.com', 'John Doe', 12376, '2024-08-09 10:30:00', 'Damaged Product',
   'Dear John,We understand your frustration and assure you that we are taking your concerns seriously.'
   || 'Your replacement is our top priority, and we will ensure it is packaged securely. 
       If there are any further issues, please do not hesitate to escalate.'
   || 'Thank you for your continued patience, and we hope to restore your faith in our service.
   Best regards,
   Retail Support Team');




INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Reports Defect
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-06 12:35:00', 'Product Defect',
   'Dear Support Team,I am writing to express my frustration regarding a product I purchased (Order #789654).'
   || 'The item has several defects that have made it unusable, including:'
   || '- Cracked screen   - Faulty battery   - Missing charger'
   || 'I expected better quality, and I’m highly disappointed. Please let me know how to proceed.
   Best,
   Alice Smith'),

  -- Support Team Acknowledges Defect
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-06 12:45:00', 'Product Defect',
   'Dear Alice,Thank you for bringing this to our attention. We apologize for the inconvenience caused by the defective product.'
   || 'To help you resolve this issue, please provide the following details:'
   || ' - Photos of the defects   - Description of the issues'
   || 'We want to ensure you receive a satisfactory resolution.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Details
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-06 13:00:00', 'Product Defect',
   'Hi Support,Here are the requested details for the defective product:'
   || '- Attached photos showing the cracks and defects.   - The product stopped functioning properly within a week of purchase.'
   || 'It’s frustrating to deal with such issues right after purchasing. What are my options for a replacement or refund?
   Best,
   Alice Smith'),

  -- Support Team Requests More Information
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-06 13:30:00', 'Product Defect',
   'Dear Alice,Thank you for the photos and details. We understand your frustration.'
   || 'In order to process your request, could you please confirm the following:'
   || '- Purchase date   - Store or website where it was bought'
   || 'Once we have this information, we will expedite your request.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Purchase Information
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-06 14:00:00', 'Product Defect',
   'Hi Support,I purchased the product on July 25, 2024, from your website.'
   || 'I expected a better experience, especially considering the price I paid. What’s taking so long?'
   || 'Please process my request as soon as possible!
   Best,
   Alice Smith'),

  -- Support Team Apologizes for Delay
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-06 14:30:00', 'Product Defect',
   'Dear Alice,We sincerely apologize for the delay in processing your request. Your concerns are important to us.'
   || 'Here’s what will happen next:'
   || '- We will escalate your case to our quality control team.   - You should receive an update within 48 hours.'
   || 'Thank you for your patience!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Frustration
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-06 15:00:00', 'Product Defect',
   'Hi Support,48 hours for an update? That’s wonderful customer service!'
   || 'In the meantime, here are my thoughts:'
   || '- I can’t believe I have to wait this long for a product I paid good money for.   - Should I just buy another one?'
   || 'This has been quite the experience, but I guess I’m getting used to it!
   Best,
   Alice Smith'),

  -- Support Team Provides Update
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-06 15:30:00', 'Product Defect',
   'Dear Alice,Thank you for your understanding. We have received an update from our quality control team.'
   || 'Unfortunately, the item is classified as defective and is eligible for a refund or exchange. Here’s what we can do:'
   || ' - Full refund to your original payment method.   - Replacement with a new item'
   || 'Please let us know which option you prefer.
   Best regards,
   Retail Support Team'),

  -- Customer Chooses Replacement
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-06 16:00:00', 'Product Defect',
   'Hi Support,I’ll take the replacement, but I must say this process has been exhausting.'
   || 'I hope the new item works as it should because I really don’t want to go through this again.'
   || 'Please expedite the shipping!
   Best,
   Alice Smith'),

  -- Support Team Confirms Replacement Order
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-06 16:30:00', 'Product Defect',
   'Dear Alice,Your replacement has been ordered and is set to ship within 2-3 business days.'
   || 'We’ll send you tracking information as soon as it’s shipped. Thank you for your patience during this process.'
   || 'We value your feedback and hope to provide a better experience next time!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Skepticism
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-07 09:00:00', 'Product Defect',
   'Hi Support,Great, a replacement is on the way!'
   || 'Just to clarify:'
   || '- I hope this one isn’t also defective.   - Should I be prepared for another wait?'
   || 'I’ll keep my fingers crossed, but I’m not holding my breath!
   Best,
   Alice Smith'),

  -- Support Team Provides Assurance
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-07 09:30:00', 'Product Defect',
   'Dear Alice,We assure you that we will closely monitor the replacement process.'
   || 'We are committed to improving our service, and your feedback is invaluable.'
   || 'If you have any further questions or concerns, please reach out anytime.
   Best regards,
   Retail Support Team'),

  -- Customer Comments on Process
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-08 10:00:00', 'Product Defect',
   'Hi Support,Thank you for the reassurance!'
   || 'I’ll say this, though: I never expected to become an expert on product defects.'
   || 'If only there was a certification for it!
   Best,
   Alice Smith'),

  -- Support Team Responds Lightly
  ('support@retailer.com', 'Retail Support', 'customer4@example.com', 'Alice Smith', 12375, '2024-08-08 10:30:00', 'Product Defect',
   'Dear Alice,We appreciate your sense of humor in this situation!'
   || 'Rest assured, we’re doing our best to prevent future defects. Your experience is helping us improve.'
   || 'Thanks for bearing with us!
   Best regards,
   Retail Support Team'),

  -- Customer Final Response with Sarcasm
  ('customer4@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12375, '2024-08-09 11:00:00', 'Product Defect',
   'Hi Support,I received the replacement today, and guess what?'
   || 'It works perfectly! Hooray!'
   || 'I’ll be sure to recommend your store to my friends—just make sure they know about the quality they might get.'
   || 'Thank you for the journey, it was truly enlightening!
   Best,
   Alice Smith');





INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Customer Initiates Exchange Request
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-05 16:50:00', 'Exchange Process',
   'Dear Support Team,I am reaching out to request an exchange for an item I purchased recently (Order #456123).'
   || 'The product arrived faulty, and I’m quite disappointed as I was looking forward to using it. Here are the details:'
   || '- Item: Bluetooth Headphones   - Issue: Not charging'
   || 'Please let me know how to proceed with the exchange process.
   Thank you,
   John Doe'),

  -- Support Team Acknowledges Request
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 17:00:00', 'Exchange Process',
   'Dear John,Thank you for contacting us regarding your exchange request for Order #456123.'
   || 'We apologize for the inconvenience caused by the faulty product. To assist you better, please provide us with the following:'
   || '- Photo of the defective item   - Any additional comments regarding the issue'
   || 'Once we receive this information, we will initiate the exchange process.
   Best regards,
   Retail Support Team'),

  -- Customer Provides Details for Exchange
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-05 17:15:00', 'Exchange Process',
   'Hi Support,Thank you for your quick response! I’ve attached a photo of the faulty Bluetooth headphones for your review.'
   || 'I would appreciate a swift resolution, as I was looking forward to using them during my travels next week.'
   || 'Thank you for your assistance!
   Best,
   John Doe'),

  -- Support Team Reviews Details
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 17:30:00', 'Exchange Process',
   'Dear John,We have received the photo and your comments. Thank you for providing this information.'
   || 'We will initiate the exchange process immediately. Here’s what will happen next:'
   || '- We will send you a prepaid shipping label to return the faulty item.  - Once we receive the item, we will ship the replacement to you.'
   || 'Thank you for your patience in this matter.
   Best regards,
   Retail Support Team'),

  -- Customer Requests Shipping Label
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-05 18:00:00', 'Exchange Process',
   'Hi Support,I appreciate your assistance. When can I expect to receive the prepaid shipping label to return the faulty headphones?'
   || 'I want to ensure that the replacement arrives before my travels next week.
   Thank you,
   John Doe'),

  -- Support Team Sends Shipping Label
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-05 18:15:00', 'Exchange Process',
   'Dear John,Attached to this email, you will find the prepaid shipping label for returning the faulty Bluetooth headphones.'
   || 'Please follow these steps to return the item:'
   || '1. Print the attached label.   2. Pack the item securely.   3. Affix the label to the package.   4. Drop it off at the nearest shipping location.'
   || 'Once we receive the item, we will expedite the shipment of your replacement.
   Best regards,
   Retail Support Team'),

  -- Customer Confirms Shipment
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-06 09:00:00', 'Exchange Process',
   'Hi Support,I have shipped the faulty headphones using the label you provided. I will send you the tracking number shortly.'
   || 'Thank you for your help in this process!
   Best,
   John Doe'),

  -- Support Team Acknowledges Shipment
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-06 09:30:00', 'Exchange Process',
   'Dear John,Thank you for confirming the shipment of the faulty headphones. Please share the tracking number so we can monitor the return.'
   || 'As soon as we receive the item, we will dispatch your replacement. Thank you for your cooperation!
   Best regards,
   Retail Support Team'),

  -- Customer Provides Tracking Information
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-06 10:00:00', 'Exchange Process',
   'Hi Support,Here’s the tracking number for the return shipment: TRACK123456.'
   || 'I appreciate your quick responses throughout this process.
   Thank you,
   John Doe'),

  -- Support Team Confirms Receipt of Return
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-06 10:30:00', 'Exchange Process',
   'Dear John,We have received the return shipment and are currently processing your exchange request.'
   || 'Your replacement Bluetooth headphones will be shipped within the next 2-3 business days.Thank you for your patience!
   Best regards,
   Retail Support Team'),

  -- Customer Inquires About Replacement Shipment
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-08 11:00:00', 'Exchange Process',
   'Hi Support,I wanted to follow up on my exchange request. When can I expect the replacement headphones to be shipped?'
   || 'I appreciate your help with this matter.
   Thank you,
   John Doe'),

  -- Support Team Provides Shipping Update
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-08 11:30:00', 'Exchange Process',
   'Dear John,Your replacement Bluetooth headphones are scheduled to ship by the end of today.'
   || 'You will receive a confirmation email with tracking information as soon as they are on their way to you.'
   || 'Thank you for your continued patience!
   Best regards,
   Retail Support Team'),

  -- Customer Receives Confirmation of Replacement Shipment
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-09 09:00:00', 'Exchange Process',
   'Hi Support,I just received the email confirming that my replacement headphones have been shipped. Thank you for resolving this issue!'
   || 'I look forward to receiving them soon.
   Best,
   John Doe'),

  -- Support Team Acknowledges Final Steps
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-09 09:30:00', 'Exchange Process',
   'Dear John,We are glad to hear that your replacement headphones are on the way!'
   || 'If you have any further questions or concerns, feel free to reach out. We are here to help!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Gratitude
  ('customer3@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12374, '2024-08-09 10:00:00', 'Exchange Process',
   'Hi Support,I wanted to take a moment to thank you for your help throughout this process. I really appreciate your support in resolving my issue.'
   || 'Looking forward to receiving the replacement headphones!
   Best,
   John Doe'),

  -- Support Team Thanks Customer
  ('support@retailer.com', 'Retail Support', 'customer3@example.com', 'John Doe', 12374, '2024-08-09 10:30:00', 'Exchange Process',
   'Dear John,Thank you for your kind words! We strive to provide the best support possible.'
   || 'If you have any more questions in the future, please don’t hesitate to reach out.
   Best regards,
   Retail Support Team');






INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Initial Request from Customer
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-04 14:10:00', 'Request for Order Cancellation',
   'Dear Support Team,I am writing to request the cancellation of my recent order (#789456). '
   || 'I made the order just two days ago, but due to unforeseen circumstances, I no longer need the items.'
   || 'Please confirm the cancellation and any steps I need to follow.
   Thank you,
   Alice Smith'),

  -- Support Team Acknowledges Request
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-04 14:15:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for reaching out. We understand your request for cancellation of order #789456.'
   || 'To ensure we handle this promptly, could you please confirm the following?   
   - Order Number   
   - Reason for Cancellation'
   || 'Once we receive this information, we will process your cancellation right away.
   Best regards,
   Retail Support Team'),

  -- Customer Clarifies Cancellation Details
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-04 14:20:00', 'Request for Order Cancellation',
   'Hi Support,Thank you for your prompt response. Here are the details you requested:'
   || '- Order Number: #789456   
   - Reason: Change of mind due to personal reasons.'
   || 'I appreciate your help in processing this cancellation quickly.
   Best,
   Alice Smith'),

  -- Support Team Confirms Cancellation Process
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-04 14:30:00', 'Request for Order Cancellation',
   'Dear Alice,We have received your cancellation request and the details provided. '
   || 'Your order (#789456) is currently being processed for cancellation. We expect it to be finalized within the next 24 hours.'
   || 'Thank you for your patience during this process.
   Best regards,
   Retail Support Team'),

  -- Customer Checks on Cancellation Status
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-05 10:05:00', 'Request for Order Cancellation',
   'Hi Support,I wanted to follow up on my cancellation request for order #789456. It has been over 24 hours, and I haven’t received a confirmation yet.'
   || 'Could you please provide me with an update? I would like to ensure everything is on track.
   Thank you,
   Alice Smith'),

  -- Support Team Apologizes for Delay
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-05 10:30:00', 'Request for Order Cancellation',
   'Dear Alice,We apologize for the delay in confirming your cancellation. There was a temporary system glitch, but we have resolved it now.'
   || 'I’m pleased to inform you that your order (#789456) has been successfully canceled. You should receive a confirmation email shortly.'
   || 'Thank you for your understanding, and we appreciate your patience.
   Best regards,
   Retail Support Team'),

  -- Customer Acknowledges Cancellation
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-05 11:00:00', 'Request for Order Cancellation',
   'Hi,Thank you for the quick resolution! I received the cancellation confirmation, and I appreciate your prompt assistance in this matter.'
   || 'I’ll consider shopping with you again in the future based on how efficiently this was handled.
   Best,
   Alice Smith'),

  -- Support Team Thanks Customer
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-05 11:15:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your understanding and kind words! We strive to provide the best service possible.'
   || 'If you have any further questions or need assistance with anything else, please feel free to reach out.
   Best regards,
   Retail Support Team'),

  -- Customer Inquires About Future Orders
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-06 09:30:00', 'Request for Order Cancellation',
   'Hi Support,I have another question regarding future orders. I’m considering placing a new order soon but would like to know if you have any promotions available right now.'
   || 'Thank you for your help!
   Best,
   Alice Smith'),

  -- Support Team Responds with Promotions
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-06 10:00:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your interest in placing a new order! Currently, we have several promotions running:'
   || '- 10% off on your first order   - Free shipping on orders over $50   - Buy one get one 50% off on selected items'
   || 'We’d love to assist you with your next purchase!
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Interest in Promotion
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-06 11:30:00', 'Request for Order Cancellation',
   'Hi Support,Thank you for sharing the promotions! I’m interested in the buy one get one 50% off offer.'
   || 'I’d like to know which items are eligible and if I can combine this with the free shipping offer as well.
   Best,
   Alice Smith'),

  -- Support Team Clarifies Promotion Details
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-06 12:00:00', 'Request for Order Cancellation',
   'Dear Alice,I’m glad to hear you’re interested in our promotions! The eligible items for the buy one get one 50% off offer are:'
   || ' - Item A   || - Item B  || - Item C'
   || 'Yes, you can absolutely combine this offer with free shipping on orders over $50.'
   || 'If you need any further assistance or wish to place your order, please let me know!
   Best regards,
   Retail Support Team'),

  -- Customer Places New Order
  ('customer2@example.com', 'Alice Smith', 'support@retailer.com', 'Retail Support', 12373, '2024-08-07 14:00:00', 'Request for Order Cancellation',
   'Hi Support,I’d like to proceed with placing a new order including Item A and Item B. '
   || 'Please apply the buy one get one 50% off promotion along with the free shipping offer to my order.'
   || 'Thank you for all your assistance! Looking forward to your confirmation.
   Best,
   Alice Smith'),

  -- Support Team Confirms New Order
  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Alice Smith', 12373, '2024-08-07 14:30:00', 'Request for Order Cancellation',
   'Dear Alice,Thank you for your order! We have successfully placed your order for Item A and Item B with the applied promotions.'
   || 'Order Summary:  
    - Item A: $5.0  
     - Item B: $3.8   
     - Discount: 50%  
     - Shipping: Free'
   || 'Your order will be shipped within the next 2-3 business days, and you will receive a confirmation email shortly.'
   || 'We appreciate your business and look forward to serving you again!
   Best regards,
   Retail Support Team');


INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12394, '2024-08-25 12:00:00', 'Customer Complaint: Incorrect Item Received', 
   'Hi,I recently received my order, but unfortunately, the item I got was incorrect. Instead of the jacket I ordered, I received a pair of shoes. '
   || 'This has caused some inconvenience, and I would like to resolve this as quickly as possible.Could you please assist me with the following:'
   || '- Initiating a return process for the incorrect item'
   || '- Ensuring I receive the correct item (the jacket)'
   || 'Thank you for your prompt assistance.
   Best regards,
   John Doe'),

  ('support@retailer.com', 'Retail Support', 'customer@example.com', 'John Doe', 12394, '2024-08-25 14:10:00', 'Customer Complaint: Incorrect Item Received', 
   'Dear John,We apologize for the inconvenience caused by this error. We strive to ensure accurate orders, and we regret that this mistake occurred. '
   || 'In order to help resolve this as quickly as possible, please provide us with the following information:'
   || '- Your order number'
   || '- The SKU or product code of the item you received'
   || 'Once we have this information, we can initiate the return process and send you the correct item.'
   || 'Thank you for your patience, and we look forward to resolving this for you soon.
   Best regards,
   Retail Support Team'),

  ('customer@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12394, '2024-08-25 15:45:00', 'Customer Complaint: Incorrect Item Received', 
   'Hello,Thank you for your quick response. Here are the details you requested:'
   || '- Order number: 5678'
   || '- SKU of the incorrect item: SH12345 (Shoes)'
   || 'The item I ordered was a leather jacket, SKU: JK56789. I appreciate your help in sorting this out.'
   || 'Could you also let me know how long the return and replacement process will take?'
   || 'Best regards,
   John Doe'),

  ('support@retailer.com', 'Retail Support', 'customer@example.com', 'John Doe', 12394, '2024-08-25 17:30:00', 'Customer Complaint: Incorrect Item Received', 
   'Dear John,Thank you for providing the details. We have initiated the return process, and you will receive a prepaid shipping label via email '
   || 'shortly. Once you receive it, please return the incorrect item (the shoes), and we will process the shipment of the correct item (the jacket).'
   || 'Here’s what will happen next:'
   || '- We will email you the shipping label within the next 30 minutes.'
   || '- After receiving the returned item, we will process the replacement within 1-2 business days.'
   || '- The new item will be shipped with express delivery (3-5 business days).'
   || 'Let us know if you have any further questions.
   Best regards,
   Retail Support Team'),

  ('customer@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12394, '2024-08-26 09:10:00', 'Customer Complaint: Incorrect Item Received', 
   'Hi,I wanted to follow up regarding the shipping label. It’s been a few hours, and I haven’t received the label yet. Could you please check on this? '
   || 'I’m eager to return the incorrect item and get the replacement as soon as possible.Thanks again for your assistance.
   Best regards,
   John Doe'),

  ('support@retailer.com', 'Retail Support', 'customer@example.com', 'John Doe', 12394, '2024-08-26 10:25:00', 'Customer Complaint: Incorrect Item Received', 
   'Dear John,We apologize for the delay. We have re-sent the shipping label to your email address. Please check your inbox or spam folder, and confirm '
   || 'if you have received it.Once we receive the returned item, we will expedite the process to ensure you receive the correct jacket as quickly as possible'
   || 'We sincerely appreciate your understanding and patience during this process.
   Best regards,
   Retail Support Team'),

  ('customer@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12394, '2024-08-26 12:40:00', 'Customer Complaint: Incorrect Item Received', 
   'Hello,I received the shipping label this time and have packaged the incorrect item. I will drop it off at the courier today.'
   || 'Could you please confirm the approximate delivery timeline for the replacement item once you receive the returned product?'
   || 'Best regards,
   John Doe'),

  ('support@retailer.com', 'Retail Support', 'customer@example.com', 'John Doe', 12394, '2024-08-26 14:20:00', 'Customer Complaint: Incorrect Item Received', 
   'Dear John,Thank you for sending back the incorrect item. Once we receive the return, the replacement jacket will be shipped within 1-2 business days. '
   || 'Here’s what you can expect:'
   || '- Once shipped, delivery will take approximately 3-5 business days (express shipping).'
   || '- You will receive a tracking number via email for the shipment.'
   || 'Please let us know if you need any further assistance during this process.
   Best regards,
   Retail Support Team'),

  ('customer@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12394, '2024-08-26 17:50:00', 'Customer Complaint: Incorrect Item Received', 
   'Hi,This entire process is taking much longer than expected. I’m disappointed with the service. I had hoped for a quicker resolution, especially since '
   || 'the mistake was on your end. I’m now considering canceling the order and requesting a full refund.Please advise on how I can proceed with the refund process if I decide to cancel.'
   || 'Best regards,John Doe'),

  ('support@retailer.com', 'Retail Support', 'customer@example.com', 'John Doe', 12394, '2024-08-26 19:10:00', 'Customer Complaint: Incorrect Item Received', 
   'Dear John,We understand your frustration, and we sincerely apologize for the inconvenience this has caused. To expedite the process, we have prioritized '
   || 'your replacement order. Your jacket will now be processed and shipped out by tomorrow morning.'
   || 'If you still wish to cancel the order and request a refund, please let us know. Otherwise, we will provide you with a tracking number once the item ships.'
   || 'We truly appreciate your patience throughout this process and are committed to making it right
   .Best regards,
   Retail Support Team');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer2@example.com', 'Sarah Lee', 'support@retailer.com', 'Retail Support', 12372, '2024-08-26 15:00:00', 'Product Inquiry: New Collection Availability',
   'Hi,I’ve recently come across your website and saw some items from your new collection that I’m interested in. '
   || 'Could you provide more details about the availability of the following items:'
   || '- Leather Jacket (SKU: LJ1001)'
   || '- High-waisted Jeans (SKU: HJ2003)'
   || 'I’d also like to know if these items are available in different sizes and colors.'
   || 'Looking forward to your reply.
   Best regards,
   Sarah Lee'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 15:45:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,Thank you for your inquiry about our new collection! We’re excited that you’ve found some items that you’re interested in.'
   || 'Regarding the items you mentioned:'
   || '- The Leather Jacket (SKU: LJ1001) is currently available in sizes S, M, and L, and comes in black and brown.'
   || '- The High-waisted Jeans (SKU: HJ2003) are available in sizes 26 to 32, and they come in light and dark blue.'
   || 'Let us know if you would like us to reserve these items for you, or if you have any other questions.'
   || 'Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@retailer.com', 'Retail Support', 12372, '2024-08-26 16:30:00', 'Product Inquiry: New Collection Availability',
   'Hello,Thank you for the quick response. I’d like to proceed with the following:'
   || '- Leather Jacket (Size: M, Color: Black)'
   || '- High-waisted Jeans (Size: 28, Color: Dark Blue)'
   || 'Could you also let me know if you offer free shipping on these items?'
   || 'Thanks again for your help.
   Best regards,
   Sarah Lee'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 17:15:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’re glad to hear that you’re interested in proceeding with the order! Here’s what we can confirm:'
   || '- The Leather Jacket (Size: M, Color: Black) is reserved for you.'
   || '- The High-waisted Jeans (Size: 28, Color: Dark Blue) are also available and reserved.'
   || 'Regarding shipping, we offer free standard shipping for orders over $100. Since your order qualifies, shipping will be free.'
   || 'Would you like to finalize the order? Once confirmed, we’ll send you the payment link.
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@retailer.com', 'Retail Support', 12372, '2024-08-26 18:00:00', 'Product Inquiry: New Collection Availability',
   'Hi,That’s great news! Yes, please proceed with the order. I’m ready to finalize the payment.'
   || 'Looking forward to receiving the payment link.
   Best regards,
   Sarah Lee'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 18:30:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’re thrilled to finalize your order! Here’s the payment link: [payment-link-here].'
   || 'Once the payment is complete, we’ll process your order immediately and send you a confirmation email with the tracking details.'
   || 'Please feel free to reach out if you need any further assistance.
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@retailer.com', 'Retail Support', 12372, '2024-08-26 19:15:00', 'Product Inquiry: New Collection Availability',
   'Hi,I’ve just completed the payment. Could you confirm that everything went through successfully?'
   || 'Also, could you provide an estimated delivery time? Thanks again!
   Best regards,
   Sarah Lee'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-26 20:00:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,Thank you for your payment. We’ve received the payment, and your order has been successfully processed.'
   || 'Here’s what you can expect next:'
   || '- Your order will be dispatched within the next 24 hours.'
   || '- You will receive an email with the tracking details once the shipment is on its way.'
   || 'Standard shipping takes 3-5 business days, so you can expect to receive your items soon.'
   || 'Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Sarah Lee', 'support@retailer.com', 'Retail Support', 12372, '2024-08-27 10:15:00', 'Product Inquiry: New Collection Availability',
   'Hi,Thanks for the update. I’m excited to receive my order! Could you let me know if I can make any changes to the delivery address before it ships?'
   || 'Just in case, here’s the current address I’d like it shipped to:'
   || '- 123 Park Avenue, Suite 500'
   || '- New York, NY 10001'
   || 'Thanks again for your help!
   Best regards,
   Sarah Lee'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Sarah Lee', 12372, '2024-08-27 11:00:00', 'Product Inquiry: New Collection Availability',
   'Dear Sarah,We’ve updated your shipping address as requested.');




INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-26 15:00:00', 'Order Delivered Confirmation',
   'Hi Support Team,I just wanted to confirm that I received my order today. Everything was packed well and arrived in perfect condition. '
   || 'Here’s a quick review of the items:'
   || '- The sneakers (SKU: SN4501) are exactly what I was looking for – the fit is perfect.'
   || '- The sweater (SKU: SW7832) is incredibly comfortable, and I love the color!'
   || 'I’m really satisfied with the quality of your products. Thank you for a smooth shopping experience.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-26 15:45:00', 'Order Delivered Confirmation',
   'Dear Emily,Thank you for confirming the delivery of your order! We’re thrilled to hear that everything arrived in great condition and that you’re happy with the items.'
   || 'Your feedback means a lot to us. It’s wonderful to know that the sneakers and sweater met your expectations.'
   || 'If you have any further questions or if we can assist you in any way, don’t hesitate to reach out.
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-26 16:15:00', 'Order Delivered Confirmation',
   'Hello Support Team,Thanks for your quick response! One quick question: do you have any care instructions for the sweater? I want to make sure I keep it in good condition.'
   || 'Also, are there any new arrivals in the accessories section? I’m interested in checking them out.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-26 17:00:00', 'Order Delivered Confirmation',
   'Dear Emily,We’re happy to help! For the sweater (SKU: SW7832), here are the care instructions:'
   || '- Machine wash cold with similar colors'
   || '- Use mild detergent'
   || '- Do not bleach'
   || '- Lay flat to dry'
   || '- Cool iron if needed'
   || 'Regarding new arrivals, we’ve just added some great items to our accessories section, including:'
   || '- Leather handbags'
   || '- Statement jewelry pieces'
   || '- Scarves and hats for the upcoming fall season'
   || 'Feel free to browse our website or let us know if you need further assistance!
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-26 17:45:00', 'Order Delivered Confirmation',
   'Hi Team,Thank you for the care instructions. I’ll make sure to follow them!'
   || 'I checked out the new accessories, and I love the handbags. Could you let me know if there’s a discount available for returning customers?'
   || 'Thanks again for all your help.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-26 18:30:00', 'Order Delivered Confirmation',
   'Dear Emily,We’re glad the care instructions were helpful!'
   || 'Regarding your inquiry about discounts, we’re excited to offer a 10% discount for returning customers on purchases above $100. '
   || 'Simply use the code RETURN10 at checkout to apply the discount.'
   || 'We’re always here to assist if you need any more help.
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-26 19:15:00', 'Order Delivered Confirmation',
   'Hi Team,That’s awesome! I’ll definitely make use of the discount. I’m adding a handbag to my cart right now.'
   || 'One last thing: is there a gift wrapping option available for this order?
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-26 20:00:00', 'Order Delivered Confirmation',
   'Dear Emily,We’re excited to hear that you’ll be making another purchase! Yes, we do offer gift wrapping for an additional $5. '
   || 'You can select the gift wrap option at checkout before finalizing the order.'
   || 'Let us know if you need further assistance!
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-27 10:15:00', 'Order Delivered Confirmation',
   'Hi Team,Thanks again! I’ve placed my order and selected the gift wrap option. Looking forward to receiving the new items soon!'
   || 'You’ve been so helpful throughout the entire process, and I really appreciate the great customer service.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-27 11:00:00', 'Order Delivered Confirmation',
   'Dear Emily,Thank you for your new order! We’re processing it and will send you the tracking details once it’s shipped.'
   || 'We’re delighted to hear that you’ve had a positive experience shopping with us. It’s always our goal to ensure our customers are satisfied.'
   || 'Feel free to reach out if you need anything else!
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-27 14:30:00', 'Order Delivered Confirmation',
   'Hi,Just received the confirmation email that my new order has shipped. I really appreciate how fast everything is moving.'
   || 'Thanks for making my shopping experience so smooth! I’m sure I’ll be a returning customer.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-27 15:00:00', 'Order Delivered Confirmation',
   'Dear Emily,We’re so glad to hear that your experience has been positive, and we can’t wait for you to receive your new order.'
   || 'Please let us know if you need anything else, and we’ll be happy to assist.'
   || 'We hope to see you shopping with us again soon!
   Best regards,
   Retail Support Team'),

  ('customer2@example.com', 'Emily Green', 'support@retailer.com', 'Retail Support', 12395, '2024-08-28 12:00:00', 'Order Delivered Confirmation',
   'Hi Team,Just a quick note to let you know that I received my new order today, and the handbag is beautiful!'
   || 'Everything came in perfect condition, and I’m beyond happy with my purchase.'
   || 'Thanks once again for the fantastic service.
   Best regards,
   Emily Green'),

  ('support@retailer.com', 'Retail Support', 'customer2@example.com', 'Emily Green', 12395, '2024-08-28 12:45:00', 'Order Delivered Confirmation',
   'Dear Emily,We’re thrilled to hear that you love your new handbag! It’s wonderful to know that everything arrived perfectly.'
   || 'Thank you for being such a loyal customer. We look forward to serving you again in the future!
   Best regards,
   Retail Support Team');



INSERT INTO emails (sender_email, sender_name, receiver_email, receiver_name, thread_id, email_received_at, email_subject, email_content)
VALUES
  -- Initial Inquiry from Customer
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-02 11:35:00', 'Order Delayed',
   'Hi Support Team,I noticed that my order has not yet been delivered, even though it was supposed to arrive two days ago. '
   || 'Could you please provide an update on the delivery status? The order number is #456789.'
   || 'I’d appreciate any information you can share regarding the current status.
   Thank you,
   John Doe'),

  -- Support Team's Initial Response
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-02 12:00:00', 'Order Delayed',
   'Dear John,Thank you for reaching out regarding your order. We apologize for the delay and are currently investigating the issue.'
   || 'We’ll update you as soon as we receive more information from our shipping partner.We appreciate your patience.
   Best regards,
   Retail Support Team'),

  -- Customer Follow-Up Inquiry
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-03 10:00:00', 'Order Delayed',
   'Hi,I haven’t received an update on my order yet. Could you provide a more concrete timeline? '
   || 'It’s been almost a week now since the original delivery date, and I’m getting concerned.'
   || 'Please expedite the process or offer an alternative solution.
   Thank you,
   John Doe'),

  -- Support Team Delay Notification
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-03 12:15:00', 'Order Delayed',
   'Dear John,We apologize for the inconvenience. Our shipping partner has reported some logistical delays due to unforeseen circumstances.'
   || 'We are working to ensure that your order is prioritized for delivery. The estimated delivery time is now extended by 3-5 business days.'
   || 'If there is anything else we can do to assist you, please let us know.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Frustration
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-04 09:30:00', 'Order Delayed',
   'Hi Support,This is becoming really frustrating. A delay of 3-5 business days is unacceptable, especially since I wasn’t informed earlier. '
   || 'I expect much better communication and service from a company like yours.'
   || 'If my order isn’t delivered by the end of this week, I’ll be forced to escalate this issue.'
   || 'I hope you understand my position and can ensure timely action.
   John Doe'),

  -- Support Team's Apology and Offer
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-04 11:00:00', 'Order Delayed',
   'Dear John,We sincerely apologize for the inconvenience caused by this delay. 
   We understand your frustration and assure you that we are doing everything in our power to resolve this matter.'
   || 'As a gesture of goodwill, we would like to offer you a 15% discount on your current order or on a future purchase. '
   || 'We’ll continue to monitor your shipment closely and keep you updated.Thank you for your understanding.
   Best regards,
   Retail Support Team'),

  -- Customer Escalates the Issue
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-04 16:30:00', 'Order Delayed',
   'Hi,While I appreciate the discount offer, it doesn’t change the fact that I’m still without my order. This has gone beyond just a delay. '
   || 'The lack of communication until I reached out and the continuing delays have been extremely frustrating.'
   || 'I will be sharing my experience publicly if this isn’t resolved in the next 48 hours. Additionally, I expect full compensation for the inconvenience caused.'
   || 'Please escalate this issue to your manager.John Doe'),

  -- Support Team Escalates to Management
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-05 09:15:00', 'Order Delayed',
   'Dear John,We understand your frustration and sincerely apologize once again for the delay. '
   || 'We have escalated this issue to our management team and are expediting the delivery process as a priority.'
   || 'Our team will update you within the next 24 hours regarding the status of your shipment.'
   || 'We greatly appreciate your patience and apologize for the inconvenience caused.
   Best regards,
   Retail Support Team'),

  -- Customer Expresses Discontent
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-05 10:45:00', 'Order Delayed',
   'Hi,This situation is completely unacceptable. I expected better from a company like yours. '
   || 'The escalation and “priority delivery” don’t seem to be making any difference. '
   || 'If I don’t receive my order by the end of the day tomorrow, I will be requesting a full refund, and I will never shop with your company again.'
   || 'Your company’s handling of this situation has been nothing short of disappointing.
   John Doe'),

  -- Support Team's Final Apology and Resolution
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-05 13:30:00', 'Order Delayed',
   'Dear John,We are deeply sorry for the ongoing issues with your order. After further escalation, we have confirmed that your shipment will be delivered within the next 24 hours.'
   || 'As a token of our sincere apologies, we are offering you a full refund along with the delivery of your order. '
   || 'We hope this helps to rectify the inconvenience caused, and we will also be offering an additional 25% discount on your next purchase if you choose to shop with us again.'
   || 'Once again, we apologize for the frustration and inconvenience this has caused.
   Best regards,
   Retail Support Team'),

  -- Customer Acknowledges Apology but Maintains Discontent
  ('customer1@example.com', 'John Doe', 'support@retailer.com', 'Retail Support', 12371, '2024-08-05 15:00:00', 'Order Delayed',
   'Hi,Thank you for the update, but I still find it disappointing that it took this long for a resolution. I’ll accept the refund and the delivery of my order, '
   || 'but I hope your company learns from this situation and handles future delays with better communication.'
   || 'I’ll consider the discount offer, but my confidence in your service has taken a significant hit.
   John Doe'),

  -- Support Team's Final Follow-Up
  ('support@retailer.com', 'Retail Support', 'customer1@example.com', 'John Doe', 12371, '2024-08-06 09:30:00', 'Order Delayed',
   'Dear John,We fully understand your concerns, and we are taking your feedback very seriously. '
   || 'Our team is reviewing the entire process to ensure that such delays are communicated more effectively in the future.'
   || 'We appreciate your understanding and hope to regain your trust in the future. 
   If there is anything else we can do to assist, please don’t hesitate to reach out.
   Best regards,
   Retail Support Team');




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
  'Support Team', 'Ethan Turner'),

  ('mary.jones@example.com', 'support@business.com', 12347, '2024-09-25 08:00:00', 'Billing Inquiry', 'Can you clarify my last bill? There seems to be a Charge I don''t understand.', 'Mary Jones', 'Alice Smith'),
  ('support@business.com', 'mary.jones@example.com', 12347, '2024-09-25 09:00:00', 'Billing Inquiry', 'We’d be happy to clarify that Charge. It''s for additional services you opted for.', 'Alice Smith', 'Mary Jones'),
  ('alex.brown@example.com', 'support@business.com', 12347, '2024-09-25 10:00:00', 'Billing Inquiry', 'Is there a way to get a detailed bill breakdown?', 'Alex Brown', 'Alice Smith'),
  ('support@business.com', 'alex.brown@example.com', 12347, '2024-09-25 11:00:00', 'Billing Inquiry', 'Yes, we can send you a detailed breakdown upon request.', 'Alice Smith', 'Alex Brown'),
  ('susan.williams@example.com', 'support@business.com', 12347, '2024-09-25 12:00:00', 'Billing Inquiry', 'I’d like to see the breakdown, please.', 'Susan Williams', 'Alice Smith'),
  ('support@business.com', 'susan.williams@example.com', 12347, '2024-09-25 13:00:00', 'Billing Inquiry', 'Sure! I will send that to your email shortly.', 'Alice Smith', 'Susan Williams'),
  
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 08:00:00', 'Feedback Request', 'I’d like to share some feedback on my recent experience.', 'Emily Davis', 'Support Team'),
  ('support@business.com', 'emily.davis@example.com', 12348, '2024-09-26 09:00:00', 'Feedback Request', 'Thank you for your feedback! We value our customers'' input.', 'Support Team', 'Emily Davis'),
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 10:00:00', 'Feedback Request', 'I found your service very helpful, thank you!', 'Emily Davis', 'Support Team'),
  ('support@business.com', 'emily.davis@example.com', 12348, '2024-09-26 11:00:00', 'Feedback Request', 'We’re glad to hear that! Please let us know if you need anything else.', 'Support Team', 'Emily Davis'),
  ('emily.davis@example.com', 'support@business.com', 12348, '2024-09-26 12:00:00', 'Feedback Request', 'I have some suggestions for improvement.', 'Emily Davis', 'Support Team'),
  ('support@business.com', 'emily.davis@example.com', 12348, '2024-09-26 13:00:00', 'Feedback Request', 'We appreciate your suggestions and will take them into account.', 'Support Team', 'Emily Davis'),
  
  ('john.doe@example.com', 'support@business.com', 12349, '2024-09-27 08:00:00', 'Product Inquiry', 'What are your shipping options?', 'John Doe', 'Alice Smith'),
  ('support@business.com', 'john.doe@example.com', 12349, '2024-09-27 09:00:00', 'Product Inquiry', 'We offer standard and express shipping options.', 'Alice Smith', 'John Doe'),
  ('mary.jones@example.com', 'support@business.com', 12349, '2024-09-27 10:00:00', 'Product Inquiry', 'How can I track my shipment?', 'Mary Jones', 'Alice Smith'),
  ('support@business.com', 'mary.jones@example.com', 12349, '2024-09-27 11:00:00', 'Product Inquiry', 'Once your order ships, you will receive a tracking number via email.', 'Alice Smith', 'Mary Jones'),
  ('alex.brown@example.com', 'support@business.com', 12349, '2024-09-27 12:00:00', 'Product Inquiry', 'Are there any additional shipping fees?', 'Alex Brown', 'Alice Smith'),
  ('support@business.com', 'alex.brown@example.com', 12349, '2024-09-27 13:00:00', 'Product Inquiry', 'Additional fees may apply for express shipping.', 'Alice Smith', 'Alex Brown'),
  ('susan.williams@example.com', 'support@business.com', 12349, '2024-09-27 14:00:00', 'Product Inquiry', 'Can I change my shipping address after placing an order?', 'Susan Williams', 'Alice Smith'),
  ('support@business.com', 'susan.williams@example.com', 12349, '2024-09-27 15:00:00', 'Product Inquiry', 'Yes, please contact us as soon as possible to make changes.', 'Alice Smith', 'Susan Williams'),
  
  ('Charles.white@example.com', 'support@business.com', 12350, '2024-09-28 08:00:00', 'Technical Support', 'I am having issues with my product.', 'Charles White', 'Alice Smith'),
  ('support@business.com', 'Charles.white@example.com', 12350, '2024-09-28 09:00:00', 'Technical Support', 'I''m sorry to hear that! Can you describe the issue?', 'Alice Smith', 'Charles White'),
  ('olivia.johnson@example.com', 'support@business.com', 12350, '2024-09-28 10:00:00', 'Technical Support', 'My product is not turning on.', 'Olivia Johnson', 'Alice Smith'),
  ('support@business.com', 'olivia.johnson@example.com', 12350, '2024-09-28 11:00:00', 'Technical Support', 'Please check if the device is Charged and try again.', 'Alice Smith', 'Olivia Johnson'),
  ('emily.davis@example.com', 'support@business.com', 12350, '2024-09-28 12:00:00', 'Technical Support', 'I have tried Charging it, but it still doesn''t work.', 'Emily Davis', 'Alice Smith'),
  ('support@business.com', 'emily.davis@example.com', 12350, '2024-09-28 13:00:00', 'Technical Support', 'In that case, we may need to arrange for a replacement. Would that be okay?', 'Alice Smith', 'Emily Davis');

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
  ('olivia.johnson@example.com', 'support@business.com', 12346, '2024-09-24 08:00:00', 'Order Status', 
   'Dear Support Team,

I hope this message finds you well. I recently placed an order with your company, and I''m writing to check on the current status of my order #1234. It''s been a few days since I received the confirmation email, and I wanted to ensure that everything is proceeding as expected.

I would appreciate it if you could provide me with an update on the order processing and an estimated delivery date if available. I am looking forward to receiving the products and appreciate your time in assisting with this.

Thank you for your help, and I look forward to your response.

Best regards,
Olivia Johnson', 
   'Olivia Johnson', 'Support Team'),

  ('support@business.com', 'olivia.johnson@example.com', 12346, '2024-09-24 09:00:00', 'Order Status', 
   'Dear Olivia,

Thank you for reaching out and for your order with us. I completely understand your eagerness to know the current status of your order. I''m happy to inform you that your order is currently being processed and is in the final stages before shipment. Once your order is dispatched, you will receive an email with the tracking information, so you can follow the delivery progress.

At this time, we estimate that your order will be shipped within the next 24 hours. From there, delivery typically takes 3-5 business days, depending on your location.

If you have any further questions or need additional assistance, please don''t hesitate to reach out. We appreciate your patience and your business with us.

Kind regards,
Support Team', 
   'Support Team', 'Olivia Johnson'),

  ('olivia.johnson@example.com', 'support@business.com', 12346, '2024-09-24 10:00:00', 'Order Status', 
   'Hi Support Team,

Thank you for your prompt response and for keeping me informed. I really appreciate it. I was hoping to also ask if you could provide an estimated delivery window for my order #1234. While I understand that shipping times can vary, it would be helpful to know when I can expect to receive the items, as I need to plan accordingly.

Also, I''d like to confirm that the shipping address on the order is correct, just in case. I''m not sure if that information was included in the confirmation email I received. Could you verify the shipping details for me?

Thanks again for your assistance. I look forward to hearing back from you soon.

Best regards,
Olivia Johnson', 
   'Olivia Johnson', 'Support Team'),

  ('support@business.com', 'olivia.johnson@example.com', 12346, '2024-09-24 11:00:00', 'Order Status', 
   'Dear Olivia,

Thank you for your email and for the additional questions. I can confirm that your shipping address is accurate, and the items will be delivered to the address listed in your confirmation email. Regarding the delivery time, we estimate that your package will arrive within 3-5 business days, depending on your location. Once the order is shipped, you will receive tracking information, which will give you more specific details on when your package will arrive.

We understand that it''s important to have this information for planning, and we will do our best to ensure that your order reaches you promptly. Please don''t hesitate to reach out if you have any further questions or concerns. We''re always here to help.

Sincerely,
Support Team', 
   'Support Team', 'Olivia Johnson'),

  ('olivia.johnson@example.com', 'support@business.com', 12346, '2024-09-24 12:00:00', 'Order Status', 
   'Hello Support Team,

Thank you very much for confirming the shipping details and for providing the estimated delivery window. It''s a relief to know that everything is on track and that I can expect the package soon.

I appreciate your prompt assistance throughout this process. I''ll keep an eye out for the tracking details once they are available. Thanks again for the excellent customer service!

Kind regards,
Olivia Johnson', 
   'Olivia Johnson', 'Support Team'),

  ('support@business.com', 'olivia.johnson@example.com', 12346, '2024-09-24 13:00:00', 'Order Status', 
   'Dear Olivia,

You''re very welcome! We''re delighted to hear that you''re satisfied with the support you''ve received so far. We always strive to ensure that our customers have a smooth and pleasant experience, and we''re happy to have been able to assist you.

If you have any other questions in the future, or if there''s anything else we can do for you, please don''t hesitate to contact us. We''re always here to help.

Best regards,
Support Team', 
   'Support Team', 'Olivia Johnson');

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
  'Support Team', 'Alex Brown'),
  
  ('support@business.com', 'rufus.brown@example.com', 12367, '2024-09-30 08:00:00', 'Feedback Request on Your Service Quality',
  'Hello Rufus,

We hope you are doing well! We would appreciate it if you could take a moment to provide us with feedback on the quality of our service. Your insights are valuable to us and help us improve.

Thank you for your time!

Best regards,
Support Team',
  'Support Team', 'Rufus Brown'),
  
  ('support@business.com', 'rufus.brown@example.com', 12367, '2024-09-30 08:30:00', 'Feedback Request on Your Service Quality',
  'Hi Rufus,

We noticed we haven''t received your feedback yet. If you could share your thoughts on our service quality, it would really help us improve. Plus, we have an exciting new offer coming soon!

Looking forward to hearing from you!

Cheers,
Support Team',
  'Support Team', 'Rufus Brown'),
  
  ('rufus.brown@example.com', 'support@business.com', 12367, '2024-09-30 09:00:00', 'Feedback Request on Your Service Quality',
  'Dear Support Team,

What’s this new offer you mentioned? I am interested to know more about it!

Thanks,
Rufus Brown',
  'Rufus Brown', 'Support Team'),
  
  ('support@business.com', 'rufus.brown@example.com', 12367, '2024-09-30 09:30:00', 'Feedback Request on Your Service Quality',
  'Hi Rufus,

Thank you for your response! The new offer is available to customers who make a minimal purchase of $100. We’d love to have you take advantage of it! Your satisfaction is our priority.

Best regards,
Support Team',
  'Support Team', 'Rufus Brown'),
  
  ('rufus.brown@example.com', 'support@business.com', 12367, '2024-09-30 10:00:00', 'Feedback Request on Your Service Quality',
  'Hello,

I’m not interested in spending that much just for an offer. I haven’t been impressed with your service quality either. Please let me know if there are other options available.

Regards,
Rufus Brown',
  'Rufus Brown', 'Support Team'),
  
  ('support@business.com', 'rufus.brown@example.com', 12367, '2024-09-30 10:30:00', 'Feedback Request on Your Service Quality',
  'Hi Rufus,

We appreciate your honesty. Could you please clarify what specific aspects of our service you found disappointing? Your feedback is important to us and will help us improve.

Thank you for your assistance!

Best,
Support Team',
  'Support Team', 'Rufus Brown'),
  
  ('support@business.com', 'rufus.brown@example.com', 12367, '2024-09-30 13:00:00', 'Feedback Request on Your Service Quality',
  'Hi Rufus,

If you ever decide to share your thoughts or need assistance, we’re just an email away. Thank you for your time and consideration.

Best wishes,
Support Team',
  'Support Team', 'Rufus Brown'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 22:30:00', 'Service complaint', 
  'I have been experiencing persistent issues with my account. I need immediate assistance to resolve this.', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-26 23:00:00', 'Service complaint', 
  'Hi Sofia Garcia, we apologize for the delay. Your request is being reviewed.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 23:30:00', 'Service complaint', 
  'That''s not good enough. I want this resolved immediately!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 00:00:00', 'Service complaint', 
  'We understand your frustration, Sofia. Can you please provide us with more details about the issue you are experiencing?', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-27 12:00:00', 'Service complaint', 
  'It''s just not working right, okay? That''s all you need to know.', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 12:15:00', 'Service complaint', 
  'Thank you for the information, Sofia. Could you please provide a bit more detail to help us assist you better?', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-28 10:00:00', 'Service complaint', 
  'I told you it’s not working. I don’t have time to explain everything!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-28 10:30:00', 'Service complaint', 
  'We appreciate your patience, Sofia. Based on what you''ve shared, we will investigate the issue. Can you please confirm if you have received any error messages?', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-30 10:00:00', 'Service complaint', 
  'I’ve seen some errors, but I don’t remember exactly. Can you just fix it already?', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-30 10:30:00', 'Service complaint', 
  'Thank you for your response, Sofia. We are investigating further. Can you please let us know if the problem is still occurring?', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-02 14:00:00', 'Service complaint', 
  'It’s still happening, but it’s not as bad as before. I guess that’s something?', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-02 14:15:00', 'Service complaint', 
  'Thank you for the update, Sofia. Could you be more specific about what issues remain so we can address them?', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-04 08:00:00', 'Service complaint', 
  'I mean, it sometimes works and sometimes doesn’t. Just do your job!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-04 08:30:00', 'Service complaint', 
  'We understand your frustration, Sofia. We are committed to resolving this. Please allow us some time to investigate further.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-06 09:00:00', 'Service complaint', 
  'Fine, but I expect an update soon!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-06 09:15:00', 'Service complaint', 
  'Absolutely, Sofia. We will keep you posted on any developments.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-08 11:00:00', 'Service complaint', 
  'I haven’t heard anything! What is taking so long?', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-08 11:15:00', 'Service complaint', 
  'We are truly sorry for the delay, Sofia. Your case is being prioritized, and we will provide an update soon.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-10 12:00:00', 'Service complaint', 
  'This is completely unacceptable! I expect better service!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-10 12:15:00', 'Service complaint', 
  'We apologize for the inconvenience, Sofia. A senior representative is currently reviewing your case.',
  'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-12 13:00:00', 'Service complaint', 
  'I need this resolved NOW! I’m losing patience.', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-12 13:15:00', 'Service complaint', 
  'We completely understand, Sofia. We are working diligently to resolve your issue as soon as possible.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-14 15:30:00', 'Service complaint', 
  'I can’t believe this is still going on. This is ridiculous!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-14 15:45:00', 'Service complaint', 
  'We sincerely apologize for your experience, Sofia. Thank you for your continued patience. We will do everything we can to resolve this.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-16 16:00:00', 'Service complaint', 
  'I’m seriously considering switching services. This is unacceptable!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-16 16:15:00', 'Service complaint', 
  'We apologize for your frustration, Sofia. We are committed to making things right. Please bear with us a little longer.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-18 17:00:00', 'Service complaint', 
  'This is getting out of hand! I want answers!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-18 17:15:00', 'Service complaint', 
  'We truly apologize, Sofia. We are working to resolve your issue, and we will keep you updated.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-20 18:30:00', 'Service complaint', 
  'I just want to know what is going on with my request! This is unacceptable!', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-20 18:45:00', 'Service complaint', 
  'Thank you for your patience, Sofia. Your issue has been escalated, and we are on it. You will hear from us soon.', 'Support Team', 'Sofia Garcia'),
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-22 19:00:00', 'Service complaint', 
  'Finally! I received an update. You guys managed to fix my problem, but honestly, I expected it to be much quicker.', 'Sofia Garcia', 'Support Team'),
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-22 19:15:00', 'Service complaint', 
  'We appreciate your feedback, Sofia. We are glad to hear your issue has been resolved, and we apologize for any inconvenience caused. Thank you for your understanding.', 'Support Team', 'Sofia Garcia');

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
    ('alex.brown@example.com', 'support@business.com', 13211, '2024-09-30 09:30:00', 'Issue with Product Quality',
    'Dear Support Team,

I hope this message finds you well. I recently purchased your product, but it has not met my expectations. It''s not functioning as advertised, and I need assistance with this matter. Could you please provide guidance on how to resolve this issue?

Thank you for your prompt attention to this matter.

Best regards,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 13211, '2024-09-30 09:45:00', 'Issue with Product Quality',
    'Hi Alex,

Thank you for reaching out. We sincerely apologize for the inconvenience you are facing with our product. Our team is looking into your issue, and we will reach out shortly with a solution or replacement. We appreciate your patience as we work to resolve this matter.

Best wishes,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 13211, '2024-09-30 10:15:00', 'Issue with Product Quality',
    'Dear Support Team,

I appreciate your prompt response, but I need to know how soon I can expect a resolution. This product is critical for my needs, and I am quite frustrated with the situation. I would greatly appreciate any updates you can provide.

Thank you for your assistance.

Sincerely,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 13211, '2024-09-30 10:30:00', 'Issue with Product Quality',
    'Hello Alex,

We understand your frustration, and we are actively working to resolve this issue. Please bear with us as we investigate further. Your satisfaction is our priority, and we are committed to ensuring you have a positive experience with our products.

Warm regards,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 13211, '2024-09-30 11:00:00', 'Issue with Product Quality',
    'Dear Support Team,

I waited for an update, but nothing has changed. I''m really disappointed that a product from your company would have such quality issues. This is unacceptable, and I hope to hear back soon with a viable solution.

Thank you for your attention to this matter.

Regards,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 13211, '2024-09-30 11:15:00', 'Issue with Product Quality',
    'Hi Alex,

We sincerely apologize for the ongoing issues with your product. Our team is prioritizing your case and will ensure you receive a resolution as soon as possible. Please know that we take this matter seriously and appreciate your understanding.

Thank you for your patience.

Best,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 13211, '2024-09-30 11:30:00', 'Issue with Product Quality',
    'Dear Support Team,

This has been a terrible experience. I expected much more from your product and your support team. I can’t believe I wasted my money on this. Please let me know how you plan to address this issue.

I look forward to your prompt response.

Thanks,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 13211, '2024-09-30 11:45:00', 'Issue with Product Quality',
    'Hello Alex,

We apologize for your experience. We take your feedback seriously and will work to improve our product quality. Please let us know if there is anything we can do to regain your trust. Your satisfaction is important to us, and we are here to help.

Best regards,
Support Team',
    'Support Team', 'Alex Brown'),
    ('alex.brown@example.com', 'support@business.com', 12390, '2024-09-30 12:00:00', 'Request for Update',
    'Dear Support Team,

I hope you are doing well. I wanted to follow up regarding the product issue I reported earlier. It has been some time, and I haven''t received any updates. I would appreciate any information you could provide about the status of my request.

Thank you for your attention to this matter.

Sincerely,
Alex Brown',
    'Alex Brown', 'Support Team'),
    ('support@business.com', 'alex.brown@example.com', 12390, '2024-09-30 12:15:00', 'Request for Update',
    'Hi Alex,

Thank you for your patience. We are still working on your case and will provide you with a detailed update shortly. Please bear with us a little longer as we strive to ensure a satisfactory resolution.

Best wishes,
Support Team',
    'Support Team', 'Alex Brown');

INSERT INTO emails (sender_email, receiver_email, thread_id, email_received_at, email_subject, email_content, sender_name, receiver_name) VALUES
  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 22:30:00', 'Service complaint', 
  'Dear Support Team,

I hope this message finds you well. I have been experiencing persistent issues with my account. I need immediate assistance to resolve this matter.

Thank you for your attention.

Best regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),
  
  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-26 23:00:00', 'Service complaint', 
  'Hi Sofia,

Thank you for reaching out. We sincerely apologize for the delay in addressing your concerns. Rest assured, your request is currently being reviewed, and we will get back to you shortly.

Best,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-26 23:30:00', 'Service complaint', 
  'Hello,

That''s not good enough! I want this resolved immediately! My patience is wearing thin, and I expect better service.

Regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 00:00:00', 'Service complaint', 
  'Dear Sofia,

We understand your frustration, and we are here to help. Could you please provide us with more details about the issue you are experiencing? Your feedback is essential for us to assist you better.

Thank you,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-27 12:00:00', 'Service complaint', 
  'Hi,

It''s just not working right, okay? That''s all you need to know. I''ve tried everything!

Sincerely,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-27 12:15:00', 'Service complaint', 
  'Dear Sofia,

Thank you for the information you provided. Could you please share a bit more detail to help us assist you better? We want to resolve your issue as quickly as possible.

Warm regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-09-28 10:00:00', 'Service complaint', 
  'Hello,

I told you it''s not working! I don’t have time to explain everything! Please fix it!

Regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-09-28 10:30:00', 'Service complaint', 
  'Hi Sofia,

We appreciate your patience during this time. Based on what you''ve shared, we will investigate the issue. Can you please confirm if you have received any error messages? Your feedback is vital for us.

Thank you,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-02 14:00:00', 'Service complaint', 
  'Dear Team,

I’ve seen some errors, but I don’t remember exactly. Can you just fix it already? I need this resolved soon!

Thanks,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-02 14:15:00', 'Service complaint', 
  'Dear Sofia,

Thank you for your response. We are investigating further and will keep you updated. Can you please let us know if the problem is still occurring?

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-04 08:00:00', 'Service complaint', 
  'Hi,

I mean, it sometimes works and sometimes doesn’t. Just do your job and fix it! I’m counting on you!

Sincerely,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-04 08:30:00', 'Service complaint', 
  'Dear Sofia,

We understand your frustration. We are committed to resolving this. Please allow us some time to investigate further, and we will keep you posted.

Thank you for your patience,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-06 09:00:00', 'Service complaint', 
  'Hello,

Fine, but I expect an update soon! This has been going on for too long!

Best,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-06 09:15:00', 'Service complaint', 
  'Dear Sofia,

Absolutely! We will keep you posted on any developments. Your satisfaction is our top priority.

Best regards,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-08 11:00:00', 'Service complaint', 
  'Dear Support Team,

I haven’t heard anything! What is taking so long? This is unacceptable!

Thank you,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-08 11:15:00', 'Service complaint', 
  'Hi Sofia,

We are truly sorry for the delay. Your case is being prioritized, and we will provide an update soon. Thank you for your understanding.

Best,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-10 12:00:00', 'Service complaint', 
  'Hello,

This is completely unacceptable! I expect better service than this!

Sincerely,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-10 12:15:00', 'Service complaint', 
  'Dear Sofia,

We apologize for the inconvenience. A senior representative is currently reviewing your case, and we will keep you updated as soon as we can.

Thank you for your patience,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-12 13:00:00', 'Service complaint', 
  'Hi,

I need this resolved NOW! I’m losing patience. Please let me know what is happening!

Regards,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-12 13:15:00', 'Service complaint', 
  'Dear Sofia,

We completely understand your urgency. We are working diligently to resolve your issue as soon as possible.

Thank you for your understanding,
Support Team', 'Support Team', 'Sofia Garcia'),

  ('sofiagarcia@example.com', 'support@business.com', 12368, '2024-10-14 09:00:00', 'Service complaint', 
  'Hello,

What is taking so long? I really expect a resolution today!

Sincerely,
Sofia Garcia', 'Sofia Garcia', 'Support Team'),

  ('support@business.com', 'sofiagarcia@example.com', 12368, '2024-10-14 09:15:00', 'Service complaint', 
  'Dear Sofia,

We are truly sorry for the inconvenience caused. We are on it and will get back to you shortly.

Thank you for your patience,
Support Team', 'Support Team', 'Sofia Garcia');

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
  ('alex.brown@example.com', 'support@business.com', 12390, '2024-09-30 09:30:00', 'Issue with Product Quality',
  'Dear Support Team,

I recently purchased your product, but it has not met my expectations. It''s not functioning as advertised, and I need assistance with this matter. Could you please provide guidance on how to resolve this issue?

Thank you for your prompt attention to this matter.

Best regards,
Alex Brown',
  'Alex Brown', 'Support Team'),
  ('support@business.com', 'alex.brown@example.com', 12390, '2024-09-30 09:45:00', 'Issue with Product Quality',
  'Hi Alex,

We apologize for the inconvenience. Our team is looking into your issue, and we will reach out shortly with a solution or replacement. We appreciate your patience as we work to resolve this matter.

Thanks,
Support Team',
  'Support Team', 'Alex Brown'),
  ('alex.brown@example.com', 'support@business.com', 12390, '2024-09-30 10:15:00', 'Issue with Product Quality',
  'Dear Support Team,

I appreciate your prompt response, but I need to know how soon I can expect a resolution. This product is critical for my needs, and I am quite frustrated with the situation. I would greatly appreciate any updates you can provide.

Thank you for your assistance.

Sincerely,
Alex Brown',
  'Alex Brown', 'Support Team'),
  ('support@business.com', 'alex.brown@example.com', 12390, '2024-09-30 10:30:00', 'Issue with Product Quality',
  'Hello Alex,

We understand your frustration, and we are actively working to resolve this issue. Please bear with us as we investigate further. Your satisfaction is our priority, and we are committed to ensuring you have a positive experience with our products.

Best,
Support Team',
  'Support Team', 'Alex Brown'),
  ('alex.brown@example.com', 'support@business.com', 12390, '2024-09-30 11:00:00', 'Issue with Product Quality',
  'Dear Support Team,

I waited for an update, but nothing has changed. I''m really disappointed that a product from your company would have such quality issues. This is unacceptable, and I hope to hear back soon with a viable solution.

Regards,
Alex Brown',
  'Alex Brown', 'Support Team'),
  ('support@business.com', 'alex.brown@example.com', 12390, '2024-09-30 11:15:00', 'Issue with Product Quality',
  'Hi Alex,

We sincerely apologize for the ongoing issues with your product. Our team is prioritizing your case and will ensure you receive a resolution as soon as possible. Please know that we take this matter seriously and appreciate your understanding.

Thank you,
Support Team',
  'Support Team', 'Alex Brown'),
  ('alex.brown@example.com', 'support@business.com', 12390, '2024-09-30 11:30:00', 'Issue with Product Quality',
  'Dear Support Team,

This has been a terrible experience. I expected much more from your product and your support team. I can’t believe I wasted my money on this. Please let me know how you plan to address this issue.

Thanks,
Alex Brown',
  'Alex Brown', 'Support Team'),
  ('support@business.com', 'alex.brown@example.com', 12390, '2024-09-30 11:45:00', 'Issue with Product Quality',
  'Hello Alex,

We apologize for your experience. We take your feedback seriously and will work to improve our product quality. Please let us know if there is anything we can do to regain your trust. Your satisfaction is important to us, and we are here to help.

Best regards,
Support Team',
  'Support Team', 'Alex Brown'),

  ('john.doe@example.com', 'support@business.com', 12392, '2024-09-30 12:20:00', 'Outstanding Support', 
  'Dear Support Team,

I just wanted to express my gratitude for your prompt assistance! I was worried that it might take a while to fix the issue, but your team resolved it faster than I expected.

Your dedication to customer service is top-notch. Thank you once again!

Best regards,
John Doe', 
  'John Doe', 'Support Team'),
  ('support@business.com', 'john.doe@example.com', 12392, '2024-09-30 12:25:00', 'Outstanding Support', 
    'Hello John,

Thank you for your kind words! We appreciate your feedback and are glad we could help. We strive to resolve every issue as quickly as possible. Don’t hesitate to reach out if you need anything else!

Best,
Support Team', 
    'Support Team', 'John Doe'),

  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 08:00:00', 'Ongoing Issue with Service',
  'Dear Support Team,

I''ve noticed recurring issues with my service for the past week. It''s causing delays in my work, and I''d appreciate it if you could look into this urgently.

Thank you,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 08:15:00', 'Ongoing Issue with Service',
  'Hi Daniel,

Thank you for reaching out. We''re aware of some disruptions, and our team is currently working on it. We''ll update you once we have more information.

Best regards,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 09:00:00', 'Ongoing Issue with Service',
  'Hello,

I appreciate your quick response, but this has been going on for days now. How much longer do I have to wait? This is starting to impact my business significantly.

Thank you for your understanding,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 09:30:00', 'Ongoing Issue with Service',
  'Hi Daniel,

I understand your frustration. We are treating this as a priority and will inform you as soon as it''s fixed. Please bear with us during this time.

Regards,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 10:00:00', 'Ongoing Issue with Service',
  'Dear Support Team,

It''s been hours, and still no progress. I''m losing patience. I can''t keep dealing with such unreliable service. I need a clear update now.

Best,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 10:15:00', 'Ongoing Issue with Service',
  'Hello Daniel,

I completely understand your frustration. Our team is currently identifying the root cause, and we should have it resolved shortly. Thank you for your patience so far.

Sincerely,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 11:00:00', 'Ongoing Issue with Service',
  'Hi,

This is unacceptable! If this isn''t fixed within the next hour, I will have no choice but to look for alternatives. You''re pushing away your loyal customers!

Thanks,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 11:15:00', 'Ongoing Issue with Service',
  'Dear Daniel,

We sincerely apologize for the delay. We recognize the impact this is having on you, and we are escalating this issue to the highest priority. Please expect an update soon.

Warm regards,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 11:45:00', 'Ongoing Issue with Service',
  'Hello,

This is my final warning. If this isn''t resolved today, I will be terminating my account with your service and moving on. I cannot afford these delays any longer.

Thank you,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 12:00:00', 'Ongoing Issue with Service',
  'Dear Daniel,

We deeply regret the inconvenience caused. The issue has now been resolved, and all systems should be functioning normally. We''ll be monitoring the situation closely. Please feel free to reach out if you need further assistance.

Thank you for your patience,
Support Team',
  'Support Team', 'Daniel James'),
  ('daniel.james@example.com', 'support@business.com', 12394, '2024-09-30 12:30:00', 'Ongoing Issue with Service',
  'Hi Support Team,

It looks like things are working again, but this experience has shaken my trust. I hope there won''t be any more issues like this. Thanks for fixing it, but it shouldn''t have taken this long.

Best regards,
Daniel James',
  'Daniel James', 'Support Team'),
  ('support@business.com', 'daniel.james@example.com', 12394, '2024-09-30 12:45:00', 'Ongoing Issue with Service',
  'Dear Daniel,

We understand, and we sincerely apologize once again. We value your business and are committed to making sure this doesn''t happen again. Please don''t hesitate to let us know if you have any further concerns.

Kind regards,
Support Team',
  'Support Team', 'Daniel James');

INSERT INTO threads (
  thread_id,
  thread_topic
)
  SELECT
    thread_id,
    email_subject
  FROM emails
  GROUP BY
    thread_id,
    email_subject
  ORDER BY
    thread_id on conflict  do nothing;

ALTER TABLE emails
ADD CONSTRAINT emails_fkey
FOREIGN KEY (thread_id)
REFERENCES threads (thread_id);

CREATE TABLE sop_document (
  doc_id SERIAL PRIMARY KEY,
  doc_content BYTEA NOT NULL,
  doc_timestamp TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION update_thread_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the updated_at field in the corresponding thread
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

commit;
