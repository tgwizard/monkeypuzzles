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

	def require_login!
		raise error 401, "Unauthorized: Not logged in" unless login?
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
		if data["status"] == "okay"
			user_params = {:email => data["email"], :identity_provider => :persona}
			if user = User.first(user_params)
				show_settings = false
			else
				user = User.create(user_params)
				show_settings = true
			end
			user.update_login!
			session[:user_id] = user.id
			return json :status => "ok", :show_settings => show_settings
		else
			return json :status => "error", :error => "Assertion verification failed"
		end
	end
	json :status => "error", :error => "No assertion provided"
end

post "/auth/logout" do
	require_login!
	session[:user_id] = nil
	return {:status => "ok"}.to_json
end

get "/settings" do
	require_login!
	erb :settings, :layout => false
end

post "/settings" do
	require_login!
	u = user

	if u.username.nil?
		u.username = params[:username].strip
	end
	u.use_gravatar = params[:use_gravatar] == "true"

	if u.save
		json :status => 'ok'
	else
		json :status => 'error', :error => u.errors
	end
end
