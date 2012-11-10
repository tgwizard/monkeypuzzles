puzzles = sort_puzzles_for_feed(@puzzles)
xml.instruct! :xml, :version => '1.0'
xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "Monkeypuzzles"
  xml.subtitle "Puzzles not even a monkey could solve. A collection of
    the greatest puzzles in the world."
  xml.link :href => url(:puzzles, :index), :rel => 'self'
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
      xml.link :href => url_for(:puzzles, :show, :slug => puzzle)
      xml.updated Time.parse(puzzle.created_at.to_s).xmlschema
      xml.content :type => 'html' do
        xml.text! puzzle.content
      end
      xml.id :href => url_for(:puzzles, :show, :slug => puzzle)
      xml.author do
        xml.name puzzle.author
      end
    end
  end
end
