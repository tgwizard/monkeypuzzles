class Comment
	include DataMapper::Resource

	property :id, Serial
	property :puzzle_id, Integer, :required =>  true
	property :content, Text, :required => true, :lazy => false
	property :created_at, DateTime, :required => true, :default => lambda {|r,p| Time.now}

	belongs_to :user
end

class Like
	include DataMapper::Resource

	property :puzzle_id, Integer, :unique => false, :index => true, :key => true
	belongs_to :user, :key => true

	property :action, Enum[:like], :required => true
	property :created_at, DateTime, :required => true, :default => lambda {|r,p| Time.now}
end

class User
	has n, :comments
	has n, :likes
end

class Puzzle
	def comments
		@comments ||= Comment.all(:puzzle_id => @id, :order => [:created_at.asc])
	end
	def reset_comments!
		@comments = nil
	end

	def num_likes
		@num_likes ||= Like.count(:puzzle_id => @id)
	end
	def reset_likes!
		@num_likes = nil
	end
	def user_likes?(user)
		puts "Checking likes #{user.email}"
		a = !user.nil? && Like.count(:puzzle_id => @id, :user => user, :action => :like) > 0
		puts a
		return a
	end
end
