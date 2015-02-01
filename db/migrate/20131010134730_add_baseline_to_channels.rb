class AddBaselineToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :baseline, :string
  end
end
