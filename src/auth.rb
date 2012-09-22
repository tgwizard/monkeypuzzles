require 'nestful'

require_relative 'user.rb'

helpers do
	# FIXME: cookie-stealing?
	def login?
		!session[:user_id].nil? && !user.nil?
	end

	def user
		@current_user ||= User.first(:id => session[:user_id])
	end

	def require_login!
		raise error 401, "Unauthorized: Not logged in" unless login?
	end
end

post "/auth/login" do
	if not params[:assertion]
		return json :status => "error", :error => "No assertion provided"
	end

	verify_url = "https://verifier.login.persona.org/verify"
	verify_params = {
		:assertion => "#{params[:assertion]}",
		:audience => url('/')
	}

	puts "Auth assertion verification #{verify_url} :: #{verify_params.to_json}"

	data = Nestful.post verify_url, :format => :json, :params => verify_params
	if data["status"] != "okay"
		return json :status => "error", :error => "Assertion verification failed"
	end

	if user = User.first(:email => data["email"])
		show_settings = false
	else
		user = User.create(:email => data["email"], :identity_provider => :persona)
		show_settings = true
	end

	user.update_login!
	session[:user_id] = user.id

	return json :status => "ok", :show_settings => show_settings
end

post "/auth/logout" do
	session[:user_id] = nil
	return {:status => "ok"}.to_json
end

get "/user/settings" do
	require_login!
	erb :settings, :layout => false
end

post "/user/settings" do
	require_login!

	if user.username.nil?
		username = params[:username]
		username = username.strip if username
		user.username = username if username.length > 0
	end
	user.use_gravatar = params[:use_gravatar] == "true"

	if user.save
		json :status => 'ok'
	else
		json :status => 'error', :error => user.errors
	end
end
