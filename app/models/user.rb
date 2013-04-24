class User < ActiveRecord::Base 
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
	attr_accessible :first_name, :last_name, :role, :username, :approved
  attr_accessible :role_ids, :as => :admin
	has_and_belongs_to_many :roles
  before_create :setup_role
  ## acts_as_orderer

  def self.approved
    where(approved: true)
  end

  def self.not_approved
    where(approved: false)
  end

  def self.order_by_name
    order("last_name ASC")
  end

  def role?(role)
   return !!self.roles.find_by_name(role.to_s)
  end

  def fullname
  	[first_name, last_name].join(" ")
  end

  def fullname=(name)
  	split = name.split(" ")
  	first_name = split[0]
  	last_name = split[1]
  end

  private
  def setup_role
  	guest = Role.find_by_name("Guest")

    if self.role_ids.empty?
      self.role_ids = [guest.id]
    end
  end
  # attr_accessible :title, :body
end
