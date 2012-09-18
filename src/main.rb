require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/json'
require 'data_mapper'

require_relative 'config.rb'

require_relative 'content.rb'
Content.load 'content'

require_relative 'user.rb'

DataMapper.auto_upgrade!

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

get '/status' do
	status = {}
	status[:status] = 'ok'
	status[:num_puzzles] =  Puzzle.all.length
	status[:num_categories] = Category.all.length

	status[:num_users] = User.all.length
	status[:num_db_rows] = status[:num_users]

	json status
end

require_relative 'auth.rb'
require_relative 'feeds.rb'
