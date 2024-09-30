begin;

CREATE TABLE emails (
  email_record_id SERIAL PRIMARY KEY,
  sender_email VARCHAR(50) NOT NULL,
  sender_name VARCHAR(100),
  receiver_email VARCHAR(50) NOT NULL,
  receiver_name VARCHAR(100),
  thread_id INT NOT NULL,
  email_received_at TIMESTAMP,
  email_subject VARCHAR(50) NOT NULL,
  email_content TEXT NOT NULL
);

CREATE TABLE threads (
  thread_id serial PRIMARY KEY,
  thread_topic VARCHAR(50)
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

commit;