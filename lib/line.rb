class Line
	attr_reader :line_number

	def initialize(str, i)
		@words = str.split
		@line_number = i
	end

	def timestamp
		Time.parse(@words[0])
	end

	def username
		if is_chat?
			@words[1][1...-1]
		else
			@words[1]
		end
	end

	def content
		if is_chat?
			[@words[2]..-1].join(" ")
		elsif is_status?
			@words.last
		else
			nil
		end
	end

	def is_chat?
		@words[1].first == "<" && @words[1].last == ">"
	end

	def is_status?
		@words.last == "joined" || @words.last == "left"
	end

	def contains_question?
		@words.join(" ").include? "?"
	end

	def contains_answer?(username)
		self.contains_reference?(username)
	end

	def contains_reference?(username)
		@words.join(" ").downcase.include? username.downcase
	end

	def contains_praise?
		@words.map(&:downcase).include?["thank", "thanks", "helpful"]
	end
end

class String
	def first
		self.chars.first
	end

	def last
		self[-1]
	end
end
