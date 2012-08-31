require 'yaml'
require 'redcarpet'

class Puzzle
  attr_reader :slug, :title, :content, :answer, :about
	attr_reader :created_at, :updated_at
  attr_reader :content_md, :answer_md, :about_md

  def initialize(attributes = {})
    @slug = attributes['slug']
    @title = attributes['title']
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
  @@markdown = markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def self.all
    @@puzzle_list
  end

  def self.find(slug)
    @@puzzles[slug]
  end

	def self.search(q)
		words = q.downcase.split

		result = []
		puzzles_left = @@puzzles.values.dup

		accept = lambda do |&criteria|
			puzzles_left.each do |puzzle|
				words.each do |word|
					if criteria.call(puzzle, word)
						result << puzzle
						puzzles_left.delete puzzle
						break
					end
				end
			end
		end

		# slugs
		accept.call do |puzzle, word|
			puzzle.slug.downcase.include? word
		end

		# titles
		accept.call do |puzzle, word|
			puzzle.title.downcase.include? word
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
	end
end

Puzzle.load 'content'
