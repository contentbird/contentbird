class AddExportablePropertiesToContent < ActiveRecord::Migration
  def change
    add_column :contents, :exportable_properties, :text
  end
end
