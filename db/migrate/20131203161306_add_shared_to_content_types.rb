class AddSharedToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :shared, :boolean, default: false
    add_index :content_types, :shared
  end
end
