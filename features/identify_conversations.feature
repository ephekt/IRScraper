Feature: Identify when a conversation starts

	Scenario: Conversation starts with a question
		Given I have a channel log with a question
		When I parse it
		Then I should see a conversation that starts with a question
