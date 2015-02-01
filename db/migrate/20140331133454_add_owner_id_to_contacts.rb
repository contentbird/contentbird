class AddOwnerIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :owner_id, :integer
    remove_index :contacts, column: :email
    add_index :contacts, [:email, :owner_id], unique: :true
  end
end
