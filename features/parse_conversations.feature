Feature: Parse a conversation between 2 users

	Scenario: Asker's username mentioned
		Given I have a conversation with a user reference
		When I parse it
		Then I should see a question and the answer

	Scenario: No username mentioned
		Given I have a conversation without a user reference
		When I parse it
		Then I should see a question and next 10 responses
