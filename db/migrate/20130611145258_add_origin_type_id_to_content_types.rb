class AddOriginTypeIdToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :origin_type_id, :integer
    add_index :content_types, :origin_type_id
  end
end
