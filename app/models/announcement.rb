class Announcement < ActiveRecord::Base
  attr_accessible :ends_at, :message, :starts_at, :title, :current_state, :position
  before_create :set_position
  include MyDateFormats
 

  # scope :current, -> { where("starts_at <= :now and ends_at >= :now", now: Time.zone.now)}
  def self.current(hidden_ids = nil)
    result = where("starts_at <= :now and ends_at >= :now", now: Time.zone.now)
    result = result.where("id not in (?)", hidden_ids) if hidden_ids.present?
    result
  end

  private
    def set_position
      if self.current_state == 3
        self.position = (Announcement.published.count)+1
      else
        self.position = nil
      end
    end
end
