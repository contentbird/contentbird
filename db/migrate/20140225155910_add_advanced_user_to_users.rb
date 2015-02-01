class AddAdvancedUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :advanced_user, :boolean, default: false
  end
end
