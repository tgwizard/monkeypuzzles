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

  def make_title(title)
    if not title.nil?
      "#{title} - Monkeypuzzles"
    else
      "Monkeypuzzles, puzzles not even a monkey could solve"
    end
  end

  def get_meta_og_url
    @meta_og_url || uri(request.path_info)
  end

  def set_meta_og_url(url)
    @meta_og_url = url
  end

  def get_meta_og_type
    @meta_og_type || "website"
  end

  def set_meta_og_type(type)
    @meta_og_type = type
  end
end
