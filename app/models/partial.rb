class Partial < ActiveRecord::Base

	attr_accessible :name, :position 

	has_many :page_partials, :dependent => :destroy
	has_many :pages, :through => :page_partials
end