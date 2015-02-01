class AddCssToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :css, :string
  end
end
