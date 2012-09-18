require 'nestful'

require_relative 'user.rb'

helpers do
	# FIXME: cookie-stealing?
	def login?
		!session[:user_id].nil?
	end

	def user
		@current_user ||= User.first(:id => session[:user_id])
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
			user = User.first_or_create(:email => data["email"], :identity_provider => :persona)
			user.update_login!
			session[:user_id] = user.id
			return data.to_json
		end
	end
	return {:status => "error"}.to_json
end

post "/auth/logout" do
	session[:user_id] = nil
	return {:status => "ok"}.to_json
end
