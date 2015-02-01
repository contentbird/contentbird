class AddOwnerIdToContentType < ActiveRecord::Migration
  def change
    add_column :content_types, :owner_id, :integer
    add_index :content_types, :owner_id
  end
end
