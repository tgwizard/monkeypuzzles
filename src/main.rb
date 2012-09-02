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
	# paths
	def path_to_puzzle(puzzle)
		url "/puzzle/#{puzzle.slug}"
	end
	def path_to_puzzle_answer(puzzle)
		url "/puzzle/#{puzzle.slug}/answer"
	end
	def path_to_category(category)
		url "/category/#{category.downcase}"
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

before '/puzzle/:slug*' do
	@puzzle = Puzzle.find params[:slug]
	if @puzzle.nil?
		raise error 404
	end
end

get '/puzzle/:slug' do
	i = Puzzle.all.index @puzzle
	@title = @puzzle.title
	@prev_puzzle_url = path_to_puzzle Puzzle.all[(i-1 + Puzzle.all.length) % Puzzle.all.length]
	@next_puzzle_url = path_to_puzzle Puzzle.all[(i+1 + Puzzle.all.length) % Puzzle.all.length]
	erb :show_puzzle
end

get '/puzzle/:slug/answer' do
	@title = "Answer for #{@puzzle.title}"
	erb :show_answer
end

get '/category/:category' do
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

get '/rss.xml' do
	builder do |xml|
		xml.instruct! :xml, :version => '1.0'
		xml.rss :version => "2.0" do
			xml.channel do
				xml.title "Monkeypuzzles"
				xml.description "A collection of the greatest puzzles in the world."
				xml.link url '/'

				puzzles = Puzzle.all.sort do |a,b|
					if a.created_at != b.created_at
						a.created_at <=> b.created_at
					else
						a.title <=> b.title
					end
				end

				puzzles.each do |puzzle|
					xml.item do
						xml.title puzzle.title
						xml.link path_to_puzzle(puzzle)
						xml.pubDate Time.parse(puzzle.created_at.to_s).rfc822()
						xml.description puzzle.content
						xml.guid puzzle.slug

					end
				end
			end
		end
	end
end
