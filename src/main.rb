require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'
require 'json'

enable :sessions

# general configuration
configure do
	set :root, File.expand_path("..", File.dirname(__FILE__))
	set :public_folder, 'static'
	set :partial_template_engine, :erb
	mime_type :woff, 'application/x-font-woff'
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

require_relative 'content.rb'
Content.load 'content'

helpers do
	# paths
	def path_to_puzzle(puzzle)
		url "/puzzles/#{puzzle.slug}"
	end
	def path_to_puzzle_answer(puzzle)
		url "/puzzles/#{puzzle.slug}/answer"
	end
	def path_to_category(category)
		url "/categories/#{category.slug}"
	end

	# other
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	@categories = Category.all
	erb :index
end

get '/random' do
	puzzle = Puzzle.all.sample
	redirect path_to_puzzle puzzle
end

get '/search' do
	@title = "Search"
	@q = (params[:q] || "").strip
	@puzzles = Puzzle.search @q

	erb :search
end

get '/puzzles' do
	@title = "All puzzles"
	@puzzles = Puzzle.all

	erb :all
end

before '/puzzles/:slug*' do
	@puzzle = Puzzle.find params[:slug]
	if @puzzle.nil?
		raise error 404
	end
end

get '/puzzles/:slug' do
	@title = @puzzle.title
	erb :show_puzzle
end

get '/puzzles/:slug/answer' do
	@title = "Answer for #{@puzzle.title}"
	erb :show_answer
end

get '/categories' do
	"TODO: "
end

get '/categories/:slug' do
	@category = Category.find params[:slug]
	if @category.nil?
		raise error 404
	end

	@title = "#{@category.title} puzzles"

	@puzzles = @category.puzzles
	erb :show_category
end

require_relative 'auth.rb'
require_relative 'feeds.rb'
