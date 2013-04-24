class Blog < ActiveRecord::Base
  attr_accessible :title, :slug, :body, :featured
  attr_accessible :starts_at, :ends_at, :current_state, :position
  attr_accessible :tag_names

  before_create :make_slug

  validates_presence_of :title, :body
	validates_uniqueness_of :title
	has_many :comments, :dependent => :destroy
	has_many :taggings, :dependent => :destroy
	has_many :tags, :through => :taggings
	attr_writer :tag_names
	after_save :assign_tags

	include MyDateFormats

	scope :featured, where(:featured => true)

	def tag_names
		@tag_names || tags.map(&:name).join('')
	end

	def self.is_featured_article?
		where(featured: true)
	end

	private

	def assign_tags
		if @tag_names
			self.tags = @tag_names.split(/\,/).map do |name|
				Tag.find_or_create_by_name(name)
			end
		end
	end

	def make_slug
    self.slug = self.title.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')
  end

  def set_position
    self.position = (Blog.published.count)+1
  end	
end
