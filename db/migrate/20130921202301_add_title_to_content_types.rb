class AddTitleToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :title, :string
  end
end
