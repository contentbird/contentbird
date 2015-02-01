class AddTypeToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :type, :string, default: 'CB::Core::WebSiteChannel'
    add_index :channels, :type
  end
end
