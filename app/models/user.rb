class User < ActiveRecord::Base
  attr_accessible :email, :username, :use_gravatar

  has_many :comment
  has_many :like

  validates :email, :uniqueness => {:case_sensitive => false}, :presence => true
  #validates :username, :uniqueness => {:case_sensitive => false}, :presence => false

  def anonymous_username
    "anonymous-#{self.id}"
  end

  def username_set?
    !username.nil?
  end

  def display_username
    username_set? ? username : anonymous_username
  end

  def image_url
    if use_gravatar
      gravatar_url
    else
      "http://www.gravatar.com/avatar/asdf"
    end
  end

  def gravatar_url
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.strip.downcase)}"
  end
end
