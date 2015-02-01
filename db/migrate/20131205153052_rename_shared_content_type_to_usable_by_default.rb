class RenameSharedContentTypeToUsableByDefault < ActiveRecord::Migration
  def change
    rename_column :content_types, :shared, :usable_by_default
  end
end
