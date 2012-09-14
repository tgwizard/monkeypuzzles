require 'yaml'
require 'redcarpet'

class Puzzle

	attr_reader :data

  attr_reader :slug, :title, :content, :answer
	attr_reader :author, :about, :categories, :related
	attr_reader :created_at, :updated_at

	attr_accessor :next_puzzle, :prev_puzzle

  def initialize(data = {})
		@data = data
    @slug = data['slug']
    @title = data['title']
		@author = data['author'] || 'Unknown'
		if data.has_key? 'categories'
			@categories = data['categories'].map do |c|
				c = Category.get_or_new :title => c
				c.puzzles << self
				c
			end
		else
			c = Category.get_or_new :title => Category::NO_CATEGORY
			c.puzzles << self
			@categories = []
		end

		@related = data['related'] ? data['related'].dup : []
		@created_at = data['created_at']
		@updated_at = data['updated_at']

    content_md = data['content']
		answer_md = data['answer']
		about_md = data['about']

    @content = @@markdown.render(content_md)
    @answer = @@markdown.render(answer_md) unless answer_md.nil?
		@about = @@markdown.render(about_md) unless about_md.nil?
  end

	def <=>(other)
		self.title <=> other.title
	end

  # class stuff
  @@puzzles = {}
	@@puzzle_list = []
  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def self.all
    @@puzzle_list
  end

  def self.find(slug)
    @@puzzles[slug]
  end

	def self.search(q)
		q = q.strip
		return Puzzle.all if q.length == 0

		words = q.downcase.split

		result = []
		puzzles_left = @@puzzle_list.dup

		accept = lambda do |&criteria|
			new_result = []
			puzzles_left.each do |puzzle|
				matches = 0
				words.each do |word|
					if criteria.call(puzzle, word)
						matches += 1
					else
						break
					end
				end
				if matches == words.length
					new_result << puzzle
				end
			end
			result += new_result
			puzzles_left -= new_result
		end

		# slugs
		accept.call do |puzzle, word|
			puzzle.slug.downcase.include? word
		end

		# titles
		accept.call do |puzzle, word|
			puzzle.title.downcase.include? word
		end

		# categories
		accept.call do |puzzle, word|
			ret = false
			puzzle.categories.each do |c|
				ret = true if c.title.include? word
			end
			ret
		end

		# contents
		accept.call do |puzzle, word|
			puzzle.data['content'].downcase.include? word
		end

		# about
		accept.call do |puzzle, word|
			if puzzle.data.has_key? 'about'
				puzzle.data['about'].downcase.include? word
			else
				false
			end
		end
		result
	end

	def self.load(dir)
		puts "loading puzzles..."
		Dir[dir + '/*'].each do |file|
			puts " --> #{file}"
			data = YAML.load_file file
			data['slug'] = File.basename file, '.yaml'
			puzzle = Puzzle.new data
			@@puzzles[puzzle.slug] = puzzle
			@@puzzle_list << puzzle
		end
		puts "#{@@puzzles.length} puzzles loaded"


		self.post_load_process
	end

	def self.post_load_process
		@@puzzle_list.sort!
		Category.all.sort!

		@@puzzle_list.each do |puzzle|
			related = []
			puzzle.related.each do |r|
				if not @@puzzles.has_key? r
					raise ArgumentError, "Related puzzle '#{r}' for #{puzzle.slug} not found"
				end
				related << @@puzzles[r]
			end
			puzzle.related.replace related

		end

		@@puzzle_list.each_index do |i|
			@@puzzle_list[i].prev_puzzle = Puzzle.all[(i-1 + Puzzle.all.length) % Puzzle.all.length]
			@@puzzle_list[i].next_puzzle = Puzzle.all[(i+1 + Puzzle.all.length) % Puzzle.all.length]
		end

	end
end

class Category
	NO_CATEGORY = 'no category'
	attr_reader :slug, :title, :content
	attr_reader :puzzles

	def initialize(data)
		@title = data[:title]
		@slug = @title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
		@content = "There are no spoons"
		@puzzles = []
	end

	def num
		@puzzles.length
	end

	def <=>(other)
		if self.title == NO_CATEGORY
			1
		elsif other.title == NO_CATEGORY
			-1
		else
			self.title <=> other.title
		end
	end

	# class stuff
	@@categories = {}
	@@category_list = []

	def self.all
		@@category_list
	end

	def self.find(slug)
		@@categories[slug]
	end

	def self.get_or_new(data)
		title = data[:title]
		c = @@category_list.find {|x| x.title == title}
		if c.nil?
			c = Category.new data
			@@categories[c.slug] = c
			@@category_list << c
		end
		puts "Returning category #{c.title}"
		c
	end
end
