class ProfilesController < ApplicationController 
	before_filter :authenticate_user!, :except => [:show] # devise method
	layout 'dashboard'
	def new 
		@profile = Profile.new	
	end

	def index
		@profiles = Profile.all 
	end

	def show 
		find_profile
	end

	def edit 
		find_profile
	end

	def create 
		@profile = Profile.new(params[:profile])
		respond_to do |format|
			if @profile.save
				format.html { redirect_to @profile, :notice => "The #{@profile.name} profile was successfully created" }
				format.js
			else
				format.html { redirect_to "new", :notice => "profile could not be created. Please fill out all ** fields"}
			end
		end
	end

	def update
		find_profile
		respond_to do |format|
			if @profile.update_attributes(params[:profile])
				format.html { redirect_to @profile, :notice => "The #{@profile.name} profile was succesfully updated"}
				format.js
			else
				format.html { render :action => "edit"}
			end
		end
	end

	def destroy
		find_profile
		@profile.destroy
		respond_to do |format|
			format.html { redirect_to root_url}
			format.js
		end
	end

	def find_profile 
		@profile = Profile.find(params[:id])
	end

end