class Comment < ActiveRecord::Base
  attr_accessible :content, :puzzle_id, :user_id
  belongs_to :user
end

class Puzzle
  def comments
    @comments ||= Comment.where(:puzzle_id => @id).order(:created_at)
  end
  def num_comments
    @num_comments ||= Comment.where(:puzzle_id => @id).count
  end
  def reset_comments!
    @comments = nil
    @num_comments = nil
  end
end
