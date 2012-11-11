class Comment < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
end

class Puzzle
  def comments
    @comments ||= Comment.all
    #@comments ||= Comment.all(:puzzle_id => @id, :orders => [:created_at])
  end
  def num_comments
    @num_comments ||= Comment.count
    #@num_comments ||= Comment.count(:puzzle_id => @id)
  end
  def reset_comments!
    @comments = nil
    @num_comments = nil
  end
end
