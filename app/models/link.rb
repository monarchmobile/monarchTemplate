class Link < ActiveRecord::Base
  attr_accessible :location, :page_ids
 
  has_many :links_pages 
  has_many :pages, :through => :links_pages

end



