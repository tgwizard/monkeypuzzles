require 'yaml'
require 'redcarpet'

class Puzzle

	attr_reader :data

	attr_reader :id
  attr_reader :slug, :title, :content, :answer
	attr_reader :author, :about, :categories, :related
	attr_reader :created_at, :updated_at

	attr_accessor :next_puzzle, :prev_puzzle

  def initialize(data = {})
		@data = data
		if not data.has_key? 'id'
			raise ArgumentError, "No id for puzzle #{data['slug']}"
		end
		@id = data['id'].to_i
    @slug = data['slug']
    @title = data['title']
		@author = data['author'] || 'Unknown'

		# these need to be set elsewhere
		@categories = []
		@related = []

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
  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def self.all
    Content.puzzle_list
  end

  def self.find(slug)
    Content.puzzle_hash[slug]
  end

	def self.search(q)
		q = q.strip
		return Puzzle.all if q.length == 0

		words = q.downcase.split

		result = []
		puzzles_left = self.all.dup

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
	def self.all
		Content.category_list
	end

	def self.find(slug)
		Content.category_hash[slug]
	end
end

class Content
	@@puzzle_hash = {}
	@@puzzle_list = []
	@@category_hash = {}
	@@category_list = []

	# accessors
	def self.puzzle_list
		@@puzzle_list
	end
	def self.puzzle_hash
		@@puzzle_hash
	end
	def self.category_list
		@@category_list
	end
	def self.category_hash
		@@category_hash
	end

	def self.load(dir)
		self.load_puzzles(dir)
		self.fix_puzzle_categories
		self.fix_puzzle_related_objects

		self.sort_contents
		self.fix_puzzle_next_prev_objects
	end

	def self.load_puzzles(dir)
		puts "loading puzzles..."
		ids = {}

		Dir[dir + '/*'].each do |file|
			print " --> "

			data = YAML.load_file file
			data['slug'] = File.basename file, '.yaml'
			slug = data['slug']
			id = data['id']


			print "%-5s %s" % ["[#{id}]", file]

			if ids.has_key? id
				raise ArgumentError, "Duplicate ids for puzzles #{slug} and #{ids[id]}"
			end
			ids[id] = slug

			puzzle = Puzzle.new data
			@@puzzle_hash[puzzle.slug] = puzzle
			@@puzzle_list << puzzle

			print " done!\n"


		end

		puts "#{@@puzzle_list.length} puzzles loaded, max id is #{ids.keys.max}"
	end

	def self.sort_contents
		@@puzzle_list.sort!
		@@category_list.sort!
	end

	def self.fix_puzzle_categories
		@@puzzle_list.each do |puzzle|
			if puzzle.data.has_key? 'categories'
				puzzle.data['categories'].each do |category_name|
					category = Content.category_get_or_new :title => category_name
					category.puzzles << puzzle
					puzzle.categories << category
				end
			else
				category = Content.category_get_or_new :title => Category::NO_CATEGORY
				category.puzzles << puzzle
			end
		end
	end

	def self.fix_puzzle_related_objects
		@@puzzle_list.each do |puzzle|
			next if not puzzle.data.has_key? 'related'
			puzzle.data['related'].each do |r|
				if not @@puzzle_hash.has_key? r
					raise ArgumentError, "Related puzzle '#{r}' for #{puzzle.slug} not found"
				end
				puzzle.related << @@puzzle_hash[r]
			end
		end
	end

	def self.fix_puzzle_next_prev_objects
		@@puzzle_list.each_index do |i|
			@@puzzle_list[i].prev_puzzle = @@puzzle_list[(i-1 + @@puzzle_list.length) % @@puzzle_list.length]
			@@puzzle_list[i].next_puzzle = @@puzzle_list[(i+1 + @@puzzle_list.length) % @@puzzle_list.length]
		end
	end

	def self.category_get_or_new(data)
		title = data[:title]
		c = @@category_list.find {|x| x.title == title}
		if c.nil?
			c = Category.new data
			@@category_hash[c.slug] = c
			@@category_list << c
		end
		c
	end
end
