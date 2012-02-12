require File.expand_path(File.join(File.dirname(__FILE__), 'line'))

class Conversation
	def initialize(lines)
		@lines = []
		@chat_lines = []
		@usernames = []

		lines.each_with_index do |line, i|
			_line = Line.new(line, i)

			@lines << _line
			@chat_lines << _line if _line.is_chat?
			@usernames << _line.username
		end
	end

	def questions
		@chat_lines.select { |chat_line| chat_line.contains_question? }
	end

	def get_answers(line)
		answers = []
		@chat_lines[line.line_number+1..-1].each do |potential_answer|
			if potential_answer.contains_answer? line.username
				answers << potential_answer 
			end
		end

		return answers
	end
end
