class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :email
      t.timestamps
    end

    add_index :contacts, :email
  end
end
