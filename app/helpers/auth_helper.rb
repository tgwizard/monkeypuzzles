MonkeyPuzzles.helpers do
  def login?
    !user.nil?
  end

  def user
    @current_user ||= User.find(session[:user_id]) if !session[:user_id].nil?
  end

  def require_login!
    raise error 401, "Unauthorized: Not logged in" unless login?
  end
end
