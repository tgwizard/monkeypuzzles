MonkeyPuzzles.helpers do
  # csrf
  def csrf_token
    Rack::Csrf.csrf_token(env)
  end
  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end
end
