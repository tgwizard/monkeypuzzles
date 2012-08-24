require 'redcarpet'

class Puzzle
  extend ActiveModel::Naming

  attr_reader :slug, :title, :content
  attr_reader :content_md

  def initialize(attributes = {})
    @slug = attributes[:slug]
    @title = attributes[:title]
    @content_md = attributes[:content_md]

    @content = @@markdown.render(@content_md).html_safe
  end

  def to_param
    @slug
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
Puzzle.add Puzzle.new(:slug => 'asdf', :title => 'Asdf title', :content_md => 'content')
