require 'digest/md5'

class User
	include DataMapper::Resource

	property :id, Serial
	property :email, String, :required => true, :unique => true, :length => 256
	property :identity_provider, Enum[:persona], :required => true
	property :created_at, DateTime, :writer => :private, :default => lambda {|r,p| Time.now}
	property :login_at, DateTime, :default => lambda {|r,p| Time.now}

	def gravatar_url
		"http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email.strip.downcase)}"
	end

	def update_login!
		self.login_at = Time.now
		save!
	end
end

