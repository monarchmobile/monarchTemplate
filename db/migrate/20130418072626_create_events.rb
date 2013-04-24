class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.date :event_start
      t.date :event_end
      t.string :location
      t.boolean :featured

      t.date :starts_at
      t.date :ends_at
      t.integer :current_state
      t.integer :position

      t.timestamps
    end
  end
end

