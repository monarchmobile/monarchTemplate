class Page < ActiveRecord::Base 
  attr_accessible :content, :current_state, :slug, :title, :position, :starts_at, :ends_at
  attr_accessible :link_ids, :partial_ids
  before_create :make_slug
  # validates :slug, :uniqueness => true

  has_many :links_pages 
  has_many :links, :through => :links_pages

  has_many :page_partials 
  has_many :partials, :through => :page_partials

  def locations?(location)
     return !!self.links.find_by_location(location.to_s)
  end

  # pretty url
  extend FriendlyId
  friendly_id :slug

  private
    def make_slug
      self.slug = self.title.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')
    end

    def set_position
      self.position = (Page.published.count)+1
    end
end
