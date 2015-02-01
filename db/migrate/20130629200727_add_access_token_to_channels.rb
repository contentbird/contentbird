class AddAccessTokenToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :access_token, :string
    add_index  :channels, :access_token, unique: true
  end
end
