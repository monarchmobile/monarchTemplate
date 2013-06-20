 class ApplicationController < ActionController::Base
	protect_from_forgery
	include ApplicationHelper
	rescue_from CanCan::AccessDenied do |exception|
	  flash[:error] = "Access denied."
	  redirect_to main_app.root_url
	end


	def after_sign_in_path_for(resource)
		superadmin = Role.find_by_name(:SuperAdmin)
		admin = Role.find_by_name(:Admin)
		fullAccess = %w(superadmin.id admin.id)
		role_ids = current_user.role_ids
		if (fullAccess & role_ids).empty? 
			root_path
		else 
			dashboard_path
	  end
	end

	private

	def resolve_layout
		case action_name
		when "show"
		  "application"
		when "index", "edit", "new"
		  "dashboard"
		else
		  "application"
		end
	end

  
end