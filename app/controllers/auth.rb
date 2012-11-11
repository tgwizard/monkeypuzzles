MonkeyPuzzles.controllers :auth do
  post :login, :provides => :json do
    if not params[:assertion]
      raise error 401, "No assertion provided"
    end

    verify_url = "https://verifier.login.persona.org/verify"
    verify_params = {
      :assertion => "#{params[:assertion]}",
      :audience => url('/')
    }

    puts "Auth assertion verification #{verify_url} :: #{verify_params.to_json}"

    data = Nestful.post verify_url, :format => :json, :params => verify_params
    if data["status"] != "okay"
      raise error 401, "Assertion verification failed"
    end

    user = User.where(:email => data["email"]).first
    show_settings = false
    if not user
      puts "asdfasdf"
      user = User.new(:email => data["email"])
      if !user.save
        # TODO: return something other than 200
        puts "Error creating user: ", user.errors.full_messages
        raise error 500, user.errors.full_messages
      end
      show_settings = true
    end

    puts user

    #user.update_login!
    session[:user_id] = user.id

    puts "saved to session"
    puts session[:user_id]

    render :status => "ok", :show_settings => show_settings
  end

  post :logout, :provides => :json do
    session[:user_id] = nil
    render :status => "ok"
  end

  get :settings do
    require_login!
    render "auth/settings", :layout => false
  end

  post :settings, :provides => :json do
    require_login!

    if not user.username_set?
      username = params[:username]
      username = username.strip if username
      user.username = username if username.length > 0
    end
    user.use_gravatar = params[:use_gravatar] == "true"

    if user.save
      render :status => 'ok'
    else
      status = {:status => 'error', :error => []}
      user.errors.each do |e|
        status[:error] << e
      end
      render status
    end
  end
end
