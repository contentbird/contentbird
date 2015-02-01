class RenameLabelToSlugOnSections < ActiveRecord::Migration
  def change
    rename_column :sections, :label, :slug
    add_index :sections, [:channel_id, :slug], unique: true
  end
end
