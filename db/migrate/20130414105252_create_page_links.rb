class CreatePageLinks < ActiveRecord::Migration
  def self.up
    create_table :links_pages, :id => false do |t|
      t.references :link, :page
    end
  end
 
  def self.down
    drop_table :links_pages
  end
end