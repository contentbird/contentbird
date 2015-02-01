class AddPublicationsCountToContents < ActiveRecord::Migration
  def change
    add_column :contents, :publications_count, :integer, default: 0, null: false
  end
end
