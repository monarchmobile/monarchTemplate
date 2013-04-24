module ApplicationHelper
# ********************** START Stock Methods START ********************
  def question_for_andrew(text)
    content_tag(:div, text, class: "andrew")
  end

  # user methods
  def restrict_access
    redirect_to root_url, notice: "access denied"
  end

  def current_users_page?(user)
      current_user && current_user.id == user.id
    end

    # generates red stars for required fields in any form
  def required_field
    content_tag :span, "**", class: "required_field"
  end

  def update_list
    models = ActiveRecord::Base.connection.tables.collect{|t| t.underscore.singularize.camelize}
    models.each do |m|
      if Supermodel.find(:all, conditions: {name: m }).count == 0
        Supermodel.create(name: m, visible: false)
      end
    end
    client_models = ["Role", "Page", "Announcement", "Profile", "Blog", "Event", "Partial", "Link"]
    client_models.each do |cm|
      instance = Supermodel.find_by_name(cm)
      instance.update_attributes(visible: true)
    end
  end

  def check_status(blog)
    if blog.published == true
      "published"
    else 
      "draft"
    end
  end

  def current_status(id)
    Status.find(id).status_name
  end

# ###################### END Stock Methods END #######################

###################### page #################
  def handle_if_published(page)
    if Describe.new(page).is_published?
      "[drag]"
    else
      ""
    end
  end

  def position_if_published(page)
    if Describe.new(page).is_published?
      page.position
    else
      ""
    end
  end

  def green_if_checked(page, link_id)
    if page.link_ids.include?(link_id)
      "green_background"
    else
      "red_background"
    end
  end

  def check_if_draft(announcement)
    current_state = announcement.current_state
    draft = Status.find_by_status_name("draft").id
    if current_state == draft
      "hidden"
    end
  end

  def hidden_attributes
    %w[id created_at updated_at]
  end

  def green_if_approved(user)
    if user.approved == true
      "green_background"
    else
      "red_background"
    end
  end

  def green_if_role(user, role_id)
    if user.role_ids.include?(role_id)
      "green_background"
    else
      "red_background"
    end
  end

  # user index
  def user_approved_status(user)
    if user.approved == true
      "Approved"
    elsif user.approved == false
      "Not Approved"
    end
  end

  
end


