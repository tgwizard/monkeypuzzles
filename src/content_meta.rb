class Comment
	include DataMapper::Resource

	property :id, Serial
	property :puzzle_id, Integer, :required =>  true
	property :content, Text, :required => true, :lazy => false
	property :created_at, DateTime, :required => true, :default => lambda {|r,p| Time.now}

	belongs_to :user
end

class User
	has n, :comments
end

class Puzzle
	def comments
		@comments ||= Comment.all(:puzzle_id => @id, :order => [:created_at.asc])
	end
	def reset_comments!
		@comments = nil
	end
end
