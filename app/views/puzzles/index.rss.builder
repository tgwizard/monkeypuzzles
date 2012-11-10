puzzles = sort_puzzles_for_feed(@puzzles)
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
        xml.link url_for(:puzzles, :show, :slug => puzzle)
        xml.pubDate Time.parse(puzzle.created_at.to_s).rfc822
        xml.description puzzle.content
        xml.guid url_for(:puzzles, :show, :slug => puzzle)
      end
    end
  end
end
