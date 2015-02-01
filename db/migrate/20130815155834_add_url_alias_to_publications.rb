class AddUrlAliasToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :url_alias, :string
    add_index  :publications, :url_alias, unique: true
  end
end
