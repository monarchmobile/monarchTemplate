class StatusesStatusable < ActiveRecord::Base
	attr_accessible :status_id, :statusable_id, :statusable_type

  belongs_to :status 
  belongs_to :statusable, :polymorphic => true
end