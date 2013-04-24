class CreateStatusableStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses_statusables, :id => false do |t|
      t.references :status, :statusable 
      t.belongs_to :statusable, polymorphic: true
      t.string :statusable_type
    end
  end
 
  def self.down
    drop_table :statuses_statusables
  end
end
