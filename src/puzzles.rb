require 'redcarpet'

class Puzzle
  attr_reader :slug, :title, :content, :answer
  attr_reader :content_md, :answer_md

  def initialize(attributes = {})
    @slug = attributes[:slug]
    @title = attributes[:title]
    @content_md = attributes[:content_md]
		@answer_md = attributes[:answer_md]

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
end

# TODO: better way to initialize all puzzles
Puzzle.add Puzzle.new(:slug => 'asdf', :title => 'Asdf title', :content_md => 'content', :answer_md => 'answer')
