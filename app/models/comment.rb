class Comment < ActiveRecord::Base
  attr_accessible :blog_id, :body, :email, :name
  validates_presence_of :body
  belongs_to :blog

end
