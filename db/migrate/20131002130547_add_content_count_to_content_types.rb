class AddContentCountToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :contents_count, :integer, default: 0, null: false
  end
end
