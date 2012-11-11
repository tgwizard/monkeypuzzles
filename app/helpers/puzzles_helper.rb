# Helper methods defined here can be accessed in any controller or view in the application

MonkeyPuzzles.helpers do
  def feed_created_at(puzzles)
    puzzles.max {|a,b| a.created_at <=> b.created_at}.created_at
  end

  def feed_updated_at(puzzles)
    puzzles.max {|a,b| a.updated_at <=> b.updated_at}.updated_at
  end

  def sort_puzzles_for_feed(puzzles)
    puzzles.sort do |a,b|
      if a.created_at != b.created_at
        # newest to oldest
        b.created_at <=> a.created_at
      else
        a.title <=> b.title
      end
    end
  end
end
