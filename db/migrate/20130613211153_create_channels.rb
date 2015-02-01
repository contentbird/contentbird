class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string    :name
      t.datetime  :closed_at
      t.string    :url_prefix
    end
    add_index :channels, :name
  end
end
