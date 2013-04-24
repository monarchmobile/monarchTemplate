 class BlogsController < ApplicationController 
  before_filter :authenticate_user!, :except => [:show] # devise method
  layout :resolve_layout

  def index
    all_blog_states
    @blogs = Blog.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @blogs }
    end
  end
  
  def show
    find_blog
    @comments = @blog.comments
    @comment = @blog.comments.build

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @blog }
    end
  end

  def blog_partial
    @blogs_partial = Describe.new(Blog).partial
    @model_name = "Blog"
    render 'shared/quick_partial_view', model_name: @model_name
  end

  def new
    @blog = Blog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blog }
    end
  end

 
  def edit
    find_blog
    authorize! :edit, @blog
   
  end

  def create
    authorize! :create, @blog
    @blog = Blog.new(params[:blog])
    respond_to do |format|
      if @blog.save
        format.html { redirect_to @blog, notice: 'blog was successfully created.' }
        format.json { render json: @blog, status: :created, location: @blog }
      else
        format.html { render action: "new" }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

 
  def update
    find_blog
    authorize! :update, @blog
    all_blog_states
    position = params[:blog][:position]
    current_state = params[:blog][:current_state]
    published = Status.find_by_status_name("published").id
    if (!current_state ==  published) 
      @blog.position = nil
    end
    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        format.html { redirect_to @blog, notice: 'blog was successfully updated.' }
        format.js { @blog }
      else
        format.html { render action: "edit" }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    find_blog 
    authorize! :destroy, @blog
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to blogs_url }
      format.json { head :no_content }
    end
  end

  def find_blog
    @blog = Blog.find(params[:id])
  end

  def sort
    all_blog_states
    params[:blog].each_with_index do |id, index|
      Blog.update_all({position: index+1}, {id: id})
    end
    render "update.js"
  end

  def blog_status
    all_blog_states
    find_blog
    current_state = params[:blog][:current_state]
    total_published = @published_blogs.count
    published = Status.find_by_status_name("published").id
    if (current_state ==  published) 
      @blog.update_attributes({current_state: current_state, position: total_published + 1})
    else
      @blog.update_attributes({current_state: current_state, position: nil })
    end

    @published_blogs.each_with_index do |id, index|
      @published_blogs.update_all({position: index+1}, {id: id})
    end
    render "update.js"
    
  end

  def blog_starts_at
    
    find_blog
    starts_at = params[:blog][:starts_at]
    current_state = params[:blog][:current_state]
    total_published = @published_blogs.count

    @blog.update_attributes({starts_at: starts_at})
    published = Status.find_by_status_name("published").id
    if (current_state ==  published) 
      @published_blogs.each_with_index do |id, index|
        @published_blogs.update_all({position: index+1}, {id: id})
      end
    end
    
    all_blog_states
    render "update.js"
  end

  def blog_ends_at
    
    find_blog
    ends_at = params[:blog][:ends_at]
    current_state = params[:blog][:current_state]
    total_published = @published_blogs.count
    
    @blog.update_attributes({ends_at: ends_at})
    published = Status.find_by_status_name("published").id
    if (current_state ==  published) 
      @published_blogs.each_with_index do |id, index|
        @published_blogs.update_all({position: index+1}, {id: id})
      end
    end
    all_blog_states
    render "update.js"
    
  end

  def all_blog_states
    @published_blogs = Describe.new(Blog).published
    @scheduled_blogs = Describe.new(Blog).scheduled
    @draft_blogs = Describe.new(Blog).draft
  end
end
