class AddAvailableForBasicUsersToContentType < ActiveRecord::Migration
  def change
    add_column :content_types, :available_to_basic_users, :boolean, default: true
  end
end
