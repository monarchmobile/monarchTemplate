class CreatePagePartials < ActiveRecord::Migration
  def self.up
    create_table :page_partials, :id => false do |t|
      t.references :page, :partial
    end
  end
 
  def self.down
    drop_table :page_partials
  end
end