class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :company
      t.string :quote
      t.string :address1
      t.string :address2
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.string :email1
      t.string :email2

      t.timestamps
    end
  end
end
