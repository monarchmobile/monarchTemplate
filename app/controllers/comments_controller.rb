class CommentsController < ApplicationController

  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end


  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end


  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end


  def edit
    @comment = Comment.find(params[:id])
  end


def create
    @blog = Blog.find(params[:blog_id])
    @comment = @blog.comments.build(params[:comment])
    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@blog, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @blog, :status => :created, :location => @blog }
      else
        format.html { redirect_to(@blog, :notice => 
        'Comment could not be saved. Please fill in all fields')}
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @comment = Comment.find(params[:id])
    @blog = @comment.blog
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@blog, :notice => 'Comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to blogs_url }
      format.json { head :no_content }
    end
  end
end
