class AddCompositeToContentType < ActiveRecord::Migration
  def change
    add_column :content_types, :composite, :boolean, default: true
    add_index :content_types, :composite
  end
end
