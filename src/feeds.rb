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
    xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
      xml.title "Monkeypuzzles"
      xml.subtitle "Puzzles not even a monkey could solve. A collection of
        the greatest puzzles in the world."
      xml.link :href => url('/atom.xml'), :rel => 'self'
      xml.link :href => url('/')
      xml.id url('/')
      xml.updated Time.parse(feed_created_at(puzzles).to_s).xmlschema
      xml.author do
        xml.name "Adam Renberg"
      end
      xml.author do
        xml.name "Olle Werme"
      end

      puzzles.each do |puzzle|
        xml.entry do
          xml.title puzzle.title
          xml.link :href => path_to_puzzle(puzzle)
          xml.updated Time.parse(puzzle.created_at.to_s).xmlschema
          xml.content :type => 'html' do
            xml.text! puzzle.content
          end
          xml.id path_to_puzzle(puzzle)
          xml.author do
            xml.name puzzle.author
          end
        end
      end
    end
  end
end
