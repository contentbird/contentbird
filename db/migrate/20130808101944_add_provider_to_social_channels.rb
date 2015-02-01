class AddProviderToSocialChannels < ActiveRecord::Migration
  def change
    add_column :channels, :provider, :string
    add_index :channels, :provider
  end
end
