class PartialsController < ApplicationController
	before_filter :authenticate_user!
	layout :resolve_layout
	def new
		@partial = Partial.new
	end

	def index
		@partials = Partial.all 
	end

	def show
		find_partial
	end

	def edit
		find_partial
	end

	def create
		@partial = Partial.new(params[:partial])
		respond_to do |format|
			if @partial.save
				format.html { redirect_to partials_path }
				format.js
			else
				format.html { render action: "new" }
	      format.json { render json: @link.errors, status: :unprocessable_entity }
			end
		end
	end

	def update
		find_partial
		respond_to do |format|
			if @partial.update_attributes(params[:partial])
				format.html { redirect_to partials_path }
				format.js
			else
				format.html
				format.js
			end
		end
	end

	def destroy
		find_partial
		@partial.destroy
		respond_to do |format|
			format.html { redirect_to partials_path }
			format.js
		end
	end

	def find_partial
		@partial = Partial.find(params[:id])
	end
end