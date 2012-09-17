class User
	attr_reader :email
	def initialize(data)
		@email = data[:email]
	end

	def self.get(data)
		User.new data
	end
end

