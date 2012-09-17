require 'nestful'

require_relative 'user.rb'

helpers do
	def login?
		!session[:user].nil?
	end

	def user
		session[:user]
	end
end

post "/auth/login" do
	if params[:assertion]
		verify_url = "https://verifier.login.persona.org/verify"
		verify_params = {
			:assertion => "#{params[:assertion]}",
			:audience => url('/')
		}

		puts "Auth assertion verification #{verify_url} :: #{verify_params.to_json}"

		data = Nestful.post verify_url, :format => :json, :params => verify_params
		#data = {"status" => "error"}
		if data["status"] == "okay"
			session[:user] = User.get(:email => data["email"])
			return data.to_json
		end
	end
	return {:status => "error"}.to_json
end

post "/auth/logout" do
	session[:user] = nil
	return {:status => "ok"}.to_json
end
