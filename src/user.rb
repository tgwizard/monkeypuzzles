require 'digest/md5'

class User
	include DataMapper::Resource

	property :id, Serial
	property :email, String, :required => true, :unique => true, :length => 256
	property :identity_provider, Enum[:persona], :required => true

	property :username, String, :required => false, :unique => true, :length => 32
	property :use_gravatar, Boolean, :required => true, :default => true


	property :created_at, DateTime, :writer => :private, :default => lambda {|r,p| Time.now}
	property :login_at, DateTime, :default => lambda {|r,p| Time.now}

	def anonymous_username
		"anonymous-#{self.id}"
	end

	def username_set?
		!self.username.nil?
	end

	def display_username
		username_set? ? @username : anonymous_username
	end

	def image_url
		if use_gravatar
			gravatar_url
		else
			"http://www.gravatar.com/avatar/asdf"
		end
	end

	def gravatar_url
		"http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email.strip.downcase)}"
	end

	def update_login!
		self.login_at = Time.now
		save!
	end
end

