class AddDeletedAtToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :deleted_at, :datetime
    add_index :publications, :deleted_at
  end
end
