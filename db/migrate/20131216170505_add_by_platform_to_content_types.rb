class AddByPlatformToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :by_platform, :boolean, default: false
  end
end
