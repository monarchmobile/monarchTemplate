class Profile < ActiveRecord::Base
  attr_accessible :address1, :address2, :company, :email1, :email2, :fax ,:quote, :phone1, :phone2
   
end