class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
    	t.string :title
      t.text :message
      
      t.date :starts_at
      t.date :ends_at
      t.integer :current_state
      t.integer :position

      t.timestamps
    end
  end
end
