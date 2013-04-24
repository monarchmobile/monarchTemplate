class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.boolean :featured

      t.date :starts_at
      t.date :ends_at
      t.integer :current_state
      t.integer :position

      t.timestamps
    end
  end
end
