MonkeyPuzzles.helpers do
  def login?
    !user.nil?
  end

  def user
    if !session[:user_id].nil?
      begin
        @current_user ||= User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
      end
    end
  end

  def require_login!
    raise error 401, "Unauthorized: Not logged in" unless login?
  end
end
