class AddTitleToContentProperties < ActiveRecord::Migration
  def change
    add_column :content_properties, :title, :string
  end
end
