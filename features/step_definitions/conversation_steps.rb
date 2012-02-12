require File.expand_path('../../support/env', __FILE__)

Given /^I have a conversation with a user reference$/ do
	@conversation = Conversation.new([
		"05:54 <Frost> ok, that's cool I guess. What will it return?",
		"05:55 <test> something that is not relevant!",
		"05:55 <namelessjon> Frost: The results, in whichever order the data-store chooses to give you them."
	])
end

When /^I parse it$/ do
	@question = @conversation.questions.first
	@answer = @conversation.get_answers(@question).first
end

Then /^I should see a question and the answer$/ do
	@question.username.should == "Frost"
	@answer.username.should == "namelessjon"
end
