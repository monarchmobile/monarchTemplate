class Describe

	def initialize(model)
		@model = model
	end
	
	def published
    published = Status.find_by_status_name("published").id
    @model.where(current_state: published).order("position ASC")
	end

	def scheduled
    scheduled = Status.find_by_status_name("scheduled").id
    @model.where(current_state: scheduled).order("position ASC")
	end

	def draft
    draft = Status.find_by_status_name("draft").id
    @model.where(current_state: draft).order("position ASC")
	end

	def is_published?
    published = Status.find_by_status_name("published").id
    @model.current_state == published
  end

  def starts_at(id)
      object = @model.find(id)
      if !object.starts_at.blank?
        object.starts_at.strftime("%B %d, %Y")
      else
        Date.today
      end
  end

  def ends_at(id)
    object = @model.find(id)
    if !object.ends_at.blank?
        object.ends_at.strftime("%B %d, %Y")
      else
        Date.today
      end
  end

  def partial
    @model.limit(5).order("created_at DESC")
  end


end