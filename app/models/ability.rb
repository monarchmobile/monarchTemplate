class Ability
  include CanCan::Ability
  
  def initialize(user)
    # Always performed
    can :access, :ckeditor   # needed to access Ckeditor filebrowser

    # Performed checks for actions:
    can [:read, :create, :destroy], Ckeditor::Picture
    can [:read, :create, :destroy], Ckeditor::AttachmentFile
    can :read, :all
    can [:create], User
              # allow everyone to read everything
              # add ability to create comments
    user ||= User.new   
    if user.role? :SuperAdmin
      can :manage, :all 
    elsif user.role? :Admin      ### ADMIN ###
      can :manage, :all
      can :assign_roles, User
      can :dashboard
      can :access, :rails_admin
      # can [:read, :edit], Frame
      # can :manage, [Role, User]
      # piggybak specific
      can :manage, Piggybak.config.manage_classes.map(&:constantize)
      Piggybak.config.extra_abilities.each do |extra_ability|
        can extra_ability[:abilities], extra_ability[:class_name].constantize
      end
    elsif user.role? :Moderator   ### MODERATOR ###
      can :read, [Article, Comment]
      can [:create, :edit, :update], [Comment, Article]
    elsif user.role? :Guest       ### GUEST ###
       can :read, :all
       can :create, Comment   
       # can [:edit, :update], 
     end
  end
end