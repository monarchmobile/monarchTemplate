class PagesController < ApplicationController 
	before_filter :authenticate_user!, :except => [:show] # devise method
	layout :resolve_layout
	def new 
		@page = Page.new
		all_page_states
	end

	def index
		all_page_states
		
	end

	def show 
		reset_current_state(Announcement)
		reset_current_state(Event)
		reset_current_state(Blog)
		@partials = Partial.all
		@announcements_partial = Describe.new(Announcement).published.limit(5).order("starts_at DESC")
		@blogs_partial = Describe.new(Blog).published.limit(5).order("starts_at DESC")
		@events_partial = Describe.new(Event).published.limit(5).order("starts_at DESC")
		find_page
	end

	def edit 
		find_page
		all_page_states
	end

	def create 
		@page = Page.new(params[:page])
		respond_to do |format|
			if @page.save
				format.html { redirect_to @page, :notice => "The #{@page.title} page was successfully created" }
				format.js
			else
				format.html { redirect_to "new", :notice => "page could not be created. Please fill out all ** fields"}
			end
		end
	end

	def update
		find_page
		all_page_states
		position = params[:page][:position]
		current_state = params[:page][:current_state]
		published = Status.find_by_status_name("published").id
		if (!current_state ==  published) 
			@page.position = nil
		end
		respond_to do |format|
			if @page.update_attributes(params[:page])
				# reorder_pages(@page)
				format.html { redirect_to @page, :notice => "The #{@page.title} page was succesfully updated"}
				format.js
			else
				format.html { render :action => "edit"}
			end
		end
	end

	def destroy
		find_page
		@page.link_ids=[]
		@page.destroy
		respond_to do |format|
			format.html { redirect_to root_url}
			format.js
		end
	end

	def find_page 
		@page = Page.find(params[:id])
	end


	def sort
		all_page_states
	  params[:page].each_with_index do |id, index|
	    Page.update_all({position: index+1}, {id: id})
	  end
	  render "update.js"
	end

	def status
		all_page_states
		find_page
		current_state = params[:page][:current_state]
		total_published = @published_pages.count
		published = Status.find_by_status_name("published").id
		if (current_state ==  published) 
			@page.update_attributes({current_state: current_state, position: total_published + 1})
		else
			@page.update_attributes({current_state: current_state, position: nil })
		end

		@published_pages.each_with_index do |id, index|
	    @published_pages.update_all({position: index+1}, {id: id})
	  end
		render "update.js"
	  
	end

	def all_page_states
		@published_pages = Describe.new(Page).published
		@scheduled_pages = Describe.new(Page).scheduled
		@draft_pages = Describe.new(Page).draft
		@links = Link.all
		@partials = Partial.all
	end


end