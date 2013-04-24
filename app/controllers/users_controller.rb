class UsersController < ApplicationController
  before_filter :authenticate_user!
  layout :resolve_layout
  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    all_user_states
  end

  def show
    load_user
  end

  def edit
    load_user
    @admin_roles = Role.all
  end
  
  def update
    all_user_states
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    load_user
    if params[:user][:role_ids]
      @user.role_ids = params[:user][:role_ids]
    end
      
    respond_to do |format|
      if params[:user][:role_ids]
        if @user.update_attributes(params[:user], :as => :admin)
          format.html { redirect_to users_path}
          format.js
        else
          format.html { redirect_to dashboard_path}
          format.js
        end
      else 
        if @user.update_attributes(params[:user])
          format.html { redirect_to users_path}
          format.js
        else
          format.html { redirect_to dashboard_path}
          format.js
        end
      end

    end
 
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    load_user
    unless @user == current_user
      @user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

  def sort
    all_user_states
    params[:user].each_with_index do |id, index|
      User.update_all({position: index+1}, {id: id})
    end
    render "update.js"
  end

  def load_user
    @user = User.find(params[:id])
  end

  def all_user_states
    @users_waiting_to_be_approved = User.not_approved.order_by_name
    @approved_users = User.approved.order_by_name
   
  end
end