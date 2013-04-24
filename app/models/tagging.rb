class Tagging < ActiveRecord::Base
  attr_accessible :blog_id, :tag_id
  belongs_to :blog
  belongs_to :tag
end
