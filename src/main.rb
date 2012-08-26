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

helpers do
	def path_to_puzzle(puzzle)
		url "/puzzle/#{puzzle.slug}"
	end
	def path_to_puzzle_answer(puzzle)
		url "/puzzle/#{puzzle.slug}/answer"
	end
end

get '/' do
	@puzzles = Puzzle.all
	erb :index
end

get '/about' do
	erb :about
end

get '/search' do
	@q = params[:q]
	@puzzles = []
	erb :search
end

before '/puzzle/:slug*' do
	@puzzle = Puzzle.find params[:slug]
end

get '/puzzle/:slug' do
	erb :show_puzzle
end

get '/puzzle/:slug/answer' do
	erb :show_answer
end