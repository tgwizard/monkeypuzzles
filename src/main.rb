require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'

require_relative 'puzzles.rb'

configure do
	set :root, File.expand_path("..", File.dirname(__FILE__))
	set :public_folder, 'static'
	set :partial_template_engine, :erb
end

configure :production do
	not_found do
		"404 - Not Found"
	end

	error do
		"Nasty error encountered"
	end
end

helpers do
	def path_to_puzzle(puzzle)
		url "/puzzle/#{puzzle.slug}"
	end
	def path_to_puzzle_answer(puzzle)
		url "/puzzle/#{puzzle.slug}/answer"
	end
end

get '/' do
	erb :index
end

get '/random' do
	puzzle = Puzzle.all.sample
	redirect path_to_puzzle puzzle
end

get '/list' do
	@puzzles = Puzzle.all
end

get '/search' do
	@q = params[:q]
	@puzzles = Puzzle.search @q
	erb :search
end

before '/puzzle/:slug*' do
	@puzzle = Puzzle.find params[:slug]
	if @puzzle.nil?
		raise error 404
	end
end

get '/puzzle/:slug' do
	i = Puzzle.all.index @puzzle
	@prev_puzzle_url = path_to_puzzle Puzzle.all[(i-1 + Puzzle.all.length) % Puzzle.all.length]
	@next_puzzle_url = path_to_puzzle Puzzle.all[(i+1 + Puzzle.all.length) % Puzzle.all.length]
	erb :show_puzzle
end

get '/puzzle/:slug/answer' do
	erb :show_answer
end
