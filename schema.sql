CREATE TABLE emails (
			email_record_id INT PRIMARY KEY,
			sender_email CHAR(50) NOT NULL,
			email_thread_id INT NOT NULL,
			email_received_timestamp TIMESTAMP,
			email_subject CHAR(50) NOT NULL,
			email_content TEXT
		);


		CREATE TABLE email_threads (
			email_thread_id integer primary key,
			thread_topic CHAR(50)
		);		

INSERT INTO emails (
			email_record_id,
			sender_email,
			email_thread_id,
			email_received_timestamp,
			email_subject, email_content
		)
		VALUES
			(1, 'alice@example.com', 12345, '2024-09-23 08:00:00', 'Project Discussion', 'Hi Bob, 

I hope this email finds you well. I wanted to follow up on our previous discussion about the project details. I have attached a revised proposal that includes some additional information. Please 
review and let me know if there are any changes you would like to see.

Best,
Alice'),
			(2, 'bob@example.com', 12345, '2024-09-23 09:30:00', 'Project Discussion', 'Hi Alice,

Thank you for the revised proposal. I have reviewed it and would like to request a few changes. Please see below:

* Can we include a more detailed project timeline?
* Would it be possible to provide a breakdown of the estimated costs?

Looking forward to hearing back from you.

Best,
Bob'),
			(3, 'alice@example.com', 12345, '2024-09-23 10:00:00', 'Project Discussion', '
        Hi Bob,

Thank you for your feedback. I have updated the proposal to include a detailed project timeline and estimated costs. You can find the revised document attached.

Please let me know if this meets your requirements. If not, please dont hesitate to reach out with any further changes.

Best,
Alice'),
			(4, 'bob@example.com', 12345, '2024-09-23 10:30:00', 'Project Discussion', 'Hi Alice,

I have reviewed the revised proposal and it looks great. I would like to schedule a meeting to discuss the project further. Would you be available tomorrow at 2 PM?

Looking forward to hearing back from you.

Best,
Bob'),
			(5, 'carol@example.com', 12345, '2024-09-23 11:00:00', 'Project Discussion', 'Hi Bob,

I would be happy to meet with you tomorrow at 2 PM. I will make sure to bring any necessary documents and materials.

Looking forward to our discussion!

Best,
Alice'),
			(6, 'alice@example.com', 12345, '2024-09-23 11:15:00', 'Project Discussion', 'Absolutely, the more, the merrier!'),
			(7, 'dave@example.com', 12345, '2024-09-23 11:30:00', 'Project Discussion', 'Count me in for the meeting too!'),
			(8, 'bob@example.com', 12345, '2024-09-23 12:00:00', 'Project Discussion', 'Perfect! I’ll send a calendar invite.'),
			(9, 'carol@example.com', 12346, '2024-09-23 13:00:00', 'Feedback on the Proposal', 'Hi Alice, I reviewed the proposal. I have some suggestions.'),
			(10, 'alice@example.com', 12346, '2024-09-23 14:00:00', 'Feedback on the Proposal', 'Thanks, Carol! I’d love to hear your thoughts.'),
			(11, 'carol@example.com', 12346, '2024-09-23 14:30:00', 'Feedback on the Proposal', 'Let’s discuss it during our next meeting.'),
			(12, 'dave@example.com', 12346, '2024-09-23 15:00:00', 'Feedback on the Proposal', 'I also have some feedback to share.'),
			(13, 'alice@example.com', 12346, '2024-09-23 15:15:00', 'Feedback on the Proposal', 'Sounds great! Let’s make it a point to discuss.'),
			(14, 'bob@example.com', 12346, '2024-09-23 15:30:00', 'Feedback on the Proposal', 'I can’t wait to hear everyone’s input!'),
			(15, 'alice@example.com', 12347, '2024-09-23 16:00:00', 'Follow-Up', 'Hi team, just following up on our discussion from last week.'),
			(16, 'carol@example.com', 12347, '2024-09-23 16:15:00', 'Follow-Up', 'Thanks for the reminder, Alice! I’ll finalize my notes.'),
			(17, 'bob@example.com', 12347, '2024-09-23 16:30:00', 'Follow-Up', 'I’ll add my input by tomorrow.'),
			(18, 'dave@example.com', 12347, '2024-09-23 17:00:00', 'Follow-Up', 'Looking forward to it!'),
			(19, 'alice@example.com', 12348, '2024-09-23 18:00:00', 'Meeting Reminder', 'Hi everyone, just a quick reminder about our meeting tomorrow.'),
			(20, 'bob@example.com', 12348, '2024-09-23 18:30:00', 'Meeting Reminder', 'Thanks for the reminder, Alice!'),
			(21, 'carol@example.com', 12348, '2024-09-23 19:00:00', 'Meeting Reminder', 'I’ll be there!'),
			(22, 'dave@example.com', 12348, '2024-09-23 19:30:00', 'Meeting Reminder', '          : See you all tomorrow!'),
			(23, 'alice@example.com', 12349, '2024-09-24 08:00:00', 'Project Update', 'Morning team, here’s the latest update on the project.'),
			(24, 'bob@example.com', 12349, '2024-09-24 08:30:00', 'Project Update', 'Thanks for the update, Alice! Looks good.'),
			(25, 'carol@example.com', 12349, '2024-09-24 09:00:00', 'Project Update', 'I agree! Let’s keep up the momentum.'),
			(26, 'dave@example.com', 12349, '2024-09-24 09:30:00', 'Project Update', 'Great job, team!'),
			(27, 'alice@example.com', 12350, '2024-09-24 10:00:00', 'Feedback Request', 'Hi team, we’d love your feedback on the latest changes.'),
			(28, 'bob@example.com', 12350, '2024-09-24 10:30:00', 'Feedback Request', 'I’ll review it and share my thoughts.'),
			(29, 'carol@example.com', 12350, '2024-09-24 11:00:00', 'Feedback Request', 'I’m on it!'),
			(30, 'dave@example.com', 12350, '2024-09-24 11:30:00', 'Feedback Request', 'Looking forward to everyone’s input!'),
			(31, 'alice@example.com', 12351, '2024-09-24 12:00:00', 'Survey Invitation', 'Hi team, please take a moment to fill out the survey.'),
			(32, 'bob@example.com', 12351, '2024-09-24 12:30:00', 'Survey Invitation', 'Will do!'),
			(33, 'carol@example.com', 12351, '2024-09-24 13:00:00', 'Survey Invitation', 'Thanks for sharing, Alice!'),
			(34, 'dave@example.com', 12351, '2024-09-24 13:30:00', 'Survey Invitation', 'I appreciate the reminder!'),
			(35, 'alice@example.com', 12352, '2024-09-24 14:00:00', 'Final Thoughts', 'Thanks for all the feedback, everyone!'),
			(36, 'bob@example.com', 12352, '2024-09-24 14:30:00', 'Final Thoughts', 'It’s been a productive discussion!'),
			(37, 'carol@example.com', 12352, '2024-09-24 15:00:00', 'Final Thoughts', 'Agreed! Looking forward to our next steps.'),
			(38, 'dave@example.com', 12352, '2024-09-24 15:30:00', 'Final Thoughts', 'Let’s keep the momentum going!'),
			(39, 'alice@example.com', 12353, '2024-09-24 16:00:00', 'Next Steps', 'Hi team, what are our next steps?'),
			(40, 'bob@example.com', 12353, '2024-09-24 16:30:00', 'Next Steps', 'I think we should outline a timeline.'),
			(41, 'carol@example.com', 12353, '2024-09-24 17:00:00', 'Next Steps', 'Sounds like a plan!'),
			(42, 'dave@example.com', 12353, '2024-09-24 17:30:00', 'Next Steps', 'Let’s schedule a meeting to discuss.'),
			(43, 'alice@example.com', 12354, '2024-09-24 18:00:00', 'Wrap-Up', 'Thanks for the great discussion today!'),
			(44, 'bob@example.com', 12354, '2024-09-24 18:30:00', 'Wrap-Up', 'It was productive!'),
			(45, 'carol@example.com', 12354, '2024-09-24 19:00:00', 'Wrap-Up', 'Looking forward to our next meeting!'),
			(46, 'dave@example.com', 12354, '2024-09-24 19:30:00', 'Wrap-Up', 'Thanks, everyone!'),
			(47, 'alice@example.com', 12355, '2024-09-24 20:00:00', 'Thank You', 'Just wanted to say thanks for your hard work!'),
			(48, 'bob@example.com', 12355, '2024-09-24 20:30:00', 'Thank You', 'Thank you, Alice!'),
			(49, 'carol@example.com', 12355, '2024-09-24 21:00:00', 'Thank You', 'Thanks, Alice!'),
			(50, 'dave@example.com', 12355, '2024-09-24 21:30:00', 'Thank You', 'Appreciate it, Alice!');




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
