# general configuration
configure do
	enable :sessions
	use Rack::Csrf, :raise => true
	set :root, File.expand_path("..", File.dirname(__FILE__))
	set :public_folder, 'static'
	set :partial_template_engine, :erb
	mime_type :woff, 'application/x-font-woff'
end

# database configuration
DataMapper::Logger.new($stdout, :debug)
configure :development do
	DataMapper.setup :default, "sqlite://#{File.join(settings.root, 'dev.db')}"
end
configure :production do
	DataMapper.setup :default, ENV['DATABASE_URL']
end

# error handling
configure :production do
	content_for_404 = File.read(File.join(settings.root, 'views', '404.html'))
	content_for_500 = File.read(File.join(settings.root, 'views', '500.html'))

	not_found do
		content_for_404
	end
	error 500 do
		content_for_500
	end
end

# google analytics
configure :development do
	set :tracking_script, "<!-- tracking scripts go here in production -->"
end
configure :production do
	set :tracking_script, File.read(File.join(settings.root, 'views', 'google_analytics.html'))
end
helpers do
	def tracking_script
		settings.tracking_script
	end
end
