require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'

require_relative 'puzzles.rb'
Puzzle.load 'content'

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

helpers do
	# paths
	def path_to_puzzle(puzzle)
		url "/puzzles/#{puzzle.slug}"
	end
	def path_to_puzzle_answer(puzzle)
		url "/puzzles/#{puzzle.slug}/answer"
	end
	def path_to_category(category)
		url "/categories/#{category.downcase}"
	end

	# other
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	@categories = Puzzle.categories.to_a.sort do |a,b|
		if a[0] == Puzzle::NO_CATEGORY
			1
		elsif b[0] == Puzzle::NO_CATEGORY
			-1
		else
			a[0] <=> b[0]
		end
	end

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

get '/categories/:category' do
	@category = params[:category].downcase
	@title = "#{@category.capitalize} puzzles"
	if Puzzle.categories[@category].nil?
		raise error 404
	end
	if @category == Puzzle::NO_CATEGORY
		@puzzles = Puzzle.all.select {|p| p.categories.empty?}
	else
		@puzzles = Puzzle.all.select {|p| p.categories.include? @category}
	end
	erb :show_category
end

require_relative 'feeds.rb'
