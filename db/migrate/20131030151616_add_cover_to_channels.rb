class AddCoverToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :cover, :string
  end
end
