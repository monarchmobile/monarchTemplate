class LinksController < ApplicationController
	before_filter :authenticate_user!
	def new
		@link = Link.new
		respond_to do |format|
	      format.js
	    end
	end


	def create 
		@link = Link.new(params[:link])
	    respond_to do |format|
	      if @link.save
	      	format.html
	        format.js
	      else
	        format.html { render action: "new" }
	        format.json { render json: @link.errors, status: :unprocessable_entity }
	      end
	    end
	end
end