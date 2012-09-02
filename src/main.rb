require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'

require_relative 'puzzles.rb'

configure do
	set :root, File.expand_path("..", File.dirname(__FILE__))
	set :public_folder, 'static'
	set :partial_template_engine, :erb
	mime_type :woff, 'application/x-font-woff'
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

def feed_puzzles
	Puzzle.all.sort do |a,b|
		if a.created_at != b.created_at
			# newest to oldest
			b.created_at <=> a.created_at
		else
			a.title <=> b.title
		end
	end
end

def feed_created_at(puzzles)
	puzzles.max {|a,b| a.created_at <=> b.created_at}.created_at
end
def feed_updated_at(puzzles)
	puzzles.max {|a,b| a.updated_at <=> b.updated_at}.updated_at
end

get '/rss.xml' do
	puzzles = feed_puzzles

	builder do |xml|
		xml.instruct! :xml, :version => '1.0'
		xml.rss :version => "2.0", :"xmlns:atom" => "http://www.w3.org/2005/Atom" do
			xml.channel do
				xml.title "Monkeypuzzles"
				xml.description "Puzzles not even a monkey could solve. A collection of
					the greatest puzzles in the world."
				xml.link url '/'
				xml.tag! 'atom:link', :href => url('/rss.xml'), :rel => 'self', :type => 'application/rss+xml'
				xml.language 'en-us'

				xml.pubDate Time.parse(feed_created_at(puzzles).to_s).rfc822
				xml.lastBuildDate Time.parse(feed_updated_at(puzzles).to_s).rfc822

				puzzles.each do |puzzle|
					xml.item do
						xml.title puzzle.title
						xml.link path_to_puzzle(puzzle)
						xml.pubDate Time.parse(puzzle.created_at.to_s).rfc822
						xml.description puzzle.content
						xml.guid path_to_puzzle(puzzle)
					end
				end
			end
		end
	end
end

get '/atom.xml' do
	puzzles = feed_puzzles

	builder do |xml|
		xml.instruct! :xml, :version => '1.0'
		xml.rss :xmlns => "http://www.w3.org/2005/Atom" do
			xml.channel do
				xml.title "Monkeypuzzles"
				xml.subtitle "Puzzles not even a monkey could solve"
				xml.link :href => url('/atom.xml'), :rel => 'self'
				xml.link :url => url('/')
				xml.updated Time.parse(feed_created_at(puzzles).to_s).xmlschema

				puzzles.each do |puzzle|
					xml.entry do
						xml.title puzzle.title
						xml.link :href => path_to_puzzle(puzzle)
						xml.updated Time.parse(puzzle.created_at.to_s).xmlschema
						xml.content puzzle.content
						xml.id path_to_puzzle(puzzle)
					end
				end
			end
		end
	end
end
