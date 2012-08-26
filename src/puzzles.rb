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
  @@markdown = markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def self.all
    @@puzzles.values
  end

  def self.find(slug)
    @@puzzles[slug]
  end

  def self.add(p)
    @@puzzles[p.slug] = p
  end

	def self.load(dir)
		Dir[dir + '/*'].each do |file|
			puts "loading puzzle #{file}"
			data = YAML.load_file file
			data['slug'] = File.basename file, '.yaml'
			puzzle = Puzzle.new data
			self.add puzzle
		end
	end
end


Puzzle.load 'content'
