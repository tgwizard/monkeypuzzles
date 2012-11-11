class Like < ActiveRecord::Base
  attr_accessible :puzzle_id, :user_id
  belongs_to :user
end

class Puzzle
  def num_likes
    @num_likes ||= Like.where(:puzzle_id => @id).count
  end
  def reset_likes!
    @num_likes = nil
  end
  def user_likes?(user)
    !user.nil? && Like.where(:puzzle_id => @id, :user_id => user).count > 0
  end
end
