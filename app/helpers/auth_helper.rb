MonkeyPuzzles.helpers do
  def login?
    false
  end

  def user
    @current_user = nil
  end

  def require_login!
    raise error 401, "Unauthorized: Not logged in" unless login?
  end
end
