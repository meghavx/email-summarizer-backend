CREATE TABLE emails (
			email_record_id serial PRIMARY KEY,
			sender_email CHAR(250) NOT NULL,
			email_thread_id INT NOT NULL,
			email_received_timestamp TIMESTAMP default now(),
			email_subject CHAR(250) NOT NULL,
			email_content TEXT
		);

		CREATE TABLE email_threads (
			email_thread_id serial primary key,
			thread_topic CHAR(250)
		);		

INSERT INTO emails (
			sender_email,
			email_thread_id,
			email_received_timestamp,
			email_subject, email_content
		)
		VALUES
			( 'alice@example.com', 12345, '2024-09-23 08:00:00', 'Project Discussion', 'Hi Bob, 

I hope this email finds you well. I wanted to follow up on our previous discussion about the project details. I have attached a revised proposal that includes some additional information. Please 
review and let me know if there are any changes you would like to see.

Best,
Alice'),
			( 'bob@example.com', 12345, '2024-09-23 09:30:00', 'Project Discussion', 'Hi Alice,

Thank you for the revised proposal. I have reviewed it and would like to request a few changes. Please see below:

* Can we include a more detailed project timeline?
* Would it be possible to provide a breakdown of the estimated costs?

Looking forward to hearing back from you.

Best,
Bob'),
			( 'alice@example.com', 12345, '2024-09-23 10:00:00', 'Project Discussion', '
        Hi Bob,

Thank you for your feedback. I have updated the proposal to include a detailed project timeline and estimated costs. You can find the revised document attached.

Please let me know if this meets your requirements. If not, please dont hesitate to reach out with any further changes.

Best,
Alice'),
			( 'bob@example.com', 12345, '2024-09-23 10:30:00', 'Project Discussion', 'Hi Alice,

I have reviewed the revised proposal and it looks great. I would like to schedule a meeting to discuss the project further. Would you be available tomorrow at 2 PM?

Looking forward to hearing back from you.

Best,
Bob'),
			( 'carol@example.com', 12345, '2024-09-23 11:00:00', 'Project Discussion', 'Hi Bob,

I would be happy to meet with you tomorrow at 2 PM. I will make sure to bring any necessary documents and materials.

Looking forward to our discussion!

Best,
Alice'),
			('alice@example.com', 12345, '2024-09-23 11:15:00', 'Project Discussion', 'Absolutely, the more, the merrier!'),
			('dave@example.com', 12345, '2024-09-23 11:30:00', 'Project Discussion', 'Count me in for the meeting too!'),
			('bob@example.com', 12345, '2024-09-23 12:00:00', 'Project Discussion', 'Perfect! I’ll send a calendar invite.'),
			('carol@example.com', 12346, '2024-09-23 13:00:00', 'Feedback on the Proposal', 'Hi Alice, I reviewed the proposal. I have some suggestions.'),
			('alice@example.com', 12346, '2024-09-23 14:00:00', 'Feedback on the Proposal', 'Thanks, Carol! I’d love to hear your thoughts.'),
			('carol@example.com', 12346, '2024-09-23 14:30:00', 'Feedback on the Proposal', 'Let’s discuss it during our next meeting.'),
			('dave@example.com', 12346, '2024-09-23 15:00:00', 'Feedback on the Proposal', 'I also have some feedback to share.'),
			('alice@example.com', 12346, '2024-09-23 15:15:00', 'Feedback on the Proposal', 'Sounds great! Let’s make it a point to discuss.'),
			('bob@example.com', 12346, '2024-09-23 15:30:00', 'Feedback on the Proposal', 'I can’t wait to hear everyone’s input!'),
			('alice@example.com', 12347, '2024-09-23 16:00:00', 'Follow-Up', 'Hi team, just following up on our discussion from last week.'),
			('carol@example.com', 12347, '2024-09-23 16:15:00', 'Follow-Up', 'Thanks for the reminder, Alice! I’ll finalize my notes.'),
			('bob@example.com', 12347, '2024-09-23 16:30:00', 'Follow-Up', 'I’ll add my input by tomorrow.'),
			('dave@example.com', 12347, '2024-09-23 17:00:00', 'Follow-Up', 'Looking forward to it!'),
			('alice@example.com', 12348, '2024-09-23 18:00:00', 'Meeting Reminder', 'Hi everyone, just a quick reminder about our meeting tomorrow.'),
			('bob@example.com', 12348, '2024-09-23 18:30:00', 'Meeting Reminder', 'Thanks for the reminder, Alice!'),
			('carol@example.com', 12348, '2024-09-23 19:00:00', 'Meeting Reminder', 'I’ll be there!'),
			('dave@example.com', 12348, '2024-09-23 19:30:00', 'Meeting Reminder', '          : See you all tomorrow!'),
			('alice@example.com', 12349, '2024-09-24 08:00:00', 'Project Update', 'Morning team, here’s the latest update on the project.'),
			('bob@example.com', 12349, '2024-09-24 08:30:00', 'Project Update', 'Thanks for the update, Alice! Looks good.'),
			('carol@example.com', 12349, '2024-09-24 09:00:00', 'Project Update', 'I agree! Let’s keep up the momentum.'),
			('dave@example.com', 12349, '2024-09-24 09:30:00', 'Project Update', 'Great job, team!'),
			('alice@example.com', 12350, '2024-09-24 10:00:00', 'Feedback Request', 'Hi team, we’d love your feedback on the latest changes.'),
			('bob@example.com', 12350, '2024-09-24 10:30:00', 'Feedback Request', 'I’ll review it and share my thoughts.'),
			('carol@example.com', 12350, '2024-09-24 11:00:00', 'Feedback Request', 'I’m on it!'),
			('dave@example.com', 12350, '2024-09-24 11:30:00', 'Feedback Request', 'Looking forward to everyone’s input!'),
			('alice@example.com', 12351, '2024-09-24 12:00:00', 'Survey Invitation', 'Hi team, please take a moment to fill out the survey.'),
			('bob@example.com', 12351, '2024-09-24 12:30:00', 'Survey Invitation', 'Will do!'),
			('carol@example.com', 12351, '2024-09-24 13:00:00', 'Survey Invitation', 'Thanks for sharing, Alice!'),
			('dave@example.com', 12351, '2024-09-24 13:30:00', 'Survey Invitation', 'I appreciate the reminder!'),
			('alice@example.com', 12352, '2024-09-24 14:00:00', 'Final Thoughts', 'Thanks for all the feedback, everyone!'),
			('bob@example.com', 12352, '2024-09-24 14:30:00', 'Final Thoughts', 'It’s been a productive discussion!'),
			('carol@example.com', 12352, '2024-09-24 15:00:00', 'Final Thoughts', 'Agreed! Looking forward to our next steps.'),
			('dave@example.com', 12352, '2024-09-24 15:30:00', 'Final Thoughts', 'Let’s keep the momentum going!'),
			('alice@example.com', 12353, '2024-09-24 16:00:00', 'Next Steps', 'Hi team, what are our next steps?'),
			('bob@example.com', 12353, '2024-09-24 16:30:00', 'Next Steps', 'I think we should outline a timeline.'),
			('carol@example.com', 12353, '2024-09-24 17:00:00', 'Next Steps', 'Sounds like a plan!'),
			('dave@example.com', 12353, '2024-09-24 17:30:00', 'Next Steps', 'Let’s schedule a meeting to discuss.'),
			('alice@example.com', 12354, '2024-09-24 18:00:00', 'Wrap-Up', 'Thanks for the great discussion today!'),
			('bob@example.com', 12354, '2024-09-24 18:30:00', 'Wrap-Up', 'It was productive!'),
			('carol@example.com', 12354, '2024-09-24 19:00:00', 'Wrap-Up', 'Looking forward to our next meeting!'),
			('dave@example.com', 12354, '2024-09-24 19:30:00', 'Wrap-Up', 'Thanks, everyone!'),
			('alice@example.com', 12355, '2024-09-24 20:00:00', 'Thank You', 'Just wanted to say thanks for your hard work!'),
			('bob@example.com', 12355, '2024-09-24 20:30:00', 'Thank You', 'Thank you, Alice!'),
			('carol@example.com', 12355, '2024-09-24 21:00:00', 'Thank You', 'Thanks, Alice!'),
			('dave@example.com', 12355, '2024-09-24 21:30:00', 'Thank You', 'Appreciate it, Alice!');




INSERT INTO email_threads (
			email_thread_id,
			thread_topic
		)
			SELECT
				email_thread_id,
				email_subject
			FROM emails
			GROUP BY
				email_thread_id,
				email_subject
			ORDER BY
				email_thread_id;
				
ALTER TABLE emails
		ADD CONSTRAINT emails_fkey
		FOREIGN KEY (email_thread_id)
		REFERENCES email_threads (email_thread_id);
