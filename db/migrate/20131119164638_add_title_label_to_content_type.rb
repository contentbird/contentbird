class AddTitleLabelToContentType < ActiveRecord::Migration
  def change
    add_column :content_types, :title_label, :string
  end
end
