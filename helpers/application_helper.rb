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
# ###################### END Stock Methods END #######################
end