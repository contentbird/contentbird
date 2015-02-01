class ChangeIndexOnPublicationUrlAlias < ActiveRecord::Migration
  def up
  	remove_index :publications, :url_alias
  	add_index :publications, [:url_alias, :channel_id], unique: true
  end
  def down
  	remove_index :publications, [:url_alias, :channel_id]
  	add_index :publications, :url_alias, :channel_id, unique: true
  end
end
