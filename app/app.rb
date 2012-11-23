require 'rack/csrf'
class MonkeyPuzzles < Padrino::Application
  use ActiveRecord::ConnectionAdapters::ConnectionManagement
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions
  use Rack::Csrf, :raise => true

  ##
  # Caching support
  #
  # register Padrino::Cache
  # enable :caching
  #
  # You can customize caching store engines:
  #
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
  #   set :cache, Padrino::Cache::Store::Memory.new(50)
  #   set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
  #

  ##
  # Application configuration options
  #
  # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
  # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
  # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
  # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
  # set :public_folder, "foo/bar" # Location for static assets (default root/public)
  # set :reload, false            # Reload application files (default in development)
  # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
  # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
  # disable :sessions             # Disabled sessions by default (enable if needed)
  # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
  # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
  #

  mime_type :woff, 'application/x-font-woff'

  ##
  # You can configure for a specified environment like:
  #
  #   configure :development do
  #     set :foo, :bar
  #     disable :asset_stamp # no asset timestamping for dev
  #   end
  #

  ##
  # You can manage errors like:

  error 404 do
    render 'errors/404'
  end

  error 500 do
    render 'errors/500'
  end


  get :index, :map => "/" do
    @categories = Category.all
    @top_liked = Puzzle.all.sort {|a,b| b.num_likes <=> a.num_likes}.
      take(5).take_while {|a| a.num_likes > 0}
    @most_commented = Puzzle.all.sort {|a,b| b.num_comments <=> a.num_comments}.
      take(5).take_while {|a| a.num_comments > 0}
    render 'index'
  end

  get :search do
    @title = "Search"
    @q = (params[:q] || "").strip
    @puzzles = Puzzle.search @q

    render 'search'
  end

  get :random do
    puzzle = Puzzle.all.sample
    redirect url_for(:puzzles, :show, :slug => puzzle.slug)
  end

  get :no_route_found, :map => /\/.+/, :priority => :low do
    not_found
  end
end
