require 'digest/md5'

class User
	attr_reader :email, :gravatar_url
	def initialize(data)
		@email = data[:email]
		@gravatar_url = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email.strip.downcase)}"
	end

	def self.get(data)
		User.new data
	end
end

