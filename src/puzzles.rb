require 'yaml'
require 'redcarpet'

class Puzzle
	NO_CATEGORY = 'no category'

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
		@categories = data['categories'] || []
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

  # class stuff
  @@puzzles = {}
	@@puzzle_list = []
	@@categories = {}
  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def self.all
    @@puzzle_list
  end

  def self.find(slug)
    @@puzzles[slug]
  end

	def self.categories
		@@categories
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
				ret = true if c.include? word
			end
			ret
		end

		# contents
		accept.call do |puzzle, word|
			puzzle.data['content'].downcase.include? word
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
		end
		puts "#{@@puzzles.length} puzzles loaded"

		@@puzzle_list = @@puzzles.values.sort do |a,b|
			a.title <=> b.title
		end

		@@puzzle_list.each do |puzzle|
			puzzle.categories.each do |category|
				@@categories[category] = 1 + @@categories.fetch(category, 0)
			end
			if puzzle.categories.empty?
				@@categories[NO_CATEGORY] = 1 + @@categories.fetch(NO_CATEGORY, 0)
			end

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
