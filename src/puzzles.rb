require 'yaml'
require 'redcarpet'

class Puzzle
	NO_CATEGORY = 'no category'

  attr_reader :slug, :title, :content, :answer
	attr_reader :author, :about, :categories, :related
	attr_reader :created_at, :updated_at
  attr_reader :content_md, :answer_md, :about_md

  def initialize(attributes = {})
    @slug = attributes['slug']
    @title = attributes['title']
		@author = attributes['author'] || 'Unknown'
		@categories = attributes['categories'] || []
		@related = attributes['related'] || []

    @content_md = attributes['content']
		@answer_md = attributes['answer']
		@about_md = attributes['about']
		@created_at = attributes['created_at']
		@updated_at = attributes['updated_at']

    @content = @@markdown.render(@content_md)
    @answer = @@markdown.render(@answer_md) unless @answer_md.nil?
		@about = @@markdown.render(@about_md) unless @about_md.nil?
  end

  # class stuff
  @@puzzles = {}
	@@puzzle_list = []
	@@categories = {}
  @@markdown = markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

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
				words.each do |word|
					if criteria.call(puzzle, word)
						new_result << puzzle
						break
					end
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
			puzzle.categories.include? word
		end

		# contents
		accept.call do |puzzle, word|
			puzzle.content_md.downcase.include? word
		end

		result
	end

	def self.load(dir)
		Dir[dir + '/*'].each do |file|
			puts "loading puzzle #{file}"
			data = YAML.load_file file
			data['slug'] = File.basename file, '.yaml'
			puzzle = Puzzle.new data
			@@puzzles[puzzle.slug] = puzzle
		end

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
				related << @@puzzles[r]
			end
			puzzle.related.replace related
		end
	end
end

Puzzle.load 'content'
