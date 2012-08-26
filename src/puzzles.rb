require 'yaml'
require 'redcarpet'

class Puzzle
  attr_reader :slug, :title, :content, :answer
  attr_reader :content_md, :answer_md

  def initialize(attributes = {})
    @slug = attributes['slug']
    @title = attributes['title']
    @content_md = attributes['content']
		@answer_md = attributes['answer']

    @content = @@markdown.render(@content_md)
    @answer = @@markdown.render(@answer_md)
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
