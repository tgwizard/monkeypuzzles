MonkeyPuzzles.helpers do
  # csrf
  def csrf_token
    Rack::Csrf.csrf_token(env)
  end
  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  # tracking script
  def tracking_script
    if settings.environment == :production
      render "google_analytics", :layout => false
    end
  end
end
