require 'digest/md5'

class User
	include DataMapper::Resource
	attr_reader :email

	property :id, Serial
	property :email, String, :required => true, :unique => true, :length => 256
	property :idp, Enum[:persona], :required => true
	property :created_at, DateTime, :writer => :private, :default => lambda {|r,p| Time.now}

	def gravatar_url
		"http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email.strip.downcase)}"
	end
end

