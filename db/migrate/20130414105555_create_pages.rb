class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.string :slug
      
      t.date :starts_at
      t.date :ends_at
      t.integer :current_state
      t.integer :position
      
      t.timestamps
    end
  end
end