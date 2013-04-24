class CreateSupermodels < ActiveRecord::Migration
  def change
    create_table :supermodels do |t|
      t.string :name
      t.boolean :visible, :default => false
      t.integer :position

      t.timestamps
    end
  end
end
