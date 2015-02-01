class AddPlatformUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :platform_user, :boolean, default: false
  end
end
