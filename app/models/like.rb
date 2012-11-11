class Like < ActiveRecord::Base
  belongs_to :user
end

class Puzzle
  def num_likes
    #@num_likes ||= Like.count(:puzzle_id => @id)
    @num_likes ||= Like.count
  end
  def reset_likes!
    @num_likes = nil
  end
  def user_likes?(user)
    !user.nil? && Like.count(:puzzle_id => @id, :user => user, :action => :like) > 0
  end
end
