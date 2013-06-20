class Event < ActiveRecord::Base
  attr_accessible :title, :slug, :body, :event_start, :event_end, :featured
  attr_accessible :starts_at, :ends_at, :current_state, :position

	before_create :make_slug, :set_position

  validates_presence_of :title, :body
	validates_uniqueness_of :title


	include MyDateFormats

	scope :featured, where(:featured => true)

	private

	def make_slug
    self.slug = self.title.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')
  end

  def set_position
    self.position = (Describe.new(Event).published.count)+1
  end	
end
