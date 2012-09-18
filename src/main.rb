require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/json'
require 'data_mapper'
require 'rack/csrf'

require_relative 'config.rb'

require_relative 'content.rb'
Content.load 'content'

require_relative 'user.rb'
require_relative 'content_meta.rb'

require_relative 'migrations.rb'
DataMapper.auto_upgrade!
DataMapper.finalize

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

	# csrf
	def csrf_token
		Rack::Csrf.csrf_token(env)
	end
	def csrf_tag
		Rack::Csrf.csrf_tag(env)
	end
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

post '/puzzles/:slug/comments' do
	if not login?
		return json :status => 'error', :error => 'Not logged in'
	end

	content = params[:content].strip

	if content.empty?
		return json :status => 'error', :error => 'Content is empty'
	end

	Comment.create(:puzzle_id => @puzzle.id, :content => content, :user => user)
	@puzzle.reset_comments!

	json :status => 'ok', :url => path_to_puzzle(@puzzle)
end

post '/puzzles/:slug/like' do
	if not login?
		return json :status => 'error', :error => 'Not logged in'
	end

	action = params[:action]

	case action
	when 'like'
		puts "Liking puzzle #{@puzzle.id}, #{user}"
		like = Like.first_or_create(:puzzle_id => @puzzle.id, :user => user, :action => :like)
	when 'unlike'
		puts "Unliking puzzle"
		like = Like.first(:puzzle_id => @puzzle.id, :user => user)
		like.destroy if like
	else
		return json :status => 'error', :error => "Unknown action #{action}"
	end

	@puzzle.reset_likes!

	json :status => 'ok', :action => action, :num_likes => @puzzle.num_likes
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

	status[:num_users] = User.count
	status[:num_comments] = Comment.count
	status[:num_likes] = Like.count
	status[:num_db_rows] = status[:num_users] + status[:num_comments] +
		status[:num_likes]

	json status
end

require_relative 'auth.rb'
require_relative 'feeds.rb'
